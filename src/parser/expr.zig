const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const parser = @import("./parser.zig");

pub const BinaryExprTkn = struct {
    left: Token,
    op: *Token,
    right: Token,
    result_type: *Token,
};

pub const BinaryExpr = struct {
    left: parser.Node,
    op: Token,
    right: Token,
    result_type: *Token,
};
