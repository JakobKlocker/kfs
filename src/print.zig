const console = @import("console.zig").Console;

fn printInt(arg: anytype) void {
    var val: isize = arg;
    var buffer: [128]u8 = undefined;
    // if (val == 0) {
        // console.write("0");
        // return ;
    // }
    val = 0;
    buffer[0] = 0;

    // var sign = false;
    // if (val < 0) sign = true;

    // var i: usize = 0;
    // while (val != 0) : (i += 1) {
        // buffer[i] = @intCast(@mod(val, 10) + '0');
        // val = @divTrunc(val, 10);
    // }

    // if (sign) {
        // buffer[i] = '-';
        // i += 1;
    // }

    // while (i >= 0) {
        // console.write(&[_]u8{buffer[i]});
        // i -= 1;
    // }
}

fn printComptimeInt(arg: anytype) void {
    comptime var val = arg;
    inline while (val != 0) {
        const c: u8 = @intCast((val % 10) + '0');
        console.write(&[_]u8{c});
        val /= 10;
    }
}

fn printFloat(arg: anytype) void {
    console.write(@typeName(@TypeOf(arg)) ++ "float");
}

fn printComptimeFloat(arg: anytype) void {
    console.write(@typeName(@TypeOf(arg)) ++ "float");
}

fn printPointer(arg: anytype) void {
    console.write(@typeName(@TypeOf(arg)) ++ "pointer");
}

fn handleTypes(arg: anytype) void {
    switch (@typeInfo(@TypeOf(arg))) {
        .Int => printInt(arg),
        .Float => printFloat(arg),
        .Pointer => printPointer(arg),
        else => switch (@TypeOf(arg)) {
            comptime_int => printComptimeInt(arg),
            comptime_float => printComptimeFloat(arg),
            else => {
                console.write(@typeName(@TypeOf(arg)) ++ "lol");

            }
        }
    }
}

pub fn print(comptime format:  []const u8, args: anytype) void {
    const State = enum {
        start,
        open,
        close,
    };

    comptime var state: State = State.start;
    comptime var arg_index: usize = 0;
    comptime var index: usize = 0;

    inline for (format, 0..) |c, i| {
        switch (state) {
            State.start => switch (c) {
                '{' => {
                    if (index < i) console.write(format[index..i]);
                    state = State.open;
                },
                '}' => {
                    if (index < i) console.write(format[index..i]);
                    state = State.close;
                },
                else => {}
            },
            State.open => switch (c) {
                '{' => {
                    state = State.start;
                    index = i;
                },
                '}' => {
                    handleTypes(args[arg_index]);
                    arg_index += 1;
                    state = State.start;
                    index = i + 1;
                },
                else => @compileError("Unknown format: " ++ [1]u8{c}),
            },
            State.close => switch (c) {
                '}' => {
                    state = State.start;
                    index = i;
                },
                else => @compileError("Single '}' encountered"),
            }
        }
    }
    comptime {
        if (args.len != arg_index) {
            @compileError("Unused arguments");
        }
        if (state != State.start) {
            @compileError("Incomplete format string: " ++ format);
        }
    }
    if (index < format.len) {
        console.write(format[index..format.len]);
    }
}

