const ports = @import("ports.zig");

// this PS2 Dirver is referenced from https://wiki.osdev.org/%228042%22_PS/2_Controller
pub const PS2 = struct {
    const data: u16 = 0x60; // read and write data from/to the PS/2 Controller
    const status: u16 = 0x64; // Status register contains flags for the data port
    const command: u16 = 0x64; // Command register is used to send commands to the PS/2 controller

    pub fn recv() u8 {

        while (ports.inb(status) & 0b1 != 1) { // waiting for input; should be replaced with interrups later
            ports.io_wait();
        }

        const x = ports.inb(data);
        return x;
    }
};

