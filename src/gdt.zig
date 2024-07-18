// pub const Gdt = struct {
//     const GDTR = packed struct {
//         limit: u16,
//         base: usize,
//     };

//     const GDT_ENTRY = packed struct {
//         limit_low: u16,
//         base_low: u16,
//         base_middle: u8,
//         access_byte: u8,
//         granularity: u8,
//         base_high: u8,
//     };

//     const GDT_ENT_LEN = 2;

//     fn createGdtEntry(base: u32, limit: u32, access: u32, granularity: u8) GDT_ENTRY {
//         return GDT_ENTRY{
//             .limit_low = @truncate(limit),
//             .base_low = @truncate((base & 0xFFFF)),
//             .base_middle = @truncate(((base >> 16) & 0xFF)),
//             .access_byte = @truncate(access),
//             .granularity = @truncate(((limit >> 16) & 0x0F) | (granularity & 0xF0)),
//             .base_high = @truncate((base >> 24) & 0xFF),
//         };
//     }

//     pub fn init() void {
//         const gdt_entries = [GDT_ENT_LEN]GDT_ENTRY{
//             createGdtEntry(0, 0, 0, 0), // Null segment
//             createGdtEntry(1, 0xFF, 0x9A, 0xCF), // Kernel Code segment
//             //createGdtEntry(2, 0xFFFFF, 0x92, 0xCF), // Kernel Data segment
//             //createGdtEntry(3, 0xFFFFF, 0x92, 0xCF), // Kernel Stack segment
//             // createGdtEntry(4, 0xFFFFF, 0xFA, 0xCF), // User Code segment
//             // createGdtEntry(5, 0xFFFFF, 0xF2, 0xCF), // User Data segment
//             // createGdtEntry(6, 0xFFFFF, 0xF2, 0xCF), // User Stack segment
//         };

//         const gdtr = GDTR{
//             .base = @intFromPtr(&gdt_entries[0]),
//             .limit = GDT_ENT_LEN * @sizeOf(GDT_ENTRY) - 1,
//         };

//         //@memcpy(@as(*[7]GDT_ENTRY, @ptrFromInt(gdtr.base)), &gdt_entries); //move the struct to 0x800

//         lgdt(&gdtr);
//     }
// };

// pub fn lgdt(gdt_ptr: *const Gdt.GDTR) void {
//     // Load the GDT into the CPU
//     asm volatile ("lgdt (%%eax)"
//         :
//         : [gdt_ptr] "{eax}" (gdt_ptr),
//     );

//     // Load the kernel data segment, index into the GDT
//     asm volatile ("mov %%bx, %%ds"
//         :
//         : [KERNEL_DATA_OFFSET] "{bx}" (0x10),
//     );

//     asm volatile ("mov %%bx, %%es");
//     asm volatile ("mov %%bx, %%fs");
//     asm volatile ("mov %%bx, %%gs");
//     asm volatile ("mov %%bx, %%ss");

//     // Load the kernel code segment into the CS register
//     asm volatile (
//         \\ljmp $0x08, $1f
//         \\1:
//     );
// }

// // const ACCESS = packed struct {
// //     accessed: u1 = 0, // Accessed flag (always 0 initially)
// //     read_write: u1, // Readable for code segments, writable for data segments
// //     conforming_expand_down: u1, // Conforming for code, expand down for data
// //     executable: u1, // Executable flag (1 for code segments)
// //     descriptor_type: u1 = 1, // Descriptor type (0 = system, 1 = code/data)
// //     privilege_level: u2, // Descriptor privilege level
// //     present: u1 = 1, // Present flag
// // };

const GDTEntry = packed struct { limit: u16, base_low: u16, base_middle: u8, access: u8, flags: u8, base_high: u8 };

const TSSEntry = packed struct { prev_tss: u32, esp0: u32, ss0: u32, esp1: u32, ss1: u32, esp2: u32, ss2: u32, cr3: u32, eip: u32, eflags: u32, eax: u32, ecx: u32, edx: u32, ebx: u32, esp: u32, ebp: u32, esi: u32, edi: u32, es: u32, cs: u32, ss: u32, ds: u32, fs: u32, gs: u32, ldt: u32, trap: u32, iomap_base: u32 };

const GDTPointer = packed struct { limit: u16, base: *GDTEntry };

var gdt_entries: [6]GDTEntry = undefined;

var tss_entry: TSSEntry = .{
    .prev_tss = 0,
    .esp0 = 0,
    .ss0 = 0,
    .esp1 = 0,
    .ss1 = 0,
    .esp2 = 0,
    .ss2 = 0,
    .cr3 = 0,
    .eip = 0,
    .eflags = 0,
    .eax = 0,
    .ecx = 0,
    .edx = 0,
    .ebx = 0,
    .esp = 0,
    .ebp = 0,
    .esi = 0,
    .edi = 0,
    .es = 0,
    .cs = 0,
    .ss = 0,
    .ds = 0,
    .fs = 0,
    .gs = 0,
    .ldt = 0,
    .trap = 0,
    .iomap_base = 0,
};

var gdt_pointer: GDTPointer = undefined;

comptime {
    asm (
        \\ .type gdtFlush, @function
        \\ gdtFlush:
        \\     mov +4(%esp), %eax
        \\     lgdt (%eax)
        \\     mov $0x10, %ax
        \\     mov %ax, %ds
        \\     mov %ax, %es
        \\     mov %ax, %fs
        \\     mov %ax, %gs
        \\     mov %ax, %ss
        \\     ljmp $0x08, $1f
        \\ 1: ret
    );
}

comptime {
    asm (
        \\ .type tssFlush, @function
        \\ tssFlush:
        \\     mov $0x2B, %ax
        \\     ltr %ax
        \\     ret
    );
}

extern fn gdtFlush(*const GDTPointer) void;

extern fn tssFlush() void;

fn writeTSS(num: u32, ss0: u16, esp0: u32) void {
    const base: u32 = @intFromPtr(&tss_entry);
    const limit: u32 = base + @sizeOf(TSSEntry);

    gdtSetGate(num, base, limit, 0xE9, 0x00);

    tss_entry.ss0 = ss0;
    tss_entry.esp0 = esp0;
    tss_entry.cs = 0x08 | 0x3;
    tss_entry.ss = 0x10 | 0x3;
    tss_entry.ds = 0x10 | 0x3;
    tss_entry.es = 0x10 | 0x3;
    tss_entry.fs = 0x10 | 0x3;
    tss_entry.gs = 0x10 | 0x3;
}

pub fn gdtInit() void {
    gdt_pointer.limit = @sizeOf(GDTEntry) * 6 - 1;
    gdt_pointer.base = &gdt_entries[0];

    gdtSetGate(0, 0, 0, 0, 0);
    gdtSetGate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
    gdtSetGate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
    gdtSetGate(3, 0, 0xFFFFFFFF, 0xFA, 0xCF);
    gdtSetGate(4, 0, 0xFFFFFFFF, 0xF2, 0xCF);
    writeTSS(5, 0x10, 0x0);
    gdtFlush(&gdt_pointer);
    tssFlush();
}

pub fn gdtSetGate(num: u32, base: u32, limit: u32, access: u8, flags: u8) void {
    gdt_entries[num].base_low = @truncate(base);
    gdt_entries[num].base_middle = @truncate(base >> 16);
    gdt_entries[num].base_high = @truncate(base >> 24);
    gdt_entries[num].limit = @truncate(limit);
    gdt_entries[num].flags = @truncate(limit >> 16);
    gdt_entries[num].flags |= (flags & 0xF0);
    gdt_entries[num].access = access;
}
