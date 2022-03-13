# Autoconf/Automake binaries and headers
bin_PROGRAMS = unittest accepttest

# General compiler/linker flags
AM_CFLAGS = ${CFLAGS} -I../src
AM_LDFLAGS = ${LDFLAGS} -L../src -lwfcvm -lm -gfortran

TARGETS = unittest accepttest

# Dist sources
unittest_SOURCES = *.c *.h
accepttest_SOURCES = *.c *.h

.PHONY = run_unit run_accept

all: $(bin_PROGRAMS)

############################################
# Executables
############################################


accepttest: unittest.o unittest_defs.o test_helper.o \
	test_grid.o
	$(CC) -o $@ $^ $(AM_LDFLAGS)

run_accept: accepttest
	./run_accept
	
unittest: accepttest.o unittest_defs.o test_helper.o \
	test_wfcvm_exec.o
	$(CC) -o $@ $^ $(AM_LDFLAGS)  

run_unit: unittest
	./run_unit
	
clean:
	rm -rf *.o accepttest unittest
	
install: all
	mkdir -p ${prefix}/test
	cp test-extract.ref ${prefix}/test
	cp test-grid.in ${prefix}/test
	cp accepttest ${prefix}/test
	cp unittest ${prefix}/test
