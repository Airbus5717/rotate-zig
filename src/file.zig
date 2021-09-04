const std = @import("std");
const allocator = std.heap.c_allocator;

pub fn readFile(filename: []const u8) ![:0]const u8 {
    var dir = std.fs.cwd();
    var file = try dir.openFile(filename, .{});
    const len = try file.getEndPos();
    file.close();
    if (len > std.math.maxInt(usize)) {
        return error{OutOfMemory}.OutOfMemory;
    }
    const str = try dir.readFileAlloc(allocator, filename, len);
    defer allocator.free(str);
    return std.cstr.addNullByte(allocator, str);
}
