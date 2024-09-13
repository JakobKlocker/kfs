const ports = @import("ports.zig");
const print = @import("print.zig");
const cmds = @import("cmds.zig").cmds;
const string = @import("string.zig");

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

    var cmd: [255]u8 = undefined;

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
        if (char == 0x08) { // this is for deleting a character in the console
            if (col[buf] == 0) return;
            if (col[buf] % WIDTH == 0) return;

            while (buffer[buf][col[buf]] == 0) col[buf] -= 1;
            buffer[buf][col[buf]] = 0;
            renderBuffer(buf) catch unreachable;
            if (col[buf] != 0)
                setCursorPosition(@intCast(col[buf] - 1));
            return;
        }

        if (char == '\n') {
            col[buf] += WIDTH - (col[buf] % WIDTH);
            if (col[buf] >= HISTORY * WIDTH)
                col[buf] = 0;
            buffer[buf][col[buf]] = '\n';
            renderBuffer(buf) catch unreachable;
            return;
        }
    }

    fn putChar(char: u8) void {
        const buf = activ_buffer;
        const row = col[buf] / WIDTH;

        specialChars(char); // handel special character like enter and delte
        if (char < 32 or char > 126) return; // allow only printable ascii charaters to be printed to the screen

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

    pub fn getCmd() void {
        const buf = activ_buffer;
        const row = col[buf] / WIDTH;
        const size = col[buf] % WIDTH;

        const start_index = row * WIDTH;
        const end_index = start_index + size + 1;

        const cmd_with_color = buffer[buf][start_index..end_index];
        bufferCmdToStr(cmd_with_color);
        if (string.strcmp(@constCast(&cmd), "reboot")) {
            cmds.reboot();
        } else if (string.strcmp(@constCast(&cmd), "shutdown")) {
            cmds.shutdown();
        } else if (string.strcmp(@constCast(&cmd), "halt")) {
            cmds.halt();
        } else if (string.strcmp(@constCast(&cmd), "stack")) {
            print.printStack();
        } else {
            setColor(VGA_COLOR.Black, VGA_COLOR.Red);
            write("\nCommand not found");
            setColor(VGA_COLOR.White, VGA_COLOR.Black);
        }
    }

    pub fn bufferCmdToStr(buffer_cmd: []u16) void {
        var size: usize = 0;

        while (size < buffer_cmd.len) {
            cmd[size] = @truncate(buffer_cmd[size]);
            size += 1;
        }
        cmd[size] = 0;
    }
};
