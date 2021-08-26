const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn readFile(filename: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    return try file.readToEndAlloc(allocator, std.math.maxInt(usize));
}
