    #--------------------------------------------------------------------------
    # interrupt handler for UART
    #.set HW_uart_control,(x_IO_BASE_ADDR +  ? * x_IO_ADDR_RANGE)
    .comm uart_control 56 #TODO setar endereço no MIPS p/ acessar no C

RX:
    andi  $a0, $k1, UART_rx_irq # Is this reception?
    beq   $a0, $zero, TX        #   no, test if it's transmission
    
    lui   $a0, %hi(HW_uart_addr)
    ori   $a0, $a0, %lo(HW_uart_addr)
    lw    $a1, 4($a0)           # Read data
    nop                         #   and store it to UART's buffer
    sw    $a1, 4($k0)           #   and return from interrupt
    addiu $a1, $zero, 1
    sw    $a1, 8($k0)           # Signal new arrival 
    # TODO: Read data, store it to buffer and decrement nrx (we're reading a char)
TX:
    andi $a0, $k1, UART_tx_irq  # Is this transmission?
    beq  $a0, $zero, END        #   no, end handler
    nop
    # TODO: Increment ntx (we're sending a char)

END:

