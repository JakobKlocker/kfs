//Virtual Address Format
//AAAAAAAAAA         BBBBBBBBBB        CCCCCCCCCCCC
// directory index    page table index  offset into page

const PAGES_SIZE = 4096;
const PAGES_PER_TABLE = 1024;
const PAGES_PER_DIR = 1024;
const PTABLE_ADDR_SPACE_SIZE = 0x400000;
const DTABLE_ADDR_SPACE_SIZE = 0x100000000;

const page_table_entry: [PAGES_PER_TABLE]PAGE_PTE = undefined;
const page_directory_entry: [PAGES_PER_DIR]PAGE_PDE = undefined;

var current_page_directory: *[PAGES_PER_TABLE]PAGE_PDE = undefined;
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
pub fn get_physical_address(pte: u32) u32 {
    return pte & ~0xFFF;
}

// no Null check, look into zigs checking later
pub fn page_table_lookup_entry(pt: *[PAGES_PER_TABLE]PAGE_PTE, virtual_addr: u32) *const PAGE_PTE {
    return &pt[page_table_index(virtual_addr)];
}

// no Null check, look into zigs checking later
// page table index can be used here as well, since need frame address again
pub fn page_directory_lookup_entry(pd: *[PAGES_PER_TABLE]PAGE_PDE, virtual_addr: u32) *const PAGE_PDE {
    return &pd[page_table_index(virtual_addr)];
}

pub fn get_page(virtual_addr: u32) *PAGE_PDE {
    // get page directory
    var page_directory = current_page_directory;

    //get page table in directory
    const page_directory_entrys = &page_directory[page_directory_index(virtual_addr)];
    const page_table: *PAGE_PTE = get_physical_address(page_directory_entrys);

    //get page in table
    const page: *PAGE_PDE = &page_table.*[page_table_index(virtual_addr)];
    return page;
}
