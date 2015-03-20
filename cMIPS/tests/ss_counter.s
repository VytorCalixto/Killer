	.include "cMIPS.s"
	.text
	.align 2
	.globl _start
	.ent _start
_start: li   $5, 6
	la   $15, x_IO_BASE_ADDR
	la   $20, x_IO_BASE_ADDR + 64   # counter address
	li   $6, 0x80000004
	nop
	sw   $6,0($20)
lasso:	nop
	addiu $5,$5,-1
	bne   $5,$0,lasso
        nop
	li   $6, 0x00000004
	sw   $6,0($20)
	nop
	nop
	nop
	nop
	nop
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
	.end _start

