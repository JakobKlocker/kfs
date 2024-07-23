const console = @import("console.zig").Console;
const port = @import("ports.zig");
const keyboard = @import("keyboard.zig").Keyboard;
const VGA = @import("console.zig").VGA_COLOR;
const keyboardLayout = @import("keyboard.zig").@"us QWERTY";
const idt = @import("idt.zig");
const GDT = @import("gdt.zig");

export fn kernel_main() noreturn {
    GDT.gdt.init();
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");

    while (true) {
        const c = keyboard.getChar(keyboardLayout);
        console.putChar(c);
    }
}

