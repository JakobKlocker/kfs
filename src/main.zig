const console = @import("console.zig").Console;
const VGA = @import("console.zig").VGA_COLOR;
const idt = @import("idt.zig");
const gdt = @import("gdt.zig");

export fn kernel_main() noreturn {
    gdt.testin();
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");

    idt.init_idt();

    while (true) {}
}
