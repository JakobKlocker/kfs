const ports = @import("ports.zig");

pub const PS2 = struct {
    const data: u16 = 0x60; // read and write data from the PS/2 Controller
    const status: u16 = 0x64; // Status register contains flags for the data port
    const command: u16 = 0x64; // Command register is used to send commands to the PS/2 controller

    pub fn read() u8 {
        const x = ports.inb(data);
        return x;
    }
};
