const pmm = @import("PMM.zig");

pub fn PageVector(comptime T: type) type {
    return struct {
        const vector = @This();
        total: usize, // total amount of objects before reallocateing
        size: usize, // amount of objects used
        data: ?[*]T,

        pub fn init() vector {
            return vector{
                .total = 0,
                .size = 0,
                .data = null,
            };
        }

        pub fn add(this: *vector, data: T) !void {
            if (this.size >= this.total or this.data != null) {
                try this.realloc();
            } 
            this.data.?[this.size] = data;
            this.size += 1;
        }

        pub fn get(this: *vector, index: usize) !T {
            if (index >= this.size)
                return error.OUT_OF_BOUNDS;
            return this.data[index];
        }

        pub fn remove(this: *vector, index: usize) !void {
            if (index >= this.size)
                return error.OUT_OF_BOUNDS;

            if (this.data) |data| {
                for (index..this.size) |i| {
                    data[i] = data[i+1];
                }
            }
            this.size -= 1;
        }

        fn realloc(this: *vector) !void {
            const newElements = pmm.PAGE_SIZE / @sizeOf(T);
            const newSize = this.total + newElements;
            const newPages = if (newSize % pmm.PAGE_SIZE == 0) newSize / pmm.PAGE_SIZE else newSize / pmm.PAGE_SIZE + 1;
            const newData: [*]T = @ptrFromInt(try pmm.getPagesInternal(newPages));

            if (this.data) |data| {
                for (0..this.total) |i| {
                    newData[i] = data[i];
                }
            }
            this.data = newData;
            this.total = newSize;
        }

        pub fn deinit(this: *vector) void {
            pmm.freePagesInternal(this.data, this.total / pmm.PAGE_SIZE + 1);
            this.total = 0;
            this.size = 0;
            this.data = null;
        }
    };
}
