    #--------------------------------------------------------------------------
    # interrupt handler for UART

RX:
    andi  $a0, $k1, UART_rx_irq # Is this reception?
    beq   $a0, $zero, TX        #   no, test if it's transmission

    lui   $a0, %hi(Ud)    
    ori   $a0, $a0, %lo(Ud)     # $a0 <- Ud
    
    lw    $a1, 48($a0)          # Read nrx
    
    la  $2,x_IO_BASE_ADDR 
    sw  $a1,0($2)               # Print for debug

    addiu $k1, $zero, 16
    slt   $k1, $a1, $k1         # If nrx >= 16 the queue is full
    beq   $k1, $zero, END 
    
    addiu $a1, $a1, 1           # Increment nrx right now so we dont need to read it again
    sw    $a1, 48($a0)          # Save incremented nrx

    lw    $a1, 20($a0)          # Read rx_tl
    nop
    addiu $k1, $a1, 1           # Increment RX_tail
    andi  $k1, $k1, 15          # It's a circular queue so: (rx_tl+1)%16 
    sw    $k1, 20($a0)          # Save new rx_tl

    add   $a0, $a1, $a0         # Get queue tail address (before the increment)
    
    lui   $a1, %hi(HW_uart_addr)
    ori   $a1, $a1, %lo(HW_uart_addr)
    lbu    $k1, 4($a1)           # Read data
    nop
    sb    $k1, 0($a0)           # Put data on RX_queue tail

    la  $2,x_IO_BASE_ADDR 
    sw  $a0,0($2)               # Print for debug



TX:
    andi  $a0, $k1, UART_tx_irq # Is this transmission?
    beq   $a0, $zero, END       #   no, end handler

    lui   $a0, %hi(Ud)
    ori   $a0, $a0, %lo(Ud)     # $a0 <- Ud

    lw    $a1, 52($a0)          # Read ntx

    addiu $k1, $zero, 16
    slt   $k1, $a1, $k1         # If ntx < 16 there's something on the queue
    beq   $k1, $zero, END      

    addiu $a1, $a1, 1           # Increment ntx
    sw    $a1, 52($a0)          # Save incremented ntx

    lw    $a1, 40($a0)          # Read tx_hd
    nop
    addiu $k1, $a1, 1           # Increment tx_hd: we've transmitted, there's space on the queue
    andi  $k1, $k1, 15          # It's a circular queue so: (tx_hd+1)%16
    sw    $k1, 40($a0)          # Save tx_hd

    addiu $a1, $a1, 24          # tx_hd position on tx_queue
    add   $a0, $a1, $a0         # tx_queue head address
    lbu   $a1, 0($a0)           # Read TX_queue head

    lui   $a0, %hi(HW_uart_addr)
    ori   $a0, $a0, %lo(HW_uart_addr)
    sb    $a1, 4($a0)           # Put data on UART

END:

