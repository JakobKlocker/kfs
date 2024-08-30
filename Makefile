all:
	rm -rf kernel.iso
	zig build -Dtarget=x86-freestanding --release=off
	mkdir -p boot/grub
	mv kernel boot/kernel.elf
	cp grub.cfg boot/grub
	grub-mkrescue -o test.iso .
	qemu-system-i386 -cdrom test.iso -d int,cpu_reset -no-reboot