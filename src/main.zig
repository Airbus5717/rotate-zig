const std = @import("std");
const print = std.debug.print;
const lexer = @import("lexer/lexer.zig");
const file = @import("file.zig");
const output = @import("log.zig");

pub fn main() !void {
    compile();
}

pub fn compile() void {
    var lex = lexer.initLexer("main.txt");
    const src = file.readFile(lex.file) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    lex.freeLexer();
    print("{s}", .{src});
}
