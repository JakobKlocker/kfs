// const PAGE_PTE_FLAGS = enum  {

// 	PTE_PRESENT			=	1,		//0000000000000000000000000000001
// 	PTE_WRITABLE		=	2,		//0000000000000000000000000000010
// 	PTE_USER			=	4,		//0000000000000000000000000000100
// 	PTE_WRITETHOUGH		=	8,		//0000000000000000000000000001000
// 	PTE_NOT_CACHEABLE		=	0x10,		//0000000000000000000000000010000
// 	PTE_ACCESSED		=	0x20,		//0000000000000000000000000100000
// 	PTE_DIRTY			=	0x40,		//0000000000000000000000001000000
// 	PTE_PAT			=	0x80,		//0000000000000000000000010000000
// 	PTE_CPU_GLOBAL		=	0x100,		//0000000000000000000000100000000
// 	PTE_LV4_GLOBAL		=	0x200,		//0000000000000000000001000000000
//    	PTE_FRAME			=	0x7FFFF000 	//1111111111111111111000000000000
// };

//https://wiki.osdev.org/images/6/60/Page_table_entry.png
const PAGE_PTE_FLAGS = packed struct {
    PTE_PRESENT: u1 = 0, // 1 bit for Present (P)
    PTE_WRITABLE: u1 = 0, // 1 bit for Read/Write (RW)
    PTE_USER: u1 = 0, // 1 bit for User/Supervisor (U/S)
    PTE_WRITETHROUGH: u1 = 0, // 1 bit for Write-through (PWT)
    PTE_NOT_CACHEABLE: u1 = 0, // 1 bit for Cache Disable (PCD)
    PTE_ACCESSED: u1 = 0, // 1 bit for Accessed (A)
    PTE_DIRTY: u1 = 0, // 1 bit for Dirty (D)
    PTE_PAT: u1 = 0, // 1 bit for Page Attribute Table (PAT)
    PTE_CPU_GLOBAL: u1 = 0, // 1 bit for Global Page (G)
    PTE_AVL: u3 = 0, // 3 bits (AVL)
    PTE_FRAME: u20 = 0, // 20 bits for the frame address (physical page)
};

const myTest = PAGE_PTE_FLAGS{
    .PTE_ACCESSED = 1,
};

// extern void		pd_entry_add_attrib (pd_entry* e, uint32_t attrib);
// extern void		pd_entry_del_attrib (pd_entry* e, uint32_t attrib);
// extern void		pd_entry_set_frame (pd_entry*, physical_addr);
// extern bool		pd_entry_is_present (pd_entry e);
// extern bool		pd_entry_is_user (pd_entry);
// extern bool		pd_entry_is_4mb (pd_entry);
// extern bool		pd_entry_is_writable (pd_entry e);
// extern physical_addr	pd_entry_pfn (pd_entry e);
// extern void		pd_entry_enable_global (pd_entry e);
