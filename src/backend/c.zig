const std = @import("std");

const Parser = @import("../parser/parser.zig").Parser;
const log = @import("../log.zig");
const Lexer = @import("../lexer/lexer.zig").Lexer;
const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const ImportStmt = @import("../parser/import.zig").ImportStmt;
const variable = @import("../parser/var.zig");

pub fn exportToC(parser: *Parser, outputfile: []const u8) !void {
    const cfile = @embedFile("./stdlib/std.c");
    const header = @embedFile("./stdlib/std.h");
    const output = try std.fs.cwd().createFile(
        outputfile,
        .{ .read = true },
    );
    defer output.close();
    try output.writeAll(header);
    // export typedefs here
    // TODO

    try output.writeAll(
        \\
        \\//  $$$$$$\                  $$\
        \\// $$  __$$\                 $$ |
        \\// $$ /  \__| $$$$$$\   $$$$$$$ | $$$$$$\
        \\// $$ |      $$  __$$\ $$  __$$ |$$  __$$\
        \\// $$ |      $$ /  $$ |$$ /  $$ |$$$$$$$$ |
        \\// $$ |  $$\ $$ |  $$ |$$ |  $$ |$$   ____|
        \\// \$$$$$$  |\$$$$$$  |\$$$$$$$ |\$$$$$$$\
        \\//  \______/  \______/  \_______| \_______|
        \\
        \\// code begin here
        \\
        \\
    );
    // export code here
    try convertParserToC(output, parser);
    try output.writeAll("\n// code end here\n");
    // end export here
    // std lib
    try output.writeAll(cfile[17..cfile.len]);
}

pub fn convertParserToC(output: std.fs.File, parser: *Parser) !void {
    for (parser.gstmts.items) |item| {
        switch (item) {
            .IMPORT => |*item2| {
                try exportImports(item2.*, output);
            },
            .GVAR => |*item2| {
                try exportGVars(item2.*, output);
            },
            else => {},
        }
    }
}

fn exportImports(import: ImportStmt, output: std.fs.File) !void {
    const val = import.value.value;
    if (import.include) {
        try std.fmt.format(output.writer(), "#include <{s}.h>\n", .{val[1 .. val.len - 1]});
    } else {
        try std.fmt.format(output.writer(), "#include \"{s}.h\"\n", .{val[1 .. val.len - 1]});
    }
}

fn exportGVars(@"var": variable.Variable, output: std.fs.File) !void {
    try std.fmt.format(output.writer(), "const {s} {s} = {s};\n", .{
        rotateToC(@"var".var_type), @"var".id.*, @"var".value.tkn.value,
    });
}

pub fn rotateToC(tkn_type: TokenType) ![]const u8 {
    switch (tkn_type) {
        .IntKeyword => return "int",
        .CharKeyword => return "char",
        .FloatKeyword => return "double",
        .BoolKeyword => return "bool",
        .StringKeyword => return "char *",
        else => {
            return log.Errors.UNIMPLEMENTED;
        },
    }
}
