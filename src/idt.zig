extern fn idtFlushASM() void;

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

const idt_descriptor = IDT_DESCRIPTOR{
    .base = @intFromPtr(&idt_entires),
    .limit = @sizeOf(idt_entires) * 256 - 1,
};

pub const idt = struct {
    pub fn init() void {
        @memset(&idt_entires, IDT_ENTRY{});

        //set gates next

        //flush IDK

    }
};
pub inline fn idtInitFlush(idtr: *IDT_DESCRIPTOR) void {
    asm volatile ("lidt (%%eax)"
        :
        : [idtr] "{eax}" (idtr),
    );
    asm volatile ("sti");
}

pub fn testing() void {
    console.write("called");
    asm volatile ("iret");
}

pub fn setIdtEntry(entry: *idt_entires, offset: usize, selector: u16, flags: u8) void {
    entry.base_low = @truncate(offset);
    entry.selector = selector;
    entry.flags = flags;
    entry.base_high = @truncate((offset >> 16));
}
