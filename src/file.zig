const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn readFile(filename: []const u8) ![:0]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const src = allocator.dupeZ(u8, try file.readToEndAlloc(allocator, std.math.maxInt(usize)));
    return src;
}
