const console = @import("console.zig").Console;
const VGA = @import("console.zig").VGA_COLOR;
const IDT = @import("idt.zig");
const GDT = @import("gdt.zig");
const PIC = @import("pic.zig");

export fn kernel_main() void {
    GDT.gdt.init();
    PIC.remapPic();
    IDT.idt.init();
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");

    while (true) {}
}
