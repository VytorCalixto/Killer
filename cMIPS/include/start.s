	# mips-as -O0 -EL -mips32 -o start.o start.s
	.include "cMIPS.s"
	.text
	.set noreorder
	.align 2
	.extern main
	.global _start
	.global _exit
	.global exit
	.org x_INST_BASE_ADDR,0
	.ent _start

        ##
        ## reset leaves processor in kernel mode, all else disabled
        ##

	# initialize SP: ramTop-8
_start: li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8)

	# set STATUS, cop0, hw interrupt IRQ7,IRQ6,IRQ5 enabled
        li   $k0, 0x1000e001
        mtc0 $k0, cop0_STATUS
 
	nop
	jal main  # on returning from main(), MUST go into exit()
	nop       #  to stop the simulation.
exit:	
_exit:	nop	  # flush pipeline
	nop
	nop
	nop
	nop
	wait 0    # then stop VHDL simulation
	nop
	nop
	.end _start


	#----------------------------------------------------------------
	.global _excp_0000
	.global excp_0000
	.global _excp_0100
	.global excp_0100
	.global _excp_0180
	.global excp_0180
	.global _excp_0200
	.global excp_0200
	##
	##================================================================
	##
	.org x_EXCEPTION_0000,0 # exception vector_0000
	.ent _excp_0000
excp_0000:
_excp_0000:
        mfc0 $k0, cop0_STATUS
	j nmi_reset_handler
	nop
	#excp_0000ret:
	#	li   $k0, 0x1000ff01   # enable interrupts, user mode
	#       mtc0 $k0, cop0_STATUS
	#	eret

	#----------------------------------------------------------------
	# handler for NMI or soft-reset -- simply abort simulation
nmi_reset_handler:
	mfc0 $k1,cop0_CAUSE    # read CAUSE
	nop
	wait 0x38              # abort simulation, no code in Table 8-25
	nop
	# j excp_0000ret       #  OR do something else!
	.end _excp_0000

	##
	##================================================================
	## exception vector_0100 TLBrefill, from See MIPS Run pg 145
	##
	.org x_EXCEPTION_0100,0
	.ent _excp_0100
	.set noreorder
	.set noat

excp_0100:
_excp_0100:
	mfc0 $k1, cop0_Context
	lw   $k0, 0($k1)           # k0 <- TP[Context.lo]
	lw   $k1, 8($k1)           # k1 <- TP[Context.hi]
	mtc0 $k0, cop0_EntryLo0    # EntryLo0 <- k0 = even element
	mtc0 $k1, cop0_EntryLo1    # EntryLo1 <- k1 = odd element
	ehb
	tlbwr	                   # update TLB
	eret	
	.end _excp_0100


	##
	##================================================================
	## handler for all exceptions except interrupts and TLBrefill
	##
        .bss
        .align  2
        .comm   _excp_saves 16*4       # area to save up to 16 registers
        # _excp_saves[0]=CAUSE, [1]=STATUS, [2]=ASID,
	#            [8]=$ra, [9]=$a0, [10]=$a1, [11]=$a2, [12]=$a3
        .text
        .set    noreorder

	.org x_EXCEPTION_0180,0  # exception vector_180
	.ent _excp_0180
excp_0180:
_excp_0180:
	mfc0 $k0, cop0_STATUS
	lui  $k1, %hi(_excp_saves)
	ori  $k1, $k1, %lo(_excp_saves)
	sw   $k0, 1*4($k1)
        mfc0 $k0, cop0_CAUSE
	sw   $k0, 0*4($k1)
	
	andi $k0, $k0, 0x3f    # keep only the first 16 ExceptionCode & b"00"
	sll  $k0, $k0, 1       # displacement in vector is 8 bytes
	lui  $k1, %hi(excp_tbl)
        ori  $k1, $k1, %lo(excp_tbl)
	add  $k1, $k1, $k0
	jr   $k1
	nop

excp_tbl: # see Table 8-25, pg 95,96
	wait 0x02  # interrupt, should never arrive here, abort simulation
	nop

	j h_Mod  # 1
	nop

	j h_TLBL # 2
	nop

	j h_TLBS # 3
	nop

	wait 0x04  # 4 AdEL addr error      -- abort simulation
	nop
	wait 0x05  # 5 AdES addr error      -- abort simulation
	nop
	wait 0x06  # 6 IBE addr error      -- abort simulation
	nop
	wait 0x07  # 7 DBE addr error      -- abort simulation
	nop

	j h_syscall # 8
	nop

	j h_breakpoint # 9
	nop

	j h_RI    # 10 reserved instruction
	nop

	j h_CpU   # 11 coprocessor unusable
	nop

	j h_Ov    # 12 overflow
	nop

	j h_trap  # 13 trap
	nop
	
	wait 0x14 # reserved, should never get here -- abort simulation
	nop
	
	wait 0x15 # PF exception, should never get here -- abort simulation
	nop

h_Mod:	
h_TLBL:		
h_TLBS:	
h_syscall:
h_breakpoint:	
h_RI:	
h_CpU:	
h_Ov:	
h_trap:	
	
excp_0180ret:
	lui  $k1, %hi(_excp_saves) # Read previous contents of STATUS
	ori  $k1, $k1, %lo(_excp_saves)
	lw   $k0, 1*4($k1)
	# mfc0 $k0, cop0_STATUS
	
	lui  $k1, 0xffff           #  and do not modify its contents
	ori  $k1, $k1, 0xfff1      #  except for re-enabling interrupts
	ori  $k0, $k0, M_StatusIEn #  and keeping user/kernel mode
	and  $k0, $k1, $k0         #  as it was on exception entry 
	mtc0 $k0, cop0_STATUS	
	eret			   # Return from exception

	.end _excp_0180
	#----------------------------------------------------------------

	##
	##===============================================================
	## interrupt handlers at exception vector 0200
	##
	# name all handlers here
	.extern countCompare  # IRQ7 = hwIRQ5, see vhdl/tb_cMIPS.vhd
	.extern UARTinterr    # IRQ6 - hwIRQ4
	.extern extCounter    # IRQ5 - hwIRQ3

	.set M_CauseIM,0x0000ff00   # keep bits 15..8 -> IM = IP
	.set M_StatusIEn,0x0000ff01 # user mode, enable all interrupts

	.set noreorder
	
	.org x_EXCEPTION_0200,0     # exception vector_200, interrupt handlers
	.ent _excp_0200
excp_0200:
_excp_0200:
	mfc0 $k0, cop0_CAUSE
	andi $k0, $k0, M_CauseIM  # Keep only IP bits from Cause
	mfc0 $k1, cop0_STATUS
	and  $k0, $k0, $k1        # and mask with IM bits 

	srl  $k0, $k0, 11	  # keep only 3 MS bits of IP (irq7..5)
	lui  $k1, %hi(handlers_tbl) # plus displacement in j-table of 8 bytes
	ori  $k1, $k1, %lo(handlers_tbl)
	add  $k1, $k1, $k0
	jr   $k1
	nop

handlers_tbl:
	j Dismiss		   # no request: 000
	nop

	j extCounter		   # lowest priority, IRQ5: 001
	nop	

	j UARTinterr		   # mid priority, IRQ6: 01x
	nop
	j UARTinterr
	nop

	j countCompare             # highest priority, IRQ7: 1xx
	nop
	j countCompare
	nop
	j countCompare
	nop
	j countCompare
	nop


Dismiss: # No pending request, must have been noise
	 #  do nothing and return

excp_0200ret:
	mfc0 $k0, cop0_STATUS	   # Read STATUS register
	addi $k1, $zero, -15       #  and do not modify its contents -15=fff1
	ori  $k0, $k0, M_StatusIEn #  except for re-enabling interrupts
	and  $k0, $k1, $k0         #  and keeping user/kernel mode
	mtc0 $k0, cop0_STATUS      #  as it was on interrupt entry 	
	eret			   # Return from interrupt
	nop

	.end _excp_0200
	#----------------------------------------------------------------

	
	
	#----------------------------------------------------------------
	# normal code starts here -- do not edit next line
	.org x_ENTRY_POINT,0

