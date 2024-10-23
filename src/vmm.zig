const pmm = @import("PMM.zig");

//Virtual Address Format
//AAAAAAAAAA         BBBBBBBBBB        CCCCCCCCCCCC
// directory index    page table index  offset into page

//https://wiki.osdev.org/images/6/60/Page_table_entry.png
const PAGE_PTE = packed struct(u32) {
    PTE_PRESENT: u1 = 0, // 1 bit for Present (P)
    PTE_WRITABLE: u1 = 0, // 1 bit for Read/Write (RW)
    PTE_USER: u1 = 0, // 1 bit for User/Supervisor (U/S)
    PTE_WRITETHROUGH: u1 = 0, // 1 bit for Write-through (PWT)
    PTE_NOT_CACHEABLE: u1 = 0, // 1 bit for Cache Disable (PCD)
    PTE_ACCESSED: u1 = 0, // 1 bit for Accessed (A)
    PTE_DIRTY: u1 = 0, // 1 bit for Dirty (D)
    PTE_PAT: u1 = 0, // 1 bit for Page Attribute Table (PAT)
    PTE_CPU_GLOBAL: u1 = 0, // 1 bit for Global Page (G)
    PTE_AVL: u3 = 0, // 3 bits (AVL/UNUSED)
    PTE_FRAME: u20 = 0, // 20 bits for the frame address (physical page)
};

//Page Directory Entry
const PAGE_PDE = packed struct(u32) {
    PDE_PRESENT: u1 = 0, // 1 bit for Present (P)
    PDE_WRITABLE: u1 = 0, // 1 bit for Read/Write (RW)
    PDE_USER: u1 = 0, // 1 bit for User/Supervisor (U/S)
    PDE_WRITETHROUGH: u1 = 0, // 1 bit for Write-through (PWT)
    PDE_NOT_CACHEABLE: u1 = 0, // 1 bit for Cache Disable (PCD)
    PDE_ACCESSED: u1 = 0, // 1 bit for Accessed (A)
    PDE_UNUSED: u1 = 0, // 1 bit
    PDE_PAT: u1 = 0, // 1 bit for Page Attribute Table (PAT)
    PDE_UNUSED1: u4 = 0, // 3 bits (AVL/UNUSED)
    PDE_FRAME: u20 = 0, // 20 bits for the frame address (physical page)
};

const PAGES_SIZE = 4096;
const PAGES_PER_TABLE = 1024;
const PAGES_PER_DIR = 1024;
const PTABLE_ADDR_SPACE_SIZE = 0x400000;
const DTABLE_ADDR_SPACE_SIZE = 0x100000000;

const PAGE_TABLE_STRUCT = struct {
    const pages: [PAGES_PER_TABLE]PAGE_PTE = {};
};

const PAGE_DIRECTORY_STRUCT = struct {
    const entrys: [PAGES_PER_DIR]PAGE_PDE = {};
};

const PAGE_TABLES: [PAGES_PER_TABLE]PAGE_TABLE_STRUCT = undefined;
const PAGE_DIRECTORY: PAGE_DIRECTORY_STRUCT = undefined;
var current_page_directory: *PAGE_DIRECTORY_STRUCT = undefined;
var current_physical_pd: PAGE_PDE = PAGE_PDE{};

pub fn page_directory_index(virtual_addr: u32) u32 {
    return (virtual_addr >> 22) & 0x3FF;
}

pub fn page_table_index(virtual_addr: u32) u32 {
    return (virtual_addr >> 12) & 0x3FF;
}

//clear lowest 12 bits, if address is 0x12345ABC make it to 0x12345000, since that will be the frame (only 20 bits)
//so it clears the flags, and just keeps the frame when calling it with a PTE
pub fn get_frame(pte: u32) u32 {
    return pte & 0xFFFFF000;
}

//TODO: Allocate real physical block & cast to PAGE_PTE, replace test_page
pub fn alloc_page(page_table_entry: *PAGE_PTE) *PAGE_PTE {
    //alloc physical block instead of test_page
    const page = pmm.getPages(1);
    page_table_entry.PTE_FRAME = get_frame(page); // not sure if get_frame is correct here
    page_table_entry.PTE_PRESENT = 1;
    return page;
}

//TODO: Call physical function to free phyiscal memory here
pub fn free_page(page_table_entry: *PAGE_PTE) void {
    //call function to FREE
    page_table_entry.PTE_PRESENT = 0;
}

// no Null check, look into zigs checking later
pub fn page_table_entry_lookup(page_table: *PAGE_TABLE_STRUCT, virtual_addr: u32) *PAGE_PTE {
    return &page_table.*.pages[page_table_index(virtual_addr)];
}

// no Null check, look into zigs checking later
pub fn page_directory_entry_lookup(page_directory: *PAGE_DIRECTORY_STRUCT, virtual_addr: u32) *PAGE_PDE {
    return &page_directory.*.entrys[page_directory_index(virtual_addr)];
}

pub fn get_page(virtual_addr: u32) *PAGE_PTE {
    // get page directory
    const page_directory = current_page_directory;

    //get page table in directory
    const page_directory_entry = page_directory_entry_lookup(page_directory, virtual_addr);

    //Clear the flags, so I have only the Page Table Pointer
    const page_table: *PAGE_PTE = get_frame(page_directory_entry);

    //get page in table
    const page: *PAGE_PTE = &page_table.*[page_table_index(virtual_addr)];
    return page;
}

//TODO: Check how to add a u32 to Frame correctly!!! Important for all functions, where I set/get the frame
pub fn map_page(virtual_addr: *PAGE_PTE, physical_addr: *u32) bool {
    const page_directory = current_page_directory;
    const page_directory_entry = page_directory_entry_lookup(page_directory, virtual_addr);

    if (page_directory_entry.PTE_PRESENT != 1) {
        // const table: *PAGE_TABLES = {}; // Call Phyiscal Memory manager here and check if worked
        const table: *PAGE_TABLES = pmm.getPages(1);

        @memset(table, 0);
        page_directory_entry.PTE_WRITABLE = 1;
        page_directory_entry.PTE_PRESENT = 1;
        page_directory_entry.PTE_FRAME = @truncate(table >> 12); // just map the higher 20 bits to the frame, maybe function for that?
    }
    const page_table: *PAGE_TABLE_STRUCT = get_frame(page_directory_entry);

    const page = &page_table.*.pages[page_table_index(virtual_addr)];

    page.PTE_PRESENT = 1;
    page.PTE_FRAME = @truncate(physical_addr >> 12); // just map the higher 20 bits to the frame, maybe function for that?
}

//TODO:gotta check if it flushes correctly, if the asm syntax is correct
pub fn flush_tlb(virtual_addr: u32) void {
    asm volatile ("cli");
    asm volatile ("invlpg (%%eax)"
        :
        : [virtual_addr] "{eax}" (virtual_addr),
    );
    asm volatile ("sti");
}

fn clear_table(table: *PAGE_TABLE_STRUCT) void {
    for (table.pages) |*page| {
        page.* = PAGE_PTE{};
    }
}
pub fn init_vmm() !void {
    // First kernel upper halve & Idendity map first 4MB
    const idendity_table: *PAGE_TABLE_STRUCT = @ptrFromInt(try (pmm.getPages(1)));
    const kernel_table: *PAGE_TABLE_STRUCT = @ptrFromInt(try (pmm.getPages(1)));

    clear_table(idendity_table);
    clear_table(kernel_table);

    for (0..1024) |i| {
        const addr = i * PAGES_SIZE;
        var page: PAGE_PTE = @bitCast(try (pmm.getPages(1)));
        page.PTE_PRESENT = 1;
        page.PTE_FRAME = @truncate(addr >> 12); // just map the higher 20 bits to the frame, maybe function for that?

        idendity_table.*.pages[page_table_index(addr)] = page; // how to access this?!
    }

    var frame = 0x100000;
    var virt_addr = 0xc0000000;
    for (0..1024) |_| {
        var page: PAGE_PTE = pmm.getPages(1) catch |err| {
            _ = err;
            return;
        };
        page.PTE_PRESENT = 1;
        page.PTE_FRAME = @truncate(frame >> 12); // just map the higher 20 bits to the frame, maybe function for that?

        kernel_table.*[page_table_index(virt_addr)] = page;

        frame += 4096;
        virt_addr += 4096;
    }

    const page_directory: *PAGE_DIRECTORY_STRUCT = pmm.getPages(1) catch |err| {
        _ = err;
        return;
    };

    page_directory.*.entrys[page_directory_index(0x00000000)].PDE_PRESENT = 1;
    page_directory.*.entrys[page_directory_index(0x00000000)].PDE_WRITABLE = 1;
    page_directory.*.entrys[page_directory_index(0x00000000)].PDE_FRAME = @truncate(idendity_table >> 12);

    page_directory.*.entrys[page_directory_index(0xc0000000)].PDE_PRESENT = 1;
    page_directory.*.entrys[page_directory_index(0xc0000000)].PDE_WRITABLE = 1;
    page_directory.*.entrys[page_directory_index(0xc0000000)].PDE_FRAME = @truncate(kernel_table >> 12);

    // //activate recursive paging, FFC00000 == [1023]
    page_directory.*.entrys[1023].PDE_PRESENT = 1;
    page_directory.*.entrys[1023].PDE_WRITABLE = 1;
    page_directory.*.entrys[1023].PDE_FRAME = @truncate(page_directory >> 12);

    loadPageDir(page_directory);
    activatePaging();
}

pub inline fn loadPageDir(page_dir: *PAGE_DIRECTORY_STRUCT) void {
    asm volatile ("mov cr3, (%%eax)"
        :
        : [page_dir] "{eax}" (page_dir),
    );
}

extern fn activatePaging() void;
comptime {
    asm (
        \\.global activatePaging
        \\.type activatePaging, @function;
        \\activatePaging:
        \\   mov %cr0, %eax
        \\   or $0x80000001, %eax
        \\   mov %eax, %cr0
        \\   ret
    );
}
