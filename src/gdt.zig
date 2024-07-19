const GDT_ENTRY = packed struct {
    limit_low: u16,
    base_low: u16,
    base_mid: u8,
    access: GDT_ACCESS,
    limit_high: u4,
    flags: GDT_FLAGS,
    base_high: u8,
};

const GDT_ACCESS = packed struct {
    accessed: u1 = 0, // Accessed flag (always 0 initially)
    read_write: u1, // Readable for code segments, writable for data segments
    conforming_expand_down: u1, // Conforming for code, expand down for data
    executable: u1, // Executable flag (1 for code segments)
    descriptor_type: u1 = 1, // Descriptor type (0 = system, 1 = code/data)
    privilege_level: u2, // Descriptor privilege level
    present: u1 = 1, // Present flag
};

const GDT_FLAGS = packed struct {
    reserved: u1 = 0, //always 0
    is_64: u1,
    is_32: u1,
    granularity: u1,
};

const GDT_DESCRIPTOR = packed struct {
    size: u16,
    base: u32,
};
const GDT_ENTRIES_LEN = 7;

const gdt_entries: *[GDT_ENTRIES_LEN]GDT_ENTRY = @ptrFromInt(0x800);

const gdt_descriptor = GDT_DESCRIPTOR{
    .base = @intFromPtr(gdt_entries),
    .size = GDT_ENTRIES_LEN * @sizeOf(GDT_ENTRY) - 1,
};

const gdt = struct {
    pub fn init() void {}
};
