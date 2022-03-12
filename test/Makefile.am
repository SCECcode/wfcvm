# Autoconf/Automake binaries and headers
bin_PROGRAMS = unittest accepttest

# General compiler/linker flags
AM_CFLAGS = ${CFLAGS} -I../src
AM_LDFLAGS = ${LDFLAGS} -L../src -lwfcvm -lm -gfortran

TARGETS = unittest accepttest

all: $(bin_PROGRAMS)

accepttest: unittest.o unittest_defs.o test_helper.o
	$(CC) -o $@ $^ $(AM_CFLAGS)
	
unittest: accepttest.o unittest_defs.o test_helper.o test_grid.o
	$(CC) -o $@ $^ $(AM_CFLAGS)  
	
clean:
	rm -rf *.o accepttest unittest
	
install: all
	mkdir -p ${prefix}/test
	cp test-extract.ref ${prefix}/test
	cp test-grid.in ${prefix}/test
	cp accepttest ${prefix}/test
	cp unittest ${prefix}/test
