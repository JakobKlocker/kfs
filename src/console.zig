const ports = @import("ports.zig");


pub const VGA_COLOR = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

pub const Console = struct {
    const buffer: [*]volatile u16 = @ptrFromInt(0xb8000);
    const WIDTH = 80;
    const HEIGHT = 25;

    var col: u16 = 0;
    var row: u16 = 0;
    var color: u16 = 0;

    pub fn clear() void {
        for (0..HEIGHT) |height| {
            for (0..WIDTH) |width| {
                buffer[height * WIDTH + width] = 0;
            }
        }
        col = 0;
        row = 0;
    }

    pub fn setColor(char_color: VGA_COLOR, background_color: VGA_COLOR) void {
        const fc: u16 = @intFromEnum(char_color);
        const bc: u16 = @intFromEnum(background_color);
        color = (fc | (bc << 4)) << 8;
    }

    pub fn putChar(char: u8) void {
        const c: u16 = char | color;
        buffer[row * WIDTH + col] = c;

        col += 1;
        if (col >= WIDTH) {
            col = 0;
            row += 1;
        }

        if (row >= HEIGHT) {
            row = 0;
        }
    }

    pub fn write(str: []const u8) void {
        for (str) |c| {
            putChar(c);
        }
    }

    pub fn setCursorPosition(pos: u16) void {
    ports.outb(0x3D4, 14);
    ports.outb(0x3D5, @intCast(pos >> 8));

    // Send the low byte of the cursor position
    ports.outb(0x3D4, 15);
    ports.outb(0x3D5, @intCast(pos & 0xFF));
}

};
