const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;

pub const BinaryExpr = struct {
    left: Token,
    op: Token,
    right: Token,
    result: Token,
};
