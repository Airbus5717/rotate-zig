const std = @import("std");
const ArrayList = std.ArrayList;

const TokenType = @import("../lexer/tokens.zig").TokenType;

pub const Functions = struct { params: ArrayList(VariableDef) };
