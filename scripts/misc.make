startqemueasy:
	qemu-system-or32 -nographic -kernel src/linux/vmlinux

startqemu: 
	qemu-system-or32 -nographic -kernel src/linux/vmlinux

startor1keasy: 
	sim -f patches/or1ksim.cfg src/linux/vmlinux

startor1k:
	sim -f patches/or1ksim.cfg src/linux/vmlinux

