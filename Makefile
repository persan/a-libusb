
all:clean compile Makefile.inc
include Makefile.inc
Makefile.inc:Makefile
	echo prefix=$(shell cd $(dir $(shell which gnatls))/..;pwd) >${@}
	echo _includedir=\${INSTALL_DIR}/\${prefix}/include/usb-ada >>${@}
	echo _libdir=\${INSTALL_DIR}/\${prefix}/lib/usb-ada >>${@}
	echo _gprdir=\${INSTALL_DIR}/\${prefix}/lib/gnat >>${@}

setup:Makefile.inc

compile:
	gprbuild -p -P usb -XLIBRARY_TYPE=static
	gprbuild -p -P usb -XLIBRARY_TYPE=relocatable

clean:
	rm -rf lib .obj

install:
	mkdir -p ${_includedir}  ${_libdir}
	cp src/*.ad? ${_includedir}
	cp -r lib/usb-ada/* ${_libdir}
	cp usb.gpr.in ${_gprdir}/usb.gpr

uninstall:
	rm -rf ${_includedir}  ${_libdir}  ${_gprdir}/usb.gpr
