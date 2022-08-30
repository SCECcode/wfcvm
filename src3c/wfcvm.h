#ifndef WFCVM_H
#define WFCVM_H

/* Initializer */
void wfcvm_init_(char *modeldir, int *errcode);

/* Get version ID. Version string buffer must be 64 bytes in size */
void wfcvm_version_(char *ver, int *errcode);

/* Query WFCVM */
void wfcvm_query_(int *nn, 
		  float *rlon, float *rlat,float *rdep,
		  float *alpha, float *beta, float *rho,
		  int *errcode);


#endif
