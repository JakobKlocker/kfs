extern fn gdtFlushASM() void; // see https://devdocs.io/zig/index#Assembly

const GDT_ENTRY = packed struct {
    limit_low: u16,
    base_low: u24,
    access: GDT_ACCESS,
    limit_high: u4,
    flags: GDT_FLAGS,
    base_high: u8,
};

const GDT_ACCESS = packed struct {
    accessed: u1 = 0, //Indicates whether the segment has been accessed. DEFAUL = 0
    read_write: u1, // For data segments: Indicates whether the segment is writable.  || For code segments: Indicates whether the segment is readable.
    conforming_expand_down: u1, // For data segments: Indicates the direction of growth (0 for upward, 1 for downward). || For code segments: Indicates if the code segment is conforming.
    executable: u1, // Indicates whether the segment is executable (code segment).
    descriptor_type: u1 = 1, // Descriptor type (0 = system, 1 = code/data)
    privilege_level: u2, // Indicates the privilege level of the segment (0-3, with 0 being the highest privilege).
    present: u1 = 1, // Indicates whether the segment is present in memory.
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

const NULL_SEG = GDT_ACCESS{
    .accessed = 0,
    .conforming_expand_down = 0,
    .descriptor_type = 0,
    .executable = 0,
    .present = 0,
    .privilege_level = 0,
    .read_write = 0,
};

const KERNEL_CODE_SEG = GDT_ACCESS{
    .accessed = 0,
    .read_write = 1,
    .conforming_expand_down = 0,
    .executable = 1,
    .descriptor_type = 1,
    .privilege_level = 0,
    .present = 1,
};

const KERNEL_DATA_SEG = GDT_ACCESS{
    .accessed = 0,
    .read_write = 1,
    .conforming_expand_down = 0,
    .executable = 0,
    .descriptor_type = 1,
    .privilege_level = 0,
    .present = 1,
};

const KERNEL_STACK_SEG = GDT_ACCESS{
    .accessed = 0,
    .read_write = 1,
    .conforming_expand_down = 1, // the stack grows downwards, set to one
    .executable = 0,
    .descriptor_type = 1,
    .privilege_level = 0,
    .present = 1,
};

const USER_CODE_SEG = GDT_ACCESS{
    .accessed = 0,
    .read_write = 0, // check to do
    .conforming_expand_down = 0,
    .executable = 1,
    .descriptor_type = 1,
    .privilege_level = 3,
    .present = 1,
};

const USER_DATA_SEG = GDT_ACCESS{
    .accessed = 0,
    .read_write = 1,
    .conforming_expand_down = 0,
    .executable = 0,
    .descriptor_type = 1,
    .privilege_level = 3,
    .present = 1,
};

const USER_STACK_SEG = GDT_ACCESS{
    .accessed = 0,
    .read_write = 1,
    .conforming_expand_down = 1, // set to 1, as above stack grows down
    .executable = 0,
    .descriptor_type = 1,
    .privilege_level = 3,
    .present = 1,
};

const NULL_FLAGS = GDT_FLAGS{
    .granularity = 0,
    .is_32 = 0,
    .is_64 = 0,
    .reserved = 0,
};

const BIT32_FLAGS = GDT_FLAGS{
    .granularity = 1,
    .is_32 = 1,
    .is_64 = 0,
    .reserved = 0,
};

const gdt_entries: *[GDT_ENTRIES_LEN]GDT_ENTRY = @ptrFromInt(0x800);

const gdt_descriptor = GDT_DESCRIPTOR{
    .base = @intFromPtr(gdt_entries),
    .size = GDT_ENTRIES_LEN * @sizeOf(GDT_ENTRY) - 1,
};

//Took https://github.com/SamyPesse/How-to-Make-a-Computer-Operating-System/blob/master/Chapter-6/README.md as reference for stack setup
//should find a more in depth tutorial why/how stack is used in that segment
pub const gdt = struct {
    pub fn init() void {
        gdt_entries[0] = createGdtEntry(0, 0, NULL_SEG, NULL_FLAGS); // first GDT entry has to be NULL
        gdt_entries[1] = createGdtEntry(0, 0xFFFFF, KERNEL_CODE_SEG, BIT32_FLAGS); // Kernel Code Segment
        gdt_entries[2] = createGdtEntry(0, 0xFFFFF, KERNEL_DATA_SEG, BIT32_FLAGS); // Kernel Data Segment
        gdt_entries[3] = createGdtEntry(0, 0x0, KERNEL_STACK_SEG, BIT32_FLAGS); // Kernel Stack Segment
        gdt_entries[4] = createGdtEntry(0, 0xFFFFF, USER_CODE_SEG, BIT32_FLAGS); // User Code Segment
        gdt_entries[5] = createGdtEntry(0, 0xFFFFF, USER_DATA_SEG, BIT32_FLAGS); // User Data Segment
        gdt_entries[6] = createGdtEntry(0, 0x0, USER_STACK_SEG, BIT32_FLAGS); // User Stack Segment

        gdtInitFlush();
    }
};

pub fn gdtInitFlush() void {
    asm volatile ("lgdtl (%%eax)"
        :
        : [gdt_descriptor] "{eax}" (&gdt_descriptor),
    );
    gdtFlushASM();
}

limit_low: u16,
base_low: u24,
access: GDT_ACCESS,
limit_high: u4,
flags: GDT_FLAGS,
base_high: u8,

fn createGdtEntry(base: u32, limit: u32, access: GDT_ACCESS, flags: GDT_FLAGS) GDT_ENTRY {
    return GDT_ENTRY{
        .limit_low = @truncate(limit),
        .base_low = @truncate(base),
        .access = access,
        .limit_high = @truncate(base >> 16),
        .flags = flags,
        .base_high = @truncate(base >> 24),
    };
}

comptime {
    asm (
        \\.global gdtFlushASM;
        \\.type gdtFlushASM, @function;
        \\gdtFlushASM:
        \\ movw $0x10, %ax
        \\ movw %ax, %ds
        \\ movw %ax, %es
        \\ movw %ax, %fs
        \\ movw %ax, %gs
        \\ ljmp $0x08, $next
        \\ next: ret
    );
}
