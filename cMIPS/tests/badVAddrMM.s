	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.set noreorder
	.align 2
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
	nop
exit:	
_exit:	nop	# flush pipeline
	nop
	nop
	nop
	nop
	wait    # then stop VHDL simulation
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
	sw    $k0,0($14)        # print CAUSE

	mfc0  $k0, cop0_EPC     # 
	sw    $k0,0($14)        # print EPC
	addiu $7,$7,-1		# repetiton counter

	addiu $k1, $zero, -4	# -4 = 0xffff.fffc
	and   $15,$15,$k1	# fix the invalid address

	eret
	.end _excp_180


	.org x_ENTRY_POINT,0    # normal code start
main:	la $14, x_IO_BASE_ADDR
	la $15, x_IO_BASE_ADDR
	li $7, 3                # do 3 rounds
	la $3, -1
	nop

here:	addiu $3, $3, 1
	sw  $3, 0($15)          # exception handler decreases $7
	beq $7, $zero, next     # there should be 3 exceptions: addr&{01,10,11}
	nop			# of type AddrError store=x14
	addu $15, $15, $3
	j here
	nop
	
next:	li $29, '\n'           # to separate output
	sw $29, x_IO_ADDR_RANGE($14)
	la $15, x_DATA_BASE_ADDR
	la $18, x_IO_BASE_ADDR
	li $7, 3
	la $3, -1
	sw $7, 0($15)
	nop

there:	addiu $3,$3,1
	lw  $3, 0($15)      	# there should be 3 exceptions: addr&{01,10,11}
	sw  $7, 0($18)		# of type AddrError if/ld=x10
	beq $7, $zero, after
	nop
	addu $15, $15, $3
	j there
	nop

	
after:	li $29, '\n'           	# to separate output
	sw $29, x_IO_ADDR_RANGE($14)
	la $14, x_IO_BASE_ADDR
	la $15, x_IO_BASE_ADDR
	li $7, 3
	la $3, -1
	nop

here2:	addiu $3, $3, 1      	# there should be 3 exceptions: addr&{01,11}
	sh  $3, 0($15)		# of type AddrError store=x14
	beq $7, $zero, next2
	nop
	addu $15, $15, $3
	j here2
	nop

	
next2:	li $29, '\n'           # to separate output
	sw $29, x_IO_ADDR_RANGE($14)
	la $15, x_DATA_BASE_ADDR
	la $18, x_IO_BASE_ADDR
	li $7, 3
	la $3, -1
	sw  $7, 0($15)
	nop

there2:	lh  $3, 0($15)      	# there should be 3 exceptions: addr&{01,11}
	sw  $7, 0($18)		# of type AddrError if/ld=x10
	beq $7, $zero, end
	nop
	addu $15, $15, $3
	nop
	j there2
	nop
	
end:	j exit
	nop
