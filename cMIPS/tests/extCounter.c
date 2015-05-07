// Testing the external counter is difficult because it counts clock cycles
// rather than instructions -- if the io/instruction latencies change then
// the simulation output also changes and comparisons become impossible.

#include "cMIPS.h"

#define FALSE (0==1)
#define TRUE  ~(FALSE)

#define N 4
#define CNT_VALUE 0x40000040    // set count to 64 cycles

void main(void) {
  int i, increased, new, old;


  startCounter(CNT_VALUE, 0);  // no interrupts

  for (i=0; i < N; i++) {       // repeat N rounds
    print(i);                   // print number of round

    startCounter((CNT_VALUE + (i<<2)), 0);  // num cycles increases with i

    increased = TRUE;
    old = 0;

    do {

      if ( (new=readCounter()) > old) {
	increased = increased & TRUE;
	old = new;
      } else {
	increased = FALSE;
      }

    } while ( (readCounter() & 0x3fffffff) < (CNT_VALUE & 0x3ffffff) );    // done?

    if (increased) {
      to_stdout('o');
      to_stdout('k');
    } else {
      to_stdout('e');
      to_stdout('r');
      to_stdout('r');
    }

    to_stdout('\n');
  }

}
