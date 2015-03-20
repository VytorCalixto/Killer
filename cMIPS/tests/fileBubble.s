	.file	1 "fileBubble.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.text
	.align	2
	.globl	sort
	.set	nomips16
	.ent	sort
	.type	sort, @function
sort:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	blez	$5,$L9
	move	$9,$4

	move	$10,$0
	j	$L3
	move	$3,$0

$L5:
	lw	$6,0($9)
	lw	$7,0($2)
	nop
	slt	$8,$7,$6
	beq	$8,$0,$L4
	nop

	sw	$7,0($9)
	sw	$6,0($2)
$L4:
	addiu	$3,$3,1
	slt	$6,$3,$5
	bne	$6,$0,$L5
	addiu	$2,$2,4

$L6:
	addiu	$10,$10,1
	beq	$10,$5,$L9
	addiu	$9,$9,4

	move	$3,$10
$L3:
	slt	$2,$3,$5
	beq	$2,$0,$L6
	nop

	sll	$2,$3,2
	j	$L5
	addu	$2,$4,$2

$L9:
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	sort
	.size	sort, .-sort
	.align	2
	.globl	readInt
	.set	nomips16
	.ent	readInt
	.type	readInt, @function
readInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	li	$2,251658240			# 0xf000000
	ori	$3,$2,0x400
	lw	$3,0($3)
	ori	$2,$2,0x404
	lw	$2,0($2)
	nop
	bne	$2,$0,$L13
	nop

	sw	$3,0($4)
$L13:
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	readInt
	.size	readInt, .-readInt
	.align	2
	.globl	writeInt
	.set	nomips16
	.ent	writeInt
	.type	writeInt, @function
writeInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	li	$2,251658240			# 0xf000000
	ori	$2,$2,0x800
	j	$31
	sw	$4,0($2)

	.set	macro
	.set	reorder
	.end	writeInt
	.size	writeInt, .-writeInt
	.align	2
	.globl	writeClose
	.set	nomips16
	.ent	writeClose
	.type	writeClose, @function
writeClose:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	li	$3,1			# 0x1
	li	$2,251658240			# 0xf000000
	ori	$2,$2,0x404
	j	$31
	sw	$3,0($2)

	.set	macro
	.set	reorder
	.end	writeClose
	.size	writeClose, .-writeClose
	.align	2
	.globl	print
	.set	nomips16
	.ent	print
	.type	print, @function
print:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$4,0($2)

	.set	macro
	.set	reorder
	.end	print
	.size	print, .-print
	.align	2
	.globl	main
	.set	nomips16
	.ent	main
	.type	main, @function
main:
	.frame	$sp,48,$31		# vars= 8, regs= 5/0, args= 16, gp= 0
	.mask	0x800f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-48
	sw	$31,44($sp)
	sw	$19,40($sp)
	sw	$18,36($sp)
	sw	$17,32($sp)
	sw	$16,28($sp)
	lui	$16,%hi(buf)
	addiu	$16,$16,%lo(buf)
	move	$17,$16
	move	$18,$0
	j	$L21
	addiu	$19,$sp,16

$L22:
	lw	$2,16($sp)
	nop
	sw	$2,0($17)
	addiu	$18,$18,1
	addiu	$17,$17,4
$L21:
	jal	readInt
	move	$4,$19

	beq	$2,$0,$L22
	lui	$4,%hi(buf)

	addiu	$4,$4,%lo(buf)
	jal	sort
	move	$5,$18

	blez	$18,$L23
	move	$17,$0

$L24:
	lw	$4,0($16)
	jal	writeInt
	addiu	$17,$17,1

	lw	$4,0($16)
	jal	print
	addiu	$16,$16,4

	slt	$2,$17,$18
	bne	$2,$0,$L24
	nop

$L23:
	jal	writeClose
	nop

	lw	$31,44($sp)
	lw	$19,40($sp)
	lw	$18,36($sp)
	lw	$17,32($sp)
	lw	$16,28($sp)
	j	$31
	addiu	$sp,$sp,48

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main

	.comm	buf,512,4
	.ident	"GCC: (GNU) 4.4.3"
