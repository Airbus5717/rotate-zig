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

    pub fn describe(self: TokenType) []const u8 {
        return @tagName(self);
    }
};
