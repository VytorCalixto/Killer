// test references to unaligned data references

/*---------------------------------------------------------------------------*/
#include "cMIPS.h"

#ifndef cMIPS
  #include <stdio.h>
#endif

#define BSZ 16

unsigned short bsh[BSZ];
unsigned int   bin[BSZ];

/*---------------------------------------------------------------------------*/

#ifdef cMIPS
  extern void exit(int);
  extern void print(int);
  extern int readInt(int *);
  extern void writeInt(int);
#endif

void main() {
    
  int i;
  short *shptr;
  int   *inptr;

  shptr = &(bsh[0]);
  
  *shptr = 1;
  for(i=1; i < BSZ; i++) {
    *(shptr+i) = *(shptr+i - 1) + 1;
  }

  inptr = &(bin[0]);
  
  *inptr = 1;
  for(i=1; i < BSZ; i++) {
    *(inptr+i) = *(inptr+i - 1) + 1;
  }

  shptr = &(bsh[0]);
  inptr = &(bin[0]);

  // force unaligned LOAD reference to short
  // print((int)*(short *)((int)shptr+3));

  // OR

  // force unaligned LOAD reference to integer
  // print((int)*(int *)((int)inptr+3));

  // OR

  // force unaligned STORE reference to short
  *((short *)((int)shptr+3)) = 7;


  // OR
  // make code behave reasonably

  for(i=0; i<BSZ; i++) {
#ifdef cMIPS
    // print((int)*(shptr + i));
    // print(*(inptr + i));
#else
    printf("%08x\n%08x\n",
	   ((unsigned int)bsh[i], bin[i]);
#endif
  }

}
