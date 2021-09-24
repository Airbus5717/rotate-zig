const std = @import("std");
const ArrayList = std.ArrayList;

const TokenType = @import("../lexer/tokens.zig").TokenType;
const variable = @import("./var.zig");

pub const Functions = struct { params: ArrayList(variable.VariableWithType) };
