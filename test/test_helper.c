#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "unittest_defs.h"
#include "test_helper.h"

int debug_mode =0;

int test_assert_file_exist(const char* filename)
{
  FILE *fp;

  fp = fopen(filename, "r");
  if (fp == NULL) {
    fclose(fp);
    return(1);
  }
  return(0);
}

double get_preset_ucvm_surface(double y, double x) {
   if(y == -118.1 && x == 34.0) {
      return 55.827;
   }
   return 0;
}


/* Execute wfcvm_txt as a child process */
int run_wfcvm_txt(const char *cvmdir, const char *infile, const char *outfile)
{
  char currentdir[128];

//  printf("Running cmd: wfcvm_txt %s %s\n", infile, outfile);

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

int runVXWFCVM(const char *bindir, const char *cvmdir, 
	  const char *infile, const char *outfile)
{
  char currentdir[1280];
  char runpath[1280];
  char flags[1280];

  sprintf(runpath, "%s/run_vx_wfcvm.sh", bindir);

  if(debug_mode) { strcat(flags, "-d "); }

  /* Save current directory */
  getcwd(currentdir, 1280);
  
  /* Fork process */
  pid_t pid;
  pid = fork();
  if (pid == -1) {
    perror("fork");
    return(1);
  } else if (pid == 0) {
    /* Change dir to cvmdir */
    if (chdir(bindir) != 0) {
      printf("FAIL: Error changing dir in run_vx_wfcvm.sh\n");
      return(1);
    }

    if (strlen(flags) == 0) {
      execl(runpath, runpath, infile, outfile, (char *)0);
    } else {
      execl(runpath, runpath, flags, infile, outfile, (char *)0);
    }

    perror("execl"); /* shall never get to here */
    printf("FAIL: CVM exited abnormally\n");
    return(1);
  } else {
    int status;
    waitpid(pid, &status, 0);
    if (WIFEXITED(status)) {
      return(0);
    } else {
      printf("FAIL: CVM exited abnormally\n");
      return(1);
    }
  }

  return(0);
}

