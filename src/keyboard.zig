const PS2 = @import("ps2.zig").PS2;

pub const @"us QWERTY": []const u8 = &.{0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};

pub const Keyboard = struct {

    pub fn scan() u16 {
        var code: u16 = PS2.recv();

        if (code == 0xE0) {
            code <<= 8;
            code |= PS2.recv(); // recive second half
        }

        return code;
    }

    pub fn getChar(lang: []const u8) u8 {
        const scancode = scan();

        return lang[scancode];
    }

};

