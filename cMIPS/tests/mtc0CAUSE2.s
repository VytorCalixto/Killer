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
	wait  # then stop VHDL simulation
	nop
	nop
	.end _start
	
	.org x_EXCEPTION_0180,0 # exception vector_180
	.global _excp_180
	.global excp_180
	.ent _excp_180
excp_180:	
_excp_180:
        mfc0  $k0, cop0_CAUSE
	sw    $k0,0($15)        # print CAUSE
	addiu $7,$7,-1
	li    $k0, 0x10000300   # disable interrupts except SW0,1
        mtc0  $k0, cop0_STATUS
	mtc0  $zero, cop0_CAUSE # clear CAUSE
	eret
	.end _excp_180


	.org x_ENTRY_POINT,0      # normal code starts here
main:	la $15,x_IO_BASE_ADDR
	li $7,4                # do four rounds
	li $5,0
here:	sw $5, 0($15)

	li   $6, 0x10000302   # kernel mode, disable interrupts
	mtc0 $6,cop0_STATUS
	li   $6, 0x0000ffff   # write garbage to CAUSE, assert sw interr 0,1
	mtc0 $6,cop0_CAUSE

	addiu $5,$5,2
	
	li   $6, 0x10000301   # user mode, enable sw interrupts
	mtc0 $6,cop0_STATUS
	nop 		      # SW interrupt here 
	
	bne   $7,$zero, here

	j exit
