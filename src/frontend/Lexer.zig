const std = @import("std");
const print = std.debug.print;
const isDigit = std.ascii.isDigit;
const ArrayList = std.ArrayList;

const isAlphaNum_ = @import("../common.zig").isID;
const file_io = @import("../file.zig");

pub const Token = packed struct {
    token_type: Token_Type = undefined,
    index: u32 = undefined,
    len: u32 = undefined,
};

pub const Lexer = @This();
// Lexer member variables
allocator: *std.mem.Allocator = undefined,
contents: [*:0]u8 = undefined,
tokens: ArrayList(Token) = undefined,
file_name: []const u8 = undefined,
length: u32 = undefined, // contents length
index: u32 = undefined,
line: u32 = undefined,
len: u32 = undefined,

pub fn init(file_name: []const u8, allocator: std.mem.Allocator) !Lexer {
    // allocator, file_name, length and contents are put in using readfile;
    var s: Lexer = try file_io.readFile(file_name, allocator);
    s.tokens = ArrayList(Token).init(allocator);
    s.index = 0;
    s.line = 1;
    s.len = 0;
    return s;
}

pub fn deinit(self: *Lexer) void {
    self.tokens.deinit();
    std.heap.raw_c_allocator.destroy(self.contents);
}

pub fn lex(self: *Lexer) !void {
    while (self.current() != 0) : (self.index += 1) {
        const c = self.current();
        const p = self.peek();
        self.len = 1;
        switch (c) {

            // numbers
            '0'...'9' => try self.lexNumbers(),

            // strings
            '"' => try self.lexStrings(),

            // chars
            '\'' => try self.lexChars(),

            // builtin functions
            '@' => try self.lexBuiltins(),

            // symbols
            '{' => try self.addToken(.LeftCurly),
            '}' => try self.addToken(.RightCurly),
            '(' => try self.addToken(.LeftParen),
            ')' => try self.addToken(.RightParen),
            '[' => try self.addToken(.LeftSQRBrackets),
            ']' => try self.addToken(.RightSQRBrackets),
            ';' => try self.addToken(.SemiColon),
            '.' => try self.addToken(.Dot),
            ',' => try self.addToken(.Comma),
            ':' => try self.addToken(.Colon),

            // symbols with one or more chars
            '>' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.GreaterEqual);
                } else try self.addToken(.Greater);
            },
            '<' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.LessEqual);
                } else try self.addToken(.Less);
            },
            '=' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.EqualEqual);
                } else try self.addToken(.Equal);
            },
            '+' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.AddEqual);
                } else try self.addToken(.PLUS);
            },
            '-' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.SubEqual);
                } else try self.addToken(.MINUS);
            },
            '*' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.MultEqual);
                } else try self.addToken(.Star);
            },
            '/' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.DivEqual);
                } else if (p == '/') {
                    // SINGLE LINE COMMENTS
                    while (self.isNotEOF() and self.current() != '\n') {
                        self.advance();
                    }
                } else if (p == '*') {
                    // MULTI LINE COMMENTS
                    self.advance();
                    var end_of_comment: bool = false;
                    while (self.isNotEOF() and !end_of_comment) {
                        if (self.past() == '*' and self.current() == '/') {
                            self.advance();
                            end_of_comment = true;
                        }
                        self.advance();
                    }
                } else {
                    try self.addToken(.DIV);
                }
            },
            '!' => {
                if (p == '=') {
                    self.advanceLength();
                    try self.addToken(.NotEqual);
                } else try self.addToken(.Not);
            },

            //
            // identifiers
            '_', 'A'...'Z', 'a'...'z' => try self.lexIdentifiers(),
            else => {
                break;
            },
        }
    }
    try self.addToken(.EOT);
}

fn lexIdentifiers(self: *Lexer) !void {
    //
    while (isAlphaNum_(self.current())) {
        self.advanceLength();
    }
    var _type = .Identifier;

    switch (self.len) {}

    try self.addToken(_type);
}

fn lexNumbers(self: *Lexer) !void {
    self.advance();

    var reach_dot = false;
    while (isDigit(self.current()) or self.current() == '.') {
        if (self.current() == '.') {
            if (reach_dot) break;
            reach_dot = true;
        }
        self.advance();
        self.advanceLength();
    }
    self.index -= self.len;
    if (self.len > 100) return;
    try self.addToken(if (reach_dot) .Float else .Integer);
}

fn lexStrings(self: *Lexer) !void {
    _ = self;
}

fn lexChars(self: *Lexer) !void {
    self.advance();
}

fn lexBuiltins(self: *Lexer) !void {
    _ = self;
    print("TODO: Lexer builtins ", .{});
    std.debug.assert(false);
}

fn advance(self: *Lexer) void {
    self.index += 1;
}

fn advanceLength(self: *Lexer) void {
    self.len += 1;
}

fn current(self: *Lexer) u8 {
    return self.contents[self.index];
}

fn past(self: *Lexer) u8 {
    return self.contents[self.index - 1];
}

fn peek(self: *Lexer) u8 {
    return self.contents[self.index + 1];
}

fn isNotEOF(self: *Lexer) bool {
    return self.index < self.length;
}

fn addToken(self: *Lexer, _type: Token_Type) !void {
    try self.tokens.append(Token{
        .token_type = _type,
        .index = self.index,
        .len = self.len,
    });
}

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
    GreaterEqual, // >=
    Less, // <
    LessEqual, // <=
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

    pub fn toString(tag: Token_Type) []const u8 {
        return @tagName(tag);
    }
};
