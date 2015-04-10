//========================================================================
// UART receive functional test
// Linux computer must be connected via USB-serial (/dev/ttyUSB0)
//    and must run minicom @ 115.200 bps
// If all is wall, all typed at minicom's terminal are echoed on the LCD
//========================================================================


#include "cMIPS.h"

typedef struct control { // control register fields (uses only ls byte)
  int ign   : 24,        // ignore uppermost bits
    rts     : 1,         // Request to Send
    ign2    : 2,         // bits 6,5 ignored
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


#if 0
char s[32]; // = "the quick brown fox jumps over the lazy dog";
#else
// char s[32]; // = "               ";
#endif

int main(void) { // receive a string through the UART serial interface
                 // and write it to the LCD display
  volatile Tserial *uart;  // tell GCC not to optimize away code
  volatile Tstatus status;
  Tcontrol ctrl;
  int i,n;
  int state;
  char c, s[32];

  LCDinit();

  LCDtopLine();

  LCDput('c');
  LCDput('M');
  LCDput('I');
  LCDput('P');
  LCDput('S');
  LCDput(' ');
  LCDput('s');
  LCDput('a');
  LCDput('y');
  LCDput('s');
  LCDput(' ');
  LCDput('H');
  LCDput('I');
  LCDput('!');

  LCDbotLine();

  uart = (void *)IO_UART_ADDR; // bottom of UART address range

  ctrl.ign   = 0;
  ctrl.rts   = 0;
  ctrl.ign2  = 0;
  ctrl.intTX = 0;
  ctrl.intRX = 0;
  ctrl.speed = 3;
  uart->cs.ctl = ctrl;

  LCDput(':');
  LCDput(' ');

  n = 0;
  do {

    while ( ( (state = uart->cs.stat.s) & RXfull ) == 0 )
      ;
    c = (char)uart->d.rx;
    DSP7SEGput( state>>4 , 0, state & 0xf, 0);
    LCDput(c);

    // cmips_delay(12500000);
    n = n + 1;
    if ( n == 16 ){ 
      LCDbotLine();
      n = 0;
    }

  } while (1 == 1);

  return 0;

}
