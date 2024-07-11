

all:
	zig build -Dtarget=x86-freestanding --release=fast --summary none
	qemu-system-i386 -kernel kernel 
