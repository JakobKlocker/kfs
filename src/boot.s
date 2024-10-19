.set MB_PAGE_ALIGN,  1 << 0
.set MB_MEM_INFO,  1 << 1
.set MB_USE_GFX,  1
.set MB_MAGIC,  0x1BADB002
.set MB_FLAGS,  MB_PAGE_ALIGN | MB_MEM_INFO | MB_USE_GFX
.set MB_CHECKSUM, (0 - (MB_MAGIC + MB_FLAGS))



.extern kernel_main

.global _start
.global stack_top
 
 
.section .multiboot
	.align 4 
	.long MB_MAGIC
	.long MB_FLAGS
	.long MB_CHECKSUM
	; .long 0, 0, 0, 0, 0
	; .long 0
	; .long 1920
	; .long 600
	; .long 32

.section .bss

	.align 16
	stack_bottom:
		.skip 4096
	stack_top:

 
.section .text
	_start:
		mov $stack_top, %esp

        push %eax
        push %ebx
		call kernel_main
 
		hang:
			cli      // Disable CPU interrupts
			hlt      // Halt the CPU
			jmp hang // If that didn't work, loop around and try again.