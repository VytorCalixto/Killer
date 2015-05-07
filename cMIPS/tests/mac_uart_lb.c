//-------------------------------------------------------------------
// loop-back test
//   UART's input must be connected to UART's output for this to work
//-------------------------------------------------------------------

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



int strcopy(const char *y, char *x) {
  int i=0;
  while ( (*x++ = *y++) != '\0' ) // copy and check end-of-string
    i = i+1;
  *x = '\0';
  return(i+1);
}

// to remove code not needed for debugging at the simulator -> SYNTHESIS=0
#define SYNTHESIS 1

int main(void) { // receive a string through the UART, in loop back
                 // and write it to the LCD display
  volatile Tserial *uart;  // tell GCC not to optimize away code
  volatile Tstatus status;
  Tcontrol ctrl;
  int i,n;
  int state;
  char s,r;

#if SYNTHESIS
  LCDinit();

  LCDtopLine();

  LCDput(' ');
  LCDput('h');
  LCDput('e');
  LCDput('l');
  LCDput('l');
  LCDput('o');
  LCDput(' ');
  LCDput('w');
  LCDput('o');
  LCDput('r');
  LCDput('l');
  LCDput('d');

  LCDbotLine();
#else
  to_stdout('\n');
#endif

  uart = (void *)IO_UART_ADDR; // bottom of UART address range

  ctrl.ign   = 0;
  ctrl.rts   = 0;
  ctrl.ign2  = 0;
  ctrl.intTX = 0;
  ctrl.intRX = 0;
  ctrl.speed = 2;
  uart->cs.ctl = ctrl;

  s = '0';
  do {

    while ( ( (state = uart->cs.stat.s) & TXempty ) == 0 )
      { };
    uart->d.tx = (int)s;

    while ( ( (state = uart->cs.stat.s) & RXfull ) == 0 )
      { };
    r = (char)uart->d.rx;

#if SYNTHESIS
    LCDput( r );

    DSP7SEGput( state>>4 , 0, state & 0xf, 0);

    cmips_delay(25000000);
#else
    to_stdout(r);
#endif

    s = (char)((int)s +1);

  } while (s != ':');

#if SYNTHESIS
  LCDput( ' ' );
  LCDput( 'z' );

  do { } while (1 == 1);
#else
    to_stdout('\n');
    to_stdout('\n');
#endif

  return 0;

}
