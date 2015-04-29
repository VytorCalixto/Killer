	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
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
        nop
        mtc0 $k0, cop0_EPC
        nop
        eret     # go into user mode, all else disabled
        nop
exit:	
_exit:	nop	 # flush pipeline
	nop
	nop
	nop
	nop
	wait     # then stop VHDL simulation
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
	#sw    $k0, 0($15)       # print CAUSE = 0000.0030
	#sw    $k0, 0($15)       # print CAUSE = 0000.0030
	sw    $k0, 0($15)       # print CAUSE = 0000.0030
	li    $k0, 0x18000302   #   disable interrupts
	mtc0  $k0, cop0_STATUS  #   and return
	nop
	eret
	.end _excp_180


	.org x_ENTRY_POINT,0    # normal code starts at 0x0000.0100
main:	la $15,x_IO_BASE_ADDR
	la $16,x_IO_BASE_ADDR+x_IO_ADDR_RANGE
	li $17, '\n'

	# signed overflow       
	li  $3,0x7FFFFFFF	# positive +s positive -> positive
	li  $4,0x00000001
	add $5,$3,$4
	sw  $5, 0($15)		# ===exception=== 0x8000.0000 == negative

	nop
	sw $17, 0($16)
	
	# no overflow
	li   $6,0xFFFFFFFe      # negative + positive -> no overflow
	addi $7,$6,1
	sw   $7, 0($15)		# 0xffff.ffff == negative

	nop
	sw $17, 0($16)
	
	# add unsigned, no overflow
	li   $3,0x7FFFFFFF      # positive +u positive -> positive
	li   $4,0x00000001
	addu $5,$3,$4
	sw   $5, 0($15)		# 0x8000.0000 == unsigned positive

	nop
	sw $17, 0($16)
	
	# add unsigned, no overflow
	li    $6,0xFFFFFFFe	# negative +u positive -> positive
	addiu $7,$6,1
	sw    $7, 0($15)	# 0xffff.ffff == unsigned positive

	nop
	sw $17, 0($16)
	
	# no overflow
	li   $3,0xFFFFFFFF	# negative +s positive -> negative 
	li   $4,0x00000001
	add  $5,$3,$4
	sw   $5, 0($15)		# 0x0000.0000

	nop
	sw $17, 0($16)
	
	# signed overflow
	li   $6,0x80000000      # negative -s negative -> negative
	addi $7,$6,-1
	sw   $7, 0($15)		# ===exception=== 0x7fff.ffff == positive

	nop
	sw $17, 0($16)
	
	# unsigned overflow
	li   $6,0x80000000      # positive -u negative -> positive
	addiu $7,$6,-1
	sw   $7, 0($15)		# 0x7fff.ffff == positive

	nop
	sw $17, 0($16)
	
	# no overflow, unsigned
	li   $3,0xFFFFFFFF      # positive +u positive -> positive
	li   $4,0x00000001
	addu $5,$3,$4
	sw   $5, 0($15)		# 0x0000.0000  ok since instr is an addU

	nop
	sw $17, 0($16)
	
	# signed overflow 
	li    $6,0x7FFFFFFe	# positive +s positive -> positive
	addi  $7,$6,2
	sw    $7, 0($15)	# ===exception=== 0x8000.0000 == negative

	nop
end:	j exit
	