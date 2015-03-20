#include "cMIPS.h"

typedef struct control { // control register fields (uses only ls byte)
  int ign   : 24+3,      // ignore uppermost bits
    intTX   : 1,         // interrupt on TX buffer empty (bit 4)
    intRX   : 1,         // interrupt on RX buffer full (bit 3)
    speed   : 3;         // 4,8,16..256 tx-rx clock data rates  (bits 0..2)
} Tcontrol;

typedef struct status { // status register fields (uses only ls byte)
  int s;
  // int ign   : 24,      // ignore uppermost bits
  //  ign7    : 1,        // ignored (bit 7)
  //  txEmpty : 1,        // TX register is empty (bit 6)
  //  rxFull  : 1,        // octet available from RX register (bit 5)
  //  int_TX_empt: 1,     // interrupt pending on TX empty (bit 4)
  //  int_RX_full: 1,     // interrupt pending on RX full (bit 3)
  //  ign2    : 1,        // ignored (bit 2)
  //  framing : 1,        // framing error (bit 1)
  //  overun  : 1;        // overun error (bit 0)
} Tstatus;

#define RXfull  0x00000020
#define TXempty 0x00000040


typedef union ctlStat { // control + status on same address
  Tcontrol  ctl;        // write-only
  Tstatus   stat;       // read-only
} TctlStat;

typedef union data {    // data registers on same address
  int tx;               // write-only
  int rx;               // read-only
} Tdata;

typedef struct serial {
  TctlStat cs;
  Tdata    d;
} Tserial;


extern int _uart_buff[16];

int main(void) { // receive a string through the UART serial interface
  volatile Tserial *uart;  // tell GCC not to optimize away code
  Tcontrol ctrl;
  volatile int *bfr = &(_uart_buff[0]);
  volatile char c;

  uart = (void *)IO_UART_BOT_ADDR; // bottom of UART address range

  ctrl.ign   = 0;
  ctrl.intTX = 0;
  ctrl.intRX = 1;
  ctrl.speed = 1;    // operate at 1/2 of the highest data rate
  uart->cs.ctl = ctrl;

  // handler sets flag=bfr[2] to 1 after new character is read;
  // this program resets the flag on fetching a new character from buffer

  c = (char)bfr[2];   // interrupt handler's flag
  
  do {
    while ( (c = (char)bfr[2]) == 0 ) 
      {};                 // nothing new
    c = (char)bfr[1];     // get new character
    bfr[2] = 0;           //   and reset flag
    to_stdout( (int)c );
  } while (c != '\0');    // end of string?

  return c;

}
