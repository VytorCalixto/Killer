	##
        ## Test the TLB INDEX and RANDOM registers
	## 
        ## First, check randomness of RANDOM

	.include "cMIPS.s"

	.set MMU_CAPACITY, 8
	.set MMU_WIRED,    1  ### do not change mapping for base of ROM

	.text
	.align 2
	.set noreorder
	.globl _start
	.ent _start
_start: li   $5, MMU_WIRED
	li   $6, MMU_CAPACITY - 1
	la   $15, x_IO_BASE_ADDR
	nop
	nop
	nop # give the RANDOM counter some time after resetting,
	nop #   so it can advance freely a few cycles
	nop
	nop

	mtc0  $6, cop0_Index
	mtc0  $5, cop0_Wired  ### make sure all but 0'th TLB entries are usable

	li    $7, MMU_CAPACITY - 2  # waited for several cycles, now
L1:	addiu $7,  $7, -1           #   print 6 random values in 1..CAPACITY-1
	mfc0  $25, cop0_Random      # 1 entry wired(0)
	bne   $7,  $zero, L1
	sw    $25, 0($15)

        li   $30, '\n'		    # print a blank line
        sw   $30, x_IO_ADDR_RANGE($15)

	li    $7, MMU_CAPACITY - 2  # print 6 random values in 3..CAPACITY-1
	li    $5, MMU_WIRED + 2     # 3 entries are wired (0..2)
	mtc0  $5, cop0_Wired

L2:	addiu $7,  $7,-1
	mfc0  $25, cop0_Random
	bne   $7,  $zero, L2
	sw    $25, 0($15)

        li   $30, '\n'		    # print a blank line
        sw   $30, x_IO_ADDR_RANGE($15)

	li    $7, MMU_CAPACITY - 2  # print 6 random values in 7..7=CAPACITY-1
	li    $5, MMU_CAPACITY - 1  # 7 entries are wired (0..6)
	mtc0  $5, cop0_Wired

L3:	addiu $7,  $7,-1
	mfc0  $25, cop0_Random
	bne   $7,  $zero, L3
	sw    $25, 0($15)

	
        li   $30, '\n'		    # print a blank line
        sw   $30, x_IO_ADDR_RANGE($15)

	li    $7, 10                # print 10 random values in 0..CAPACITY-1
	li    $5, 0                 # no entries are wired
	mtc0  $5, cop0_Wired

L4:	addiu $7,  $7,-1
	nop
	mfc0  $25, cop0_Random
	bne   $7,  $zero, L4
	sw    $25, 0($15)
	
	nop
	nop
        nop
	nop
	nop
        nop
        wait
	nop
	nop
	.end _start

	
