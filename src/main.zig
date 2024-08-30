const console = @import("console.zig").Console;
const port = @import("ports.zig");
const keyboard = @import("keyboard.zig").Keyboard;
const VGA = @import("console.zig").VGA_COLOR;
const keyboardLayout = @import("keyboard.zig").@"us QWERTY";
const GDT = @import("gdt.zig");
const print = @import("print.zig").print;
const IDT = @import("idt.zig");
const PIC = @import("pic.zig");

export fn kernel_main() void {
    GDT.gdt.init();
    PIC.remapPic();
    IDT.idt.init();
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.setActiveBuffer(0) catch unreachable;
    print("{c}", .{"Hello, World!"});

    while (true) {
        const c = keyboard.getASCII(keyboardLayout);
        print("{c}", .{c});
    }
}

