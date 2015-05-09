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
        eret    # leave exception level, all else disabled
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
	
	.org    x_EXCEPTION_0180,0 # exception vector_180
	.global excp_180
	.ent    excp_180
excp_180:
        li    $k0, '['              # to separate output
        sw    $k0, x_IO_ADDR_RANGE($14)
        li    $k0, '\n'
        sw    $k0, x_IO_ADDR_RANGE($14)

        mfc0  $k0, cop0_CAUSE
	sw    $k0, 0($14)       # print CAUSE
	mfc0  $k0, cop0_EPC     # fix return address
	sw    $k0, 0($14)       # print EPC
	addiu $7, $7, -1

        addiu $k1, $zero, -4    # -4 = 0xffff.fffc
        and   $k1, $k1, $k0     # fix the invalid address
	mtc0  $k1, cop0_EPC

	li $k0, ']'              # to separate output
        sw $k0, x_IO_ADDR_RANGE($14)
        li $k0, '\n'
        sw $k0, x_IO_ADDR_RANGE($14)

	eret
	.end excp_180


	.org x_ENTRY_POINT,0    # normal code start
main:	la $14, x_IO_BASE_ADDR  # used by handler
	la $15, x_IO_BASE_ADDR
	li $7, 3
	la $3, here
	nop

here:	sw    $3, 0($15)
	nop                     # 4th jr is to this address
	beq   $7, $zero, end
	nop
	addiu $3, $3, 1
	nop			# do not stall on $3
	nop
	jr    $3
	nop
	nop
	nop
end:	j exit
	nop
