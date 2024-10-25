const multiboot = @import("multibootheader.zig");
const console = @import("console.zig").Console;
const port = @import("ports.zig");
const keyboard = @import("keyboard.zig").Keyboard;
const VGA = @import("console.zig").VGA_COLOR;
const keyboardLayout = @import("keyboard.zig").@"us QWERTY";
const GDT = @import("gdt.zig");
const print = @import("print.zig").print;
const printStack = @import("print.zig").printStack;
const IDT = @import("idt.zig");
const PIC = @import("pic.zig");
const mem = @import("PMM.zig");
const vmm = @import("vmm.zig");
const panic = @import("print.zig").panic;
const panicLevels = @import("print.zig").panicLevel;

export fn kernel_main(mbd: *multiboot.multiboot_info, magic: u32) void {
    GDT.gdt.init();
    PIC.remapPic();
    IDT.idt.init();
    mem.init(mbd, magic);

    console.clear();
    console.setActiveBuffer(0) catch unreachable;
    console.setColor(VGA.DarkGray, VGA.Black);
    print("{c}", .{"4"});
    console.setColor(VGA.LightCyan, VGA.Black);
    console.setColor(VGA.White, VGA.Black);
    print("{c}", .{"2"});
    vmm.init_vmm() catch panic("OUT_OF_MEMORY", panicLevels.HIGH);
    while (true) {
        port.io_wait();
    }
}
