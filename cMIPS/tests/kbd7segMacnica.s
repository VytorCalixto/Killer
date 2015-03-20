	.include "cMIPS.s"
        .text
        .align 2
	.set noreorder
	.set noat
        .globl _start
        .ent _start
_start: nop
        la   $15, x_IO_BASE_ADDR + 10*x_IO_ADDR_RANGE  # keyboard
	la   $25, x_IO_BASE_ADDR +  9*x_IO_ADDR_RANGE  # 7 segment display
	li   $1, -1
	li   $31,1
	sll  $31,$31,31      # bit 31 = 1

wait1:	lw   $8, 0($15)      # read keyboard
	nop
	and  $9,$8,$1        # any key pressed?  any bit not zero?
	beq  $9,$zero,wait1
	nop
	
deb1:	lw   $8, 0($15)      # read keyboard, check debouncing ended
	nop
	and  $9,$8,$31       # bit 31 == 1: data is clean
	beq  $9,$zero, deb1
	nop
	sw   $8, 0($25)      # write key read to 7 segment display
	j wait1
	nop
        nop
        nop
        wait
        .end _start
