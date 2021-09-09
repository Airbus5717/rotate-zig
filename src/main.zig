const std = @import("std");

const lexer = @import("lexer/lexer.zig");
const output = @import("log.zig");
const config = @import("config.zig");

pub fn main() void {
    compile();
}

pub fn compile() void {
    const filename = "main.vr";
    const logFile = config.log_output;
    var lex = lexer.initLexer(filename, logFile) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer lex.freeLexerArrayLists();
    defer lex.freeSourceCode();
    lex.lex();
}
