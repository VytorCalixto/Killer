#include "cMIPS.h"

typedef struct control { // control register fields (uses only ls byte)
  int ign   : 24+3,      // ignore uppermost bits
    intTX   : 1,         // interrupt on TX buffer empty (bit 4)
    intRX   : 1,         // interrupt on RX buffer full (bit 3)
    speed   : 3;         // 4,8,16..256 tx-rx clock data rates  (bits 0..2)
} Tcontrol;

typedef struct status {  // status register fields (uses only ls byte)
  int s;
  // int ign   : 24,     // ignore uppermost bits
  //  ign7    : 1,       // ignored (bit 7)
  //  txEmpty : 1,       // TX register is empty (bit 6)
  //  rxFull  : 1,       // octet available from RX register (bit 5)
  //  int_TX_empt: 1,    // interrupt pending on TX empty (bit 4)
  //  int_RX_full: 1,    // interrupt pending on RX full (bit 3)
  //  ign2    : 1,       // ignored (bit 2)
  //  framing : 1,       // framing error (bit 1)
  //  overrun  : 1;      // overrun error (bit 0)
} Tstatus;

#define RXfull  0x00000020
#define TXempty 0x00000040


typedef union ctlStat {  // control + status on same address
  Tcontrol  ctl;         // write-only
  Tstatus   stat;        // read-only
} TctlStat;

typedef union data {     // data registers on same address
  int tx;                // write-only
  int rx;                // read-only
} Tdata;

typedef struct serial {
  TctlStat cs;           // control & status at address UART + 0
  Tdata    d;            // TX & RX registers at address UART + 4
} Tserial;

int proberx(void);       // retorna nrx
int probetx(void);       // retorna ntx
int iostat(void);        // retorna inteiro com status no byte menos sign
void ioctl(int);         // escreve byte menos sign no reg de controle
char getc(void);         // retorna caractere na fila, decrementa nrx
void putc(char);         // insere caractere na fila, decrementa ntx
int wrtc(char);          // escreve caractere diretamente em txreg
int enableInterr(void);  // habilita interrupcoes, retorna STATUS
int disableInterr(void); // desabilita interrupcoes, retorna STATUS

int main(void){
    int i;
    volatile int state;  // tell GCC not to optimize away code
    volatile Tserial *uart;
    volatile Tstatus status;
    Tcontrol ctrl;

    uart = (void *)IO_UART_ADDR; // bottom of UART address range

    ctrl.ign   = 0;
    ctrl.intTX = 0;
    ctrl.intRX = 1;
    ctrl.speed = 1;      // operate at 1/2 of the highest data rate
    uart->cs.ctl = ctrl;

    return 0;
}