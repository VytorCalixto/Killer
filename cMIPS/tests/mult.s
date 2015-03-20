	.include "cMIPS.s"
	.text
	.align 2
	.set noat
	.globl _start
	.ent _start
_start: nop
	la   $15,x_IO_BASE_ADDR
	li   $3,1
	li   $4,2
incr:	mult $3,$4
	mflo $5
	sw   $5, 0($15) # print=2,4,6,8,...,x20,x22,x24,x26,x28
	addi $3,$3,1
	slti $22,$5,40
	bne  $22,$0,incr 
	nop
	nop
	nop
	nop
	wait
	.end _start
