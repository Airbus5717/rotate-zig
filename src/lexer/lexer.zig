const std = @import("std");
const file = @import("../file.zig");
const ArrayList = std.ArrayList;
const allocator = std.heap.c_allocator;

const log = @import("../log.zig");
const Errors = log.Errors;
const token = @import("tokens.zig");
const Token = token.Token;
const TokenType = token.TokenType;
const Pos = token.Pos;

pub const Lexer = struct {
    tkns: ArrayList(Token),
    lines: ArrayList(usize),
    begin: usize,
    index: usize,
    line: usize,
    col: usize,
    length: usize,
    file: []const u8,
    src: []const u8,

    pub fn freeLexerArrayLists(self: *Lexer) void {
        self.tkns.deinit();
        self.lines.deinit();
    }

    pub fn freeSourceCode(self: *Lexer) void {
        allocator.free(self.src);
    }

    pub fn lex(self: *Lexer) void {
        if (self.src.len < 1) {
            log.printLog(Errors.END_OF_FILE, self);
            return;
        }
        while (self.current() != 0) {
            self.single() catch |err| {
                log.printLog(err, self);
                return;
            };
            self.skipWhite();
        }
        self.outputTokens() catch |err| {
            log.logErr(@errorName(err));
            return;
        };
    }

    pub fn single(self: *Lexer) !void {
        self.skipWhite();
        const c = self.current();
        self.length = 1;
        self.begin = self.index;
        const save_index = self.index;
        const save_line = self.line;
        const save_col = self.col;
        var reached_dot = false;
        if (std.ascii.isDigit(c)) {
            _ = self.advance();
            while (std.ascii.isDigit(self.current()) or self.current() == '.') {
                if (self.current() == '.') {
                    if (reached_dot) {
                        break;
                    } else {
                        reached_dot = true;
                    }
                }
                _ = self.advance();
                self.length += 1;
            }
            self.col = save_col;
            self.line = save_line;
            self.index = save_index;
            if (reached_dot) {
                self.addToken(TokenType.Float);
            } else {
                self.addToken(TokenType.Integer);
            }
            return;
        } else if (c == '"') {
            _ = self.advance();
            while (self.current() != '"') {
                if (self.current() == 0 or self.current() == '\n') {
                    return Errors.NOT_CLOSED_STR;
                } else if (self.current() == '\\' and self.peek() == '"') {
                    _ = self.advance();
                    self.length += 1;
                }
                _ = self.advance();
                self.length += 1;
            }
            self.length += 1;
            self.col = save_col;
            self.line = save_line;
            self.index = save_index;
            self.addToken(TokenType.String);
            return;
        } else if (c == '\'') {
            _ = self.advance();
            while (self.current() != '\'') {
                if (self.current() == 0) {
                    self.length = 1;
                    return Errors.END_OF_FILE;
                }
                if (std.ascii.isSpace(self.current()) and self.peek() != '\'') {
                    self.length = 1;
                    return Errors.NOT_CLOSED_CHAR;
                }

                if (self.length == 2 and self.past() == '\\' and self.current() != '\\') {
                    _ = self.advance();
                    self.length += 1;
                    break;
                } else if (self.length > 1 and self.past() != '\\' and (self.peek() == '\'' or self.peek() == '\\')) {
                    self.length = 1;
                    return Errors.NOT_CLOSED_CHAR;
                } else if (self.length > 1) {
                    self.length = 1;
                    return Errors.NOT_CLOSED_CHAR;
                }
                _ = self.advance();
                self.length += 1;
            }

            self.length += 1;
            self.col = save_col;
            self.line = save_line;
            self.index = save_index;
            self.addToken(TokenType.Char);
            return;
        } else switch (c) {
            '=' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.EqualEqual);
                    _ = self.advance();
                } else {
                    self.addToken(TokenType.Equal);
                }
            },
            ':' => self.addToken(TokenType.Colon),
            ';' => self.addToken(TokenType.SemiColon),
            '+' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.AddEqual);
                    _ = self.advance();
                } else {
                    self.addToken(TokenType.Plus);
                }
            },
            '-' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.SubEqual);
                    _ = self.advance();
                } else {
                    self.addToken(TokenType.Minus);
                }
            },
            '*' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.MultEqual);
                    _ = self.advance();
                } else {
                    self.addToken(TokenType.Star);
                }
            },
            '/' => {
                const cc = self.peek();
                if (cc == '=') {
                    self.length += 1;
                    self.addToken(TokenType.DivEqual);
                    _ = self.advance();
                } else if (cc == '/') {
                    while (self.current() != '\n' and self.notEof()) {
                        _ = self.advance();
                    }
                } else {
                    self.addToken(TokenType.Div);
                }
            },
            '(' => self.addToken(TokenType.LeftParen),
            ')' => self.addToken(TokenType.RightParen),
            '{' => self.addToken(TokenType.LeftCurly),
            '}' => self.addToken(TokenType.RightCurly),
            '[' => self.addToken(TokenType.LeftSQRBrackets),
            ']' => self.addToken(TokenType.RightSQRBrackets),
            '>' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.GreaterEqual);
                    _ = self.advance();
                } else {
                    self.addToken(TokenType.Greater);
                }
            },
            '<' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.LessEqual);
                    _ = self.advance();
                } else {
                    self.addToken(TokenType.Less);
                }
            },
            '.' => self.addToken(TokenType.Dot),
            '!' => self.addToken(TokenType.Not),
            else => {
                if (c == '_' or std.ascii.isAlpha(c)) {
                    self.multiChar() catch |err| {
                        return err;
                    };
                } else if (self.index >= self.src.len) {
                    return Errors.END_OF_FILE;
                } else return Errors.UNKNOWN_TOKEN;
            },
        }
        return;
    }

    pub fn notEof(self: *Lexer) bool {
        if (self.current() != 0) {
            return true;
        } else {
            return false;
        }
    }

    pub fn multiChar(self: *Lexer) !void {
        const save_col = self.col;
        const save_line = self.line;
        const save_index = self.index;
        const save_len = self.length;
        self.length = 1;
        _ = self.advance();
        var length: usize = 1;
        while (std.ascii.isAlNum(self.current()) or self.current() == '_') {
            _ = self.advance();
            length += 1;
        }
        self.length = save_len;
        self.index = save_index;
        self.line = save_line;
        self.col = save_col;
        var tkn_type = TokenType.Identifier;
        switch (length) {
            2 => {
                if (std.mem.eql(u8, "if", self.slice(length))) {
                    tkn_type = TokenType.If;
                } else if (std.mem.eql(u8, "fn", self.slice(length))) {
                    tkn_type = TokenType.Function;
                } else if (std.mem.eql(u8, "or", self.slice(length))) {
                    tkn_type = TokenType.Or;
                } else if (std.mem.eql(u8, "as", self.slice(length))) {
                    tkn_type = TokenType.As;
                }
            },
            3 => {
                if (std.mem.eql(u8, "for", self.slice(length))) {
                    tkn_type = TokenType.For;
                } else if (std.mem.eql(u8, "let", self.slice(length))) {
                    tkn_type = TokenType.Let;
                } else if (std.mem.eql(u8, "pub", self.slice(length))) {
                    tkn_type = TokenType.Public;
                } else if (std.mem.eql(u8, "str", self.slice(length))) {
                    tkn_type = TokenType.StringKeyword;
                } else if (std.mem.eql(u8, "mut", self.slice(length))) {
                    tkn_type = TokenType.Mutable;
                } else if (std.mem.eql(u8, "int", self.slice(length))) {
                    tkn_type = TokenType.IntKeyword;
                } else if (std.mem.eql(u8, "ref", self.slice(length))) {
                    tkn_type = TokenType.Ref;
                } else if (std.mem.eql(u8, "and", self.slice(length))) {
                    tkn_type = TokenType.And;
                }
            },
            4 => {
                if (std.mem.eql(u8, "else", self.slice(length))) {
                    tkn_type = TokenType.Else;
                } else if (std.mem.eql(u8, "true", self.slice(length))) {
                    tkn_type = TokenType.True;
                } else if (std.mem.eql(u8, "false", self.slice(length))) {
                    tkn_type = TokenType.False;
                } else if (std.mem.eql(u8, "char", self.slice(length))) {
                    tkn_type = TokenType.CharKeyword;
                } else if (std.mem.eql(u8, "bool", self.slice(length))) {
                    tkn_type = TokenType.BoolKeyword;
                } else if (std.mem.eql(u8, "void", self.slice(length))) {
                    tkn_type = TokenType.Void;
                } else if (std.mem.eql(u8, "skip", self.slice(length))) {
                    tkn_type = TokenType.Skip;
                }
            },
            5 => {
                if (std.mem.eql(u8, "while", self.slice(length))) {
                    tkn_type = TokenType.While;
                } else if (std.mem.eql(u8, "false", self.slice(length))) {
                    tkn_type = TokenType.False;
                } else if (std.mem.eql(u8, "match", self.slice(length))) {
                    tkn_type = TokenType.Match;
                } else if (std.mem.eql(u8, "break", self.slice(length))) {
                    tkn_type = TokenType.Break;
                } else if (std.mem.eql(u8, "float", self.slice(length))) {
                    tkn_type = TokenType.FloatKeyword;
                }
            },
            6 => {
                if (std.mem.eql(u8, "return", self.slice(length))) {
                    tkn_type = TokenType.Return;
                } else if (std.mem.eql(u8, "import", self.slice(length))) {
                    tkn_type = TokenType.Import;
                } else if (std.mem.eql(u8, "struct", self.slice(length))) {
                    tkn_type = TokenType.Struct;
                }
            },
            else => {
                self.length = length;
                self.addToken(TokenType.Identifier);
                return;
            },
        }
        self.length = length;
        self.addToken(tkn_type);
    }

    pub fn addToken(self: *Lexer, token_type: TokenType) void {
        const position = Pos{ .line = self.line, .col = self.col, .index = self.index };
        const tkn = Token{
            .pos = position,
            .tkn_type = token_type,
            .value = self.slice(self.length),
        };
        self.tkns.append(tkn) catch |err| {
            log.logErr(@errorName(err));
        };

        var i: u8 = 1;
        while (i <= self.length) : (i += 1) {
            _ = self.advance();
        }
    }
    pub fn slice(self: *Lexer, len: usize) []const u8 {
        return self.src[self.index..(self.index + len)];
    }

    pub fn next(self: *Lexer) void {
        self.index += 1;
    }

    pub fn peek(self: *Lexer) u8 {
        return self.src[self.index + 1];
    }

    pub fn past(self: *Lexer) u8 {
        return self.src[self.index - 1];
    }

    pub fn specific(self: *Lexer, i: usize) u8 {
        return self.src[self.index + i];
    }

    pub fn current(self: *Lexer) u8 {
        return self.src[self.index];
    }

    pub fn advance(self: *Lexer) bool {
        const c = self.current();
        self.next();
        if (c != '\n') {
            self.col += 1;
        } else {
            self.col = 1;
            self.line += 1;
            self.lines.append(self.index) catch |err| {
                log.logErr(@errorName(err));
            };
        }
        return true;
    }

    pub fn skipWhite(self: *Lexer) void {
        var b: bool = true;
        while (std.ascii.isSpace(self.current()) and b) {
            b = self.advance();
        }
    }

    pub fn outputTokens(self: *Lexer) !void {
        const output = try std.fs.cwd().createFile(
            "output.txt",
            .{ .read = true },
        );
        defer output.close();
        for (self.tkns.items) |tkn, index| {
            try std.fmt.format(output.writer(), "{d: ^3}: Token: {s: <10} at {s}:{d}:{d} with text: \"{s}\"\n", .{
                index, tkn.tkn_type.describe(), self.file, tkn.pos.line, tkn.pos.col, tkn.value,
            });
        }
        // for (self.lines.items) |line| {
        //     print("{d}\n", .{line});
        // }
    }
};

pub fn initLexer(filename: []const u8) !Lexer {
    var self = Lexer{
        .tkns = ArrayList(Token).init(allocator),
        .lines = ArrayList(usize).init(allocator),
        .index = 0,
        .begin = 0,
        .line = 1,
        .col = 1,
        .length = 1,
        .file = filename,
        .src = undefined,
    };
    self.src = try file.readFile(filename);
    return self;
}
