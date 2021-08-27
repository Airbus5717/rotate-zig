const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const print = std.debug.print;

const log = @import("../log.zig");
const Errors = log.Errors;
const Token = @import("tokens.zig").Token;
const TokenType = @import("tokens.zig").TokenType;
const Pos = @import("tokens.zig").Pos;

pub const Lexer = struct {
    tkns: ArrayList(Token),
    index: usize,
    line: usize,
    col: usize,
    length: usize,
    file: []const u8,
    src: []const u8,
    err: Errors,

    pub fn freeLexer(self: *Lexer) void {
        self.tkns.deinit();
    }

    pub fn lex(self: *Lexer) !void {
        while (self.index < self.src.len and self.notEof()) {
            print("in lex loop idx: {d}\n", .{self.index});
            const b: bool = self.single() catch |err| {
                log.logErr(@errorName(err));
            };

            if (!b) break;
            self.index += 1;
            self.skipWhite();
        }
    }

    pub fn single(self: *Lexer) !bool {
        if (self.src.len < 1) {
            self.err = log.Errors.END_OF_FILE;
            log.printLog(self);
            return false;
        }

        self.skipWhite();
        const c = self.current();
        self.length = 1;
        var reached_dot = false;
        if (std.ascii.isDigit(c)) {
            const save_col = self.col;
            const save_line = self.line;
            const save_index = self.index;
            self.advance();
            while (std.ascii.isDigit(self.current()) or self.current() == '.') {
                print("in number loop idx: {d}\n", .{self.index});

                if (self.current() == '.') {
                    if (reached_dot) {
                        break;
                    } else {
                        reached_dot = true;
                    }
                }
                self.advance();
                self.length += 1;
                print("in number length: {d}\n", .{self.length});
            }
            self.col = save_col;
            self.line = save_line;
            self.index = save_index;
            if (reached_dot) {
                self.addToken(TokenType.Float);
            } else {
                self.addToken(TokenType.Integer);
            }
            return true;
        } else if (c == '"') {
            return true;
        } else if (c == '\'') {
            return true;
        } else switch (c) {
            '=' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.EqualEqual);
                    self.advance();
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
                    self.advance();
                } else {
                    self.addToken(TokenType.Plus);
                }
            },
            '-' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.SubEqual);
                    self.advance();
                } else {
                    self.addToken(TokenType.Minus);
                }
            },
            '*' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.MultEqual);
                    self.advance();
                } else {
                    self.addToken(TokenType.Star);
                }
            },
            '/' => {
                const cc = self.peek();
                if (cc == '=') {
                    self.length += 1;
                    self.addToken(TokenType.DivEqual);
                    self.advance();
                } else if (cc == '/') {
                    while (self.current() != '\n' and self.notEof()) {
                        self.advance();
                    }
                } else {
                    self.addToken(TokenType.Div);
                }
            },
            else => {
                if (c == '_' or std.ascii.isAlpha(c)) {
                    try self.multiChar();
                } else {
                    return false;
                }
            },
        }
        print("reached end idx: {d}\n", .{self.index});
        return true;
    }

    pub fn notEof(self: *Lexer) bool {
        if (self.index < self.src.len) {
            return true;
        } else return false;
    }

    pub fn multiChar(self: *Lexer) !void {
        _ = self;
    }

    pub fn addToken(self: *Lexer, token_type: TokenType) void {
        const position = Pos{ .line = self.line, .col = self.col, .index = self.index };
        const tkn = Token{
            .pos = position,
            .tkn_type = token_type,
            .value = &self.src[self.index..(self.length + self.index)],
        };
        print("adding token: {s}\n", .{token_type.describe()});
        self.tkns.append(tkn) catch |err| {
            log.logErr(@errorName(err));
        };
    }

    pub fn next(self: *Lexer) void {
        assert(self.index < self.src.len);
        self.index += 1;
    }

    pub fn peek(self: *Lexer) u8 {
        assert(self.index < self.src.len);
        return self.src[self.index + 1];
    }

    pub fn specific(self: *Lexer, i: usize) u8 {
        assert(self.index < self.src.len);
        return self.src[self.index + i];
    }

    pub fn current(self: *Lexer) u8 {
        assert(self.index < self.src.len);
        return self.src[self.index];
    }

    pub fn advance(self: *Lexer) void {
        const c = self.src[self.index];
        if (self.index + 1 >= self.src.len) {
            return;
        }
        self.index += 1;
        if (c != '\n') {
            self.col += 1;
        } else {
            self.col = 1;
            self.line += 1;
        }
    }

    pub fn skipWhite(self: *Lexer) void {
        while (std.ascii.isSpace(self.current()) and self.notEof()) {
            self.advance();
        }
    }
};

pub fn initLexer(filename: []const u8) Lexer {
    var self = Lexer{
        .tkns = ArrayList(Token).init(allocator),
        .index = 0,
        .line = 1,
        .col = 1,
        .length = 1,
        .file = filename,
        .src = undefined,
        .err = log.Errors.UNKNOWN_TOKEN,
    };
    return self;
}
