const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;

pub fn isVal(tkn_type: TokenType) bool {
    switch (tkn_type) {
        .String, .Integer, .Float, .Char, .True, .False => return true,
        else => return false,
    }
}

pub fn getType(tkn_type: TokenType) TokenType {
    switch (tkn_type) {
        .String => return .StringKeyword,
        .Char => return .CharKeyword,
        .True, .False => return .BoolKeyword,
        .Float => return .FloatKeyword,
        .Integer => return .IntKeyword,
        else => return .Null,
    }
}
