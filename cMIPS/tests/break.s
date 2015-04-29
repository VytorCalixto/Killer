	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.global _start
	.global _exit
	.global exit
	.set noreorder
	.ent    _start

        ##
        ## reset leaves processor in kernel mode, all else disabled
        ##
_start: nop
	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
        la   $k0, main
        nop
        mtc0 $k0, cop0_EPC
        nop
        eret     # go into user mode, all else disabled
        nop
exit:	
_exit:	nop	 # flush pipeline
	nop
	nop
	nop
	nop
	wait     # then stop VHDL simulation
	nop
	nop
	.end _start
	
	.org x_EXCEPTION_0180,0 # exception vector_180
	.global _excp_180
	.global excp_180
	.ent _excp_180
excp_180:	
_excp_180:
        mfc0  $k0, cop0_CAUSE
	sw    $k0, 0($15)       # print CAUSE
        li    $k0, '\n'
	sw    $k0, x_IO_ADDR_RANGE($15)  # print new-line
	addiu $7, $7, -1
	eret
	.end _excp_180

	.org x_EXCEPTION_0200,0 # exception vector_200
	.global _excp_200
	.global excp_200
	.ent _excp_200
excp_200:
_excp_200:
        ##
        ## this exception should not happen
        ##
        mfc0  $k0, cop0_CAUSE
	sw    $k0,0($15)        # print CAUSE
	addiu $7,$7,+1
	eret
	.end _excp_200

	
	.org x_ENTRY_POINT,0      # normal code start
main:	la $15,x_IO_BASE_ADDR
	li $7,4
	li $5,0
here:	sw $5, 0($15)

	addiu $5, $5,2
	break 15
	bne   $7, $zero, here
	nop

	j exit
	nop
