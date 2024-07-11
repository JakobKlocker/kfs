const console = @import("console.zig").Console;
const VGA = @import("console.zig").VGA_COLOR;

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MB1_MAGIC: i64 = 0x1BADB002;
const FLAGS: i64 = ALIGN | MEMINFO;
 
const MultibootHeader = extern struct {
    magic: u32 = MB1_MAGIC,
    flags: u32,
    checksum: u32,
};
 
export var multiboot align(4) linksection(".multiboot") = MultibootHeader {
    .flags = FLAGS,
    .checksum = (-(MB1_MAGIC + FLAGS)) & 0xFFFFFFFF,
};

export fn _start() noreturn {
    console.clear();
    console.setColor(VGA.White, VGA.Black);
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");
    console.write("Hello, World!");

    while (true) {}
}
