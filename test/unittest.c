#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include "unittest_defs.h"


int main (int argc, char *argv[])
{
  char *xmldir;

  if (argc == 2) {  
    xmldir = argv[1];
  } else {
    xmldir = NULL;
  }

  /* Run test suites */
  fprintf(stderr, "No unit tests currently defined\n");

  return 0;
}
