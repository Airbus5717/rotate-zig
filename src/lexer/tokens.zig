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
    Multiply, // *
    AddEqual, // +=
    SubEqual, // -=
    MultEqual, // *=
    DivEqual, // /=
    Struct, // 'struct'
    Ref, // 'ref'
    Void, // 'void'
    Skip, // 'continue' alternative

    pub fn describe(self: TokenType) []const u8 {
        switch (self) {
            TokenType.Identifier => return "ID",
            TokenType.Equal => return "EQUAL",
            TokenType.Let => return "LET",
            TokenType.Integer => return "INT",
            TokenType.IntKeyword => return "INT_KWORD",
            TokenType.Float => return "FLOAT",
            TokenType.FloatKeyword => return "FLOAT_KWORD",
            TokenType.String => return "STRING",
            TokenType.StringKeyword => return "STR_KWORD",
            TokenType.Char => return "CHAR",
            TokenType.CharKeyword => return "CHAR_KWORD",
            TokenType.True => return "TRUE",
            TokenType.False => return "FALSE",
            TokenType.BoolKeyword => return "BOOL",
            TokenType.Newline => return "NEWLINE",
            TokenType.SemiColon => return "SEMICOLON';'",
            TokenType.Colon => return "COLON':'",
            TokenType.Function => return "FUNCTION",
            TokenType.Plus => return "PLUS'+'",
            TokenType.Minus => return "MINUS'-'",
            TokenType.Star => return "STAR'*'",
            TokenType.Div => return "DIVIDE'/'",
            TokenType.LeftParen => return "LEFT_PAREN'('",
            TokenType.RightParen => return "RIGHT_PAREN')'",
            TokenType.LeftCurly => return "LEFT_CURLY'{'",
            TokenType.RightCurly => return "RIGHT_CURLY'}'",
            TokenType.LeftSQRBrackets => return "LEFT_SQR_BRKS'['",
            TokenType.RightSQRBrackets => return "RIGHT_SQR_BRKS']'",
            TokenType.Return => return "RETURN",
            TokenType.Import => return "IMPORT",
            TokenType.Include => return "INCLUDE",
            TokenType.If => return "IF",
            TokenType.Else => return "ELSE",
            TokenType.For => return "FOR",
            TokenType.While => return "WHILE",
            TokenType.Arrow => return "ARROW'->'",
            TokenType.Greater => return "GREATER'>'",
            TokenType.GreaterEqual => return "GREATER_EQUAL'>='",
            TokenType.Less => return "LESS'<'",
            TokenType.LessEqual => return "LESS_EQUAL'<='",
            TokenType.Dot => return "DOT'.'",
            TokenType.Not => return "NOT'!'",
            TokenType.And => return "AND",
            TokenType.Or => return "OR",
            TokenType.DoubleQuotes => return "DQUOTES'\"'",
            TokenType.Quote => return "QUOTE'\''",
            TokenType.Comma => return "COMMA','",
            TokenType.Default => return "DEFAULT','",
            TokenType.Public => return "PUBLIC",
            TokenType.Divider => return "DIVIDER'|'",
            TokenType.Mutable => return "MUTABLE",
            TokenType.Match => return "MATCH",
            TokenType.As => return "AS",
            TokenType.EqualEqual => return "EQUAL_EQUAL'=='",
            TokenType.Break => return "BREAK",
            TokenType.AddEqual => return "ADD_EQUAL'+='",
            TokenType.SubEqual => return "SUB_EQUAL'-='",
            TokenType.MultEqual => return "MULT_EQUAL'*='",
            TokenType.DivEqual => return "DIV_EQUAL'/='",
            TokenType.Struct => return "STRUCT",
            TokenType.Ref => return "REF",
            TokenType.Void => return "VOID",
            TokenType.Skip => return "SKIP",
            else => return "???",
        }
    }
};
