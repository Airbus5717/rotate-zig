const std = @import("std");
const print = std.debug.print;

const Lexer = @import("./frontend/Lexer.zig");
const Token_Type = Lexer.Token_Type;
const readFile = @import("file.zig").readFile;

pub fn compile(name: []const u8) !void {
    var allocator = std.heap.raw_c_allocator;

    var lexer: Lexer = try Lexer.init(name, allocator);
    defer lexer.deinit();
    try lexer.lex();
}

pub fn main() void {
    const file_name = "main.vr";
    compile(file_name) catch |err| {
        std.log.err("{s}", .{@errorName(err)});
    };
}

test {
    _ = @import("file.zig");
}
