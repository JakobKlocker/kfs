// Function to write a byte to a specific I/O port
pub inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
    );
}

// Function to read a byte the value of a certain port
pub inline fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[value]"
        : [value] "={al}" (-> u8),
        : [port] "N{dx}" (port),
    );
}

//Wait a very small amount of time (1 to 4 microseconds, generally).
pub inline fn io_wait() void {
    outb(0x80, 0);
}
