

URL1 = ftp://gcc.gnu.org/pub/gcc/infrastructure/
URL2 = http://www.busybox.net/downloads/
URL3 = www.nano-editor.org/dist/v2.2/
URL4 = http://ftp.gnu.org/pub/gnu/ncurses/
URL5 = http://directfb.org/downloads/Core/DirectFB-1.6/


#not used
fetchutils:
	wget -P downloads/ $(URL1)/gmp-$(GMP_VERSION).tar.bz2
	wget -P downloads/ $(URL1)/mpfr-$(MPFR_VERSION).tar.bz2
	wget -P downloads/ $(URL1)/mpc-$(MPC_VERSION).tar.gz
	wget -P downloads/ $(URL2)/busybox-$(BUSYBOX_VERSION).tar.bz2
	wget -P downloads/ $(URL3)/nano-$(NANO_VERSION).tar.gz
	wget -P downloads/ $(URL4)/ncurses-$(NCURSES_VERSION).tar.gz
	wget -P downloads/ $(URL5)/DirectFB-$(DIRECTFB_VERSION).tar.gz


$(URLS):
	@for url in ${URLS}; do \                                               
		if [ ! -e $$(somefunc $${url}) ]; then \
			echo wget $${url}; \
			wget $${url}; \
		fi \
	done