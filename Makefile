

all:
	zig build -Dtarget=x86-freestanding --release=fast --summary none
#qemu-system-i386 -kernel kernel 
	mkdir -p boot/grub
	cp grub.cfg boot/grub
	cp kernel ./kernel.elf
	grub-mkrescue -o test.iso
	testtest
#qemu-system-i386 -cdrom /home/schnee/projects/hello-world/zig-out/bin/test.iso -machine type=pc-i440fx-3.1