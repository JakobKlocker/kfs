all:
	rm -rf kernel.iso
	zig build -Dtarget=x86-freestanding --release=off
	mkdir -p boot/grub
	mv kernel boot/kernel.elf
	cp grub.cfg boot/grub
	grub-mkrescue -o kernel.iso .
	qemu-system-i386 -cdrom kernel.iso #-d int,cpu_reset -no-reboot



debug:
	rm -rf kernel.iso
	zig build -Dtarget=x86-freestanding --release=off
	mkdir -p boot/grub
	mv kernel boot/kernel.elf
	cp grub.cfg boot/grub
	grub-mkrescue -o kernel.iso .
	qemu-system-i386 -cdrom kernel.iso -gdb tcp::1234 -S #-d int,cpu_reset -no-reboot
