const ports = @import("ports.zig");

pub fn remap_pic(offset1: u8, offset2: u8) void {
    // can read the data here first, in and add it at the end agian in case there are other interupts

    //ICW1 - begin initialization
    ports.outb(0x20, 0x11);
    ports.outb(0xA0, 0x11);

    ports.io_wait();

    //ICW2 - remap offset address of IDT || Has to be past 0x20, first 32 interupts are reserverd for cpu exceptions
    ports.outb(offset1, 0x20);
    ports.outb(offset2, 0x28);

    ports.io_wait();

    // ICW3 - setup cascading
    ports.outb(0x21, 0x00);
    ports.outb(0xA1, 0x00);

    ports.io_wait();

    // ICW4 - environment info
    ports.outb(0x21, 0x01);
    ports.outb(0xA1, 0x01);
    // Initialization finished

    ports.io_wait();

    // mask interrupts
    ports.outb(0x21, 0xff);
    ports.outb(0xA1, 0xff);
}

pub fn remapNew() void {
    ports.outb(0x20, 0x11);
    ports.outb(0xA0, 0x11);

    ports.outb(0x21, 0x20);
    ports.outb(0xA1, 0x28);

    ports.outb(0x21, 0x04);
    ports.outb(0xA1, 0x02);

    ports.outb(0x21, 0x01);
    ports.outb(0xA1, 0x01);

    ports.outb(0x21, 0x00);
    ports.outb(0xA1, 0x00);
}
