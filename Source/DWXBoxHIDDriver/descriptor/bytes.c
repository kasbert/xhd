
#include <stdio.h>
#include <fcntl.h>

int main (int argc, char**argv) {

  int col;
  int count;
  unsigned char byte;

  count = 0;
  col = 0;
  while (1 == read(0, &byte, 1)) {

    if ( (col++ % 16) == 0)
      printf ("\n");
    
    printf ("0x%.2x,", byte);
    
    count++;
  }

  printf ("\n%d bytes",  count);
  
  return 0;
}
