const vga = @import("vga.zig");


const IDTPointer = packed struct {
    limit: u16,
    base: usize,
};


// pub fn load_idt() !void {
//     var idtr : IDTPointer = undefined;
//     idtr.base = &idt_entry;
//     idtr.limit = sizeof(idt_entry) - 1;

//     asm volatile ("lidt [%%eax]" :
//     "{rax}" (idtr));
// }


const IDTEntry = packed struct {
    base_lo: u16 = 0,
    sel: u16= 0,
    zero: u8= 0,
    flags: u8= 0,
    base_hi: u16 = 0,
};

const idt_entry = IDTEntry{};

#define KEYBOARD_IRQ 1



pub fn setup_keyboard_idt_entry() void {
    var isr_base :u32 = @intFromPtr(keyboard_test);

    var selector_code_segment: u16 = 0x08;

    // Populate the IDT entry for keyboard interrupt
    idt_entry.offset_low = isr_base & 0xFFFF;
    idt_entry.segment_selector = selector_code_segment;
    idt_entry.reserved = 0;
    idt_entry.type_attr = 0x8E;
    idt_entry.offset_high = (isr_base >> 16) & 0xFFFF;
}

pub fn keyboard_test() !void {
    vga.printChar('Z');    
}