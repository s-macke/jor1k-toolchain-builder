# --------------------------------------
TOOLCHAIN_DIR = /opt/or1k
TOOLCHAIN_NAME = or1k-linux
# --------------------------------------

PATH := $(PATH):$(TOOLCHAIN_DIR)/bin
SYSROOT := $(TOOLCHAIN_DIR)/or1k-linux/sys-root2

PARENT_DIR = $(lastword $(subst /, ,$(PWD)))

#for all the tools
PKG_CONFIG_DIR := 
PKG_CONFIG_PATH :=  
PKG_CONFIG_LIBDIR := ${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig
PKG_CONFIG_SYSROOT_DIR := $(SYSROOT)

deletedir = if test -d $(1); then 				\
	rm -rf $(1)/ $(1)/.??* $(1)/.[^.] ;			\
	fi;


CONFIG_HOST = --host=or1k-linux --prefix=/usr


extractpatch = 							\
	$(call deletedir,src/$(1))					\
	if test -e downloads/$(1)-$(2).tar.gz; then 			\
		tar -C src -xzf downloads/$(1)-$(2).tar.gz;		\
	else									\
	if test -e downloads/$(1)-$(2).tar.bz2; then			\
		tar -C src -xjf downloads/$(1)-$(2).tar.bz2;		\
	else									\
		echo Error: Could not find file downloads/$(1)-$(2).tar.gz or downloads/$(1)-$(2).tar.bz2;			\
		exit 1;														\
	fi;				\
	fi;									\
	mv src/$(1)-$(2) src/$(1);					\
	cd src/$1; find . -name "config.sub" -exec sed -i 's/or32/or1k/g' {} \;;


#Naming our phony targets, targets which dont create files
.PHONY: help info env dep test clean toolchainpull toolchaincheck

help:
	@echo "  help: shows this help screen"
	@echo "  info: shows some variables used (please change the Makefile)"
	@echo "  env: prints some global variables. Execute this if you want to compile by your own"
	@echo "Please take a look in README.MD for all supported commands"


info:
	@echo "TOOLCHAIN_DIR=$(TOOLCHAIN_DIR)"
	@echo "PATH = $(PATH)"
	@echo "SYSROOT = $(SYSROOT)"
	@echo "SRCDIR = $(CURDIR)"
	@echo "PARENT_DIR = $(PARENT_DIR)"
	@echo "PROGS/LIBS available: $(PROGS)"

dep:
	@echo "mandatory: gcc make flex bison" 
	@echo "other: e2fsprogs python qemu or1ksim"

env:
	@echo "===================================================="
	@echo "Execute following commands in your shell"
	@echo "===================================================="
	@echo "export PATH=$(PATH)"
	@echo "export SYSROOT=$(SYSROOT)"
	@echo "export PKG_CONFIG_DIR=$(PKG_CONFIG_DIR)"
	@echo "export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)"
	@echo "export PKG_CONFIG_LIBDIR=$(PKG_CONFIG_LIBDIR)"
	@echo "export PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR)"
	@echo "===================================================="

test:
	#check if path is working
	or1k-linux-gcc -v

init:
	mkdir -p src
	mkdir -p downloads
	mkdir $(TOOLCHAIN_DIR)

#build toolchain
include scripts/toolchain.make

#build tools to compile your own stuff on the target
include scripts/build.make

#scripts to create the ext2 image
include scripts/image.make

#fetch files not in the toolchain
include scripts/fetch.make

# several important programs and libraries
include scripts/progs.make

# X11 libraries
include scripts/X.make

include scripts/misc.make


kernel:
	#patch src/linux/arch/openrisc/include/asm/bitops.h < patches/bitops_linux.patch
	#cp patches/bitops.h src/linux/arch/openrisc/include/asm/
	cd src/linux; make clean
	cd src/linux; make distclean
	cp patches/or1ksim.dts src/linux/arch/openrisc/boot/dts
	cp patches/CONFIG_LINUX src/linux/.config
	cd src/linux; make
	cd src/linux; or1k-linux-objcopy -O binary vmlinux vmlinux.bin


helloworldfile:
	cp patches/test.c $(SYSROOT)/
	or1k-linux-gcc $(SYSROOT)/hello.c -o $(SYSROOT)/hello

archive:
	tar -cvjf or1k-toolchain.tar.bz2 -C ../ $(PARENT_DIR)/Makefile $(PARENT_DIR)/README.MD $(PARENT_DIR)/patches $(PARENT_DIR)/scripts

clean:
	-rm *.done
