all:
	rm -rf kernel.iso
	zig build -Dtarget=x86-freestanding --release=off
	mkdir -p bootdir/boot/grub
	mv kernel bootdir/boot/kernel.elf
	cp grub.cfg bootdir/boot/grub
	grub-mkrescue -o kernel.iso bootdir --compress=xz
	qemu-system-i386 -cdrom kernel.iso -m 1024M

debug:
	rm -rf kernel.iso
	zig build -Dtarget=x86-freestanding --release=off
	mkdir -p bootdir/boot/grub
	mv kernel bootdir/boot/kernel.elf
	cp grub.cfg bootdir/boot/grub
	grub-mkrescue -o kernel.iso bootdir --compress=xz
	qemu-system-i386 -cdrom kernel.iso -m 1024M -gdb tcp::1234 -S
