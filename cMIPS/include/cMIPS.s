
	# see vhdl/packageMemory.vhd for addresses
        .set x_INST_BASE_ADDR,0x00000000
        .set x_INST_MEM_SZ,0x00004000

        .set x_DATA_BASE_ADDR,0x00040000
        .set x_DATA_MEM_SZ,0x00004000
	
        .set x_IO_BASE_ADDR,0x0F000000
        .set x_IO_MEM_SZ,0x00002000
	.set x_IO_ADDR_RANGE,0x00000020

	.set HW_counter_addr,(x_IO_BASE_ADDR +  5 * x_IO_ADDR_RANGE)
	.set HW_FPU_addr,    (x_IO_BASE_ADDR +  6 * x_IO_ADDR_RANGE)
	.set HW_uart_addr,   (x_IO_BASE_ADDR +  7 * x_IO_ADDR_RANGE)
	.set HW_dsp7seg_addr,(x_IO_BASE_ADDR +  9 * x_IO_ADDR_RANGE)
	.set HW_keybd_addr,  (x_IO_BASE_ADDR + 10 * x_IO_ADDR_RANGE)
	.set HW_lcd_addr,    (x_IO_BASE_ADDR + 11 * x_IO_ADDR_RANGE)

	# see vhdl/packageExcp.vhd for addresses
	.set x_EXCEPTION_0000,0x00000060
	.set x_EXCEPTION_0100,0x000000A0
	.set x_EXCEPTION_0180,0x000000C0
	.set x_EXCEPTION_0200,0x00000200
	.set x_ENTRY_POINT,   0x00000300

	.set cop0_Index,   $0
	.set cop0_Random,  $1
	.set cop0_EntryLo0,$2
	.set cop0_EntryLo1,$3
	.set cop0_Context ,$4
	.set cop0_PageMask,$5
	.set cop0_Wired,   $6
	.set cop0_BadVAddr,$8
	.set cop0_COUNT   ,$9
	.set cop0_EntryHi ,$10
	.set cop0_COMPARE ,$11
	.set cop0_STATUS  ,$12
	.set cop0_CAUSE   ,$13
	.set cop0_EPC,     $14
	.set cop0_CONFIG,  $16
	.set cop0_CONFIG_f0,0
	.set cop0_CONFIG_f1,1
	.set cop0_LLAddr,  $17
	.set cop0_ErrorPC, $30

	
	# reset: COP0 present, at exception level, all else disabled
	.set cop0_STATUS_reset,0x10000002

	# reset: COUNTER stopped, use special interrVector, no interrupts
	.set cop0_CAUSE_reset, 0x0880007c
