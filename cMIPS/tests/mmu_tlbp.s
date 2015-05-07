	##
	## Test the TLB as if it were just a memory array
	## Perform a series of indexed writes, then a series of probes
	##   first two fail, next two succeed
	##
        ## EntryLo1 is not implemented as of may2015
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

	## load into MMU(3)
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
	
	tlbr 			# read TLB from index = 3
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)


	## load into MMU(2)
	addiu $1, $1, -1
	mtc0 $1, cop0_Index
	la   $5, entryHi_2
	mtc0 $5, cop0_EntryHi
	la   $6, entryLo0_2
	mtc0 $6, cop0_EntryLo0
	la   $7, entryLo1_2
	mtc0 $7, cop0_EntryLo1
	tlbwi

	tlbr 			# read TLB from index = 2
	mfc0 $23, cop0_EntryHi
	sw   $23, 0($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)

	
	## load into MMU(1)
	addiu $1, $1, -1
	mtc0 $1, cop0_Index
	la   $8, entryHi_1
	mtc0 $8, cop0_EntryHi
	la   $9, entryLo0_1
	mtc0 $9, cop0_EntryLo0
	la   $10, entryLo1_1
	mtc0 $10, cop0_EntryLo1
	tlbwi

	
	## load into MMU(4)
	addiu $1, $zero, 4
	mtc0 $1, cop0_Index
	la   $11, entryHi_0
	mtc0 $11, cop0_EntryHi
	la   $12, entryLo0_0
	mtc0 $12, cop0_EntryLo0
	la   $13, entryLo1_0
	mtc0 $13, cop0_EntryLo1
	tlbwi

	li $30, '\n'
	sw $30, x_IO_ADDR_RANGE($31)

	##
	## and now probe two entries that will surely miss
	##

	## make a copy of entryHi_3 and change  VPN to force a miss
vpn:	la   $14, entryHi_3
	ori  $14, $14, 0x8000   # change VPN w.r.t tlb(3)
	mtc0 $14, cop0_EntryHi
	sw   $14, 0($31)

	ehb 	# clear all hazards
	
	tlbp    # and probe the tlb

	mfc0 $15, cop0_Index    # check for bit31=1
	sw   $15, 0($31)

	slt  $16, $15, $zero    # $16 <- (bit31 = 1)
	beq  $16, $zero, asid
	nop

	li   $30, 'm'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)
	nop
	sw   $30, x_IO_ADDR_RANGE($31)

	
	## make a copy of entryHi_2 and change ASID to force a miss
asid:	la  $18, entryHi_2
	ori $18, $18, 0x88      # change ASID w.r.t tlb(2)

	mtc0 $18, cop0_EntryHi
	sw   $18, 0($31)

	ehb 	# clear all hazards
	
	tlbp    # and probe the tlb

	mfc0 $19, cop0_Index    # check for bit31=1
	sw   $19, 0($31)

	slt  $20, $19, $zero    # $20 <- (bit31 = 1)
	beq  $20, $zero, hits
	nop

	li   $30, 'm'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)
	nop
	sw   $30, x_IO_ADDR_RANGE($31)

	##
	## and now probe two entries that will surely hit
	##

	## make a copy of entryHi_1 to force a hit
hits:	la  $18, entryHi_1

	mtc0 $18, cop0_EntryHi
	sw   $18, 0($31)

	ehb 	# clear all hazards
	
	tlbp    # and probe the tlb

	mfc0 $19, cop0_Index    # check for bit31=1
	sw   $19, 0($31)

	slt  $20, $19, $zero    # $20 <- (bit31 = 1)
	beq  $20, $zero, hit1
	nop

	li   $30, 'm'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)


hit1:	li   $30, 'h'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '='
	sw   $30, x_IO_ADDR_RANGE($31)
	andi $30, $19, (MMU_CAPACITY - 1)
	addi $30, $30, '0'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)
	nop
	sw   $30, x_IO_ADDR_RANGE($31)
	

	## make a copy of entryHi_0 to force a hit
	la  $18, entryHi_0

	mtc0 $18, cop0_EntryHi
	sw   $18, 0($31)

	ehb 	# clear all hazards
	
	tlbp    # and probe the tlb

	mfc0 $19, cop0_Index    # check for bit31=1
	sw   $19, 0($31)

	slt  $20, $19, $zero    # $20 <- (bit31 = 1)
	beq  $20, $zero, hit0
	nop

	li   $30, 'm'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)

hit0:	li   $30, 'h'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '='
	sw   $30, x_IO_ADDR_RANGE($31)
	andi $30, $19, (MMU_CAPACITY - 1)
	addi $30, $30, '0'
	sw   $30, x_IO_ADDR_RANGE($31)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($31)
	
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

	
