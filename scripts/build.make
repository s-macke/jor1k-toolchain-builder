gmp_VERSION = 4.3.2
mpfr_VERSION = 2.4.2
mpc_VERSION = 0.8.1


buildtools: gmp mpfr mpc binutils gcc

gmp mpfr mpc:
	$(call extractpatch,$@,$($@_VERSION))

gcc: 
	mkdir -p src/build-gcc
	touch $(SYSROOT)/usr/include/fenv.h
	rm -rf src/build-gcc/*
	ln -sf ../gmp src/or1k-gcc/gmp
	ln -sf ../mpfr src/or1k-gcc/mpfr
	ln -sf ../mpc src/or1k-gcc/mpc
	cd src/build-gcc; CFLAGS="-Os -fpic" ../../src/or1k-gcc/configure \
	--target=or1k-linux \
	--host=or1k-linux \
	--prefix=/usr \
	--program-prefix=  \
	--disable-libssp \
	--srcdir=../../src/or1k-gcc \
	--enable-languages=c,c++ \
	--enable-threads=single \
	--disable-libquadmath \
	--disable-libatomic \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-multilib \
	--without-headers \
	--disable-docs
	cd src/build-gcc; echo "MAKEINFO = :" >> Makefile	
	cd src/build-gcc; make
	cd src/build-gcc; make DESTDIR=$(SYSROOT) install-strip

binutils:	
	rm -rf src/build-or1k-src/*
	mkdir -p src/build-or1k-src
	cd src/build-or1k-src;../../src/or1k-src/configure \
	--target=or1k-linux \
	--host=or1k-linux \
	--prefix=/usr \
	--program-prefix= \
	--disable-shared \
	--disable-itcl \
	--disable-tk \
	--disable-tcl \
	--disable-winsup \
	--disable-libgui \
	--disable-rda \
	--disable-sid \
	--disable-sim \
	--disable-gdb \
	--with-sysroot \
	--disable-newlib \
	--disable-libgloss \
	--disable-werror \
	--without-docdir
	cd src/build-or1k-src; echo "MAKEINFO = :" >> Makefile
	cd src/build-or1k-src; make
	cd src/build-or1k-src; echo "install-strip: install" >> readline/Makefile
	cd src/build-or1k-src; echo "install-strip: install" >> utils/Makefile
	cd src/build-or1k-src; STRIPPROG="or1k-linux-strip" make DESTDIR=$(SYSROOT) install-strip
