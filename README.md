# KFS – Minimal x86 Kernel in Zig

KFS is a small hobby operating system kernel written in **Zig** with **x86 Assembly**, targeting the **x86 (32-bit) architecture**.  
The project focuses on low-level system programming concepts such as bootstrapping, memory management, interrupts, and basic device I/O.

The kernel is Multiboot-compliant and is loaded using **GRUB**.

---

## Features

- Multiboot-compatible kernel
- Bootstrapping with x86 Assembly
- Kernel written primarily in **Zig**
- Global Descriptor Table (**GDT**) setup
- Interrupt Descriptor Table (**IDT**) and interrupt handling
- Programmable Interrupt Controller (**PIC**) initialization
- Basic keyboard input (PS/2)
- VGA text-mode console output
- Port I/O abstractions
- Physical Memory Manager (**PMM**)
- Simple command handling

---

## Architecture

- **Target architecture:** x86 (IA-32, 32-bit)
- **Bootloader:** GRUB (Multiboot)
- **Language stack:**
  - Zig (kernel logic)
  - x86 Assembly (boot code)
- **Execution environment:** Bare metal

---

## Project Status

This project was created as a learning exercise in low-level systems programming.
Development is **no longer actively maintained**, but the repository remains available
for reference and educational purposes.


