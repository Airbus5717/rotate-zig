const std = @import("std");
const os = std.os;
const max_int = std.math.maxInt(u32);

pub const File = struct {
    name: []const u8,
    contents: []const u8, // already stores length
};

pub fn readFile(name: []const u8, allocator: *std.mem.Allocator) !File {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const abs_path = try std.fs.realpath(name, &path_buffer);

    var file = try std.fs.openFileAbsolute(abs_path, .{ .read = true });
    defer file.close();

    const file_size = try file.getEndPos();
    if (file_size > max_int) return error.TooLargeFile;
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.read(buffer[0..buffer.len]);
    return File{
        .name = name,
        .contents = buffer,
    };
}
