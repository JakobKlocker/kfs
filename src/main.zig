const console = @import("console.zig").Console;
const port = @import("ports.zig");
const keyboard = @import("PS2.zig").Keyboard;
const VGA = @import("console.zig").VGA_COLOR;

export fn kernel_main() noreturn {
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");

    while (true) {
        const c = keyboard.getChar();
        console.putChar(c);
    }
}
