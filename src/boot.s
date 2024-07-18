.extern kernel_main

.global _start

.set MB_MAGIC, 0x1BADB002          // This is a 'magic' constant that GRUB will use to detect our kernel's location.
.set MB_FLAGS, 0
.set MB_CHECKSUM, (0 - (MB_MAGIC + MB_FLAGS))
 
.section .multiboot
	.align 4 
	.long MB_MAGIC
	.long MB_FLAGS
	.long MB_CHECKSUM
 
.section .bss

	.align 16
	stack_bottom:
		.skip 4096
	stack_top:
 
.section .text
	_start:
	
		mov $stack_top, %esp
		call kernel_main
		hang:
			; cli      // Disable CPU interrupts
			hlt      // Halt the CPU
			; jmp hang // If that didn't work, loop around and try again.

