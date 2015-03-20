	.include "cMIPS.s"
	.text
	.align 2
	.set noat
	.globl _start
	.ent _start
_start: la $16, x_IO_BASE_ADDR
	la $15,(x_DATA_BASE_ADDR+0x10)
	la $5, snd
	li $3,1
	li $4,5
	addi  $29,$0,100
	move  $8,$zero
snd:	#sw   $31, 0($16) # $31 <- 0,snd+4
	add  $8,$8,$3    # $8  <-  1, 7,13,19,25,31,
	add  $8,$8,$4    # $8  <-  6,12,18,24,30,36,
	add  $9,$8,$8    # $9  <- 12,24,36,48,60,72,
	sw   $9, 4($16)
	slt  $28,$9,$29
        beq  $28,$0,.L1
	nop
	add  $9,$0,$5
	jr   $9
	nop
.L1:
end:	nop
	nop
	wait
	nop
	.end _start
