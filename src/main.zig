const std = @import("std");
const print = std.debug.print;
const Lexer = @import("./frontend/Lexer.zig");
const Token_Type = Lexer.Token_Type;
const reader = @import("file.zig");

pub fn compile() !void {
    var allocator = std.heap.raw_c_allocator;

    const file = try reader.readFile("main.vr", &allocator);
    var lexer = Lexer.init(file, allocator);
    try lexer.lex();
}

pub fn main() void {
    compile() catch |err| {
        std.log.err("{s}", .{@errorName(err)});
    };
}
