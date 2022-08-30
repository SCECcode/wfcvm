#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <getopt.h>
#include "unittest_defs.h"
#include "test_helper.h"
#include "test_grid_exec.h"


int test_wfcvm_txt()
{
  char infile[128];
  char outfile[128];
  char reffile[128];
  char currentdir[128];

  printf("Test: wfcvm_txt executable w/ large grid\n");

  /* Save current directory */
  getcwd(currentdir, 128);

  sprintf(infile, "%s/inputs/%s", currentdir, "test-grid.in");
  sprintf(outfile, "%s/%s", currentdir, "test-grid.out");
  sprintf(reffile, "%s/ref/%s", currentdir, "test-grid-extract.ref");

  if (test_assert_int(run_wfcvm_txt("../src", infile, outfile), 0) != 0) {
    printf("wfcvm_txt failure\n");
    return(1);
  }

  /* Perform diff btw outfile and ref */
  if (test_assert_file(outfile, reffile) != 0) {
    return(1);
  }

  unlink(outfile);

  printf("PASS\n");
  return(0);
}



int suite_grid(const char *xmldir)
{
  suite_t suite;
  char logfile[256];
  FILE *lf = NULL;

  /* Setup test suite */
  strcpy(suite.suite_name, "suite_grid");
  suite.num_tests = 1;
  suite.tests = malloc(suite.num_tests * sizeof(test_t));
  if (suite.tests == NULL) {
    fprintf(stderr, "Failed to alloc test structure\n");
    return(1);
  }
  test_get_time(&suite.exec_time);

  /* Setup test cases */
  strcpy(suite.tests[0].test_name, "test_wfcvm_txt");
  suite.tests[0].test_func = &test_wfcvm_txt;
  suite.tests[0].elapsed_time = 0.0;

  if (test_run_suite(&suite) != 0) {
    fprintf(stderr, "Failed to execute tests\n");
    return(1);
  }

  if (xmldir != NULL) {
    sprintf(logfile, "%s/%s.xml", xmldir, suite.suite_name);
    lf = init_log(logfile);
    if (lf == NULL) {
      fprintf(stderr, "Failed to initialize logfile\n");
      return(1);
    }
    
    if (write_log(lf, &suite) != 0) {
      fprintf(stderr, "Failed to write test log\n");
      return(1);
    }
    
    close_log(lf);
  }

  free(suite.tests);

  return 0;
}
