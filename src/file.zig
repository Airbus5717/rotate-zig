const std = @import("std");
const os = std.os;
const max_32bit = std.math.maxInt(u32);
const Lexer = @import("./frontend/Lexer.zig").Lexer;

pub fn readFile(
    name: []const u8,
    allocator: std.mem.Allocator,
) !Lexer {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const abs_path = try std.fs.realpath(name, &path_buffer);
    var file = try std.fs.openFileAbsolute(
        abs_path,
        .{ .read = true },
    );
    defer file.close();

    const file_size = try file.getEndPos();
    if (file_size > max_32bit) return error.FileTooBig;

    const buffer = try allocator.allocSentinel(u8, file_size, 0);

    _ = try file.read(buffer);

    return Lexer{
        .file_name = name,
        .contents = buffer,
        .length = @truncate(u32, file_size),
    };
}

test "file read" {
    try std.heap.testAllocator(std.heap.raw_c_allocator);
    var allocator = std.testing.allocator;
    const test_file = @embedFile("../build.zig");
    const test_read_file = try readFile("build.zig", &allocator);
    const length = test_read_file.length;
    try std.testing.expect(test_file.len == length);
    allocator.free(test_read_file.contents[0..length]);
}
