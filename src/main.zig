const console = @import("console.zig").Console;
const VGA = @import("console.zig").VGA_COLOR;
const idt = @import("idt.zig");
const GDT = @import("gdt.zig");
const PIC = @import("pic.zig");

export fn kernel_main() noreturn {
    GDT.gdt.init();
    PIC.remapNew();
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");

    while (true) {}
}
