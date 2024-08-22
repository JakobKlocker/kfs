const console = @import("console.zig").Console;
const port = @import("ports.zig");
const keyboard = @import("keyboard.zig").Keyboard;
const VGA = @import("console.zig").VGA_COLOR;
const keyboardLayout = @import("keyboard.zig").@"us QWERTY";
const idt = @import("idt.zig");
const GDT = @import("gdt.zig");
const print = @import("print.zig").print;

export fn kernel_main() noreturn {
    GDT.gdt.init();
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.setActiveBuffer(0) catch unreachable;
    print("{}", .{12000000000000000000000000000000000});

    while (true) {
        const c = keyboard.getASCII(keyboardLayout);
        print("{}", .{c});
    }
}

