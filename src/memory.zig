//Virtual Address Format
//AAAAAAAAAA         BBBBBBBBBB        CCCCCCCCCCCC
// directory index    page table index  offset into page

const PAGES_SIZE = 4096;
const PAGES_PER_TABLE = 1024;
const PAGES_PER_DIR = 1024;
const PTABLE_ADDR_SPACE_SIZE = 0x400000;
const DTABLE_ADDR_SPACE_SIZE = 0x100000000;

const pt_entry: [PAGES_PER_TABLE]u32 = undefined;
const pd_entry: [PAGES_PER_DIR]u32 = undefined;

//https://wiki.osdev.org/images/6/60/Page_table_entry.png
const PAGE_PTE_FLAGS = packed struct(u32) {
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
const PAGE_PDE_FLAGS = packed struct(u32) {
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

const myTest = PAGE_PTE_FLAGS{
    .PTE_ACCESSED = 1,
};

fn page_directory_index(virtual_addr: u32) u32 {
    return (virtual_addr >> 22) & 0x3FF;
}

fn page_table_index(virtual_addr: u32) u32 {
    return (virtual_addr >> 12) & 0x3FF;
}

fn get_physical_address(pte: u32) u32 {
    return pte & ~0xFFF;
}


// below from writeup http://www.brokenthorn.com/Resources/OSDev18.html, need p mem allocator to continue
fn pmmngr_alloc_block() 
fn vmmngr_alloc_page (e: * pt_entry) bool {
 
	//! allocate a free physical frame
	p = pmmngr_alloc_block ();
	if (!p)
		return false;
 
	//! map it to the page
	pt_entry_set_frame (e, (physical_addr)p);
	pt_entry_add_attrib (e, I86_PTE_PRESENT);

	return true;
}

// extern void		pd_entry_add_attrib (pd_entry* e, uint32_t attrib);
// extern void		pd_entry_del_attrib (pd_entry* e, uint32_t attrib);
// extern void		pd_entry_set_frame (pd_entry*, physical_addr);
// extern bool		pd_entry_is_present (pd_entry e);
// extern bool		pd_entry_is_user (pd_entry);
// extern bool		pd_entry_is_4mb (pd_entry);
// extern bool		pd_entry_is_writable (pd_entry e);
// extern physical_addr	pd_entry_pfn (pd_entry e);
// extern void		pd_entry_enable_global (pd_entry e);
