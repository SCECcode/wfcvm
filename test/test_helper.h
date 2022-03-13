#ifndef TEST_HELPER_H
#define TEST_HELPER_H

int test_assert_file_exist(const char* filename);

double get_preset_ucvm_surface(double y, double x);

/* Execute wfcvm_txt as a child process */
int run_wfcvm_txt(const char *cvmdir, const char *infile, const char *outfile);


#endif
