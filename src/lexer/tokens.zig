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
    Function, // 'fn'
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
    Nil, // `nil`
    Long, // long
    LongKeyword, // `long`
    Type, // type
    Block, // c code block
    Builtin, // zig like builtins @identifer

    pub fn describe(self: TokenType) []const u8 {
        return @tagName(self);
    }
};

pub const Type = enum(u8) {
    _int,
    _isize,
    _usize,
    _u8,
    _u16,
    _u32,
    _u64,
    _i8,
    _i16,
    _i32,
    _i64,
    _f32,
    _f64,
    _f128,
    _char,
    _void,
    _struct,
    _none,

    pub fn describe(self: Type) []const u8 {
        return @tagName(self);
    }

    // zig fmt: off
    pub fn typeToC(self: Type) []const u8 {
        switch (self) {
            ._isize   => return "long long",
            ._usize   => return "size_t",
            ._int     => return "int",
            ._f32     => return "float",
            ._f64     => return "double",
            ._f128    => return "long double",
            ._char    => return "char",
            ._void    => return "void",
            ._i8      => return "int8_t",
            ._i16     => return "int16_t",
            ._i32     => return "int32_t",
            ._i64     => return "int64_t",
            ._u8      => return "uint8_t",
            ._u16     => return "uint16_t",
            ._u32     => return "uint32_t",
            ._u64     => return "uint64_t",
            ._none    => return "NULL",
        }
    }
    // zig fmt: on
};
