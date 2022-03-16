# Autoconf/Automake binaries and headers
lib_LIBRARIES = libwfcvm.a
bin_PROGRAMS = wfcvm_txt wfcvm

# General compiler/linker flags
AM_CFLAGS = ${CFLAGS} -fPIC 
AM_LDFLAGS = ${LDFLAGS} -lgfortran
AM_FCFLAGS = ${FCFLAGS} -fPIC
#AM_FCFLAGS = -fcheck=all -Wall -g -fbacktrace ${FCFLAGS} -fPIC

TARGETS = wfcvm wfcvm_txt libwfcvm.a libwfcvm.so

all: $(bin_PROGRAMS) $(lib_LIBRARIES) libwfcvm.so

vx_wfcvm : vx_wfcvm.o libwfcvm.a
	$(CC) -o $@ $^ $(AM_LDFLAGS)

wfcvm: wf_cvm3d.f
	${FC} ${FFLAGS} $^ -o $@

wfcvm_txt: wfcvm_main.f wfcvm_sub.f wfcvm_txt.f
	$(FC) $(AM_FCFLAGS) $^ -o $@

libwfcvm.a: wfcvm_sub.o wfcvm_static.o
	$(AR) rcs $@ $^

libwfcvm.so: wfcvm_sub.o wfcvm.o
	$(FC) -shared $(AM_CFLAGS) -o libwfcvm.so $^

wfcvm_sub.o: wfcvm_sub.f
	$(FC) $(AM_FCFLAGS) -o $@ -c $^

wfcvm.o: wfcvm.c
	$(CC) -fPIC -DDYNAMIC_LIBRARY -o $@ -c $^ $(AM_CFLAGS)

wfcvm_static.o: wfcvm.c
	$(CC) -o $@ -c $^ $(AM_CFLAGS)


install: all
	mkdir -p ${prefix}
	mkdir -p ${libdir}
	mkdir -p ${includedir}
	mkdir -p ${prefix}/src
	cp libwfcvm.a ${libdir}
	cp libwfcvm.so ${libdir}
	cp wfcvm.h ${includedir}
	find ./* -maxdepth 0 ! -name 'libwfcvm.*' ! -name '*.h' ! -name 'test*' ! -name 'wfcvm' ! -name '*.f' ! -name '*.o' ! -name 'Makefile*' ! -exec cp '{}' '${prefix}/src' \;

clean:
	rm -rf *.o *~ wfcvm_txt *.a
