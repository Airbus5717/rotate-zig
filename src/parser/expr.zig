const token = @import("../lexer/tokens.zig");
const Token = token.Token;
const TokenType = token.TokenType;
const Type = token.Type;
const parser = @import("./parser.zig");

pub const ExprEnum = enum {
    group,
    binary,
    literal,
    unary,
};

pub const Expr = union(ExprEnum) {
    group: GroupExpr,
    binary: BinaryExpr,
    literal: LiteralExpr,
    unary: UnaryExpr,
};

pub const GroupExpr = struct {
    expr: *Expr,
};

pub const UnaryExpr = struct {
    op: *Token,
    expr: *Expr,
};

pub const BinaryExpr = struct {
    left: *Expr,
    op: *Token,
    right: *Expr,
    result_type: Type,

    // pub fn getResType(self: BinaryExpr) Type {
    // }
};

pub const LiteralExpr = struct {
    tkn: *Token,
};
