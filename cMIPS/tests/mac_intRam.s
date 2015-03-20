	.include "cMIPS.s"
        .text
        .align 2
	.set noreorder
        .globl _start
        .ent _start

	# delay loops over four instructions, so divide num cycles by 4
	.set wait_1_sec,       50000000/4 # 1s / 20ns
	.set LCD_power_cycles, 10000000/4 # 200ms / 20ns
	.set LCD_reset_cycles, 2500000/4  # 50ms / 20ns
	.set LCD_clear_delay,  35000/4    # 0.7ms / 20ns
	.set LCD_delay_30us,   1500/4     # 30us / 20ns
	.set LCD_oper_delay,   750/4      # 15us / 20ns
	.set LCD_write_delay,  750/4      # 15us / 20ns

	# smaller constants for simulation
	# .set wait_1_sec,       5   # 1s / 20ns
	# .set LCD_power_cycles, 4   # 200ms / 20ns
	# .set LCD_reset_cycles, 4   # 50ms / 20ns
	# .set LCD_clear_delay,  2   # 0.7ms / 20ns
	# .set LCD_delay_30us,   4   # 30us / 20ns
	# .set LCD_oper_delay,   4   # 15us / 20ns
	# .set LCD_write_delay,  2   # 15us / 20ns

_start: nop

	### tell the world we are alive
	la  $15, HW_dsp7seg_addr   # 7 segment display
	li  $16, 1
	sw  $16, 0($15)            # write to 7 segment display

	la $4, LCD_reset_cycles    # wait for 50ms, so LCDcntrllr resets
	jal delay
	nop

	### WAKE UP commands -- send these at 30us intervals	
	##  peripheral reads only LSbyte, so send a word and it gets a byte

	la  $26, HW_lcd_addr       # LCD display hw address
	li  $21, 4
	la  $19, 0x17393030

wakeup:	sw  $19, 0($26)
	la  $4, LCD_delay_30us     # wait for 30us
	jal delay
	nop
	srl  $19,$19,8              # next command/byte
	addi $21, $21, -1
	bne  $21, $zero, wakeup
	nop

	### display is now on fast clock
	
	### next four commands
	li  $21, 4
	la  $19, 0x0f6d5670

more4:	sw  $19, 0($26)
	nop			    # give some time to LCD controller
	nop
w_m4:	lw   $4, 0($26)		    # wait for BUSYflag=0
	nop
	andi $4, $4, 0x80
	bne  $4, $zero, w_m4
	nop
	srl  $19,$19,8              # next command/byte
	addi $21, $21, -1
	bne  $21, $zero, more4
	nop
	

	li  $19, 0b00000110        # x06 entry mode: blink, Shift, addrs++
	sw  $19, 0($26)
	nop
	nop
w_ntry:	lw   $4, 0($26)
	nop
	andi $4, $4, 0x80
	bne  $4, $zero, w_ntry
	nop

	jal LCDclr
	nop

	# jal LCDhome1               # cursor at home, clear screen
	# nop

	la  $15, HW_dsp7seg_addr # 7 segment display
	li  $16, 0x05
	sw  $16, 0($15)            # write to 7 segment display
	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop

	### end of commands +++++++++++++++++++++++++++++++++++++++


        # first line of Hello world!

	# first line
	jal LCDhome1               # cursor at home, clear screen
	nop
	
	la  $4, 0x6c6c6548
	jal send
	nop

	la  $4, 0x6f77206f
	jal send
	nop

	la  $4, 0x21646c72
	jal send
	nop

	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop
	
	# second line
	jal LCDhome2
	nop

	la  $4, 0x69617320
	jal send
	nop

	la  $4, 0x4d632064
	jal send
	nop

	la  $4, 0x20535049
	jal send
	nop

	
	### tell where we are
	la  $15, HW_dsp7seg_addr # 7 segment display
	li  $16, 0x06
	sw  $16, 0($15)            # write to 7 segment display
	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop
	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop
	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop
	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop
	

	### test internal FPGA RAM ------------------------------------

	jal LCDclr
	nop

	jal LCDhome1
	nop
	
	la $8,  x_DATA_BASE_ADDR
	la $10, 0x30313233       # 
	sw $10, 0($8)
	la $11, 0x34353637       # 
	sw $11, 4($8)
	la $12, 0x003a3938       #
	sw $12, 8($8)


loop:	lbu   $13, 0($8)
	addiu $8, $8, 1
	beq   $13, $zero, endT1
	nop

	jal  LCDput
	move  $4, $13            # print number

	#jal  LCDput
	#li   $4, 0x20            #   and a SPACE
	
	j    loop
	nop

	
	la  $15, HW_dsp7seg_addr # 7 segment display
	li  $16, 7
	sw  $16, 0($15)          # write to 7 segment display
	nop

	la $4, wait_1_sec          # wait ONE second
	jal delay
	nop
	
endT1:	j   endT1                # wait forever 
	nop
	
#----------------------------------------------------------------------
	
	
### send one character to LCD's RAM -----------------------------------
LCDput:	la   $6, HW_lcd_addr    # LCD display
	sw   $4, 4($6)		# write character to LCD's RAM
	nop			# give the controller time
	nop
dlyput:	lw   $4, 0($6)
	nop
	andi $4, $4, 0x80
	bne  $4, $zero, dlyput
	nop

	jr $ra
	nop
#----------------------------------------------------------------------


### put cursor at home, write do 1st position of 1st line -------------
LCDhome1: la  $6, HW_lcd_addr   # LCD display
	li  $4, 0b10000000      # x80 RAMaddrs=00, cursor at home
	sw  $4, 0($6)

	la  $4, LCD_clear_delay    # wait for CLEAR
dlyhm1:	addiu $4, $4, -1
	nop
	bne $4, $zero, dlyhm1
	nop

#       nop
#	nop			# give the controller time
#	nop	
#dlyhm1:	lw   $4, 0($6)
#	nop
#	andi $4, $4, 0x80
#	bne  $4, $zero, dlyhm1
#	nop

	jr $ra
	nop
#----------------------------------------------------------------------

### put cursor at home, write do 1st position of 2nd line -------------
LCDhome2: la  $6, HW_lcd_addr   # LCD display
	li  $4, 0b11000000      # x80 RAMaddrs=40, cursor at home
	sw  $4, 0($6)

	la  $4, LCD_clear_delay    # wait for CLEAR
dlyhm2:	addiu $4, $4, -1
	nop
	bne $4, $zero, dlyhm2
	nop

#	nop
#	nop			# give the controller time
#	nop	
#dlyhm2:	lw   $4, 0($6)
#	nop
#	andi $4, $4, 0x80
#	bne  $4, $zero, dlyhm2
#	nop

	jr $ra
	nop
#----------------------------------------------------------------------

### clear display and send cursor home -------------------------------
LCDclr: la  $6, HW_lcd_addr     # LCD display
	li  $4, 0b00000001      # x01 clear display -- DELAY=0.6ms
	sw  $4, 0($6)

	la  $4, LCD_clear_delay    # wait for CLEAR
dlyclr:	addiu $4, $4, -1
	nop
	bne $4, $zero, dlyclr
	nop


#	nop
#	nop			# give the controller time
#	nop	
#dlyclr:	lw   $4, 0($6)
#	nop
#	andi $4, $4, 0x80
#	bne  $4, $zero, dlyclr
#	nop

	jr $ra
	nop
#----------------------------------------------------------------------

	
### send 4 characters to LCD's RAM ------------------------------------
send:	la  $26, HW_lcd_addr    # LCD display
	
	sw   $4, 4($26)		# write character to LCD's RAM
	srl  $4, $4, 8

	la $5, LCD_write_delay
delay0:	addiu $5, $5, -1
	nop
	bne $5, $zero, delay0
	nop

	sw   $4, 4($26)		# write character to LCD's RAM
	srl  $4, $4, 8	

	la $5, LCD_write_delay
delay1:	addiu $5, $5, -1
	nop
	bne $5, $zero, delay1
	nop

	sw  $4, 4($26)		# write character to LCD's RAM
	srl $4, $4, 8

	la $5, LCD_write_delay
delay2:	addiu $5, $5, -1
	nop
	bne $5, $zero, delay2
	nop

	sw  $4, 4($26)		# write character to LCD's RAM

	la $5, LCD_write_delay
delay3:	addiu $5, $5, -1
	nop
	bne $5, $zero, delay3
	nop

	jr $ra
	nop	
# ---------------------------------------------------------------------
	

### delay for N/4 processor cycles ------------------------------------	
delay:	addiu $4, $4, -1
	nop
	bne $4, $zero, delay
	nop
	jr $ra
	nop

	
	.end _start

	
	### command table in initialized RAM, for when it works	;)
# 	.data
# cmdVec:
        # .byte  0b00110000        # x30 wake-up
        # .byte  0b00110000        # x30 wake-up
        # .byte  0b00111001        # x39 funct: 8bits, 2line, 5x8font, IS=0
        # .byte  0b00010111        # x17 int oscil freq: 1/5bias, freq=700kHz 
        # .byte  0b01110000        # x70 contrast for int follower mode: 0
        # .byte  0b01010110        # x56 pwrCntrl: ICON=off, boost=on, contr=2 
        # .byte  0b01101101        # x6d follower control: fllwr=on, aplif=5 
        # .byte  0b00001111        # x0f displayON/OFF: Off, cur=on, blnk=on
        # .byte  0b00000110        # x06 entry mode: blink, noShift, addrs++
        # .byte  0b00000001        # x01 clear display
        # .byte  0b10000000        # x80 RAMaddrs=0, cursor at home
        # .byte  0b10000000        # x80 RAMaddrs=0, cursor at home
        # .byte  0b11000000        # x80 RAMaddrs=40, cursor at home
	# .byte 0,0
# 
#string:	 .asciiz "Hello world! said cMIPS"	
#	la  $19, 0x6c6c6548
#	la  $19, 0x6f77206f
#	la  $19, 0x21646c72
#	la  $19, 0x69617320
#	la  $19, 0x4d632064
#	la  $19, 0x00535049
