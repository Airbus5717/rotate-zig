const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.c_allocator;

const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const config = @import("../config.zig");
const log = @import("../log.zig");

const BinaryExpr = struct {
    left: Token,
    op: Token,
    right: Token,
};

const GroupExpr = struct {};
const LiteralExpr = struct {};

pub fn parse(lexer: *Lexer) !void {
    for (lexer.tkns.items) |item, index| {
        _ = item;
        _ = index;
    }
}
