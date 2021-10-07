const std = @import("std");
const ArrayList = std.ArrayList;

const TokenType = @import("../lexer/tokens.zig").TokenType;
const variable = @import("./var.zig");
const parse = @import("./parser.zig");
const Lexer = @import("../lexer/lexer.zig").Lexer;
const Stmts = @import("./stmt.zig").Stmts;
const log = @import("../log.zig");

pub const Functions = struct {
    arguments: ArrayList(variable.VariableWithType),
    defers: ArrayList(TokenType),
    stmts: ArrayList(Stmts),
    isPub: bool,
};

pub fn parseFunctions(parser: *parse.Parser, lexer: *Lexer, index: *usize, isPub: bool) log.Errors!usize {
    _ = parser;
    _ = lexer;
    _ = index;
    _ = isPub;
    return index.*;
}
