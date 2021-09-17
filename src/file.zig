const std = @import("std");
const allocator = std.heap.c_allocator;

const log = @import("log.zig");
const config = @import("config.zig");

pub fn readFile(filename: []const u8, output: std.fs.File) ![:0]const u8 {
    var file = try std.fs.cwd().openFile(filename, .{});
    const len = try file.getEndPos();
    file.close();
    if (len > std.math.maxInt(usize)) {
        return error{OutOfMemory}.OutOfMemory;
    }
    const str = try std.fs.cwd().readFileAlloc(allocator, filename, len);
    defer allocator.free(str);

    std.fmt.format(output.writer(), "## source code\n{s}rs\n{s} \n{s}\n", .{ "`" ** 3, str, "`" ** 3 }) catch |err| {
        log.logErr(@errorName(err));
    };

    return std.cstr.addNullByte(allocator, str);
}
