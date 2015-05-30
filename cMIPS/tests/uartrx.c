#include "cMIPS.h"

typedef struct control { // control register fields (uses only ls byte)
  int ign   : 24,        // ignore uppermost bits
    rts     : 1,         // Request to Send out (bit 7)
    ign2    : 2,         // bits 6,5 ignored
    intTX   : 1,         // interrupt on TX buffer empty (bit 4)
    intRX   : 1,         // interrupt on RX buffer full (bit 3)
    speed   : 3;         // 4,8,16..256 tx-rx clock data rates  (bits 0..2)
} Tcontrol;

typedef struct status { // status register fields (uses only ls byte)
#if 0
  int s;
#else
  int ign : 24,       // ignore uppermost 3 bytes
  cts     : 1,        // Clear To Send inp=1 (bit 7)
  txEmpty : 1,        // TX register is empty (bit 6)
  rxFull  : 1,        // octet available from RX register (bit 5)
  int_TX_empt: 1,     // interrupt pending on TX empty (bit 4)
  int_RX_full: 1,     // interrupt pending on RX full (bit 3)
  ign2    : 1,        // ignored (bit 2)
  framing : 1,        // framing error (bit 1)
  overun  : 1;        // overun error (bit 0)
#endif
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
char s[32]; // = "               ";
#endif

int main(void) { // receive a string through the UART serial interface
  int i;
  volatile int state;
  volatile Tserial *uart;  // tell GCC not to optimize away code
  volatile Tstatus status;
  Tcontrol ctrl;

  uart = (void *)IO_UART_ADDR; // bottom of UART address range

  ctrl.ign   = 0;
  ctrl.rts   = 1;
  ctrl.ign2  = 0;
  ctrl.intTX = 0;
  ctrl.intRX = 0;
  ctrl.speed = 1;   // operate at the second highest data rate
  uart->cs.ctl = ctrl;

  i = -1;

  do {
    i = i+1;

    //  while ( ! ( (state = uart->cs.stat.s) & RXfull ) )
    while ( (state = (int)uart->cs.stat.rxFull) == 0 )
      if (state == 0) cmips_delay(1); // just do something with state
    s[i] = (char)uart->d.rx;
    to_stdout( s[i] );

  } while (s[i] != '\0');

  return 0;

}
