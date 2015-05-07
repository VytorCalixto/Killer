
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

#define LONG_STRING 1

#if LONG_STRING
char *dog = "\n\tthe quick brown fox jumps over the lazy dog\n";
char s[32];
#else
char s[32]; //  = "123";
#endif

int strcopy(const char *y, char *x)
{
  int i=0;
  while ( (*x++ = *y++) != '\0' ) // copia e testa final
    i = i+1;
  *x = '\0';
  return(i+1);
}



#define SPEED 0       // operate at the highest data rate

#define COUNTING ((SPEED+1)*100) // how long to wait for last bits to be sent out


int main(void) { // send a string through the UART serial interface
  int i;
  volatile int state, val;
  volatile Tserial *uart;  // tell GCC to not optimize away tests
  Tcontrol ctrl;

  volatile int *counter;        // address of counter

#if LONG_STRING
  i = strcopy(dog, s);
#else
  s[0] = '1';   s[1] = '2';   s[2] = '3';   s[3] = '\0';
#endif 

  uart = (void *)IO_UART_ADDR;  // UART's address

  counter = (int *)IO_COUNT_ADDR; // counter's address

  ctrl.speed = SPEED;
  ctrl.intTX = 0;  // no interrupts
  ctrl.intRX = 0;
  ctrl.ign2  = 0;
  ctrl.ign   = 0;
  ctrl.rts   = 1;
  uart->cs.ctl = ctrl;

  i = -1;
  do {

    i = i+1;
    // while ( (state = uart->cs.stat.txEmpty) != 1 )
    while ( ! ( (state = uart->cs.stat.s) & TXempty ) )
      ;
    uart->d.tx = (int)s[i];

  } while (s[i] != '\0');  // '\0' is transmitted in previous line


  // then wait until last char is sent out of the shift-register to return
  startCounter(COUNTING, 0);

  while ( (val=(readCounter() & 0x3fffffff)) < COUNTING )
    {}; 

  return val;  // so compiler won't optimize away the last loop
}
