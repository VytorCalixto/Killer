	.include "cMIPS.s"
	.text
	.align 2
	.set noreorder
	.globl _start
	.ent _start
_start:	nop
	la  $15, x_DATA_BASE_ADDR + 0x10
	la  $16, x_IO_BASE_ADDR
	addi  $3,$0,-10
	ori   $5,$0,4
        addi  $9,$0,10
	nop
snd:	sw   $3, 4($15)
	addi $3,$3,1
	lw   $4, 4($15)
	sw   $4, 0($16)
	add  $15,$15,$5
	slt  $8,$3,$9
        bne  $8,$0,snd
        nop
        wait
        nop
	.end _start
