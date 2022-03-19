/* 
 * @file wfcvm.c
 * @brief Main file for WFCVM library.
 * @author - SCEC 
 * @version 
 *
 * @section DESCRIPTION
 *
 *
 */

#include "wfcvm.h"

/* Fortran constants */
#define WFCVM_FORTRAN_MODELDIR_LEN 128
#define WFCVM_FORTRAN_VERSION_LEN 64
/* Maximum number of points to query */
#define WFCVM_MAX_POINTS 1000000

/* Init flag */
int wfcvm_is_initialized = 0;

/* Buffers initialized flag */
int wfcvm_buf_init = 0;

/* Model conf */
wfcvm_configuration_t *wfcvm_configuration;

/* Query buffers */
int *wfcvm_index = NULL;
float *wfcvm_lon = NULL;
float *wfcvm_lat = NULL;
float *wfcvm_dep = NULL;
float *wfcvm_vp = NULL;
float *wfcvm_vs = NULL;
float *wfcvm_rho = NULL;

/*
 * Initializes the WFCVS plugin model within the UCVM framework. In order to initialize
 * the model, we must provide the UCVM install path and optionally a place in memory
 * where the model already exists.
 *
 * @param dir The directory in which UCVM has been installed.
 * @param label A unique identifier for the velocity model.
 * @return Success or failure, if initialization was successful.
 */
int wfcvm_init(const char *dir, const char *label) {

  char configbuf[512];
  int errcode=0;

  /* Fortran fixed string length */
  char modeldir[WFCVM_FORTRAN_MODELDIR_LEN];

  if (wfcvm_is_initialized) {
    fprintf(stderr, "Model %s is already initialized\n", label);
    return(UCVM_CODE_ERROR);
  }

// Initialize variables.
  wfcvm_configuration = calloc(1, sizeof(wfcvm_configuration_t));

  // Configuration file location when built with UCVM
  sprintf(configbuf, "%s/model/%s/data/config", dir, label);


  // Read the wfcvm_configuration file.
  if (wfcvm_read_configuration(configbuf, wfcvm_configuration) != UCVM_CODE_SUCCESS) {
    wfcvm_print_error("Model configuration can not be accessed.");
    return(UCVM_CODE_ERROR);
  }

 // model's data location
  int pathlen=strlen(dir)+strlen(label)+strlen(wfcvm_configuration->model_dir); // throw in some extra
  if (pathlen >= WFCVM_FORTRAN_MODELDIR_LEN) {
    wfcvm_print_error("Config path too long.");
    return(UCVM_CODE_ERROR);
  }

  sprintf(modeldir, "%s/model/%s/data/%s/", dir, label, wfcvm_configuration->model_dir);

  wfcvm_init_(modeldir, &errcode,WFCVM_FORTRAN_MODELDIR_LEN);
  if (errcode != 0) {
    fprintf(stderr, "Failed to init WFCVM\n");
    return(UCVM_CODE_ERROR);
  }

  /* Allocate buffers */
  if (wfcvm_buf_init == 0) {
    wfcvm_index = malloc(WFCVM_MAX_POINTS*sizeof(int));
    wfcvm_lon = malloc(WFCVM_MAX_POINTS*sizeof(float));
    wfcvm_lat = malloc(WFCVM_MAX_POINTS*sizeof(float));
    wfcvm_dep = malloc(WFCVM_MAX_POINTS*sizeof(float));
    wfcvm_vp = malloc(WFCVM_MAX_POINTS*sizeof(float));
    wfcvm_vs = malloc(WFCVM_MAX_POINTS*sizeof(float));
    wfcvm_rho = malloc(WFCVM_MAX_POINTS*sizeof(float));
    wfcvm_buf_init = 1;
  }

  wfcvm_is_initialized = 1;

  return(UCVM_CODE_SUCCESS);
}

/**
 * Reads the wfcvm_configuration file describing the various properties of WFCVM and populates
 * the wfcvm_configuration struct. This assumes wfcvm_configuration has been "calloc'ed" and validates
 * that each value is not zero at the end.
 *
 * @param file The wfcvm_configuration file location on disk to read.
 * @param config The wfcvm_configuration struct to which the data should be written.
 * @return Success or failure, depending on if file was read successfully.
 */
int wfcvm_read_configuration(char *file, wfcvm_configuration_t *config) {
  FILE *fp = fopen(file, "r");
  char key[40];
  char value[80];
  char line_holder[128];

  // If our file pointer is null, an error has occurred. Return fail.
  if (fp == NULL) {
    wfcvm_print_error("Could not open the wfcvm_configuration file.");
    return UCVM_CODE_ERROR;
  }

  // Read the lines in the wfcvm_configuration file.
  while (fgets(line_holder, sizeof(line_holder), fp) != NULL) {
    if (line_holder[0] != '#' && line_holder[0] != ' ' && line_holder[0] != '\n') {
      sscanf(line_holder, "%s = %s", key, value);

      // Which variable are we editing?
      if (strcmp(key, "utm_zone") == 0) config->utm_zone = atoi(value);
      if (strcmp(key, "model_dir") == 0) sprintf(config->model_dir, "%s", value);
    }
  }

  // Have we set up all wfcvm_configuration parameters?
  if (config->utm_zone == 0) {
    wfcvm_print_error("One wfcvm_configuration parameter not specified. Please check your wfcvm_configuration file.");
    return UCVM_CODE_ERROR;
  }

  fclose(fp);

  return UCVM_CODE_SUCCESS;
}


/*
 * Called when the model is being discarded. Free all variables.
 *
 * @return UCVM_CODE_SUCCESS
 */

int wfcvm_finalize()
{
  if (wfcvm_buf_init == 1) {
    free(wfcvm_index);
    free(wfcvm_lon);
    free(wfcvm_lat);
    free(wfcvm_dep);
    free(wfcvm_vp);
    free(wfcvm_vs);
    free(wfcvm_rho);
    wfcvm_buf_init = 0;
  }
  wfcvm_is_initialized = 0;
  return(UCVM_CODE_SUCCESS);
}


/*
 * Returns the version information.
 *
 * @param ver Version string to return.
 * @param len Maximum length of buffer.
 * @return Zero
 */
int wfcvm_version(char *ver, int len) {
  int errcode;
  /* Fortran fixed string length */
  char verstr[WFCVM_FORTRAN_VERSION_LEN];

  wfcvm_version_(verstr, &errcode,WFCVM_FORTRAN_VERSION_LEN);
  if (errcode != 0) {
    fprintf(stderr, "Failed to retrieve version from WFCVM\n");
    return(UCVM_CODE_ERROR);
  }

  strncpy(ver, verstr, len);
  return(UCVM_CODE_SUCCESS);
}

/**
 * setparam WFCVM
 *
 * @param points The points at which the queries will be made.
 */
int wfcvm_setparam(int id, int param, ...) {

  va_list ap;
  int zmode;

  va_start(ap, param);
  switch (param) {
   case UCVM_PARAM_QUERY_MODE:
      zmode = va_arg(ap,int);
      switch (zmode) {
        case UCVM_COORD_GEO_DEPTH:
        case UCVM_COORD_GEO_ELEV:
          /* point from ucvm is always for depth */
          break;
        default:
          wfcvm_print_error("Unsupported coord type\n");
          return UCVM_CODE_ERROR;
          break;
       }
       break;
  }
  va_end(ap);

  return(UCVM_CODE_SUCCESS);
}



/**
 * Queries WFCVM at the given points and returns the data that it finds.
 *
 * @param points The points at which the queries will be made.
 * @param data The data that will be returned (Vp, Vs, density, Qs, and/or Qp).
 * @param numpoints The total number of points to query.
 * @return UCVM_CODE_SUCCESS or UCVM_CODE_ERROR.
 */
int wfcvm_query(wfcvm_point_t *pnt, wfcvm_properties_t *data, int numpoints) {

  int i, j;
  int nn = 0;
  double depth;
  int errcode = 0;

  if (wfcvm_buf_init == 0) {
    wfcvm_print_error("Model data is inaccessible");
    return(UCVM_CODE_ERROR);
  }

  nn = 0;
  for (i = 0; i < numpoints; i++) {

      //depth = data[i].depth + data[i].shift_cr;
      depth = pnt[i].depth;

      if (depth >= 0.0) {
        /* Query point */
        wfcvm_index[nn] = i;
        wfcvm_lon[nn] = (float)(pnt[i].longitude);
        wfcvm_lat[nn] = (float)(pnt[i].latitude);
        wfcvm_dep[nn] = (float)(depth);
        wfcvm_vp[nn] = 0.0;
        wfcvm_vs[nn] = 0.0;
        wfcvm_rho[nn] = 0.0;
        nn++;
        if (nn == WFCVM_MAX_POINTS) {
          wfcvm_query_(&nn, wfcvm_lon, wfcvm_lat, wfcvm_dep, 
                     wfcvm_vp, wfcvm_vs, wfcvm_rho, &errcode);
          
          if (errcode == 0) {
            for (j = 0; j < nn; j++) {
              data[wfcvm_index[j]].vp = (double)wfcvm_vp[j];
              data[wfcvm_index[j]].vs = (double)wfcvm_vs[j];
              data[wfcvm_index[j]].rho = (double)wfcvm_rho[j];
            }
          }
          nn = 0;
        }
        } else {
          // skip the ones that has negative depth
      }
  }

  if (nn > 0) {
    wfcvm_query_(&nn, wfcvm_lon, wfcvm_lat, wfcvm_dep, 
             wfcvm_vp, wfcvm_vs, wfcvm_rho, &errcode);
    if (errcode == 0) {
      for (j = 0; j < nn; j++) {
        data[wfcvm_index[j]].vp = (double)wfcvm_vp[j];
        data[wfcvm_index[j]].vs = (double)wfcvm_vs[j];
        data[wfcvm_index[j]].rho = (double)wfcvm_rho[j];
      }
    }
  }

  return(UCVM_CODE_SUCCESS);
}


/**
 * Prints the error string provided.
 *
 * @param err The error string to print out to stderr.
 */
void wfcvm_print_error(char *err) {
  fprintf(stderr, "An error has occurred while executing WFCVM . The error was:\n\n");
  fprintf(stderr, "%s", err);
  fprintf(stderr, "\n\nPlease contact software@scec.org and describe both the error and a bit\n");
  fprintf(stderr, "about the computer you are running WFCVM on (Linux, Mac, etc.).\n");
}


// The following functions are for dynamic library mode. If we are compiling
// a static library, these functions must be disabled to avoid conflicts.
#ifdef DYNAMIC_LIBRARY

/**
 * Init function loaded and called by the UCVM library. Calls wfcvm_init.
 *
 * @param dir The directory in which UCVM is installed.
 * @return Success or failure.
 */
int model_init(const char *dir, const char *label) {
	return wfcvm_init(dir, label);
}

/**
 * Query function loaded and called by the UCVM library. Calls wfcvm_query.
 *
 * @param points The basic_point_t array containing the points.
 * @param data The basic_properties_t array containing the material properties returned.
 * @param numpoints The number of points in the array.
 * @return Success or fail.
 */
int model_query(wfcvm_point_t *points, wfcvm_properties_t *data, int numpoints) {
	return wfcvm_query(points, data, numpoints);
}

/**
 * Finalize function loaded and called by the UCVM library. Calls wfcvm_finalize.
 *
 * @return Success
 */
int model_finalize() {
	return wfcvm_finalize();
}

/**
 * Version function loaded and called by the UCVM library. Calls wfcvm_version.
 *
 * @param ver Version string to return.
 * @param len Maximum length of buffer.
 * @return Zero
 */
int model_version(char *ver, int len) {
	return wfcvm_version(ver, len);
}

/**
 * Setparam function loaded and called by the UCVM library. Calls wfcvm_setparam.
 *
 * @param id  don'care
 * @param param
 * @param val, it is actually just 1 int
 * @return Success or fail.
 */
int model_setparam(int id, int param, int val) {
        return wfcvm_setparam(id, param, val);
}



int (*get_model_init())(const char *, const char *) {
        return &wfcvm_init;
}
int (*get_model_query())(wfcvm_point_t *, wfcvm_properties_t *, int) {
         return &wfcvm_query;
}
int (*get_model_finalize())() {
         return &wfcvm_finalize;
}
int (*get_model_version())(char *, int) {
         return &wfcvm_version;
}
int (*get_model_setparam())(int, int, ...) {
         return &wfcvm_setparam;
}

#endif
