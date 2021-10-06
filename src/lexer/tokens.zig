pub const Pos = packed struct {
    line: usize,
    col: usize,
    index: usize,
};

pub const Token = struct {
    pos: Pos,
    tkn_type: TokenType,
    value: []const u8,
};

pub const TokenType = enum(u8) {
    Identifier, // id
    Equal, // =
    Let, // 'let'
    Integer, // refers to ints
    IntKeyword, // 'int'
    Float, // refer to floats
    FloatKeyword, // 'float'
    String, // refer to strings
    StringKeyword, // 'str'
    Char, // refers to chars
    CharKeyword, // 'char'
    True, // 'true'
    False, // 'false'
    BoolKeyword, // 'bool'
    Newline, // ! '\n' Weird Token
    SemiColon, // ;
    Colon, // :
    Function, // 'fn'pub const Pos = struct {
    LeftParen, // (
    RightParen, // )
    LeftCurly, // {
    RightCurly, // }
    LeftSQRBrackets, // [
    RightSQRBrackets, // ]
    Return, // 'return'
    Import, // 'import'
    Include, // 'include'
    If, // 'if'
    Else, // 'else'
    For, // 'for'
    While, // 'while'
    Arrow, // ->
    Greater, // >
    GreaterEqual, // >=
    Less, // <
    LessEqual, // <=
    Dot, // .
    Not, // "!"
    And, // 'and'
    Or, // 'or'
    DoubleQuotes, // "
    Quote, // '
    Comma, // ,
    Default, // '_'
    Public, // 'pub'
    Divider, // |
    Mutable, // 'mut'
    Match, // 'match'
    As, // 'as'
    EqualEqual, // ==
    Break, // 'break'
    Plus, // +
    Minus, // -
    Star, // *
    Div, // /
    AddEqual, // +=
    SubEqual, // -=
    MultEqual, // *=
    DivEqual, // /=
    Struct, // 'struct'
    Ref, // 'ref'
    Void, // 'void'
    Skip, // 'continue' alternative
    Defer, // `defer`
    Null,
    Long,
    LongKeyword,
    Type,

    pub fn describe(self: TokenType) []const u8 {
        return @tagName(self);
    }
};

pub const Type = enum(u8) {
    @"int",
    @"isize",
    @"usize",
    @"u8",
    @"u16",
    @"u32",
    @"u64",
    @"i8",
    @"i16",
    @"i32",
    @"i64",
    @"f32",
    @"f64",
    @"f128",
    @"char",
    @"void",
    @"struct",

    pub fn describe(self: Type) []const u8 {
        return @tagName(self);
    }

    // zig fmt: off
    pub fn typeToC(self: Type) []const u8 {
        switch (self) {
            .@"isize"   => return "long long",
            .@"usize"   => return "size_t",
            .@"int"     => return "int",
            .@"f32"     => return "float",
            .@"f64"     => return "double",
            .@"f128"    => return "long double",
            .@"char"    => return "char",
            .@"void"    => return "void",
            .@"i8"      => return "int8_t",
            .@"i16"     => return "int16_t",
            .@"i32"     => return "int32_t",
            .@"i64"     => return "int64_t",
            .@"u8"      => return "uint8_t",
            .@"u16"     => return "uint16_t",
            .@"u32"     => return "uint32_t",
            .@"u64"     => return "uint64_t",
        }
    }
    // zig fmt: on
};
