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

const PAGE_PTE_FLAGS = struct {
    PTE_PRESENT: u32         = 1 << 0,   // 0000000000000000000000000000001
    PTE_WRITABLE: u32        = 1 << 1,   // 0000000000000000000000000000010
    PTE_USER: u32            = 1 << 2,   // 0000000000000000000000000000100
    PTE_WRITETHROUGH: u32    = 1 << 3,   // 0000000000000000000000000001000
    PTE_NOT_CACHEABLE: u32   = 1 << 4,   // 0000000000000000000000000010000
    PTE_ACCESSED: u32        = 1 << 5,   // 0000000000000000000000000100000
    PTE_DIRTY: u32           = 1 << 6,   // 0000000000000000000000001000000
    PTE_PAT: u32             = 1 << 7,   // 0000000000000000000000010000000
    PTE_CPU_GLOBAL: u32      = 1 << 8,   // 0000000000000000000000100000000
    PTE_LV4_GLOBAL: u32      = 1 << 9,   // 0000000000000000000001000000000
    PTE_FRAME: u32           = 0x7FFFF000,  // 1111111111111111111000000000000
};

