#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "unittest_defs.h"
#include "test_helper.h"


/* Execute wfcvm_txt as a child process */
int run_wfcvm_txt(const char *cvmdir, const char *infile, const char *outfile)
{
  char currentdir[128];

  printf("Running cmd: wfcvm_txt %s %s\n", infile, outfile);

  /* Save current directory */
  getcwd(currentdir, 128);
  
  /* Fork process */
  pid_t pid;
  pid = fork();
  if (pid == -1) {
    perror("fork");
    return(1);
  } else if (pid == 0) {
    /* Change dir to cvmdir */
    if (chdir(cvmdir) != 0) {
      printf("FAIL: Error changing dir in run_wfcvm_txt\n");
      return(1);
    }

    execl( "./run_wfcvm_txt.sh", "./run_wfcvm_txt.sh", infile, outfile, 
	   (char *)0);
    perror("execl"); /* shall never get to here */
    printf("FAIL: WFCVM exited abnormally\n");
    return(1);
  } else {
    int status;
    waitpid(pid, &status, 0);
    if (WIFEXITED(status)) {
      return(0);
    } else {
      printf("FAIL: WFCVM exited abnormally\n");
      return(1);
    }
  }

  return(0);
}
