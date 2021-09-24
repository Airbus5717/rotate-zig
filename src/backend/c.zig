const std = @import("std");

const Parser = @import("../parser/parser.zig").Parser;

pub fn exportToC(parser: *Parser) void {
    const cfile: []const u8 = @embedFile("./stdlib/std.c");
    _ = cfile;
    _ = parser;
}
