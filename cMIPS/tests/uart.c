#include "cMIPS.h"

typedef struct control {   // control register fields (uses only ls byte)
    int ign   : 24+3,      // ignore uppermost bits
        intTX : 1,         // interrupt on TX buffer empty (bit 4)
        intRX : 1,         // interrupt on RX buffer full (bit 3)
        speed : 3;         // 4,8,16..256 tx-rx clock data rates  (bits 0..2)
} Tcontrol;

typedef struct status {    // status register fields (uses only ls byte)
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

typedef union ctlStat {    // control + status on same address
    Tcontrol  ctl;         // write-only
    Tstatus   stat;        // read-only
} TctlStat;

typedef union data {       // data registers on same address
    int tx;                // write-only
    int rx;                // read-only
} Tdata;

typedef struct serial {
    TctlStat cs;           // control & status at address UART + 0
    Tdata    d;            // TX & RX registers at address UART + 4
} Tserial;

typedef struct UARTDriver{
    char rx_q[16];         // reception queue
    int rx_hd;             // reception queue head index
    int rx_tl;             // reception queue tail index
    char tx_q[16];         // transmission queue
    int tx_hd;             // transmission queue head index
    int tx_tl;             // transmission queue tail index
    int nrx;               // characters in RX_queue
    int ntx;               // spaces left in TX_queue
} UARTDriver;

#define EOF -1

int proberx(void);         // returns nrx
int probetx(void);         // returns ntx
int iostat(void);          // returns integer with status at lsb
void ioctl(int);           // write lsb in control register
char getc(void);           // returns char in queue, decrements nrx
int Putc(char);            // inserts char in queue, decrements ntx
int ctoi(char);            // converts a character to an integer

void initUd();

extern UARTDriver Ud;
volatile Tserial *uart;

int main(){
    int i;
    volatile int state;    // tell GCC not to optimize away code
    volatile Tstatus status;
    volatile char c;
    uart = (void *)IO_UART_ADDR; // bottom of UART address range
    Tcontrol ctrl;


    ctrl.ign   = 0;
    ctrl.intTX = 0;
    ctrl.intRX = 1;
    ctrl.speed = 2;        // operate at 1/2 of the highest data rate
    uart->cs.ctl = ctrl;

    initUd();

    c = getc();
    while(c != '\0') {
        if(c != EOF) {
            int n = 0;
            while(c != '\n' && c != '\0') {
                int h = ctoi(c);
                if(h != EOF) {
                    n = n*16 + h;         
                }
                c = getc();
            }
            print(n);
            //while(!Putc(c)); // Wait till there's space on queue
        }
        c = getc();
    }
    Putc(c); // Sends EOF

    return 0;
}

void initUd(){
    Ud.rx_hd = 0;
    Ud.rx_tl = 0;
    Ud.tx_hd = 0;
    Ud.tx_tl = 0;
    Ud.nrx = 0;
    Ud.ntx = 16;
}

char getc(){
    char c;
    if(Ud.nrx > 0){
        // print(1);
        // print(Ud.nrx);
        c = Ud.rx_q[Ud.rx_hd];
        Ud.rx_hd = (Ud.rx_hd+1)%16;
        disableInterr();
        Ud.nrx--;
        enableInterr();
    }else{
        //print(2);
        c = EOF;
    }
    return c;
}

int Putc(char c){
    int sent;
    if(Ud.ntx == 16) {
        uart->d.tx = c;
        return 1;
    }

    if(Ud.ntx > 0){
        Ud.tx_q[Ud.tx_tl] = c;
        Ud.tx_tl = (Ud.tx_tl+1)%16;
        disableInterr();
        Ud.ntx--;
        enableInterr();
        sent = 1;
    }else{
        sent = 0;
    }
    return sent;
}

int proberx(){
    return Ud.nrx;
}

int probetx(){
    return Ud.ntx;
}

int ctoi(char c) {
    // If it's a number
    if(c >=0x30 && c < 0x3a) {
        return ((int) c) - 0x30;
    }

    // If it's an uppercase letter
    if(c >= 0x41 && c < 0x47) {
        return ((int) c) - 0x37; // 0x40 - 0xa
    }

    // If it's a lowercase letter
    if(c >= 0x61 && c < 0x67) {
        return ((int) c) - 0x57; //0x60 - 0xa
    }

    return EOF;
}