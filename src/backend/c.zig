const std = @import("std");
const parser = @import("../parser/parser.zig");
const Lexer = @import("../lexer/lexer.zig").Lexer;

pub fn exportCode(outputfile: []const u8, parsed: *parser.Parser, lexer: *Lexer) !void {
    var output = try std.fs.cwd().createFile(
        outputfile,
        .{ .read = true },
    );
    defer output.close();
    for (parsed.loc.items) |item, index| {
        switch (item.parsed_type) {
            .Imports => {
                // std.debug.print("{any}\n", .{parsed.imports.items[item.idx].ref_token});
                try exportImports(&output, parsed, lexer, index);
            },
            else => std.debug.print("{d}\n", .{item.parsed_type}),
        }
    }
}

pub fn exportImports(output: *std.fs.File, parsed: *parser.Parser, lexer: *Lexer, index: usize) !void {
    _ = output;
    // for ```include "stdio";``` should be ```#include <stdio.h>```
    const token = lexer.tkns.items[parsed.imports.items[parsed.loc.items[index].idx].ref_token];
    // std.debug.print("{any}\n", .{token});
    if (parsed.imports.items[parsed.loc.items[index].idx].sys) {
        try std.fmt.format(output.writer(), "#include <{s}.h> \n", .{token.value[1 .. token.value.len - 1]});
    } else {
        try std.fmt.format(output.writer(), "#include \"{s}.h\" \n", .{token.value[1 .. token.value.len - 1]});
    }
}
