# Testing the internal counter is difficult because it counts clock cycles
# rather than instructions -- if the I/O or memory latencies change then
# the simulation output also changes and comparisons are impossible.
# To perform comparisons the trick is to only update the counter when the
# PC is updated, thus counting instructions.  If there are any stalls,
# the counter also stalls and the simulation outputs are the same
# regardless of the relative latencies.

	# mips-as -O0 -EL -mips32r2
	.include "cMIPS.s"
	.text
	.align 2
	.set noat
	.set noreorder
	.global _start
	.global _exit
	.global exit
	.ent _start
_start: nop
        li   $k0, cop0_STATUS_reset # RESET, kernel mode, all else disabled
        mtc0 $k0, cop0_STATUS
	li   $sp,(x_DATA_BASE_ADDR+x_DATA_MEM_SZ-8) # initialize SP: ramTop-8
        li   $k0, 0x1800ff01  # RESET_STATUS, kernel mode, interr enabled
        mtc0 $k0, cop0_STATUS
        li   $k0, cop0_CAUSE_reset  # RESET, disable counter
        mtc0 $k0, cop0_CAUSE

	la   $15,x_IO_BASE_ADDR
	nop
	jal main
	nop
exit:	
_exit:	nop	# flush pipeline
	nop
	nop
	nop
	nop
	wait	# then stop VHDL simulation
	nop
	nop
	.end _start
	
	.org x_EXCEPTION_0180,0
	.global _excp_180
	.global excp_180
	.ent _excp_180
excp_180:	
_excp_180:
        mfc0  $k0,cop0_CAUSE	# read CAUSE and
	sw    $k0,0($15)       	#   print it
	eret
	.end _excp_180

	
	.org x_EXCEPTION_0200,0
	.ent _excp_200
excp_200:	
_excp_200:	
	sw    $13, x_IO_ADDR_RANGE($15) # blank line
        mfc0  $k0, cop0_CAUSE	# read CAUSE and
	sw    $k0, 0($15)      	#   print it
	mfc0  $k1, cop0_COUNT  	# print current COUNT
	sw    $k1, 0($15)
	addiu $k1, $k1,(64-9) 	# interrupt again in approx 64 cycles
	mtc0  $k1, cop0_COMPARE
	sw    $k1, 4($15)      	# show new limit

	li   $k0, 0x1800ff01   	# enable interrupts
        mtc0 $k0, cop0_STATUS
	sw   $13, x_IO_ADDR_RANGE($15) # blank line
	eret
	.end _excp_200


	.org x_ENTRY_POINT,0
main:	la    $15, x_IO_BASE_ADDR
 	li    $13, '\n'

	addiu $5,$zero,(64-9)   # interrupt again in approx 64 cycles
	mtc0  $5,cop0_COMPARE

	mfc0  $5,cop0_CAUSE
	li    $6,0xf7ffffff    	# CAUSE(DisableCount) <= 0
	and   $5,$5,$6
	mtc0  $5,cop0_CAUSE   	# enable counter

	addiu $11,$12,1        	# this is a NOP

here:	addiu $11,$12,2	        # this is a NOP
	mfc0  $16,cop0_COUNT   	# print current COUNT
	sw    $16,0($15)
	slti  $1,$16,0x200     	# COUNT > 0x200 => stop counter and program
	beq   $1,$zero,there
	addiu $11,$12,3		# this is a NOP
	addiu $11,$12,4		# this is a NOP
	b here
	addiu $11,$12,5		# this is a NOP

	sw    $13, x_IO_ADDR_RANGE($15)
there:	mfc0  $5,cop0_CAUSE
	lui   $6,0x0880        	# CAUSE(DisableCount) <= 1
	or    $5,$5,$6
	mtc0  $5,cop0_CAUSE   	# disable counter
	addiu $11,$12,6		# this is a NOP
	mfc0  $16,cop0_COUNT   	# print current COUNT
	sw    $16,0($15)
	addiu $11,$12,7		# this is a NOP
	addiu $11,$12,8		# this is a NOP
	addiu $11,$12,9		# this is a NOP
	addiu $11,$12,10	# this is a NOP
	mfc0  $16,cop0_COUNT   	# print current COUNT
	sw    $16,0($15)
	j exit
	nop
