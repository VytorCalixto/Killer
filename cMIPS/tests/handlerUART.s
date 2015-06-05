    #--------------------------------------------------------------------------
    # interrupt handler for UART

RX:
    andi  $a0, $k1, UART_rx_irq # Is this reception?
    beq   $a0, $zero, TX        #   no, test if it's transmission

    lui   $a0, %hi(nrx)    
    ori   $a0, $a0, %lo(nrx)
    lw    $a1, 0($a0)           # Read nrx
    
    addiu $a2, $zero, 16
    slt   $a2, $a1, $a2         # If nrx >= 16 the queue is full
    beq   $a2, $zero, END 
    
    addiu $a1, $a1, 1           # Increment nrx right now so we dont need to read it again
    sw    $a1, 0($a0)           # Save incremented nrx

    lui   $a0, %hi(rx_tl)    
    ori   $a0, $a0, %lo(rx_tl)
    lw    $a1, 0($a0)           # Read rx_tl
    nop
    addiu $a2, $a1, 1           # Increment RX_tail
    andi  $a2, $a2, 15          # It's a circular queue so: (rx_tl+1)%16 
    sw    $a2, 0($a0)           # Save new rx_tl

    lui   $a0, %hi(HW_uart_addr)
    ori   $a0, $a0, %lo(HW_uart_addr)
    lw    $a2, 4($a0)           # Read data

    lui   $a0, %hi(rx_queue)    
    ori   $a0, $a0, %lo(rx_queue)
    add   $a0, $a1, $a0         # Get queue tail address (before the increment)
    sw    $a2, 0($a0)           # Put data on RX_queue tail


TX:
    andi  $a0, $k1, UART_tx_irq # Is this transmission?
    beq   $a0, $zero, END       #   no, end handler

    lui   $a0, %hi(ntx)
    ori   $a0, $a0, %lo(ntx)
    lw    $a1, 0($a0)           # Read ntx

    addiu $a2, $zero, 16
    slt   $a2, $a1, $a2         # If ntx < 16 there's something on the queue
    beq   $a2, $zero, END      

    addiu $a1, $a1, 1           # Increment ntx
    sw    $a1, 0($a0)           # Save incremented ntx

    lui   $a0, %hi(tx_hd)
    ori   $a0, $a0, %lo(tx_hd)
    lw    $a1, 0($a0)           # Read tx_hd
    nop
    addiu $a2, $a1, 1           # Increment tx_hd: we've transmitted, there's space on the queue
    andi  $a2, $a2, 15          # It's a circular queue so: (tx_hd+1)%16
    sw    $a2, 0($a0)           # Save tx_hd

    lui   $a0, %hi(tx_queue)
    ori   $a0, $a0, %lo(tx_queue)
    add   $a0, $a1, $a0         # Get queue head address (before the increment)
    lw    $a1, 0($a0)           # Read TX_queue head

    lui   $a0, %hi(HW_uart_addr)
    ori   $a0, $a0, %lo(HW_uart_addr)
    sw    $a1, 0($a0)           # Put data on UART

END:

