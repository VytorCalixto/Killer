	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.set noreorder
	.global _start
	.global _exit
	.global exit
	.ent    _start
_start: nop
	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
        la   $k0, main
        nop
        mtc0 $k0, cop0_EPC
        nop
        eret    # go into user mode, all else disabled
        nop
exit:	
_exit:	nop	# flush pipeline
	nop
	nop
	nop
	nop
	wait	# then stop VHDL simulation
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
	mfc0  $k0, cop0_EPC     # fix return address
	addiu $7, $7, -1
	srl   $k0, $k0, 2
	sll   $k0, $k0, 2
	mtc0  $k0, cop0_EPC
	nop
	eret
	.end _excp_180


	.org x_ENTRY_POINT,0    # normal code start
main:	la $15,x_IO_BASE_ADDR
	li $7,4
	la $3,here
	nop
	nop
here:	sw  $3, 0($15)
	nop                     # 4th jr is to this address
	beq $7,$zero, end
	nop
	addiu $3,$3,1
	nop
	jr  $3
	nop
	nop
	nop
end:	j exit
	nop
	