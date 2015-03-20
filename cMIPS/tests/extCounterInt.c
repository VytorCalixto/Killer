// Sieve of Eratostenes
// Counts number of primes smaller than MAX

#include "cMIPS.h"

#define MAX   100
#define FALSE 0
#define TRUE  ~FALSE

extern _counter_buff;

int p[MAX];

void main() {

  int i, k, iter;
  int num;

  _counter_buff = 0;   // variable where num interrupts is accumulated
  startCounter(200,TRUE);   // counter will interrupt after N cycles

  p[0] = 0;
  for (i = 1; i < MAX; i++)
    p[i] = TRUE;
  i = 2;

  while (i*i <= MAX) {
    if (p[i] == TRUE) {
      k = i + i;
      while (k < MAX) {
	p[k] = FALSE;
	k += i;
      }
    }
    i++;
  }
  num = 0;

  print(num);  // debugging only
  to_stdout('\n');

  for (i = 1; i < MAX; i++) {
    if (p[i] == TRUE) {
      ++num;
      print(i);  // 1 2 3 5 7 11 13 17 19 23 29 31 ...
      // 00000001 00000002 00000003 00000005 00000007 0000000b 0000000d
      //   00000011 00000013 00000017 0000001d 0000001f ...
    }
  }

  to_stdout('\n');
  print(num); // == x01a
  to_stdout('\n');
  print( _counter_buff );

}

