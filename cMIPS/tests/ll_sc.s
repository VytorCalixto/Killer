	# mips-as -O0 -EL -mips32 -o start.o start.s
	.include "cMIPS.s"
	.text
	.align 2
	.set noreorder
	.global _start
	.global _exit
	.global exit
	.ent _start
_start: nop
	li   $k0,0x10000002     # RESET_STATUS, kernel mode, all else disabled
	mtc0 $k0,cop0_STATUS
	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8)  # initialize SP: memTop-8
        li   $k0, 0x1000ff01    # enable interrupts
        mtc0 $k0, cop0_STATUS
	nop
	jal main
	nop
exit:	
_exit:	nop	     # flush pipeline
	nop
	nop
	nop
	nop
	wait  # then stop VHDL simulation
	nop
	nop
	.end _start

	
	.org x_EXCEPTION_0180,0
	.global excp_180
	.ent excp_180
excp_180:
	mfc0 $k0, cop0_CAUSE  # show cause
	sw   $k0, 0($15)
        li   $k0, 0x10000000  # disable interrupts
        mtc0 $k0, cop0_STATUS
	li   $k1, 0x00000000  # remove SW interrupt request
	mtc0 $k1, cop0_CAUSE
	li   $k0, 0x1000ff01  # enable interrupts
        mtc0 $k0, cop0_STATUS
	eret
	nop
	.end excp_180

	
	.org x_ENTRY_POINT,0
	.ent main
main:	la $15,x_IO_BASE_ADDR  # print $5=8 and count downwards
	li $5,8
	li $6,4
	li $t1,0
	la    $t0, x_DATA_BASE_ADDR
	sw    $zero, 0($t0)
	nop
loop:	sw    $5, 0($15)      # print-out $5
	nop
L:	ll    $t1, 0($t0)     # load-linked

	addiu $5,$5,-1
	bne   $5,$6,fwd       # four rounds yet?
	nop
	
	li   $k1, 0x00000100  # cause SW interrupt after 4 rounds
	mtc0 $k1, cop0_CAUSE  # causes SC to fail and prints 0000.0000=CAUSE

	nop	# must delay SC so that interrupt starts before the SC
	nop
	nop
	nop

fwd:	addi $t2, $t1, 1   # increment value read by LL
	sc   $t2, 0($t0)   # try to store, checking for atomicity
	sw   $t2, 0($15)   # prints 0000.0001 if SC succeeds
	addiu $t0,$t0,4    # use a new address in each round
	beq  $t2, $zero, L # if not atomic (0), try again, does not print 4
	sw   $zero, 0($t0) # store zero to new address

	bne  $5,$zero, loop
	nop

	sw   $zero, 0($t0) # clear untouched location
	nop
	lw   $t2, 0($t0)   # print untouched location = 0000.0000
	sw   $t2, 0($15)
	nop
	j exit
	nop
	
	.end main

#	.data
#	.align 2
#area:	.space 64,0
	