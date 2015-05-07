	##
	## Test the TLB as if it were just a memory array
	## Perform a series of indexed writes, then a series of reads
	##   and compare values read to those written
	##
	## Entries 4..7 are only read, to show initialization values
	##

	## EntryHi     : EntryLo0           : EntryLo1
	## VPN2 g ASID : PPN0 ccc0 d0 v0 g0 : PPN1 ccc1 d1 v1 g1

	## TLB(i): VPN2 g ASID : PFN0 ccc0 d0 v0 : PFN1 ccc1 d1 v1
	## TLB(0): 0    0 00   : x00  010  0  1  : x11  010  0  1
	## TLB(1): 1    1 ff   : x21  011  0  1  : x31  011  0  1
	## TLB(2): 2    0 77   : x41  010  1  1  : x51  011  1  1
	## TLB(3): 3    1 01   : x61  011  1  1  : x71  111  1  1

	.include "cMIPS.s"

	.set MMU_CAPACITY, 8
	.set MMU_WIRED,    1  ### do not change mapping for base of ROM

	.set entryHi_0,  0x00000000 #                 pfn0  zzcc cdvg
	.set entryLo0_0, 0x00000012 #  x0 x0 x0 x0 x0 0000  0001 0010 x12
	.set entryLo1_0, 0x00000412 #  x0 x0 x0 x0 x0 0100  0001 0010 x412

	.set entryHi_1,  0x000020ff #                 pfn0  zzcc cdvg
	.set entryLo0_1, 0x0000091b #  x0 x0 x0 x0 x0 1001  0001 1011 x91b
	.set entryLo1_1, 0x00000c1b #  x0 x0 x0 x0 x0 1100  0001 1011 xc1b

	.set entryHi_2,  0x00004077 #                 pfn0  zzcc cdvg
	.set entryLo0_2, 0x00001016 #  x0 x0 x0 x0 x1 0000  0001 0110 x1016
	.set entryLo1_2, 0x0000141e #  x0 x0 x0 x0 x1 0100  0001 1110 x141e

	.set entryHi_3,  0x00006001 #                 pfn0  zzcc cdvg
	.set entryLo0_3, 0x0000191f #  x0 x0 x0 x0 x1 1001  0001 1111 x191f
	.set entryLo1_3, 0x00001d3f #  x0 x0 x0 x0 x1 1101  0011 1111 x1d3f

	.text
	.align 2
	.set noreorder
	.set noat
	.globl _start
	.ent _start
_start:	la   $31, x_IO_BASE_ADDR

        li   $2, MMU_WIRED
        mtc0 $2, cop0_Wired  ### make sure all but 0'th TLB entries are usable
	
	# load into MMU(3)
	li   $1, 3
	mtc0 $1, cop0_Index
	la   $2, entryHi_3
	mtc0 $2, cop0_EntryHi
	la   $3, entryLo0_3
	mtc0 $3, cop0_EntryLo0
	la   $4, entryLo1_3
	mtc0 $4, cop0_EntryLo1
	tlbwi

	## check first record was written
	ehb
	
	mtc0 $zero, cop0_EntryHi
	mtc0 $zero, cop0_EntryLo0
	mtc0 $zero, cop0_EntryLo1
	
	addi $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)
	
	tlbr 			# read TLB at index = 3
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	mfc0 $24, cop0_EntryLo0
	sw   $24, 0($31)
	mfc0 $25, cop0_EntryLo1
	sw   $25, 0($31)

	# load into MMU(2)
	addiu $1, $1, -1
	mtc0 $1, cop0_Index
	la   $5, entryHi_2
	mtc0 $5, cop0_EntryHi
	la   $6, entryLo0_2
	mtc0 $6, cop0_EntryLo0
	la   $7, entryLo1_2
	mtc0 $7, cop0_EntryLo1
	tlbwi

	# load into MMU(1)
	addiu $1, $1, -1
	mtc0 $1, cop0_Index
	la   $8, entryHi_1
	mtc0 $8, cop0_EntryHi
	la   $9, entryLo0_1
	mtc0 $9, cop0_EntryLo0
	la   $10, entryLo1_1
	mtc0 $10, cop0_EntryLo1
	tlbwi

	# load into MMU(4)
	addiu $1, $zero, 4
	mtc0 $1, cop0_Index
	la   $11, entryHi_0
	mtc0 $11, cop0_EntryHi
	la   $12, entryLo0_0
	mtc0 $12, cop0_EntryLo0
	la   $13, entryLo1_0
	mtc0 $13, cop0_EntryLo1
	tlbwi

	# and now read values back, in reverse order

	# read from MMU(4)
	addi $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	tlbr 			# index = 0
	mfc0 $14, cop0_EntryHi
	sw   $14, 0($31)
	mfc0 $15, cop0_EntryLo0
	sw   $15, 0($31)
	mfc0 $16, cop0_EntryLo1
	sw   $16, 0($31)

	
	# read from MMU(1)
	addiu $1, $1, -3
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 1
	mfc0 $17, cop0_EntryHi
	sw   $17, 0($31)
	mfc0 $18, cop0_EntryLo0
	sw   $18, 0($31)
	mfc0 $19, cop0_EntryLo1
	sw   $19, 0($31)

	
	# read from MMU(2)
	addiu $1, $1, 1
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 2
	mfc0 $20, cop0_EntryHi
	sw   $20, 0($31)
	mfc0 $21, cop0_EntryLo0
	sw   $21, 0($31)
	mfc0 $22, cop0_EntryLo1
	sw   $22, 0($31)


	# read from MMU(1)
	addiu $1, $1, 1
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 3
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	mfc0 $24, cop0_EntryLo0
	sw   $24, 0($31)
	mfc0 $25, cop0_EntryLo1
	sw   $25, 0($31)

	##
	## now read initialization values of remaining entries
	##
	
	# read from MMU(4)
	li  $1, 4
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 4
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	mfc0 $24, cop0_EntryLo0
	sw   $24, 0($31)
	mfc0 $24, cop0_EntryLo1
	sw   $24, 0($31)


	# read from MMU(5)
	addi $1, $1, 1
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 4
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	mfc0 $24, cop0_EntryLo0
	sw   $24, 0($31)
	mfc0 $24, cop0_EntryLo1
	sw   $24, 0($31)


	# read from MMU(6)
	addi $1, $1, 1
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 4
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	mfc0 $24, cop0_EntryLo0
	sw   $24, 0($31)
	mfc0 $24, cop0_EntryLo1
	sw   $24, 0($31)


	# read from MMU(7)
	addi $1, $1, 1
	addi  $30, $1, '0'
	sw $30, x_IO_ADDR_RANGE($31)
	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	mtc0  $1, cop0_Index
	tlbr 			# index = 4
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	mfc0 $24, cop0_EntryLo0
	sw   $24, 0($31)
	mfc0 $24, cop0_EntryLo1
	sw   $24, 0($31)

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

	
