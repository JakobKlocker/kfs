const ports = @import("ports.zig");

// this PS2 Dirver is referenced from https://wiki.osdev.org/%228042%22_PS/2_Controller
const PS2 = struct {
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


pub const Keyboard = struct {

    pub fn getChar() u8 {
        var x: u16 = PS2.recv();

        if (x == 0xE0) {
            x <<= 8;
            x |= PS2.recv(); // recv second half
        }

        const b: u8 = switch (x) {
            0x02 => '1',
            0x03 => '2',
            0x04 => '3',
            0x05 => '4',
            0x06 => '5',
            0x07 => '6',
            0x08 => '7',
            0x09 => '8',
            0x0a => '9',
            0x0b => '0',
            0x81...0xD8 => 0, // ignore key release for now
            else => 0,
        };
        return b;
    }

};
