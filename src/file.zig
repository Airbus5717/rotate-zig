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

// var source = std.ArrayList(u8).init(allocator);
// defer source.deinit();

// var buffer: [4096 * 2]u8 = undefined;
// while (true) {
//     const len = try file.read(&buffer);
//     if (len == 0)
//         break;
//     try source.appendSlice(buffer[0..len]);
// }

// return try source.toOwnedSliceSentinel(0);
