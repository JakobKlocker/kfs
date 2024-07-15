const GDTR = packed struct {
    limit: u16,
    base: usize,
};

const GDT_ENTRY = packed struct {
    limit_low: u16,
    base_low: u16,
    base_middle: u8,
    access_byte: u8,
    granularity: u8,
    base_high: u8,
};

const ACCESS = packed struct {
    accessed: u1 = 0, // Accessed flag (always 0 initially)
    read_write: u1, // Readable for code segments, writable for data segments
    conforming_expand_down: u1, // Conforming for code, expand down for data
    executable: u1, // Executable flag (1 for code segments)
    descriptor_type: u1 = 1, // Descriptor type (0 = system, 1 = code/data)
    privilege_level: u2, // Descriptor privilege level
    present: u1 = 1, // Present flag
};

pub fn createGdtEntry(base: u32, limit: u32, access: ACCESS, granularity: u8) GDT_ENTRY {
    return GDT_ENTRY{
        .limit_low = (limit & 0xFFFF),
        .base_low = (base & 0xFFFF),
        .base_middle = ((base >> 16) & 0xFF),
        .access = access,
        .granularity = ((limit >> 16) & 0x0F) | (granularity & 0xF0),
        .base_high = (base >> 24) & 0xFF,
    };
}
