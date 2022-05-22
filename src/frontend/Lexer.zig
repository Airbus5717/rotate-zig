const std = @import("std");
const ArrayList = std.ArrayList;

const File = @import("../file.zig").File;

pub const Token_Type = enum(u8) {
    Identifier, // ids
    BuiltinFunc, // @ids
    Equal, // =
    Let, // 'let'
    Var, // 'var'
    Const, // 'const'
    Integer, // refers to 10 digits ints
    HexInteger, // refers to Hexidecimal ints
    BinaryInteger, // refers to binary ints
    IntKeyword, // 'int'
    INT_U8, // u8
    INT_U16, // u16
    INT_U32, // u32
    INT_U64, // u64
    INT_S8, // s8
    INT_S16, // s16
    INT_S32, // s32
    INT_S64, // s64
    Float, // refer to floats
    FLOAT_f32, // f32
    FLOAT_f64, // f64
    FloatKeyword, // 'float'
    String, // refer to strings
    StringKeyword, // 'str'
    Char, // refers to chars
    EscapedChar, // '\{}' chars i.e. '\n'
    CharKeyword, // 'char'
    True, // 'true'
    False, // 'false'
    BoolKeyword, // 'bool'
    SemiColon, // ;
    Colon, // :
    Function, // 'fn'
    PLUS, // +
    MINUS, // -
    Star, // *
    DIV, // /
    LeftParen, // (
    RightParen, // )
    LeftCurly, // {
    RightCurly, // }
    LeftSQRBrackets, // [
    RightSQRBrackets, // ]
    Return, // 'return'
    Import, // 'import'
    If, // 'if'
    Else, // 'else'
    For, // 'for'
    While, // 'while'
    Greater, // >
    Less, // <
    Dot, // .
    Not, // "!"
    NotEqual, // "!="
    And, // 'and'
    Or, // 'or'
    DoubleQuotes, // "
    Quote, // '
    Comma, // ,
    Public, // 'pub'
    Match, // 'match'
    Enum, // 'enum'
    EqualEqual, // ==
    Break, // 'break'
    AddEqual, // +=
    SubEqual, // -=
    MultEqual, // *=
    DivEqual, // /=
    Struct, // 'struct'
    Ref, // 'ref'
    Void, // 'void'
    Include, // 'include'
    Nil, // `nil` basically null
    EOT, // EOT - END OF TOKENS

    pub fn to_string(tag: Token_Type) []const u8 {
        return @tagName(tag);
    }
};

pub const Token = packed struct {
    token_type: Token_Type,
    index: u32,
    len: u32,
};

const Lexer = @This();
// member variables
tokens: ArrayList(Token) = undefined,
file: File = undefined,
index: u32 = 0,
len: u32 = 0,

pub fn init(file: File, allocator: std.mem.Allocator) Lexer {
    return Lexer{
        .tokens = ArrayList(Token).init(allocator),
        .file = file,
    };
}

pub fn deinit(self: *Lexer) void {
    self.tokens.deinit();
}

pub fn lex(self: *Lexer) !void {
    _ = self;
}

fn addToken(self: *Lexer, tkn_type: Token_Type) !void {
    try self.tokens.append(Token{
        .token_type = tkn_type,
        .index = self.index,
        .length = self.len,
    });
}
