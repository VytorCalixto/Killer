	.include "cMIPS.s"
        .text
        .align 2
	.set noreorder
	.set noat
        .globl _start
        .ent _start

	.set waitFor, 50000000/4     # wait for 1 second @ 50 MHz
	# .set waitFor, 5            # this is for simulation only
	
_start: nop
	la   $25, HW_dsp7seg_addr  # 7 segment display
	la   $5,  waitFor
	li   $3,  0
	
new:	sw    $3, 0($25)           # write to 7 segment display
	nop
wait:	addiu $5, $5, -1
	bne   $5, $zero, wait
	nop

	la    $5, waitFor          # wait for 1 second @ 50 MHz
	addiu $3, $3, 1            # change digit
	b     new	           # repeat forever
	nop
end1:	nop
        nop
        nop
        wait
	nop
	nop
        .end _start
