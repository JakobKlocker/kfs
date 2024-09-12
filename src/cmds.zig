const port = @import("ports.zig");

//8042 reset: https://wiki.osdev.org/Reboot
pub const cmds = struct {
    pub fn reboot() void {
        var good: u8 = 0x02;
        while (good & 0x02 != 0) {
            good = port.inb(0x64);
        }
        port.outb(0x64, 0xFE);
        asm volatile ("hlt");
    }

    pub fn shutdown() void {
        port.outw(0x604, 0x2000);
    }

    pub fn halt() void {
        asm volatile ("hlt");
    }
};
