# ifdef cMIPS
   #include "cMIPS.h"
#else
   #include <stdio.h>
#endif

char *memcpy2(char *dst, const char *src, int n) {
  int cnt;
  char *ret;

  ret = dst;
  cnt = (int)src % 4;
  while( (cnt > 0) && (n > 0) ) {
    *dst = *src;
    cnt--; n--;
    dst++; src++;
  } // src is now word aligned
  while ( n >= 4) {
    if ( ((int)dst % 4) == 0 ) { // dst aligned to word x00
      *((int *)dst) = *((int *)src);
    } else if ( ((int)dst % 2) == 0 ) { // dst aligned to short xx0
      *((short *)dst) = *((short *)src);
      *((short *)(dst+2)) = *((short *)(src+2));
    } else { // dst aligned to char
      *dst = *src;
      *((short *)(dst+1)) = *((short *)(src+1));
      *(dst+3) = *(src+3);
    }
    n-=4; src+=4; dst+=4;
  }
  while(n > 0) {
    *dst = *src;
    n--; dst++; src++;
  }
  return(ret);
}

void *memset(void *dst, const int val, int len) {
  register unsigned char *ptr = (unsigned char*)dst;
  int cnt;

  cnt = (int)ptr % 4;
  while( (cnt > 0) && (len > 0) ) {
    *ptr = (char)val;
    cnt--; len--;
    ptr++;
  } // ptr is now word aligned
  cnt = val | (val<<8) | (val<<16) | (val<<24);
  while (len >= 4) {
    *((int *)ptr) = cnt;
    len -= 4;
    ptr += 4;
  }
  while(len > 0) {
    *ptr = (char)val;
    len--;
    ptr++;
  }
  return(dst);
}


#define sSz 20
#define dSz 30

// char src[sSz] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
// char dst[dSz] = {255,255,255,255,255,255,255,255,255,255,255,255,255,
//		255,255,255,255,255,255,255,255,255,255,255,255,255,
//		255,255,255,129};

int main(void) {
  char src[sSz];
  char dst[dSz];

  char *vet;
  char *s,*d;
  int i,j,N;

  for (i=0; i<sSz; i++)
    src[i] = i+'a';

  for (i=0; i<dSz; i++)
    dst[i] = (char)255;
  dst[(dSz-1)] = (char)129;

#if 1

  for (j=1; j<=15; j++) {
    N=j; 
    s=src;
    d=dst;
    vet = memcpy2(d, s, N);
#ifdef cMIPS
    for (i=0; i<N; i++) { to_stdout(vet[i]); } ; to_stdout('\n');
#else
    for (i=0; i<N; i++) { printf("%c", vet[i]); } ; printf("\n");
#endif

  }

#endif

#if 1

  for (j=1; j<=15; j++) {
    N=j; 
    d=dst;
    vet = memset(d, (char)('c'+j), N);
#ifdef cMIPS
    for (i=0; i<N; i++) { to_stdout(vet[i]); } ; to_stdout('\n');
#else
    for (i=0; i<N; i++) { printf("%c", vet[i]); } ; printf("\n");
#endif


  }

#endif
  return(0);

};
