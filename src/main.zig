const std = @import("std");

const lexer = @import("lexer/lexer.zig");
const output = @import("log.zig");
const config = @import("config.zig");
const parser = @import("parser/parser.zig");
const backend = @import("backend/c.zig");

pub var log_file: std.fs.File = undefined;

pub fn main() void {
    const filename = "main.vr";
    const outputfile = "main.c";
    compile(filename, outputfile);
}

pub fn compile(filename: []const u8, outputfile: []const u8) void {
    // log file
    log_file = undefined; // try std.fs.cwd().createFile(
    // config.log_output,
    // .{ .read = true },
    // );
    // defer log_file.close();

    // lexer
    var lex = lexer.initLexer(filename, log_file) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
    defer lex.freeLexer();

    lex.lex() catch |err| {
        output.printLog(err, &lex);
        return;
    };
    // lex.outputTokens();
    if (!lex.done) {
        output.logErr("lexer failure");
        return;
    }

    // parser
    var parsed = parser.init() catch {
        return;
    };
    defer parsed.deinit();
    parsed.parse(&lex);
    // parsed.outputStmts(log_file);

    // c backend
    backend.exportToC(&parsed, outputfile) catch |err| {
        output.logErr(@errorName(err));
        return;
    };
}
