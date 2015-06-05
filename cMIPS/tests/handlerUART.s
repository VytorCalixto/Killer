    #--------------------------------------------------------------------------
    # interrupt handler for UART

RX:
    andi  $a0, $k1, UART_rx_irq # Is this reception?
    beq   $a0, $zero, TX        #   no, test if it's transmission

    lui   $a0, %hi(nrx)    
    ori   $a0, $a0, %lo(nrx)
    lw    $a1, 0($a0)           # Read nrx
    
    addiu $a0, $zero, 16
    slt   $a0, $a1, $a0         # If nrx >= 16 the queue is full
    beq   $a0, $zero, END 
    
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
    addiu $a1, $a1, 1           # Increment RX_tail
    andi  $a1, $a1, 15          # It's a circular queue so: (rx_tl+1)%16 
    sw    $a1, 0($a0)           # Save new rx_tl

    lui   $a0, %hi(nrx)    
    ori   $a0, $a0, %lo(nrx)
    lw    $a1, 0($a0)           # Read nrx
    nop
    addiu $a1, $a1, 1           # Increment nrx 
    sw    $a1, 0($a0)           # Save incremented nrx

TX:
    andi  $a0, $k1, UART_tx_irq # Is this transmission?
    beq   $a0, $zero, END       #   no, end handler

    lui   $a0, %hi(ntx)
    ori   $a0, $a0, %lo(ntx)
    lw    $a1, 0($a0)           # Read ntx

    addiu $a0, $zero, 16
    slt   $a0, $a1, $a0         # If ntx < 16 there's something on the queue
    beq   $a0, $zero, END      

    lui   $a0, %hi(tx_queue)
    ori   $a0, $a0, %lo(tx_queue)
    lw    $a1, 0($a0)           # Read TX_queue

    lui   $a0, %hi(HW_uart_addr)
    ori   $a0, $a0, %lo(HW_uart_addr)
    sw    $a1, 0($a0)           # Put data on UART

    lui   $a0, %hi(tx_hd)
    ori   $a0, $a0, %lo(tx_hd)
    lw    $a1, 0($a0)           # Read tx_hd
    nop
    addiu $a1, $a1, 1           # Increment tx_hd: we've transmitted, there's space on the queue
    andi  $a1, $a1, 15          # It's a circular queue so: (tx_hd+1)%16
    sw    $a1, 0($a0)           # Save tx_hd

    lui   $a0, %hi(ntx)
    ori   $a0, $a0, %lo(ntx)
    lw    $a1, 0($a0)           # Read ntx
    nop
    addiu $a1, $a1, 1           # Increment ntx
    sw    $a1, 0($a0)           # Save incremented ntx

END:

