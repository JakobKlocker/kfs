all:
	rm -rf test.iso
	zig build -Dtarget=x86-freestanding --release=fast --summary none
	mkdir -p boot/grub
	mv kernel boot/kernel.elf
	cp grub.cfg boot/grub
	grub-mkrescue -o kernel.img .
	qemu-system-i386 -cdrom kernel.img
