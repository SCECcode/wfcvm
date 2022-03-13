# Autoconf/Automake binaries and headers
bin_PROGRAMS = unittest accepttest

# General compiler/linker flags
AM_CFLAGS = -DDYNAMIC_LIBRARY -Wall -g -std=c99 -D_LARGEFILE_SOURCE \
        -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 ${CFLAGS} -I../src
AM_LDFLAGS = ${LDFLAGS} -L../src -lwfcvm -lm 

TARGETS = unittest accepttest

# Dist sources
unittest_SOURCES = *.c *.h
accepttest_SOURCES = *.c *.h

.PHONY = run_unit run_accept

all: $(bin_PROGRAMS)

############################################
# Executables
############################################


accepttest: accepttest.o unittest_defs.o test_helper.o \
	test_grid_exec.o
	$(CC) -o $@ $^ $(AM_LDFLAGS)

run_accept: accepttest
	./run_accept
	
unittest: unittest.o unittest_defs.o test_helper.o \
	test_wfcvm_exec.o
	$(CC) -g -o $@ $^ $(AM_LDFLAGS)  

run_unit: unittest
	./run_unit
	
clean:
	rm -rf *.o accepttest unittest
	
install: all
	mkdir -p ${prefix}/test
	cp -R inputs ${prefix}/test
	cp -R ref ${prefix}/test
	cp accepttest ${prefix}/test
	cp unittest ${prefix}/test
