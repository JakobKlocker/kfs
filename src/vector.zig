const pmm = @import("PMM.zig");

pub fn Vector(comptime T: type) type {
    return struct {
        const vector = @This();
        size: usize, // total amount of objects before reallocateing
        used: usize, // amount of objects used
        data: ?[*]T,

        pub fn init() vector {
            return vector{
                .size = 0,
                .used = 0,
                .data = null,
            };
        }

        pub fn add(this: *vector, data: T) !void {
            if (this.used >= this.size or !this.data) {
                try this.realloc();
            } 
            this.data.?[this.used] = data;
            this.used += 1;
        }

        pub fn get(this: *vector, index: usize) !T {
            if (index >= this.used)
                return error.OUT_OF_BOUNDS;
            return this.data[index];
        }

        pub fn remove(this: *vector, index: usize) !void {
            if (index >= this.used)
                return error.OUT_OF_BOUNDS;

            if (this.data) |data| {
                for (index..this.used) |i| {
                    data[i] = data[i+1];
                }
            }
            this.used -= 1;
        }

        fn realloc(this: *vector) !void {
            const newSize = this.size + pmm.PAGE_SIZE / @sizeOf(T);
            const newData: [*]T = @ptrFromInt(try pmm.getPages(newSize / pmm.PAGE_SIZE + 1));

            if (this.data) |data| {
                for (0..this.size) |i| {
                    newData[i] = data[i];
                }
            }
            this.data = newData;
            this.size = newSize;
        }

        pub fn deinit(this: *vector) void {
            pmm.freePages(this.data, this.size / pmm.PAGE_SIZE + 1);
            this.size = 0;
            this.used = 0;
            this.data = null;
        }
    };
}
