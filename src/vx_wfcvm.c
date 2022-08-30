/*
 * @file vx_wfcvm.c
 * @brief Bootstraps the test framework for the WFCVM library.
 * @author - SCEC
 * @version 1.0
 *
 * Tests the WFCVM library by loading it and executing the code as
 * UCVM would.
 *
 */

#include <getopt.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "wfcvm.h"

int wfcvm_debug=0;

int _compare_double(double f1, double f2) {
  double precision = 0.00001;
  if (((f1 - precision) < f2) && ((f1 + precision) > f2)) {
    return 1;
    } else {
      return 0;
  }
}

/* Usage function */
void usage() {
  printf("     vx_wfcvm - (c) SCEC\n");
  printf("Extract velocities from a WFCVM\n");
  printf("\tusage: vx_wfcvm [-d][-h] < file.in\n\n");
  printf("Flags:\n");
  printf("\t-d enable debug/verbose mode\n\n");
  printf("\t-h usage\n\n");
  printf("Output format is:\n");
  printf("\tvp vs rho\n\n");
  exit (0);
}

extern char *optarg;
extern int optind, opterr, optopt;

/**
 * Initializes and WFCVM in standalone mode with ucvm plugin 
 * api.
 *
 * @param argc The number of arguments.
 * @param argv The argument strings.
 * @return A zero value indicating success.
 */
int main(int argc, char* const argv[]) {

	// Declare the structures.
	wfcvm_point_t pt;
	wfcvm_properties_t ret;
        int rc;
        int opt;


        /* Parse options */
        while ((opt = getopt(argc, argv, "dh")) != -1) {
          switch (opt) {
          case 'd':
            wfcvm_debug=1;
            break;
          case 'h':
            usage();
            exit(0);
            break;
          default: /* '?' */
            usage();
            exit(1);
          }
        }

	// Initialize the model. 
        // try to use Use UCVM_INSTALL_PATH
        char *envstr=getenv("UCVM_INSTALL_PATH");
        if(envstr != NULL) {
	   assert(wfcvm_init(envstr, "wfcvm") == 0);
           } else {
	     assert(wfcvm_init("..", "wfcvm") == 0);
        }
	printf("Loaded the model successfully.\n");

        char line[1001];
        while (fgets(line, 1000, stdin) != NULL) {
           if(line[0]=='#') continue; // comment line
           if (sscanf(line,"%lf %lf %lf",
               &pt.longitude,&pt.latitude,&pt.depth) == 3) {

	      rc=wfcvm_query(&pt, &ret, 1);
              if(rc == 0) {
                printf("vs : %lf vp: %lf rho: %lf\n",ret.vs, ret.vp, ret.rho);
                } else {
                   printf("BAD: %lf %lf %lf\n",pt.longitude, pt.latitude, pt.depth);
              }
              } else {
                 break;
           }
        }

	assert(wfcvm_finalize() == 0);
	printf("Model closed successfully.\n");

	return 0;
}
