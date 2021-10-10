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
    typed_id,
};

pub const Expr = union(ExprEnum) {
    group: GroupExpr,
    binary: BinaryExpr,
    literal: LiteralExpr,
    unary: UnaryExpr,
    typed_id: LiteralExpr,
};

pub const GroupExpr = packed struct {
    expr: *Expr,
};

pub const UnaryExpr = packed struct {
    op: *Token,
    expr: *Expr,
};

pub const TypedId = packed struct {
    id: *Token,
    _type: Type,
};

pub const BinaryExpr = packed struct {
    left: *Expr,
    op: *Token,
    right: *Expr,
    result_type: Type,

    // pub fn getResType(self: BinaryExpr) Type {
    // }
};

pub const LiteralExpr = packed struct {
    tkn: *Token,
};
