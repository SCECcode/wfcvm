# Autoconf/Automake binaries and headers
lib_LIBRARIES = libwfcvm.a
bin_PROGRAMS = wfcvm_txt wfcvm_bin

# General compiler/linker flags
AM_CFLAGS = ${CFLAGS}
AM_LDFLAGS = ${LDFLAGS}
AM_FCFLAGS = ${FCFLAGS}

TARGETS = wfcvm wfcvm_txt libwfcvm.a

all: $(bin_PROGRAMS) $(lib_LIBRARIES)

wfcvm: wf_cvm3c.f
	${FC} ${FFLAGS} $^ -o $@

wfcvm_txt: wfcvm_main.f wfcvm_sub.f wfcvm_txt.f
	$(FC) $(AM_FCFLAGS) $^ -o $@

libwfcvm.a: wfcvm_sub.o
	$(AR) rcs $@ $^
	
wfcvm_sub.o: wfcvm_sub.f
	$(FC) $(AM_FCFLAGS) -o $@ -c $^

install: all
	mkdir -p ${prefix}
	mkdir -p ${libdir}
	mkdir -p ${includedir}
	mkdir -p ${prefix}/src
	cp libwfcvm.a ${libdir}
	cp wfcvm.h ${includedir}
	find ./* -maxdepth 0 ! -name libwfcvm.a ! -name '*.f' ! -name '*.o' ! -name 'Makefile*' ! -exec cp '{}' '${prefix}/src' \;

clean:
	rm -rf *.o *~ wfcvm_txt *.a
