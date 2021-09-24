const std = @import("std");

const Parser = @import("../parser/parser.zig").Parser;

pub fn exportToC(parser: *Parser, outputfile: []const u8) void {
    const cfile = @embedFile("./stdlib/std.c");
    const header = @embedFile("./stdlib/std.h");
    _ = cfile;
    _ = header;
    _ = parser;
    _ = outputfile;
}
