    #--------------------------------------------------------------------------
    # interrupt handler for UART
RX:
    andi  $a0, $k1, UART_rx_irq # Is this reception?
    beq   $a0, $zero, TX        #   no, test if it's transmission
    nop
    # TODO: Read data, store it to buffer and decrement nrx (we're reading a char)
TX:
    andi $a0, $k1, UART_tx_irq  # Is this transmission?
    beq  $a0, $zero, END        #   no, end handler
    nop
    # TODO: Increment ntx (we're sending a char)

END:

