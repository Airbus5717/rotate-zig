const TokenType = @import("../lexer/tokens.zig").TokenType;

pub const VariableDef = struct {
    immutable: bool = true,
    var_type: TokenType = undefined,
    id: []const u8 = undefined,
};
