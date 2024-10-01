const multiboot = @import("multibootheader.zig");
const print = @import("print.zig").print;


pub fn init(mbd: *multiboot.multiboot_info, magic: u32) void {
    if (magic != multiboot.MULTIBOOT_BOOTLOADER_MAGIC) 
        print("invalide magic number", .{});
    if (mbd.flags >> 6 & 0x1 == 0) 
        print("wrong map\n", .{});

    print("\n{x} {}\n", .{mbd.mmap_addr, mbd.mmap_length});

    var entry: u32 = mbd.mmap_addr;
    var totalMemory: u64 = 0;
    var availableMemory: u64 = 0;
    while (entry < mbd.mmap_addr + mbd.mmap_length) {
        const entryStruct: *align(8) multiboot.multiboot_mmap_entry = @ptrFromInt(entry);
        const addr: u64 = entryStruct.addr;
        const len: u64 = entryStruct.len;
        const size: u32 = entryStruct.size;
        const etype: u32 = entryStruct.type;
        print("Start Addr: {x} | Length: {x} | Size: {x} | Type: {}\n", .{addr, len, size, etype});

        totalMemory += @truncate(len);
        if (etype == multiboot.MULTIBOOT_MEMORY_AVAILABLE) {
            availableMemory += @truncate(len);
        }


        entry = entry + entryStruct.size + @sizeOf(@TypeOf(entryStruct.size));
        
    }
    print("Total Memory: {x}", .{totalMemory});

}
