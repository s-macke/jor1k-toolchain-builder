
# not used anymore
buildimageroot:
	dd if=/dev/zero of=ext2fsimage bs=1M count=128
	mkdir -p ext2fs
	mkfs.ext2 -F ext2fsimage
	mount ext2fsimage ext2fs -o loop,noexec,nosuid,rw
	cp -av $(SYSROOT)/* ext2fs/
	#cp a.out ext2fs/
	#cp uClibc-or1k/utils/ldd ext2fs/
	mkdir ext2fs/etc
	#touch ext2fs/etc/ld.so.conf
	#touch ext2fs/etc/ld.so.cache
	chown -Rv root:root ext2fs/
	#ln -s ../../lib/ld-uClibc.so.0 ext2fs/usr/lib/ld.so.1
	ln -s ld-uClibc.so.0 ext2fs/lib/ld.so.1
	#-chmod +s ext2fs/bin/busybox
	umount ext2fs

mke2img:
	gcc patches/mke2img.c -o mke2img -lext2fs -lcom_err

buildimage:
	dd if=/dev/zero of=ext2fsimage bs=1M count=300
	mkfs.ext2 -F ext2fsimage -b 4096
	mkdir -p $(SYSROOT)/etc
	mkdir -p $(SYSROOT)/tmp
	mkdir -p $(SYSROOT)/proc
	mkdir -p $(SYSROOT)/dev
	mkdir -p $(SYSROOT)/sys
	cp patches/startchroot $(SYSROOT)
	chmod u+x $(SYSROOT)/startchroot
	cp patches/hello.c $(SYSROOT)
	cp patches/startX $(SYSROOT)
	#this link is done in the toolchain: ln -f -s ld-uClibc.so.0 $(SYSROOT)/lib/ld.so.1
	./mke2img ext2fsimage $(SYSROOT)

splitimage:
	mkdir -p hd
	split -d -a4 --bytes=512K ext2fsimage hd/hd

