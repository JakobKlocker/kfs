// extern fn isr0() void;
// extern fn isr1() void;
// extern fn isr2() void;
// extern fn isr3() void;
// extern fn isr4() void;
// extern fn isr5() void;
// extern fn isr6() void;
// extern fn isr7() void;
// extern fn isr8() void;
// extern fn isr9() void;
// extern fn isr10() void;
// extern fn isr11() void;
// extern fn isr12() void;
// extern fn isr13() void;
// extern fn isr14() void;
// extern fn isr15() void;
// extern fn isr16() void;
// extern fn isr17() void;
// extern fn isr18() void;
// extern fn isr19() void;
// extern fn isr20() void;
// extern fn isr21() void;
// extern fn isr22() void;
// extern fn isr23() void;
// extern fn isr24() void;
// extern fn isr25() void;
// extern fn isr26() void;
// extern fn isr27() void;
// extern fn isr28() void;
// extern fn isr29() void;
// extern fn isr30() void;
// extern fn isr31() void;
// extern fn isr32() void;
// extern fn isr33() void;
// extern fn isr34() void;
// extern fn isr35() void;
// extern fn isr36() void;
// extern fn isr37() void;
// extern fn isr38() void;
// extern fn isr39() void;
// extern fn isr40() void;
// extern fn isr41() void;
// extern fn isr42() void;
// extern fn isr43() void;
// extern fn isr44() void;
// extern fn isr45() void;
// extern fn isr46() void;
// extern fn isr47() void;
// extern fn isr128() void;
// extern fn isr177() void;

var error_messages = [_][]const u8{ "Division By Zero", "Debug", "Non Maskable Interrupt", "Breakpoint", "Into Detected Overflow", "Out of Bounds", "Invalid Opcode", "No Coprocessor", "Double fault", "Coprocessor Segment Overrun", "Bad TSS", "Segment not present", "Stack fault", "General protection fault", "Page fault", "Unknown Interrupt", "Coprocessor Fault", "Alignment Fault", "Machine Check", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved" };

const vga = @import("console.zig");
const console = @import("console.zig").Console;

const IDT_DESCRIPTOR = packed struct {
    limit: u16,
    base: u32,
};

const IDT_ENTRY = packed struct {
    base_low: u16 = 0,
    selector: u16 = 0,
    reserverd_zero: u8 = 0,
    flags: u8 = 0,
    base_high: u16 = 0,
};

var idt_entires: [256]IDT_ENTRY = undefined;

var idt_descriptor = IDT_DESCRIPTOR{ .base = 0, .limit = 0 };

extern fn keyboard_isr() void;

pub const idt = struct {
    pub fn init() void {
        for (&idt_entires) |*entry| {
            entry.* = IDT_ENTRY{};
        }
        //@memset(&idt_entires, IDT_ENTRY{});
        idt_descriptor.base = @intFromPtr(&idt_entires[0]);
        idt_descriptor.limit = @sizeOf(IDT_ENTRY) * 256 - 1;

        //set gates next
        // setIdtEntry(&idt_entires[0], @intFromPtr(&isr0), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[1], @intFromPtr(&isr1), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[2], @intFromPtr(&isr2), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[3], @intFromPtr(&isr3), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[4], @intFromPtr(&isr4), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[5], @intFromPtr(&isr5), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[6], @intFromPtr(&isr6), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[7], @intFromPtr(&isr7), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[8], @intFromPtr(&isr8), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[9], @intFromPtr(&isr9), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[10], @intFromPtr(&isr10), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[11], @intFromPtr(&isr11), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[12], @intFromPtr(&isr12), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[13], @intFromPtr(&isr13), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[14], @intFromPtr(&isr14), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[15], @intFromPtr(&isr15), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[16], @intFromPtr(&isr16), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[17], @intFromPtr(&isr17), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[18], @intFromPtr(&isr18), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[19], @intFromPtr(&isr19), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[20], @intFromPtr(&isr20), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[21], @intFromPtr(&isr21), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[22], @intFromPtr(&isr22), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[23], @intFromPtr(&isr23), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[24], @intFromPtr(&isr24), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[25], @intFromPtr(&isr25), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[26], @intFromPtr(&isr26), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[27], @intFromPtr(&isr27), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[28], @intFromPtr(&isr28), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[29], @intFromPtr(&isr29), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[30], @intFromPtr(&isr30), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[31], @intFromPtr(&isr31), 0x08, 0x8E);

        // setIdtEntry(&idt_entires[32], @intFromPtr(&isr32), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[33], @intFromPtr(&isr33), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[34], @intFromPtr(&isr34), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[35], @intFromPtr(&isr35), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[36], @intFromPtr(&isr36), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[37], @intFromPtr(&isr37), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[38], @intFromPtr(&isr38), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[39], @intFromPtr(&isr39), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[40], @intFromPtr(&isr40), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[41], @intFromPtr(&isr41), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[42], @intFromPtr(&isr42), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[43], @intFromPtr(&isr43), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[44], @intFromPtr(&isr44), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[45], @intFromPtr(&isr45), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[46], @intFromPtr(&isr46), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[47], @intFromPtr(&isr47), 0x08, 0x8E);

        // setIdtEntry(&idt_entires[128], @intFromPtr(&isr128), 0x08, 0x8E);
        // setIdtEntry(&idt_entires[177], @intFromPtr(&isr177), 0x08, 0x8E);

        setIdtEntry(&idt_entires[0x21], @intFromPtr(&keyboard_isr), 0x08, 0x8E);

        //flush idt
        idtInitFlush(&idt_descriptor);
    }
};

pub inline fn idtInitFlush(idtr: *IDT_DESCRIPTOR) void {
    asm volatile ("lidt (%%eax)"
        :
        : [idtr] "{eax}" (idtr),
    );
    asm volatile ("sti");
}

pub fn setIdtEntry(entry: *IDT_ENTRY, offset: usize, selector: u16, flags: u8) void {
    entry.base_low = @truncate(offset);
    entry.selector = selector;
    entry.flags = flags;
    entry.base_high = @truncate((offset >> 16));
}

export fn handle_keyboard() void {
    vga.Console.write("worked");
}

// keyboard_isr:
//     pusha
//     call handle_keyboard  ; Call the C function to handle the keyboard input
//     popa
//     ; Send End of Interrupt (EOI) to the PICs
//     mov al, 0x20
//     out 0x20, al
//     iret

comptime {
    asm (
        \\.global keyboard_isr;
        \\.type keyboard_isr, @function;
        \\.extern handle_keyboard
        \\keyboard_isr:
        \\ pusha
        \\ call handle_keyboard
        \\ popa
        \\ mov $0x20, %al
        \\ out %al, $0x20
        \\ iret
    );
}
