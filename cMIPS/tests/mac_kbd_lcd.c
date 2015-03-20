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
  int i;
  volatile int state;
  volatile Tserial *uart;  // tell GCC not to optimize away code
  volatile Tstatus status;
  Tcontrol ctrl;
  int c, k, s;

  LCDinit();

  LCDtopLine();

  LCDput(' ');
  LCDput('H');
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
  LCDput('!');

  LCDbotLine();


  while ( 1 == 1 ) {

    while( (k = KBDget()) == -1 ) {};  // wait for key

    DSP7SEGput(k, 1, 0, 0);

    LCDput(k + 0x30);
    // LCDput(0x20);

    cmips_delay(12500000);

    DSP7SEGput(0, 0, k, 1);

  }

  return 0;

}
