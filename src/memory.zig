//Virtual Address Format
//AAAAAAAAAA         BBBBBBBBBB        CCCCCCCCCCCC
// directory index    page table index  offset into page

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
    PTE_PRESENT: u1 = 0, // 1 bit for Present (P)
    PTE_WRITABLE: u1 = 0, // 1 bit for Read/Write (RW)
    PTE_USER: u1 = 0, // 1 bit for User/Supervisor (U/S)
    PTE_WRITETHROUGH: u1 = 0, // 1 bit for Write-through (PWT)
    PTE_NOT_CACHEABLE: u1 = 0, // 1 bit for Cache Disable (PCD)
    PTE_ACCESSED: u1 = 0, // 1 bit for Accessed (A)
    PTE_UNUSED: u1 = 0, // 1 bit
    PTE_PAT: u1 = 0, // 1 bit for Page Attribute Table (PAT)
    PTE_UNUSED1: u4 = 0, // 3 bits (AVL/UNUSED)
    PTE_FRAME: u20 = 0, // 20 bits for the frame address (physical page)
};

const myTest = PAGE_PTE{
    .PTE_ACCESSED = 1,
};

pub fn page_directory_index(virtual_addr: u32) u32 {
    return (virtual_addr >> 22) & 0x3FF;
}

pub fn page_table_index(virtual_addr: u32) u32 {
    return (virtual_addr >> 12) & 0x3FF;
}

//clear lowest 12 bits, only return frame
pub fn get_frame(pte: u32) u32 {
    return pte & ~0xFFF;
}

//TODO: Allocate real physical block & cast to PAGE_PTE, replace test_page
//DO NOT USE
pub fn alloc_page(page_table_entry: *PAGE_PTE) *PAGE_PTE {
    //alloc physical block instead of test_page
    const test_page: PAGE_PTE = {};
    page_table_entry.PTE_FRAME = get_frame(test_page);
    page_table_entry.PTE_PRESENT = 1;
    return test_page;
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

    //
    const page_table: *PAGE_PTE = get_frame(page_directory_entry);

    //get page in table
    const page: *PAGE_PTE = &page_table.*[page_table_index(virtual_addr)];
    return page;
}

//gotta check if it flushes correctly, if the asm syntax is correct
pub fn flush_tlb(virtual_addr: u32) void {
    asm volatile ("cli");
    asm volatile ("invlpg (%%eax)"
        :
        : [virtual_addr] "{eax}" (virtual_addr),
    );
    asm volatile ("sti");
}
