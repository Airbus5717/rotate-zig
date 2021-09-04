const std = @import("std");

const lexer = @import("lexer/lexer.zig");
const output = @import("log.zig");

pub fn main() void {
    compile();
}

pub fn compile() void {
    const filename = "main.vr";
    var lex = lexer.initLexer(filename) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer lex.freeLexerArrayLists();
    defer lex.freeSourceCode();
    lex.lex();
}
