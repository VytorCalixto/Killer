// Testing the external counter is difficult because it counts clock cycles
// rather than instructions -- if the io/instruction latencies change then
// the simulation output also changes and comparisons become impossible.

#include "cMIPS.h"

#define N 4
#define CNT_VALUE 0x40000040    // set count to 64 cycles

void main(void) {
  int i;
  volatile int *counter;        // address of counter

  counter = (int *)IO_COUNT_ADDR;

  *counter = CNT_VALUE;

  for (i=0; i < N; i++) {       // repeat N rounds
    print(i);                   // print number of round
    *counter = (int)(CNT_VALUE + (i<<2));  // num cycles increases with i
    do {
      print((int)*counter);     // print out count value
    } while ( (*counter & 0x3fffffff) < (CNT_VALUE & 0x3ffffff) );    // done?
    to_stdout('\n');
  }

}
