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
void Putc(char);            // inserts char in queue, decrements ntx
int ctoi(char);            // converts a character to an integer

void initUd();

extern UARTDriver Ud;
volatile Tserial *uart;

int main(){
    uart = (void *)IO_UART_ADDR; // bottom of UART address range
    Tcontrol ctrl;

    ctrl.ign   = 0;
    ctrl.intTX = 1;
    ctrl.intRX = 1;
    ctrl.speed = 2;        // operate at 1/2 of the highest data rate
    uart->cs.ctl = ctrl;

    initUd();
    volatile char c;
    
    while((c = getc()) != '\0') {
        if(c != EOF) {
            Putc(c);
        }
    }
    if(Ud.ntx < 16){
        disableInterr();
        uart->d.tx = Ud.tx_q[Ud.tx_hd];
        Ud.tx_hd = (Ud.tx_hd+1)%16;
        Ud.ntx++;
        enableInterr();
    }

    int cont;
    for(cont=0;cont<1000;cont++);  //Wait for the remote uart
    
    // while((c = getc()) != '\0') {
    //     if(c != EOF) {
    //         // while(!Putc(c)); // Wait till there's space on queue
    //         int n = 0;
    //         while(c != '\n' && c != '\0') {
    //             int h = ctoi(c);
    //             if(h != EOF) {
    //                 n = n*16 + h;         
    //             }
    //             c = getc();
    //         }
    //         //If it's a negative hex make it a negative integer as well
    //         n = 0x8000&n ? (int)(0x7FFF&n)-0x8000 : n;
    //         // print(n);
    //     }
    // }
    // Putc(c); // Sends EOF

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
    char c = EOF;
    if(Ud.nrx > 0){
        disableInterr();
        c = Ud.rx_q[Ud.rx_hd];
        Ud.rx_hd = (Ud.rx_hd+1)%16;
        Ud.nrx--;
        enableInterr();
    }
    return c;
}

void Putc(char c){
    if(Ud.ntx > 0){
        disableInterr();
        Ud.tx_q[Ud.tx_tl] = c;
        Ud.tx_tl = (Ud.tx_tl+1)%16;
        Ud.ntx--;
        enableInterr();
    }else{
        while(!(TXempty&uart->cs.stat.s));
        disableInterr();
        uart->d.tx = Ud.tx_q[Ud.tx_hd];
        Ud.tx_hd = (Ud.tx_hd+1)%16;
        Ud.ntx++;
        enableInterr();
        Putc(c);
    }
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