	.file	1 "sumSstats.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.ent	main
	.type	main, @function
main:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	lui	$9,%hi(A)
	lui	$8,%hi(B)
	lui	$7,%hi(C)
	move	$25,$0
	sw	$17,24($sp)
	sw	$16,20($sp)
	sw	$31,28($sp)
	move	$16,$0
	addiu	$9,$9,%lo(A)
	addiu	$8,$8,%lo(B)
	addiu	$7,$7,%lo(C)
	li	$24,64			# 0x40
	li	$17,16			# 0x10
$L2:
	move	$3,$16
	move	$2,$0
	addu	$15,$9,$25
	addu	$14,$8,$25
	addu	$13,$7,$25
$L6:
	addu	$6,$15,$2
	addu	$5,$14,$2
	addu	$4,$13,$2
	addiu	$2,$2,4
	sw	$3,0($6)
	sw	$3,0($5)
	sw	$3,0($4)
	move	$10,$9
	move	$12,$8
	move	$11,$7
	bne	$2,$24,$L6
	addiu	$3,$3,1

	addiu	$16,$16,1
	bne	$16,$17,$L2
	addiu	$25,$25,64

	move	$13,$0
	li	$9,64			# 0x40
	li	$14,1024			# 0x400
	addu	$3,$13,$11
$L12:
	move	$2,$0
	addu	$8,$10,$13
	addu	$7,$13,$12
$L9:
	addu	$5,$8,$2
	addu	$4,$7,$2
	lw	$6,0($5)
	lw	$4,0($4)
	lw	$5,0($3)
	addu	$4,$6,$4
	addu	$4,$5,$4
	addiu	$2,$2,4
	sw	$4,0($3)
	bne	$2,$9,$L9
	addiu	$3,$3,4

	addiu	$13,$13,64
	bne	$13,$14,$L12
	addu	$3,$13,$11

	lui	$16,%hi(st)
	jal	to_stdout
	li	$4,10			# 0xa

	jal	readStats
	addiu	$4,$16,%lo(st)

	lw	$4,%lo(st)($16)
	jal	print
	addiu	$16,$16,%lo(st)

	lw	$4,4($16)
	jal	print
	nop

	lw	$4,8($16)
	jal	print
	nop

	lw	$4,12($16)
	jal	print
	nop

	lw	$4,16($16)
	jal	print
	nop

	lw	$4,20($16)
	jal	print
	nop

	jal	exit
	move	$4,$0

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main

	.comm	C,1024,4

	.comm	B,1024,4

	.comm	A,1024,4

	.comm	st,24,4
	.ident	"GCC: (GNU) 4.8.2"
