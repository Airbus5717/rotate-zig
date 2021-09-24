const Token = @import("../lexer/tokens.zig").Token;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const log = @import("../log.zig");
const parse = @import("./parser.zig");

pub const Variable = struct {
    global: bool = undefined,
    immutable: bool = true,
    var_type: TokenType = undefined,
    id: []const u8 = undefined,
    value: parse.Node,
};

pub const VariableWithType = struct {
    var_type: TokenType = undefined,
    id: []const u8 = undefined,
};

pub fn parseGVariables(
    parser: *parse.Parser,
    lexer: *Lexer,
    index: *usize,
) !usize {
    _ = lexer;
    _ = parser;
    return index.*;
}
