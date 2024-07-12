const console = @import("console.zig").Console;
const port = @import("ports.zig");
const ps2 = @import("PS2.zig").PS2;
const VGA = @import("console.zig").VGA_COLOR;

export fn kernel_main() noreturn {
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");
    

    while (true) {
        const c = ps2.read();
        console.putChar(c);
        for (0..1000000) |_| {
            port.io_wait();
        }
    }
}
