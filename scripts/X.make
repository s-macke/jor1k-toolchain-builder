# -------------------
xcb-proto_VERSION = 1.8
bigreqsproto_VERSION = 1.1.2
compositeproto_VERSION = 0.4.2
damageproto_VERSION = 1.2.1
dmxproto_VERSION = 2.3.1
dri2proto_VERSION = 2.8
fixesproto_VERSION = 5.0
fontsproto_VERSION = 2.1.2
glproto_VERSION = 1.4.16
inputproto_VERSION = 2.3
kbproto_VERSION = 1.0.6
randrproto_VERSION = 1.4.0
recordproto_VERSION = 1.14.2
renderproto_VERSION = 0.11.1
resourceproto_VERSION = 1.2.0
scrnsaverproto_VERSION = 1.2.2
videoproto_VERSION = 2.3.1
xcmiscproto_VERSION = 1.2.2
xextproto_VERSION = 7.2.1
xf86bigfontproto_VERSION = 1.2.0
xf86dgaproto_VERSION = 2.1
xf86driproto_VERSION = 2.1.1
xf86vidmodeproto_VERSION = 2.3.1
xineramaproto_VERSION = 1.2.1
xproto_VERSION = 7.0.23
PROTO_XLIBS = bigreqsproto compositeproto damageproto dmxproto dri2proto fixesproto fontsproto 	\
glproto inputproto kbproto randrproto recordproto renderproto resourceproto scrnsaverproto videoproto \
xcmiscproto xextproto xcb-proto			\
xf86bigfontproto xf86dgaproto xf86driproto xf86vidmodeproto xineramaproto xproto
xproto: $(PROTO_XLIBS)

# -------------------

xtrans_VERSION = 1.2.7
libX11_VERSION = 1.5.0
libXext_VERSION = 1.3.1
libFS_VERSION = 1.0.4
libICE_VERSION = 1.0.8
libSM_VERSION = 1.2.1
libXScrnSaver_VERSION = 1.2.2
libXt_VERSION = 1.1.3
libXmu_VERSION = 1.1.1
libXpm_VERSION = 3.5.10
libXaw_VERSION = 1.0.11
libXfixes_VERSION = 5.0
libXcomposite_VERSION = 0.4.4
libXrender_VERSION = 0.9.7
libXcursor_VERSION = 1.1.13
libXdamage_VERSION = 1.1.4
libfontenc_VERSION = 1.1.1
libXfont_VERSION = 1.4.5
libXfont_EXTRA_CONFIG = --disable-devel-docs
libXft_VERSION = 2.3.1
libXi_VERSION = 1.7.1
libXrandr_VERSION = 1.4.0
libXinerama_VERSION = 1.1.2
libXres_VERSION = 1.0.6
libXtst_VERSION = 1.2.1
libXv_VERSION = 1.0.7
libXvMC_VERSION = 1.0.7
libXxf86dga_VERSION = 1.1.3
libXxf86vm_VERSION = 1.1.2
libdmx_VERSION = 1.1.2
libpciaccess_VERSION = 0.13.1
libxkbfile_VERSION = 1.0.8
xkeyboard-config_VERSION=2.8
xkeyboard-config_EXTRA_CONFIG = --with-xkb-rules-symlink=xorg

XLIBS2 = xtrans libX11 libXext libFS libICE libSM libXScrnSaver libXt libXmu libXpm libXaw libXfixes \
libXcomposite libXrender libXcursor libXdamage libfontenc libXfont libXft libXi libXrandr libXinerama \
libXres libXtst libXv libXvMC libXxf86dga libXxf86vm libdmx libpciaccess libxkbfile xkeyboard-config
xlibs2: $(XLIBS2) 

# -------------------

libpng_VERSION = 1.6.2
libjpeg-turbo_VERSION = 1.2.1
libjpeg-turbo_EXTRA_CONFIG = --with-jpeg8
pixman_VERSION = 0.28.2
pixman_EXTRA_CONFIG = --disable-openmp
pixman_EXTRA_CFLAGS = -DPIXMAN_NO_TLS
libpthread-stubs_VERSION = 0.1
freetype_VERSION = 2.5.0.1
XPRE = libpng libjpeg-turbo pixman libpthread-stubs
xpre: $(XPRE) freetype

# -------------------

font-util_VERSION = 1.3.0
encodings_VERSION = 1.0.4
font-bh-75dpi_VERSION = 1.0.3
font-bh-ttf_VERSION = 1.0.3
font-adobe-75dpi_VERSION = 1.0.3
XFONTS = font-util encodings 
xfonts: $(XFONTS) font-bh-75dpi font-bh-ttf font-adobe-75dpi

# -------------------

util-macros_VERSION = 1.17
libXau_VERSION = 1.0.7
fontconfig_VERSION = 2.10.93
fontconfig_EXTRA_CONFIG = --disable-docs
libXdmcp_VERSION = 1.1.1
xbitmaps_VERSION = 1.1.1
libxcb_VERSION = 1.8.1
libxcb_EXTRA_CONFIG = --disable-build-docs
xcb-util_VERSION = 0.3.9
XLIBS = util-macros fontconfig libXau libXdmcp xbitmaps xcb-util
xlibs: $(XLIBS) libxcb

# -------------------

twm_VERSION = 1.0.7
xeyes_VERSION = 1.1.1
xclock_VERSION = 1.0.6
xinit_VERSION = 1.3.2
xinit_EXTRA_CONFIG = --with-xinitdir=/etc/X11/app-defaults
xterm_VERSION = 295
xkbcomp_VERSION = 1.2.4
XAPPS = twm xeyes xclock xinit xkbcomp xauth xset
xauth_VERSION = 1.0.7
xset_VERSION = 1.2.2
xapps: $(XAPPS) xterm 

# -------------------

Mesa_VERSION = 9.1.4
Mesa_EXTRA_CONFIG= --disable-dri --enable-xlib-glx --with-dri-drivers= --with-gallium-drivers=

xorg-server_VERSION = 1.12.2
xorg-server_EXTRA_CONFIG = --disable-glx-tls --disable-dri --disable-dri2 --disable-xselinux --disable-composite --disable-xdm-auth-1 \
--disable-xorg --disable-standalone-xpbproxy --disable-xwin --enable-kdrive --enable-xfbdev \
--disable-xfake --disable-config-udev

.PHONY : xpre xfonts xlibs xapps xlibs2 xproto $(XLIBS) $(XLIBS2) $(XPRE) $(PROTO_XLIBS)


$(XPRE):
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la

$(XLIBS) $(XLIBS2) $(PROTO_XLIBS) $(XFONTS):
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) --sysconfdir=/etc --localstatedir=/var --disable-static $($@_EXTRA_CONFIG)
	cd src/$@; make
	#cd src/$@; find . -type f -name "*.la" -print0 | xargs -0 sed -i -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;"
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la
	sed -i~ -e "s; /usr/lib/libxcb.la; $(SYSROOT)/usr/lib/libxcb.la;" $(SYSROOT)/usr/lib/*.la
	sed -i~ -e "s; /usr/lib/libX11.la; $(SYSROOT)/usr/lib/libX11.la;" $(SYSROOT)/usr/lib/*.la

$(XAPPS):
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) --sysconfdir=/etc --localstatedir=/var --disable-static $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)

xterm:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; sed -i '/v0/,+1s/new:/new:kb=^?:/' termcap
	cd src/$@; echo -e '\tkbs=\\177,' >>terminfo
	cd src/$@; TERMINFO=/usr/share/terminfo CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) --enable-luit --enable-wide-chars --with-app-defaults=/etc/X11/app-defaults
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)

font-bh-75dpi font-bh-ttf font-adobe-75dpi:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) --sysconfdir=/etc --localstatedir=/var --disable-static $($@_EXTRA_CONFIG)
	cd src/$@; make UTIL_DIR=$(SYSROOT)/usr/share/fonts/X11/util
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)

libxcb:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) --sysconfdir=/etc --localstatedir=/var --disable-static $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; find . -type f -name "*.la" | xargs -0 sed -i -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;"
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la
	sed -i~ -e "s; /usr/lib/libxcb.la; $(SYSROOT)/usr/lib/libxcb.la;" $(SYSROOT)/usr/lib/*.la
	sed -i~ -e "s; /usr/lib/libX11.la; $(SYSROOT)/usr/lib/libX11.la;" $(SYSROOT)/usr/lib/*.la

freetype:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) $($@_EXTRA_CONFIG)
	cd src/$@; sed -i~ -e "s;-L/usr/lib ;;" builds/unix/unix-cc.mk
	cd src/$@; make
	cd src/$@; make install DESTDIR=$(SYSROOT)
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la

#Applying patch http://lists.freedesktop.org/archives/mesa-users/2013-February/000569.html

Mesa:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; patch -Np1 -i ../../patches/MesaLib-9.1-no_ranlib.patch
	cd src/$@; patch -Np1 -i ../../patches/MesaLib-9.1.4-add_xdemos-1.patch
	cd src/$@; autoreconf -fi
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) $($@_EXTRA_CONFIG)
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
	cd src/$@; CC=or1k-linux-gcc make -C xdemos DEMOS_PREFIX=/usr V=1
	cd src/$@; sed -i~ -e "s;ifneq (;ifeq (;" xdemos/Makefile
	cd src/$@; make -C xdemos DEMOS_PREFIX=/usr DESTDIR=$(SYSROOT) install 
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la
	cp src/Mesa/include/GL/internal/dri_interface.h $(SYSROOT)/usr/include/GL/internal/
	

#nano /opt/or1k/or1k-linux/sys-root/usr/include/GL/internal/dri_interface.h

xorg-server:
	@echo Compile $@-$($@_VERSION)
	$(call extractpatch,$@,$($@_VERSION))
	cd src/$@; echo "#define IMAGE_BYTE_ORDER        MSBFirst" >> include/servermd.h
	cd src/$@; echo "#define BITMAP_BIT_ORDER        MSBFirst" >> include/servermd.h
	cd src/$@; echo "#define GLYPHPADBYTES           4" >> include/servermd.h
	cd src/$@; CFLAGS="-Os $($@_EXTRA_CFLAGS)" ./configure $(CONFIG_HOST) $($@_EXTRA_CONFIG)
	cd src/$@; make
	cd src/$@; make install-strip DESTDIR=$(SYSROOT)
	sed -i~ -e "s;libdir='/usr;libdir='$(SYSROOT)/usr;" $(SYSROOT)/usr/lib/*.la


