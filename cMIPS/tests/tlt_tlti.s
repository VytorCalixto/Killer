        ##
        ## this test is run in User Mode
        ##
 	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.global _start
	.global _exit
	.global exit
	.ent    _start

	##
	## reset leaves processor in kernel mode, all else disabled
	##
_start: nop
	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
	la   $k0, main
	mtc0 $k0, cop0_EPC
	eret # go into user mode, all else disabled
	nop
exit:	
_exit:	nop	     # flush pipeline
	nop
	nop
	nop
	nop
	wait 0x3ff   # and then stop VHDL simulation
	nop
	nop
	.end _start
	
	.org x_EXCEPTION_0180,0 # exception vector_180 at 0x00000060
	.global _excp_180
	.global excp_180
	.global _excp_200
	.global excp_200
	.ent _excp_180
excp_180:	
_excp_180:
excp_200:	
_excp_200:
        mfc0  $k0, cop0_CAUSE
	sw    $k0,0($15)        # print CAUSE to stdout
	addiu $7,$7,-1		# and decrement $7
excp_180ret:
	eret
	.end _excp_180

#	.org (end_excp_180 + 0x20),0
#	.ent _excp_200
#excp_200:	
#_excp_200:	
#	eret
#	nop
#	.end _excp_200

	.org x_ENTRY_POINT,0      # normal code starts at 0x0000.0100
main:	la    $15,x_IO_BASE_ADDR
	li    $7,4
	li    $6,10
	li    $5,0
here:	sw $5, 0($15)
	addiu $5,$5,2
	tlt   $5,$6
	beq   $7,$zero, there
	b here

there:	sw $zero, 0($15)
	sw $zero, 0($15)
	li $5,0
	li $7,4
then:	sw $5, 0($15)
	addiu $5,$5,2
	tlti $5,10
	bnez $7,then
	nop
	sw $7, 0($15)

	sw $zero, 0($15)
	sw $zero, 0($15)
	li    $5,1
	li    $7,4
	li    $6,10
here2:	sw    $6, 0($15)
	tge   $6,$5
	addiu $6,$6,-2
	beq   $7,$zero, there2
	b here2

there2:	sw $zero, 0($15)
	sw $zero, 0($15)
	li $6,10
	li $7,4
then2:	sw $6, 0($15)
	tgei  $6,1
	addiu $6,$6,-2
	bnez $7,then2
	nop
	sw $7, 0($15)
	j exit
	
