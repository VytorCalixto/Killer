        ##
        ## this test is run in User Mode
        ##
	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.set noreorder        # assembler should not reorder instructions
	.global _start
	.global _exit
	.global exit
	.ent    _start

        ##
        ## reset leaves processor in kernel mode, all else disabled
        ##
_start: nop
        li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
        la   $k0, main
        mtc0 $k0, cop0_EPC
        nop
        nop
        nop
        eret # go into user mode, all else disabled
        nop

exit:	
_exit:	nop	# flush pipeline
	nop
	nop
	nop
	nop
	wait	# and then stop VHDL simulation
	nop
	nop
	.end _start
	
	.org x_EXCEPTION_0180,0 # exception vector_180
	.ent _excp_180
excp_180:	
_excp_180:
        mfc0  $k0, cop0_CAUSE
        addiu $7,$7,-1         # decrement iteration control
        sw    $k0,0($15)       # print CAUSE
	#li    $k0, 0x18000000  # disable interrupts
        #mtc0  $k0, cop0_STATUS
	eret
	.end _excp_180

	
        .org x_EXCEPTION_0200,0 # exception vector_200
        .ent _excp_200
excp_200:
_excp_200:
        ##
        ## this exception should not happen
        ##
        li   $28,'\n'
        sw   $28, x_IO_ADDR_RANGE($15)  # signal exception to std_out
        sw   $28, x_IO_ADDR_RANGE($15)  #  print two \n
        mfc0 $k0, cop0_CAUSE
        sw   $k0,0($15)        		# print CAUSE
        sw   $28, x_IO_ADDR_RANGE($15)
        sw   $28, x_IO_ADDR_RANGE($15)
        eret                  		#   and return
        .end _excp_200

	
	.org x_ENTRY_POINT,0      # normal code
main:	la   $15,x_IO_BASE_ADDR
	
	la   $18, 0x80000000	# signed largest negative
	la   $19, 0x80000001 	# signed largest negative but one
	li   $7,4
	
	sw   $18, 0($15)
	sw   $19, 0($15)
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests

xTLTn:	nop
	tlt  $19, $18		# signed: 0x80000001 < 0x80000000 == FALSE
	sw   $7, 0($15)         # print out 4 since no trap
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests

xTLTUn:	nop
	tltu $19, $18		# unsigned: 0x80000001 < 0x80000000 == FALSE
	sw   $7, 0($15)         # print out 4 since no trap
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests


xTLTy:	nop
	tlt  $18, $19		# signed: 0x80000000 < 0x80000001 == TRUE
	sw   $7, 0($15)         # print out 3 since handler decrements $7
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests

xTLTUy:	nop
	tltu $18, $19		# unsigned: 0x80000000 < 0x80000001 == TRUE
	sw   $7, 0($15)         # print out 2 as handler decrements $7
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests

	
xTGEy:	nop
	tge  $19, $18		# signed: 0x80000001 >= 0x80000000 == TRUE
	sw   $7, 0($15)         # print out 1 as handler decrements $7
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests

xTGEUy:	nop
	tgeu $19, $18		# unsigned: 0x80000001 >= 0x80000000 == TRUE
	sw   $7, 0($15)         # print out 0 as handler decrements $7
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests


xTGEn:	nop
	tge  $18, $19		# signed: 0x80000000 >= 0x80000001 == FALSE
	sw   $7, 0($15)         # print out 0 since no trap
	
	li   $28, '\n'
        sw   $28, x_IO_ADDR_RANGE($15)     # print out '\n' to separate tests

xTGEUn:	nop
	tgeu $18, $19		# unsigned: 0x80000000 >= 0x80000001 == FALSE
	sw   $7, 0($15)         # print out 0 since no trap

 	j exit
 	nop
