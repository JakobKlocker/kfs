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
    const VGABUFFER: [*]volatile u16 = @ptrFromInt(0xb8000);
    const HISTORY = 1000;
    const WIDTH = 80;
    const HEIGHT = 25;
    const BUFFERS = 8;

    var buffer: [BUFFERS][HISTORY * WIDTH]u16 = undefined;
    var activ_buffer: usize = 0;
    var col = [_]usize{0} ** BUFFERS;
    var color: u16 = 0;

    var offset: usize = 0;

    pub fn clear() void {
        for (0..HISTORY) |height| {
            for (0..WIDTH) |width| {
                buffer[activ_buffer][height * WIDTH + width] = 0;
            }
        }
        col[activ_buffer] = 0;
    }

    pub fn setColor(char_color: VGA_COLOR, background_color: VGA_COLOR) void {
        const fc: u16 = @intFromEnum(char_color);
        const bc: u16 = @intFromEnum(background_color);
        color = (fc | (bc << 4)) << 8;
    }

    pub fn setActiveBuffer(buf: usize) !void {
        activ_buffer = buf;
        try renderBuffer(activ_buffer);
    }

    fn renderBuffer(buf: usize) !void {
        if (buf >= BUFFERS) return error.BUFFER_ERROR;
        var row = col[buf] / WIDTH;
        offset = 0;
        if (row >= HEIGHT)
            offset = row - (HEIGHT - 1);

        for (0..HEIGHT) |r| {
            for (0..WIDTH) |c| {
                VGABUFFER[r * WIDTH + c] = buffer[buf][(r + offset) * WIDTH + c];
            }
        }
        if (row >= HEIGHT)
            row = HEIGHT - 1;
        setCursorPosition(@intCast(row * WIDTH + (col[buf] % WIDTH)));
    }

    fn specialChars(char: u8) void {
        const buf = activ_buffer;
        const row = col[buf] / WIDTH;
        if (char == 0x08) {
            if (col[buf] == 0) return;

            col[buf] -= 1;
            buffer[buf][row * WIDTH + (col[buf] % WIDTH)] = 0;
            renderBuffer(buf) catch unreachable; // todo: check last char when deleting
            return ;
        }
        
        if (char == '\n') {
            col[buf] += WIDTH - (col[buf] % WIDTH);
            if (col[buf] >= HISTORY * WIDTH)
                col[buf] = 0;
            renderBuffer(buf) catch unreachable;
            return ;
        }
    }

    fn putChar(char: u8) void {
        const buf = activ_buffer;
        const row = col[buf] / WIDTH;

        specialChars(char);
        if (char < 32 or char > 126) return ; // allow only printable ascii charaters to be printed to the screen

        const c: u16 = char | color;
        buffer[buf][row * WIDTH + (col[buf] % WIDTH)] = c;

        renderBuffer(buf) catch unreachable;

        col[buf] += 1;
        if (col[buf] >= HISTORY * WIDTH) {
            col[buf] = 0;
        }
    }

    pub fn write(str: []const u8) void {
        for (str) |c| {
            putChar(c);
        }
    }

    fn setCursorPosition(pos: u16) void {
        ports.outb(0x3D4, 14);
        ports.outb(0x3D5, @intCast(pos >> 8));

        // Send the low byte of the cursor position
        ports.outb(0x3D4, 15);
        ports.outb(0x3D5, @intCast(pos & 0xFF));
    }
 
    pub fn scrollUp() void {
        if (offset <= 1) offset = 1;
        offset -= 1;
        for (0..HEIGHT) |r| {
            for (0..WIDTH) |c| {
                VGABUFFER[r * WIDTH + c] = buffer[activ_buffer][(r + offset) * WIDTH + c];
            }
        }
    }

    pub fn scrollDown() void {
        const row = col[activ_buffer] / WIDTH;
        if (row < 25) return;
        offset += 1;
        if (offset >= row - 24) offset = row - 24;
        for (0..HEIGHT) |r| {
            for (0..WIDTH) |c| {
                VGABUFFER[r * WIDTH + c] = buffer[activ_buffer][(r + offset) * WIDTH + c];
            }
        }
    }

    pub fn nextBuf() void {
        if (activ_buffer < BUFFERS - 1) {
            activ_buffer += 1;
        } else {
            activ_buffer = 0;
        }
        renderBuffer(activ_buffer) catch unreachable;
    }

    pub fn prevBuf() void {
        if (activ_buffer == 0) {
            activ_buffer = BUFFERS - 1;
        } else {
            activ_buffer -= 1;
        }
        renderBuffer(activ_buffer) catch unreachable;
    }
};
