const std = @import("std");
const allocator = std.heap.c_allocator;

const log = @import("log.zig");
const config = @import("config.zig");

pub const SrcFile = struct {
    name: []const u8,
    code: []const u8,
    len: usize,
};

pub fn readFile(filename: []const u8, output: std.fs.File) !SrcFile {
    var file = try std.fs.cwd().openFile(filename, .{});
    const len = try file.getEndPos();
    file.close();
    if (len > std.math.maxInt(usize)) {
        return error{OutOfMemory}.OutOfMemory;
    }
    const tmp = try std.fs.cwd().readFileAlloc(allocator, filename, len);
    defer allocator.free(tmp);
    const src = try allocator.alloc(u8, tmp.len + 1);
    std.mem.copy(u8, src, tmp);
    src[tmp.len] = '\n';
    const code = SrcFile{ .code = src, .len = len, .name = filename };
    // std.fmt.format(output.writer(), "## source code\n{s}rs\n{s} \n{s}\n", .{ "`" ** 3, code.code, "`" ** 3 }) catch |err| {
    //     log.logErr(@errorName(err));
    // };

    _ = output;
    return code;
}
