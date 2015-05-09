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
        eret    # leave exception level, all else disabled
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
	
	.org x_EXCEPTION_0180,0  # exception vector_180
	.global excp_180
	.ent    excp_180
excp_180:
	li $k0, '['              # to separate output
	sw $k0, x_IO_ADDR_RANGE($14)
	li $k0, '\n'             # to separate output
	sw $k0, x_IO_ADDR_RANGE($14)

	
        mfc0  $k0, cop0_CAUSE
	sw    $k0, 0($14)        # print CAUSE

	mfc0  $k0, cop0_EPC      # print EPC
	sw    $k0, 0($14)

	mfc0  $k0, cop0_BadVAddr # print BadVAddr
	sw    $k0, 0($14)

	addiu $7, $7, -1	 # repetiton counter

	addiu $k1, $zero, -4	 # -4 = 0xffff.fffc
	and   $15, $15, $k1	 # fix the invalid address

	li $k0, ']'              # to separate output
	sw $k0, x_IO_ADDR_RANGE($14)
	li $k0, '\n'             # to separate output
	sw $k0, x_IO_ADDR_RANGE($14)
	
	eret

	.end excp_180


	.org x_ENTRY_POINT,0    # normal code start

	##
	## do 4 stores: 1st aligned, 2nd, 3rd, 4th misaligned,
	##   hence 3 exceptions of type AddrError store=x14
	##
	
main:	la $14, x_IO_BASE_ADDR  # used by exception handler
	la $15, x_IO_BASE_ADDR  # used to generate misaligned references
	li $7, 3                # do 4 rounds for each type of exception
	li $3, 0                # exception handler decreases $7
	nop

here:	nop
	sw    $3, 0($15)        # causes 3 exceptions: addr&{01,10,11}
	addiu $3, $3, 1         # 1st is aligned, 2nd,3rd,4th misaligned
	beq   $7, $zero, next
	nop
	j here
	addu  $15, $15, $3

	
next:	li $29, '\n'            # to separate output
	sw $29, x_IO_ADDR_RANGE($14)
	sw $29, x_IO_ADDR_RANGE($14)


	##
	## do 4 loads, 1st aligned, 2nd, 3rd, 4th misaligned
	##   hence 3 exceptions of type AddrError if/ld=x10
	##
	
	la $15, x_DATA_BASE_ADDR
	la $18, x_IO_BASE_ADDR
	li $7, 3                # do 3 rounds
	li $3, 0
	sw $7, 0($15)
	nop

there:	nop
	lw    $5, 0($15)      	# causes 3 exceptions: addr&{01,10,11}
	sw    $7, 0($18)	# print value changed by handler
	# sw    $5, 0($18)	# print value read from memory
	addiu $3, $3, 1
	beq   $7, $zero, after
	nop
	j     there
	addu  $15, $15, $3

	
after:	li $29, '\n'           	# to separate output
	sw $29, x_IO_ADDR_RANGE($14)
	sw $29, x_IO_ADDR_RANGE($14)
	

	##
	## do 4 half-word stores: 1st,3rd aligned, 2nd,4th misaligned,
	##   hence 3 exceptions of type AddrError store=x14
	##
	
	la $14, x_IO_BASE_ADDR  # used by exception handler
	la $15, x_IO_BASE_ADDR
	li $7, 3
	li $3, 0
	nop

here2:	sh    $3, 0($15)	# causes no exception: addr & 00
	addiu $15, $15, 1      	#   of type AddrError store=x14
	addiu $3 , $3,  1
	sh    $3, 0($15)	# causes exception: addr & 01
	addiu $15, $15, 2       # handler fixes $15 to addr & 00
	addiu $3 , $3,  1
	sh    $3, 0($15)	# causes no exception: addr & 10
	addiu $15, $15, 1
	addiu $3 , $3,  1
	sh    $3, 0($15)	# causes exception: addr & 10


	
next2:	li $29, '\n'           # to separate output
	sw $29, x_IO_ADDR_RANGE($14)
	sw $29, x_IO_ADDR_RANGE($14)
	la $15, x_DATA_BASE_ADDR
	la $18, x_IO_BASE_ADDR
	li $7, 3
	la $3, 0
	sw  $7, 0($15)
	nop

	
	##
	## do 4 half-word loads: 1st,3rd aligned, 2nd,4th misaligned,
	##   hence 3 exceptions of type AddrError if/ld=x10
	##
		
there2:	lh    $3, 0($15)	# causes no exception: addr & 00
	sw    $7, 0($18)
	addiu $15, $15, 1
	addiu $3 , $3,  1
	lh    $3, 0($15)	# causes exception: addr & 01
	sw    $7, 0($18)
	addiu $15, $15, 2       # handler fixes $15 to addr & 00
	addiu $3 , $3,  1
	lh    $3, 0($15)	# causes no exception: addr & 10
	sw    $7, 0($18)
	addiu $15, $15, 1
	addiu $3 , $3,  1
	lh    $3, 0($15)	# causes exception: addr & 10
	sw    $7, 0($18)
	
end:	j exit
	nop
