const std = @import("std");
const print = std.debug.print;

const lexer = @import("lexer/lexer.zig");
const file = @import("file.zig");
const output = @import("log.zig");

pub fn main() void {
    compile() catch |err| {
        output.logErr(@errorName(err));
    };
}

pub fn compile() !void {
    const filename = "main.vr";
    var lex = lexer.initLexer(filename);
    lex.src = file.readFile(filename) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer lex.freeLexer();
    try lex.lex();
    try lex.outputTokens();
}
