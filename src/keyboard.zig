const PS2 = @import("ps2.zig").PS2;
const console = @import("console.zig").Console;

// reference taken from https://wiki.osdev.org/PS/2_Keyboard
pub const @"us QWERTY": []const [2] u8 = &.{.{0, 0}, .{0x1B, 0}, .{'1', '!'}, .{'2', '@'}, .{'3', 0}, .{'4', '$'}, .{'5', '%'},
                                            .{'6', '^'}, .{'7', '&'}, .{'8', '*'}, .{'9', '('}, .{'0', ')'}, .{'-', '_'}, .{'=', '+'},
                                            .{0x08, 0}, .{0x09, 0}, .{'q', 'Q'}, .{'w', 'W'}, .{'e', 'E'}, .{'r', 'R'}, .{'t', 'T'},
                                            .{'y', 'Y'}, .{'u', 'U'}, .{'i', 'I'}, .{'o', 'O'}, .{'p', 'P'}, .{'[', '{'}, .{']', '}'},
                                            .{'\n', 0}, .{0, 0}, .{'a', 'A'}, .{'s', 'S'}, .{'d', 'D'}, .{'f', 'F'}, .{'g', 'G'},
                                            .{'h', 'H'}, .{'j', 'J'}, .{'k', 'K'}, .{'l', 'L'}, .{';', ':'}, .{'\'', '\"'}, .{'`', '~'},
                                            .{0, 0}, .{'\\', '|'}, .{'z', 'Z'}, .{'x', 'X'}, .{'c', 'C'}, .{'v', 'V'}, .{'b', 'B'},
                                            .{'n', 'N'}, .{'m', 'M'}, .{',', '<'}, .{'.', '>'}, .{'/', '?'}, .{0, 0}, .{'*', 0}, .{0, 0},
                                            .{' ', 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0},
                                            .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{'7', 0}, .{'8', 0}, .{'9', 0}, .{'-', 0}, .{'4', 0},
                                            .{'5', 0}, .{'6', 0}, .{'+', 0}, .{'1', 0}, .{'2', 0}, .{'3', 0}, .{'0', 0}, .{'.', 0},
                                            .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}, .{0, 0}};

pub const Keyboard = struct {

    pub fn getScancode() u16 {
        var code: u16 = PS2.recv();

        if (code == 0xE0) {
            code <<= 8;
            code |= PS2.recv(); // recive second half
        }

        return code;
    }

    var shift = false;
    fn toggleShift(scancode: u16) void {
        if (scancode == 0x2A or scancode == 0x36) {
            shift = true;
        }
        else if (scancode == 0xAA or scancode == 0xB6) {
            shift = false;
        }
    }

    fn specialFunctionality(scancode: u16) void {
        if (scancode == 0xE048) { // cursor up
            console.scrollUp();
        } else if (scancode == 0xE050) { // cursor down
            console.scrollDown();
        } else if (scancode == 0xE04D) { // cursor right
            console.nextBuf();
        } else if (scancode == 0xE04B) { // cursor left
            console.prevBuf();
        }
    }
    
    pub fn getASCII(lang: []const [2]u8) u8 {
        const scancode = getScancode();

        toggleShift(scancode);
        specialFunctionality(scancode);

        if (scancode >= lang.len) // todo: remove when the layout is done
            return 0;
        if (shift)
            return lang[scancode][1];
        return lang[scancode][0];
    }

};

