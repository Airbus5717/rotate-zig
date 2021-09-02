const std = @import("std");
const allocator = std.heap.c_allocator;

const lexer = @import("lexer/lexer.zig");
const file = @import("file.zig");
const output = @import("log.zig");

pub fn main() void {
    compile();
}

pub fn compile() void {
    const filename = "main.vr";
    var lex = try lexer.initLexer(filename);
    defer lex.freeLexer();
    lex.src = file.readFile(filename) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer lex.freeSource();
    lex.lex() catch |err| {
        output.logErr(@errorName(err));
        return;
    };
}
