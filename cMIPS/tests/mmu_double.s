	##
	## Cause a TLB miss on a fetch, refill handler causes double fault
	##
	##
	## EntryHi     : EntryLo0           : EntryLo1
	## VPN2 g ASID : PPN0 ccc0 d0 v0 g0 : PPN1 ccc1 d1 v1 g1

	.include "cMIPS.s"

	.set MMU_WIRED,    2  ### do not change mapping for base of ROM, I/O

        # New entries cannot overwrite tlb[0,1] which map base of ROM, I/O

        # EntryHi cannot have an ASID different from zero, otw TLB misses
        .set entryHi_1,  0x00012000 #                 pfn0  zzcc cdvg
        .set entryLo0_1, 0x0000091b #  x0 x0 x0 x0 x0 1001  0001 1011 x91b
        .set entryLo1_1, 0x00000c1b #  x0 x0 x0 x0 x0 1100  0001 1011 xc1b

        .set entryHi_2,  0x00014000 #                 pfn0  zzcc cdvg
        .set entryLo0_2, 0x00001016 #  x0 x0 x0 x0 x1 0000  0001 0110 x1016
        .set entryLo1_2, 0x0000141e #  x0 x0 x0 x0 x1 0100  0001 1110 x141e

        .set entryHi_3,  0x00016000 #                 pfn0  zzcc cdvg
        .set entryLo0_3, 0x0000191f #  x0 x0 x0 x0 x1 1001  0001 1111 x191f
        .set entryLo1_3, 0x00001d3f #  x0 x0 x0 x0 x1 1101  0011 1111 x1d3f

        .set entryHi_4,  0x00018000 #                 pfn0  zzcc cdvg
        .set entryLo0_4, 0x00000012 #  x0 x0 x0 x0 x0 0000  0001 0010 x12
        .set entryLo1_4, 0x00000412 #  x0 x0 x0 x0 x0 0100  0001 0010 x412

	.text
	.align 2
	.set noreorder
	.set noat
	.org x_INST_BASE_ADDR,0
	.globl _start
	.ent _start

	## set STATUS, cop0, no interrupts enabled
_start:	li   $k0, 0x10000000
        mtc0 $k0, cop0_STATUS

	j main
	nop
	.end _start
	
	##
        ##================================================================
        ## exception vector_0000 TLBrefill, from See MIPS Run pg 145
        ##
        .org x_EXCEPTION_0000,0
        .ent _excp_100
        .set noreorder
        .set noat

_excp_100:  mfc0 $k1, cop0_Context
        lw   $k0, 0($k1)           # k0 <- TP[Context.lo]
        lw   $k1, 8($k1)           # k1 <- TP[Context.hi]
        mtc0 $k0, cop0_EntryLo0    # EntryLo0 <- k0 = even element
        mtc0 $k1, cop0_EntryLo1    # EntryLo1 <- k1 = odd element
        ehb
        tlbwr                      # update TLB
	li   $30, 't'
	sw   $30, x_IO_ADDR_RANGE($20)	
	li   $30, 'h'
	sw   $30, x_IO_ADDR_RANGE($20)	
	li   $30, 'e'
	sw   $30, x_IO_ADDR_RANGE($20)	
	li   $30, 'n'
	sw   $30, x_IO_ADDR_RANGE($20)	
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($20)	
	eret
        .end _excp_100


	##
        ##================================================================
        ## general exception vector_0180
        ##
        .org x_EXCEPTION_0180,0
        .ent _excp_180
        .set noreorder
        .set noat

        ## EntryHi holds VPN2(31..13), probe the TLB for the offending entry
_excp_180: tlbp         # probe for the guilty entry
        nop
        tlbr            # it will surely hit, just use Index to point at it
        mfc0 $k1, cop0_EntryLo0
        ori  $k1, $k1, 0x0002   # make V=1
        mtc0 $k1, cop0_EntryLo0
        tlbwi                   # write entry back

        li   $30, 'h'
        sw   $30, x_IO_ADDR_RANGE($20)
        li   $30, 'e'
        sw   $30, x_IO_ADDR_RANGE($20)
        li   $30, 'r'
        sw   $30, x_IO_ADDR_RANGE($20)
        li   $30, 'e'
        sw   $30, x_IO_ADDR_RANGE($20)
        li   $30, '\n'
        sw   $30, x_IO_ADDR_RANGE($20)

        eret
        .end _excp_180

	
	##
        ##================================================================
        ## normal code starts here
	##
        .org x_ENTRY_POINT,0

	
	## dirty trick: there is not enough memory for a full PT, thus
	##   we set the PT at the bottom of RAM addresses and have
	##   Context pointing into that address range

	.set PTbase, x_DATA_BASE_ADDR
	.ent main
main:	la   $20, x_IO_BASE_ADDR
	
	##
	## setup a PageTable
	##
	## 16 bytes per entry:  
	## EntryLo0           : EntryLo1
	## PPN0 ccc0 d0 v0 g0 : PPN1 ccc1 d1 v1 g1
	##

	la  $4, PTbase

	li   $5, 0            # 1st ROM mapping
	mtc0 $5, cop0_Index
	nop
	tlbr

	mfc0 $6, cop0_EntryLo0
	# sw   $6, 0($20)
	mfc0 $7, cop0_EntryLo1
	# sw   $7, 0($20)

	# 1st entry: PPN0 & PPN1 ROM
	sw  $6, 0($4)
	sw  $0, 4($4)
	sw  $7, 8($4)
	sw  $0, 12($4)

	li $5, 7              # 2nd ROM mapping
	mtc0 $5, cop0_Index
	nop
	tlbr

	mfc0 $6, cop0_EntryLo0
	# sw   $6, 0($20)
	mfc0 $7, cop0_EntryLo1
	# sw   $7, 0($20)

	# 2nd entry: PPN2 & PPN3 ROM
	sw  $6, 16($4)
	sw  $0, 20($4)
	sw  $7, 24($4)
	sw  $0, 28($4)

	# load Context with PTbase
	mtc0 $4, cop0_Context
	
	## change mapping for 2nd ROM TLB entry, thus causing a miss

	li   $9, 0x2000
	sll  $9, $9, 8

	mfc0 $8, cop0_EntryHi
	
	add  $8, $9, $8     # change tag

	mtc0 $8, cop0_EntryHi

	tlbwi		    # and write it back to TLB


	##
	## make invalid TLB entry mapping the page table
	##
        ## read tlb[4] (1st RAM mapping) and clear the V bit
        li $5, 4
        mtc0 $5, cop0_Index

        tlbr

        mfc0 $6, cop0_EntryLo0

        addi $7, $zero, -3      # 0xffff.fffd = 1111.1111.1111.1011
        and  $8, $7, $6         # clear D bit

        mtc0 $8, cop0_EntryLo0

        tlbwi                   # write entry back to TLB

	nop
	nop
	nop

	## cause a TLB miss

	jal  there
	nop
	
	li   $30, 'a'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'n'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'd'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, ' '
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'b'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'a'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'c'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'k'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, ' '
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'a'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'g'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'a'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'i'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'n'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($20)
	sw   $30, x_IO_ADDR_RANGE($20)

	
	nop
	nop
        nop
	nop
	nop
        nop
        wait
	nop
	nop

	
	.org (x_INST_BASE_ADDR + 2*4096), 0

there:	li   $30, 't'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'h'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'e'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'r'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, 'e'
	sw   $30, x_IO_ADDR_RANGE($20)
	li   $30, '\n'
	sw   $30, x_IO_ADDR_RANGE($20)

	jr   $31
	nop
	
	

	
	nop
	nop
        nop
	nop
	nop
        nop
        wait
	nop
	nop
	.end main

