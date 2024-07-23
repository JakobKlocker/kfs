const vga = @import("console.zig");
const console = @import("console.zig").Console;

const IDT = packed struct {
    limit: u16,
    base: usize,
};

const IDTEntry = packed struct {
    offset1: u16 = 0,
    selector: u16 = 0,
    zero: u8 = 0,
    type_attr: u8 = 0,
    offset2: u16 = 0,
};

var idt: [256]IDTEntry = undefined;
var idt_descriptor: IDT = undefined;

pub fn init_idt() void {
    idt_descriptor = IDT{
        .limit = @sizeOf(@TypeOf(idt)) - 1,
        .base = @intFromPtr(&idt),
    };

    for (&idt) |*entry| {
        entry.* = IDTEntry{};
    }

    set_idt_entry(&idt[0x21], @intFromPtr(&testing), 0x08, 0x8E);

    load_idt(&idt_descriptor);
}

pub inline fn load_idt(idtr: *IDT) void {
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

pub fn set_idt_entry(entry: *IDTEntry, handler: usize, selector: u16, type_attr: u8) void {
    entry.offset1 = @intCast(handler & 0xFFFF);
    entry.selector = selector;
    entry.type_attr = type_attr;
    entry.offset2 = @intCast((handler >> 16) & 0xFFFF);
}
