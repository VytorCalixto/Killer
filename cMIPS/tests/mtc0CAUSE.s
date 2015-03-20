	.include "cMIPS.s"
	.text
	.align 2
	.globl _start
	.ent _start
_start: li   $5, 32
	li   $20,4            # do four interrupts and stop
	li   $6, 0x18000303   # kernel mode, disable interrupts
	mtc0 $6,cop0_STATUS
	li   $6, 0xffffffff   # write garbage to CAUSE, assert sw interrupt
	mtc0 $6,cop0_CAUSE
	la   $15, x_IO_BASE_ADDR
	addiu $k1,$15,1024
	li   $k0, 0x80000100  # start external counter (not COUNT)
	sw   $k0,0($k1)
	mfc0 $6,cop0_CAUSE    # print CAUSE
	nop
	sw   $6,0($15)
	j code
	

	.org x_EXCEPTION_0180,0 # exception vector_180 at 0x00000060
	.global excp
excp:	li    $k0,0x00000000
	mtc0  $k0,cop0_CAUSE   # remove sw interrupt req
	li    $k0, 0x00000000
	addiu $k1, $15, 1024
	sw    $k0,0($k1)       # stop counter
	addiu $20,$20,-1
	sw    $zero,0($15)     # print zero do signal interrupt taken
	li    $k0, 0x80000100  # start counter
	sw    $k0,0($k1)
	li    $k0,0x18000301   # enable interrupts
	mtc0  $k0,cop0_STATUS
	eret

	.org x_ENTRY_POINT,0
	nop
code:	li    $9,16
	li    $6, 0x18000301   # enable interrupts
	mtc0  $6,cop0_STATUS
lasso:	addiu $5,$5,-1
	sw    $5,0($15)
	beq   $9,$5,restart
	nop
	andi  $5,$5,0x1f
	beq   $20,$zero,end
	j lasso
	
restart: li  $6, 0x00000100  # request sw interrupt
	mtc0 $6, cop0_CAUSE
	j lasso
	
end:	nop
	nop
	nop
        wait
	nop
	nop
	.end _start


# 08000300
# 00000000
# 0000001f
# 0000001e
# 0000001d
# 0000001c
# 0000001b
# 0000001a
# 00000019
# 00000018
# 00000017
# 00000016
# 00000015
# 00000014
# 00000013
# 00000012
# 00000011
# 00000010
# 00000000
# 0000000f
# 0000000e
# 0000000d
# 0000000c
# 0000000b
# 0000000a
# 00000009
# 00000008
# 00000007
# 00000006
# 00000005
# 00000004
# 00000003
# 00000002
# 00000001
# 00000000
# ffffffff
# 0000001e
# 0000001d
# 0000001c
# 0000001b
# 0000001a
# 00000019
# 00000018
# 00000017
# 00000016
# 00000015
# 00000014
# 00000013
# 00000012
# 00000011
# 00000010
# 00000000
# 0000000f
# 0000000e
# 0000000d
# 0000000c
# 0000000b
# 0000000a
# 00000009
# 00000008
# 00000007
# 00000006
# 00000005
# 00000004
# 00000003
# 00000002
# 00000001
# 00000000
# ffffffff
# 0000001e
# 0000001d
# 0000001c
# 0000001b
# 0000001a
# 00000019
# 00000018
# 00000017
# 00000016
# 00000015
# 00000014
# 00000013
# 00000012
# 00000011
# 00000010
# 00000000
# 0000000f
