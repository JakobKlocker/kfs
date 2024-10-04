const multiboot = @import("multibootheader.zig");
const print = @import("print.zig").print;

const PAGE_SIZE = 4096;
const FREE = 0;
const USED = 1;

pub var totalMemory: u32 = 0; // in KiB
pub var usedBlocks: u32 = 0;
pub var maxBlocks: u32 = 0;
var MMAP: [*]u1 = undefined;

pub fn init(mbd: *multiboot.multiboot_info, magic: u32) void {
    if (mbd.flags & 0x1 == 0)
        print("invalide memory size", .{});
    if (magic != multiboot.MULTIBOOT_BOOTLOADER_MAGIC) 
        print("invalide magic number", .{});
    if (mbd.flags >> 6 & 0x1 == 0) 
        print("wrong map\n", .{});

    totalMemory = mbd.mem_lower + mbd.mem_upper;
    maxBlocks = (totalMemory * 1024) / PAGE_SIZE;

    MMAP = @ptrFromInt(0x1000000);

    // set all memory used
    for (0..maxBlocks) |i| {
        MMAP[i] = USED;
    }

    // set all memory that is free to free
    print("\n", .{});
    var entry: u32 = mbd.mmap_addr;
    while (entry < mbd.mmap_addr + mbd.mmap_length) {
        const entryStruct: *align(8) multiboot.multiboot_mmap_entry = @ptrFromInt(entry);
        const addr: u32 = @truncate(entryStruct.addr);
        const len: u32 = @truncate(entryStruct.len);
        const size: u32 = entryStruct.size;
        const etype: u32 = entryStruct.type;
        print("Start Addr: {x} | Length: {x} | Size: {x} | Type: {}\n", .{addr, len, size, etype});

        if (etype == multiboot.MULTIBOOT_MEMORY_AVAILABLE) {
            const start = addr / PAGE_SIZE;
            const range = len / PAGE_SIZE;

            for (start..start + range) |i| {
                MMAP[i] = FREE;
            }
        }

        entry = entry + entryStruct.size + @sizeOf(@TypeOf(entryStruct.size));
    }

    // set the first page as used so address 0 is allways in use
    MMAP[0] = USED;
}

pub fn getPages(amount: usize) !usize {
    for (0..maxBlocks - amount) |i| {
        if (MMAP[i] == FREE) { // look for free memory
            for (0..amount) |j| {
                if (MMAP[i + j] == USED) { // see if every memory for the amount is free
                    break;
                }
                if (j == amount - 1) {
                    for (0..amount) |k| {
                        MMAP[i + k] = USED; // set memory used
                    }
                    return i * PAGE_SIZE;
                }
            }
        }
    }
    return error.OUT_OF_MEMORY;
}
