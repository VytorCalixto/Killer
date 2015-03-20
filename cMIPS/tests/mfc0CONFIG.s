	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.global _start
	.global _exit
	.global exit
	.ent    _start
_start: nop
        li   $k0, 0x10000002  # RESET_STATUS, kernel mode, all else disabled
        mtc0 $k0, cop0_STATUS
	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
	li   $k0, 0x0000007c # CAUSE_STATUS, no exceptions 
        mtc0 $k0, cop0_CAUSE # clear CAUSE

	nop
	jal main
	nop
exit:	
_exit:	nop	     # flush pipeline
	nop
	nop
	nop
	nop
	wait 0 # then stop VHDL simulation
	nop
	nop
	.end _start
	
	.org x_EXCEPTION_0180,0 # exception vector_180 at 0x00000060
	.global _excp_180
	.global excp_180
	.ent _excp_180
excp_180:	
_excp_180:
        mfc0  $k0, cop0_CAUSE
	sw    $k0,0($15)        # print CAUSE
	addiu $7,$7,-1
	li    $k0, 0x10000300   # disable interrupts
        mtc0  $k0, cop0_STATUS
	mtc0  $zero, cop0_CAUSE # clear CAUSE
	eret
	.end _excp_180


	.org x_ENTRY_POINT,0      # normal code starts at 0x0000.0100
main:	la $15,x_IO_BASE_ADDR
	nop
	mfc0 $6,cop0_STATUS
	sw   $6, 0($15)
	nop
	mfc0 $6,cop0_CAUSE
	sw   $6, 0($15)
	nop
	mfc0 $6,cop0_CONFIG,0
	sw   $6, 0($15)
	nop
	mfc0 $6,cop0_CONFIG,1
	li   $7, 0xfe00003f      # mask off cache configuration
	and  $6,$6,$7            #  so changes in caches won't break this
	sw   $6, 0($15)

	j exit
	
