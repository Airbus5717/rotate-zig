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
    const log_file = std.fs.cwd().createFile(
        config.log_output,
        .{ .read = true },
    ) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer log_file.close();

    var lex = lexer.initLexer(filename, log_file) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer lex.freeLexer();

    lex.lex() catch |err| {
        output.printLog(err, &lex);
        return;
    };
    lex.outputTokens();
    _ = outputfile;
    var parsed = parser.Parser.init() catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer parsed.deinit();
}
