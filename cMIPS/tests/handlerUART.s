    #--------------------------------------------------------------------------
    # interrupt handler for UART

RX:
    andi  $a0, $k1, UART_rx_irq # Is this reception?
    beq   $a0, $zero, TX        #   no, test if it's transmission
    
    lui   $a0, %hi(HW_uart_addr)
    ori   $a0, $a0, %lo(HW_uart_addr)
    lw    $a1, 4($a0)           # Read data

    lui   $a0, %hi(rx_queue)    
    ori   $a0, $a0, %lo(rx_queue)
    sw    $a1, 0($a0)           # Put data on RX_queue

    lui   $a0, %hi(rx_tl)    
    ori   $a0, $a0, %lo(rx_tl)
    lw    $a1, 0($a0)           # Read rx_tl
    nop
    addiu $a1, $a1, 1           # Increment rx_tl (shouldn't it be (rx_tl+1)%16 ?) 
    sw    $a1, 0($a0)           # Save rx_tl

    lui   $a0, %hi(nrx)    
    ori   $a0, $a0, %lo(nrx)
    lw    $a1, 0($a0)           # Read nrx
    nop
    addiu $a1, $a1, 1           # Increment nrx 
    sw    $a1, 0($a0)           # Save incremented nrx

TX:
    andi $a0, $k1, UART_tx_irq  # Is this transmission?
    beq  $a0, $zero, END        #   no, end handler
    nop
    # TODO: Increment ntx (we're sending a char)

END:

