const console = @import("console.zig").Console;

const State = enum {
    start,
    open,
    close,
};

fn printInt(arg: anytype) void {
    if (arg < 0) {
        console.write("-");
        printInt(-arg);
    }
    else if (arg < 10) {
        console.write(&[_]u8{@intCast(arg + '0')});
    } 
    else {
        printInt(@divTrunc(arg, 10));
        printInt(@mod(arg, 10));
    }
}

fn printHex(arg: anytype) void {
    if (arg < 0) {
        console.write("-");
        printHex(-arg);
    }
    else if (arg < 16) {
        if (arg < 10)
            console.write(&[_]u8{@intCast(arg + '0')})
        else
            console.write(&[_]u8{@intCast(arg - 10 + 'A')});
    } 
    else {
        printHex(@divTrunc(arg, 16));
        printHex(@mod(arg, 16));
    }
}

fn printPointer(arg: anytype) void {
    console.write(@typeName(@TypeOf(arg.*)));
    console.write("@0x");
    printHex(@intFromPtr(arg));
}

fn handleTypes(arg: anytype) void {
    switch (@typeInfo(@TypeOf(arg))) {
        .Int => printInt(arg),
        .Float => @compileError("Error: Floats not supported"),
        .Pointer => printPointer(arg),
        else => switch (@TypeOf(arg)) {
            comptime_int => printInt(arg),
            comptime_float => @compileError("Error: Floats not supported"),
            else => @compileError("Error: Unsupported type")
        }
    }
}

fn handelChars(arg: anytype) void {
    if (@TypeOf(arg) == u8) {
        console.write(&[_]u8{arg});
        return;
    }
    
    const printarg: []const u8 = @ptrCast(arg);
    console.write(printarg);

}

pub fn print(comptime format:  []const u8, args: anytype) void {
    comptime var state: State = State.start;
    comptime var arg_index: usize = 0;
    comptime var index: usize = 0;
    comptime var printChar: bool = false;

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
                    if (printChar)
                        handelChars(args[arg_index])
                    else
                        handleTypes(args[arg_index]);
                    printChar = false;
                    arg_index += 1;
                    state = State.start;
                    index = i + 1;
                },
                'c' => printChar = true,
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

