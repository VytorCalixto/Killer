	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.global _start
	.global _exit
	.global exit
	.set noreorder
	.ent    _start
_start: nop
        li   $k0, cop0_STATUS_reset # RESET, kernel mode, all else disabled
        mtc0 $k0, cop0_STATUS

	li   $k0, cop0_CAUSE_reset # RESET, no exceptions
        mtc0 $k0, cop0_CAUSE

	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
	
	nop
	jal main
	nop
exit:	
_exit:	nop	     # flush pipeline
	nop
	nop
	nop
	nop
	wait 0       # then stop VHDL simulation
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
	sw    $k0, 0($15)       # print CAUSE
        li    $k0, '\n'
	sw    $k0, x_IO_ADDR_RANGE($15)  # print new-line
	addiu $7, $7, -1
	li    $k0, 0x18000300   # disable interrupts
        mtc0  $k0, cop0_STATUS
	li    $k0, cop0_CAUSE_reset # RESET, no exceptions
        mtc0  $k0, cop0_CAUSE
	eret
	.end _excp_180

	.org x_EXCEPTION_0200,0 # exception vector_200
	.global _excp_200
	.global excp_200
	.ent _excp_200
excp_200:
_excp_200:
        mfc0  $k0, cop0_CAUSE
	sw    $k0,0($15)        # print CAUSE
	addiu $7,$7,-1
	li    $k0, 0x18000300   # disable interrupts
        mtc0  $k0, cop0_STATUS
	li    $k0, cop0_CAUSE_reset # RESET, no exceptions
        mtc0  $k0, cop0_CAUSE
	eret
	.end _excp_200

	
	.org x_ENTRY_POINT,0      # normal code start
main:	la $15,x_IO_BASE_ADDR
	li $7,4
	li $5,0
here:	sw $5, 0($15)

	li    $6, 0x18000302       # kernel mode, disable interrupts
	mtc0  $6, cop0_STATUS
	addiu $5, $5,2
	break 15
	bne   $7, $zero, here

	nop
	j exit
	nop
