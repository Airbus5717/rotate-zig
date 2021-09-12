const std = @import("std");

const lexer = @import("lexer/lexer.zig");
const output = @import("log.zig");
const config = @import("config.zig");
const parser = @import("parser/parser.zig");

const backend = @import("backend/c.zig");

pub fn main() void {
    const filename = "main.vr";
    const outputfile = "main.c";
    compile(filename, outputfile);
}

pub fn compile(filename: []const u8, outputfile: []const u8) void {
    var lex = lexer.initLexer(filename, config.log_output) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    lex.lex();
    var parse = parser.Parser.init();
    parser.parseRotate(&parse, &lex);
    defer parse.deinit();
    defer lex.freeLexer();
    // parse.outputParser() catch |err| {
    //     output.logErr(@errorName(err));
    // };
    backend.exportCode(outputfile, &parse, &lex) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
}
