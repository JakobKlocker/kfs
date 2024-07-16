pub const Gdt = struct {
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

    fn createGdtEntry(base: u32, limit: u32, access: u32, granularity: u8) GDT_ENTRY {
        return GDT_ENTRY{
            .limit_low = (limit & 0xFFFF),
            .base_low = (base & 0xFFFF),
            .base_middle = ((base >> 16) & 0xFF),
            .access_byte = access,
            .granularity = ((limit >> 16) & 0x0F) | (granularity & 0xF0),
            .base_high = (base >> 24) & 0xFF,
        };
    }

    const gdt_entries: [7]GDT_ENTRY = .{
        createGdtEntry(0, 0, 0, 0), // Null segment
        createGdtEntry(0, 0xFFFFF, 0x9A, 0xCF), // Kernel Code segment
        createGdtEntry(0, 0xFFFFF, 0x92, 0xCF), // Kernel Data segment
        createGdtEntry(0, 0xFFFFF, 0x92, 0xCF), // Kernel Stack segment
        createGdtEntry(0, 0xFFFFF, 0xFA, 0xCF), // User Code segment
        createGdtEntry(0, 0xFFFFF, 0xF2, 0xCF), // User Data segment
        createGdtEntry(0, 0xFFFFF, 0xF2, 0xCF), // User Stack segment
    };

    pub fn init() void {
        const gdtr = GDTR{
            .base = 0x00000800, // Base as defined in Subject
            .limit = 7 * @sizeOf(GDT_ENTRY) - 1,
        };

        const gdt_ptr: [*]GDT_ENTRY = @ptrFromInt(gdtr.base);

        @memcpy(gdt_ptr, &gdt_entries);

        asm volatile ("lgdtl (%%eax)"
            :
            : [gdtr] "{eax}" (&gdtr),
        );
    }
};

// const ACCESS = packed struct {
//     accessed: u1 = 0, // Accessed flag (always 0 initially)
//     read_write: u1, // Readable for code segments, writable for data segments
//     conforming_expand_down: u1, // Conforming for code, expand down for data
//     executable: u1, // Executable flag (1 for code segments)
//     descriptor_type: u1 = 1, // Descriptor type (0 = system, 1 = code/data)
//     privilege_level: u2, // Descriptor privilege level
//     present: u1 = 1, // Present flag
// };
