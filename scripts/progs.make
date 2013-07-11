openssl_VERSION = 1.0.1e
busybox_VERSION = 1.20.2
nano_VERSION = 2.2.6
nano_EXTRA_CONFIG=- --disable-nanorc
ncurses_VERSION = 5.9
ncurses_EXTRA_CONFIG = --disable-database --with-fallbacks=linux --disable-docs --without-debug
DirectFB_VERSION = 1.6.3
DirectFB-examples_VERSION = 1.6.0

zlib_VERSION = 1.2.8
expat_VERSION = 2.1.0
expat_EXTRA_CONFIG = --disable-static

bc_VERSION = 1.06.95

PROGS = busybox ncurses nano zlib openssl expat mcookie bc

.PHONY: preprogs $(PROGS)


progs: preprogs $(PROGS)

#TODO: what is libtool --finish /usr/lib

preprogs:
	mkdir -p $(SYSROOT)/var
	mkdir -p $(SYSROOT)/etc
	mkdir -p $(SYSROOT)/bin
	mkdir -p $(SYSROOT)/sbin

mcookie:
	cp patches/mcookie $(SYSROOT)/sbin
	chmod u+x $(SYSROOT)/sbin/mcookie

busybox: 
	$(call extractpatch,$@,$($@_VERSION))
	cp patches/CONFIG_BUSYBOX src/busybox/.config	
	cd src/busybox; make \
	CFLAGS="--sysroot=$(SYSROOT)" \
	CROSS_COMPILE=$(TOOLCHAIN_NAME)- \
	CONFIG_PREFIX=$(SYSROOT) \
	install

zlib:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CC=or1k-linux-gcc CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure --prefix=/usr $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; make install DESTDIR=$(SYSROOT)
	cp patches/libz.la $(SYSROOT)/usr/lib/
	cp patches/libgcc_s.la $(SYSROOT)/usr/lib/
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la

expat ncurses:
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; ./configure $(CONFIG_HOST) $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; make install DESTDIR=$(SYSROOT)

nano:
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; ./configure $(CONFIG_HOST) $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)

openssl:
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; cross=or1k-linux- ./Configure dist --prefix=/usr shared zlib-dynamic
	cd src/$@; make CC="or1k-linux-gcc" AR="or1k-linux-ar r" RANLIB="or1k-linux-ranlib"
	cd src/$@; make INSTALL_PREFIX=$(SYSROOT) install
	or1k-linux-ranlib $(SYSROOT)/usr/lib/libssl.a
	or1k-linux-ranlib $(SYSROOT)/usr/lib/libcrypt.a

bc:
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os" ./configure $(CONFIG_HOST)
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)

DirectFB:
	$(call extractpatch,$@,$($@_VERSION))
	sed -i~ -e "s;#ifdef DIRECT_BUILD_NO_SA_SIGINFO;#if 1;" src/DirectFB/lib/direct/signals.c
	sed -i~ -e "s;#ifdef WIN32;#ifndef WIN32;" src/DirectFB/lib/direct/atomic.h
	cd src/$@; CFLAGS="-Os -fpic" ./configure $(CONFIG_HOST)	\
		--enable-debug	\
		--enable-trace	\
		--program-prefix= 	\
		--disable-network	\
		--disable-werror	\
		--disable-multicore	\
		--disable-x11			\
		--disable-docs			\
		--with-gfxdrivers=none		\
		--with-inputdrivers=none		\
		--sysconfdir=/etc
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la
	sed -i~ -e "s; /usr/lib/libdirect.la; $(SYSROOT)/usr/lib/libdirect.la;" $(SYSROOT)/usr/lib/*.la
	sed -i~ -e "s; /usr/lib/libfusion.la; $(SYSROOT)/usr/lib/libfusion.la;" $(SYSROOT)/usr/lib/*.la
	cp patches/directfbrc $(SYSROOT)/etc/


DirectFB-examples:
	$(call extractpatch,$@,$($@_VERSION))
	#or1k-linux-pkg-config --list-all
	cd src/$@; CFLAGS="-Os -I$(SYSROOT)/usr/include/directfb" ./configure $(CONFIG_HOST)
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
