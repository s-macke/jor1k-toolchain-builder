fetchtoolchain: 
	cd src; git clone git://github.com/openrisc/or1k-src.git 
	cd src; git clone git://github.com/openrisc/or1k-gcc.git
	cd src; git clone git://github.com/openrisc/uClibc-or1k.git
	cd src; git clone git://github.com/openrisc/or1k-dejagnu.git
	cd src; git clone git://openrisc.net/jonas/linux
	cd src; git clone git://github.com/openrisc/or1ksim.git
	cd src/or1k-gcc; git checkout or1k-native

or1ksim:
	cd src/or1ksim; ./configure
	cd src/or1ksim; make
	cd src/or1ksim; make install

dejagnu:
	cd src/or1k-dejagnu; ./configure
	cd src/or1k-dejagnu; make
	cd src/or1k-dejagnu; make install

toolchain:
	$(MAKE) toolchain_newlib_stage1
	$(MAKE) toolchain_newlib_stage2
	$(MAKE) toolchain_newlib_stage3
	$(MAKE) toolchain_newlib_stage4
	$(MAKE) toolchain_stage1
	$(MAKE) toolchain_stage2
	$(MAKE) toolchain_stage3
	$(MAKE) toolchain_stage4
	$(MAKE) toolchain_stage5

toolchainpull: 
	-cd src/or1k-src; git pull
	-cd src/or1k-gcc; git pull
	-cd src/uClibc-or1k; git pull
	-cd src/or1ksim; git pull
	-cd src/linux; git pull

toolchaincheck:
	-cd src/or1k-src; git fsck --full
	-cd src/or1k-gcc; git fsck --full
	-cd src/uClibc-or1k; git fsck --full
	-cd src/linux; git fsck --full


toolchain_stage1:
	mkdir -p src/build-or1k-src
	rm -rf src/build-or1k-src/*
	cd src/build-or1k-src;../../src/or1k-src/configure \
        --target=or1k-linux \
        --prefix=$(TOOLCHAIN_DIR) \
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
	cd src/build-or1k-src; make install

toolchain_stage2:
	cd src/linux/; make INSTALL_HDR_PATH=${SYSROOT}/usr headers_install

toolchain_stage3:
	mkdir -p src/build-gcc
	rm -rf src/build-gcc/*
	cd src/build-gcc; ../../src/or1k-gcc/configure \
        --target=or1k-linux \
        --prefix=$(TOOLCHAIN_DIR) \
        --disable-libssp \
        --srcdir=../../src/or1k-gcc \
        --enable-languages=c \
        --without-headers \
        --enable-threads=single \
        --disable-libgomp \
        --disable-libmudflap \
        --disable-shared \
        --disable-libquadmath \
        --disable-libatomic \
        --disable-docs
	cd src/build-gcc; echo "MAKEINFO = :" >> Makefile
	cd src/build-gcc; make
	cd src/build-gcc; make install

toolchain_stage4:
	cd src/uClibc-or1k; make clean
	cd src/uClibc-or1k; make distclean
	cd src/uClibc-or1k; make ARCH=or1k defconfig
	cp patches/CONFIG_UCLIBC src/uClibc-or1k/.config
	cd src/uClibc-or1k; make PREFIX=$(SYSROOT)
	cd src/uClibc-or1k; make PREFIX=$(SYSROOT) install
	ln -f -s ld-uClibc.so.0 $(SYSROOT)/lib/ld.so.1


toolchain_stage5:
	rm -rf src/build-gcc/*
	cd src/build-gcc; ../../src/or1k-gcc/configure \
	--target=or1k-linux \
	--prefix=$(TOOLCHAIN_DIR) \
	--disable-libssp \
	--srcdir=../../src/or1k-gcc \
	--enable-languages=c,c++ \
	--enable-threads=posix \
	--disable-libgomp \
	--disable-libmudflap \
	--with-sysroot=$(SYSROOT) \
	--disable-multilib	\
	--disable-docs
	cd src/build-gcc; echo "MAKEINFO = :" >> Makefile
	cd src/build-gcc; make
	cd src/build-gcc; make install

toolchain_newlib_stage1:
	mkdir -p src/build-or1k-src
	rm -rf src/build-or1k-src/*
	cd src/build-or1k-src;../../src/or1k-src/configure \
        --target=or1k-elf \
        --prefix=$(TOOLCHAIN_DIR) \
        --enable-shared \
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
	cd src/build-or1k-src; make install


toolchain_newlib_stage2:
	mkdir -p src/build-gcc
	rm -rf src/build-gcc/*
	cd src/or1k-gcc; 
	cd src/build-gcc; ../../src/or1k-gcc/configure \
        --target=or1k-elf \
        --prefix=$(TOOLCHAIN_DIR) \
        --disable-libssp \
        --enable-languages=c \
        --disable-shared \
        --disable-docs
	cd src/build-gcc; echo "MAKEINFO = :" >> Makefile
	cd src/build-gcc; make
	cd src/build-gcc; make install

toolchain_newlib_stage3:
	rm -rf src/build-or1k-src/*
	cd src/build-or1k-src;../../src/or1k-src/configure \
        --target=or1k-elf \
        --prefix=$(TOOLCHAIN_DIR) \
        --enable-shared \
        --disable-itcl \
        --disable-tk \
        --disable-tcl \
        --disable-winsup \
        --disable-libgui \
        --disable-rda \
        --disable-sid \
        --enable-sim \
	 --disable-or1ksim \
        --enable-gdb \
        --with-sysroot \
        --enable-newlib \
        --enable-libgloss \
        --disable-werror \
        --without-docdir
	cd src/build-or1k-src; echo "MAKEINFO = :" >> Makefile
	cd src/build-or1k-src; make
	cd src/build-or1k-src; make install

toolchain_newlib_stage4:
	rm -rf src/build-gcc/*
	cd src/or1k-gcc; 
	cd src/build-gcc; ../../src/or1k-gcc/configure \
        --target=or1k-elf \
        --prefix=$(TOOLCHAIN_DIR) \
        --disable-libssp \
	 --with-newlib \
        --enable-languages=c \
        --disable-shared \
        --disable-docs
	cd src/build-gcc; echo "MAKEINFO = :" >> Makefile
	cd src/build-gcc; make
	cd src/build-gcc; make install





