const std = @import("std");

const Parser = @import("../parser/parser.zig").Parser;
const log = @import("../log.zig");
const config = @import("../config.zig");
const Lexer = @import("../lexer/lexer.zig").Lexer;
const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const ImportStmt = @import("../parser/import.zig").ImportStmt;
const variable = @import("../parser/var.zig");
const Expr = @import("../parser/expr.zig").Expr;

pub fn exportToC(parser: *Parser, outputfile: []const u8) !void {
    const cfile = @embedFile("./stdlib/std.c");
    const header = @embedFile("./stdlib/std.h");
    var one_file: bool = undefined;
    const output = try std.fs.cwd().createFile(
        outputfile,
        .{ .read = true },
    );
    defer output.close();
    const clib_output = blk: {
        if (config.seperate_std_c) {
            one_file = false;
            break :blk try std.fs.cwd().createFile(
                "std.c",
                .{ .read = true },
            );
        } else {
            one_file = true;
            break :blk output;
        }
    };
    const clib_output_header = blk: {
        if (config.seperate_std_c) {
            break :blk try std.fs.cwd().createFile(
                "std.h",
                .{ .read = true },
            );
        } else {
            break :blk output;
        }
    };
    try clib_output_header.writeAll(header ++ "\n");
    if (config.seperate_std_c) {
        try output.writeAll("#include \"std.h\"\n");
    }
    // export code here
    try output.writeAll("// code begin here\n");
    try convertParserToC(output, parser);
    try output.writeAll("\n// code end here\n");
    // end export here
    // std lib
    try clib_output.writeAll(if (!config.seperate_std_c) cfile[17..cfile.len] else cfile);
    if (!one_file) clib_output.close();
}

pub fn convertParserToC(output: std.fs.File, parser: *Parser) !void {
    for (parser.gstmts.items) |item| {
        switch (item) {
            .IMPORT => |*item2| {
                try exportImports(&item2.*, output);
            },
            .GVAR => |*item2| {
                try exportGVars(&item2.*, output);
            },
            else => {},
        }
    }
}

fn exportImports(import: *const ImportStmt, output: std.fs.File) !void {
    const val = import.value.value;
    if (import.include) {
        try std.fmt.format(output.writer(), "#include <{s}.h>\n", .{val[1 .. val.len - 1]});
    } else {
        try std.fmt.format(output.writer(), "#include \"{s}.h\"\n", .{val[1 .. val.len - 1]});
    }
}

fn exportGVars(@"var": *const variable.Variable, output: std.fs.File) !void {
    switch (@"var".value) {
        .literal => |*val| {
            // std.debug.print("literal in gvar export\n", .{});
            // std.debug.print("{any}\n", .{val.tkn.value});
            try std.fmt.format(output.writer(), "const {s} {s} = {s};\n", .{
                rotateToC(@"var".var_type), @"var".id.*, val.tkn.value,
            });
        },
        else => {
            std.debug.print("Non-literal variables are unsupported in global variables\n", .{});
            std.os.abort();
        },
    }
}

pub fn rotateToC(tkn_type: TokenType) ![]const u8 {
    switch (tkn_type) {
        .IntKeyword => return "int",
        .CharKeyword => return "char",
        .FloatKeyword => return "double",
        .BoolKeyword => return "bool",
        .StringKeyword => return "char *",
        .LongKeyword => return "long",
        else => {
            return log.Errors.UNIMPLEMENTED;
        },
    }
}
