const port = @import("ports.zig");

const Command = enum {
    Reboot,
    Shutdown,
    Halt,
};

pub const cmds = struct {
    //8042 reset: https://wiki.osdev.org/Reboot
    pub fn reboot() void {
        var good: u8 = 0x02;
        while (good & 0x02 != 0) {
            good = port.inb(0x64);
        }
        port.outb(0x64, 0xFE);
        asm volatile ("hlt");
    }
    //https://wiki.osdev.org/Shutdown
    pub fn shutdown() void {
        port.outw(0x604, 0x2000);
    }

    pub fn halt() void {
        asm volatile ("hlt");
    }
};
