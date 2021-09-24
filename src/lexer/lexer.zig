const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.c_allocator;

const log = @import("../log.zig");
const file = @import("../file.zig");
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
    file: file.SrcFile,
    log_file: std.fs.File,
    done: bool = false,

    pub fn freeLexer(self: *Lexer) void {
        self.freeLexerArrayLists();
        self.freeSourceCode();
    }

    pub fn freeLexerArrayLists(self: *Lexer) void {
        self.tkns.deinit();
        self.lines.deinit();
    }

    pub fn freeSourceCode(self: *Lexer) void {
        allocator.free(self.file.code);
    }

    pub fn lex(self: *Lexer) !void {
        if (self.file.len < 1) {
            return Errors.END_OF_FILE;
        }
        while (self.index < self.file.len) {
            try self.single();
            self.skipWhite();
        }
        self.done = true;
    }

    fn single(self: *Lexer) !void {
        self.skipWhite();
        const c = try self.current();
        self.length = 1;
        self.begin = self.index;
        const save_index = self.index;
        const save_line = self.line;
        const save_col = self.col;
        var reached_dot = false;
        if (std.ascii.isDigit(c)) {
            if (!self.advance()) return;
            while (std.ascii.isDigit(try self.current()) or try self.current() == '.') {
                if ((try self.current()) == '.') {
                    if (reached_dot) {
                        break;
                    } else {
                        reached_dot = true;
                    }
                }
                if (!self.advance()) return;

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
            if (!self.advance()) return;
            while ((try self.current()) != '"') {
                if ((try self.current()) == 0 or (try self.current()) == '\n') {
                    return Errors.NOT_CLOSED_STR;
                } else if ((try self.current()) == '\\' and self.peek() == '"') {
                    _ = self.advance();
                    self.length += 1;
                }
                if (!self.advance()) return;
                self.length += 1;
            }
            self.length += 1;
            self.col = save_col;
            self.line = save_line;
            self.index = save_index;
            self.addToken(TokenType.String);
            return;
        } else if (c == '\'') {
            if (!self.advance()) return;

            while ((try self.current()) != '\'') {
                if ((try self.current()) == 0) {
                    self.length = 1;
                    return Errors.END_OF_FILE;
                }
                if (std.ascii.isSpace((try self.current())) and self.peek() != '\'') {
                    self.length = 1;
                    return Errors.NOT_CLOSED_CHAR;
                }

                if (self.length == 2 and self.past() == '\\' and (try self.current()) != '\\') {
                    if (!self.advance()) return;

                    self.length += 1;
                    break;
                } else if (self.length > 1 and self.past() != '\\' and (self.peek() == '\'' or self.peek() == '\\')) {
                    self.length = 1;
                    return Errors.NOT_CLOSED_CHAR;
                } else if (self.length > 1) {
                    self.length = 1;
                    return Errors.NOT_CLOSED_CHAR;
                }
                if (!self.advance()) return;

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
                    if (!self.advance()) return;
                } else {
                    self.addToken(TokenType.Plus);
                }
            },
            '-' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.SubEqual);
                    if (!self.advance()) return;
                } else {
                    self.addToken(TokenType.Minus);
                }
            },
            '*' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.MultEqual);
                    if (!self.advance()) return;
                } else {
                    self.addToken(TokenType.Star);
                }
            },
            '/' => {
                const cc = self.peek();
                if (cc == '=') {
                    self.length += 1;
                    self.addToken(TokenType.DivEqual);
                    if (!self.advance()) return;
                } else if (cc == '/') {
                    while ((try self.current()) != '\n') {
                        if (!self.advance()) return;
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
                    if (!self.advance()) return;
                } else {
                    self.addToken(TokenType.Greater);
                }
            },
            '<' => {
                if (self.peek() == '=') {
                    self.length += 1;
                    self.addToken(TokenType.LessEqual);
                    if (!self.advance()) return;
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
                } else if (self.index >= self.file.len) {
                    return Errors.END_OF_FILE;
                } else return Errors.UNKNOWN_TOKEN;
            },
        }
        return;
    }

    fn notEof(self: *Lexer) bool {
        if ((try self.current()) != 0) {
            return true;
        } else {
            return false;
        }
    }

    fn multiChar(self: *Lexer) !void {
        const save_col = self.col;
        const save_line = self.line;
        const save_index = self.index;
        const save_len = self.length;
        self.length = 1;
        if (!self.advance()) return;

        var length: usize = 1;
        while (std.ascii.isAlNum((try self.current())) or (try self.current()) == '_') {
            if (!self.advance()) return;

            length += 1;
        }
        self.length = save_len;
        self.index = save_index;
        self.line = save_line;
        self.col = save_col;
        var tkn_type = TokenType.Identifier;
        const word = self.slice(length);
        switch (length) {
            2 => {
                if (std.mem.eql(u8, "if", word)) {
                    tkn_type = TokenType.If;
                } else if (std.mem.eql(u8, "fn", word)) {
                    tkn_type = TokenType.Function;
                } else if (std.mem.eql(u8, "or", word)) {
                    tkn_type = TokenType.Or;
                } else if (std.mem.eql(u8, "as", word)) {
                    tkn_type = TokenType.As;
                }
            },
            3 => {
                if (std.mem.eql(u8, "for", word)) {
                    tkn_type = TokenType.For;
                } else if (std.mem.eql(u8, "let", word)) {
                    tkn_type = TokenType.Let;
                } else if (std.mem.eql(u8, "pub", word)) {
                    tkn_type = TokenType.Public;
                } else if (std.mem.eql(u8, "str", word)) {
                    tkn_type = TokenType.StringKeyword;
                } else if (std.mem.eql(u8, "mut", word)) {
                    tkn_type = TokenType.Mutable;
                } else if (std.mem.eql(u8, "int", word)) {
                    tkn_type = TokenType.IntKeyword;
                } else if (std.mem.eql(u8, "ref", word)) {
                    tkn_type = TokenType.Ref;
                } else if (std.mem.eql(u8, "and", word)) {
                    tkn_type = TokenType.And;
                }
            },
            4 => {
                if (std.mem.eql(u8, "else", word)) {
                    tkn_type = TokenType.Else;
                } else if (std.mem.eql(u8, "true", word)) {
                    tkn_type = TokenType.True;
                } else if (std.mem.eql(u8, "char", word)) {
                    tkn_type = TokenType.CharKeyword;
                } else if (std.mem.eql(u8, "bool", word)) {
                    tkn_type = TokenType.BoolKeyword;
                } else if (std.mem.eql(u8, "void", word)) {
                    tkn_type = TokenType.Void;
                } else if (std.mem.eql(u8, "skip", word)) {
                    tkn_type = TokenType.Skip;
                }
            },
            5 => {
                if (std.mem.eql(u8, "while", word)) {
                    tkn_type = TokenType.While;
                } else if (std.mem.eql(u8, "false", word)) {
                    tkn_type = TokenType.False;
                } else if (std.mem.eql(u8, "match", word)) {
                    tkn_type = TokenType.Match;
                } else if (std.mem.eql(u8, "break", word)) {
                    tkn_type = TokenType.Break;
                } else if (std.mem.eql(u8, "float", word)) {
                    tkn_type = TokenType.FloatKeyword;
                } else if (std.mem.eql(u8, "defer", word)) {
                    tkn_type = TokenType.Defer;
                }
            },
            6 => {
                if (std.mem.eql(u8, "return", word)) {
                    tkn_type = TokenType.Return;
                } else if (std.mem.eql(u8, "import", word)) {
                    tkn_type = TokenType.Import;
                } else if (std.mem.eql(u8, "struct", word)) {
                    tkn_type = TokenType.Struct;
                }
            },
            7 => {
                if (std.mem.eql(u8, "include", word)) {
                    tkn_type = TokenType.Include;
                }
            },
            else => {},
        }
        self.length = length;
        self.addToken(tkn_type);
    }

    fn addToken(self: *Lexer, token_type: TokenType) void {
        self.tkns.append(.{
            .pos = .{
                .line = self.line,
                .col = self.col,
                .index = self.index,
            },
            .tkn_type = token_type,
            .value = self.slice(self.length),
        }) catch |err| {
            log.logErr(@errorName(err));
        };

        var i: u8 = 1;
        while (i <= self.length) : (i += 1) {
            if (!self.advance()) break;
        }
    }
    fn slice(self: *Lexer, len: usize) []const u8 {
        return self.file.code[self.index..(self.index + len)];
    }

    fn next(self: *Lexer) void {
        self.index += 1;
    }

    fn peek(self: *Lexer) u8 {
        return self.file.code[self.index + 1];
    }

    fn past(self: *Lexer) u8 {
        return self.file.code[self.index - 1];
    }

    fn specific(self: *Lexer, i: usize) u8 {
        return self.file.code[self.index + i];
    }

    fn current(self: *Lexer) !u8 {
        return self.file.code[self.index];
    }

    fn advance(self: *Lexer) bool {
        const c = try self.current();
        self.next();
        if (c != '\n') {
            self.col += 1;
        } else {
            self.col = 1;
            self.line += 1;
            self.lines.append(self.index) catch |err| {
                log.logErr(@errorName(err));
                return false;
            };
        }
        return true;
    }

    fn skipWhite(self: *Lexer) void {
        var b: bool = true;
        while (self.index < self.file.len and std.ascii.isSpace(try self.current()) and b) {
            b = self.advance();
        }
    }

    pub fn outputTokens(self: *Lexer) void {
        std.fmt.format(self.log_file.writer(), "{s}\n## lexer \n```\n", .{"-" ** 10}) catch |err| {
            log.logErr(@errorName(err));
        };
        for (self.tkns.items) |tkn, index| {
            std.fmt.format(self.log_file.writer(), "{d: ^3}: Token: {s: <10} at {s}:{d}:{d} : \"{s}\"\n", .{
                index, tkn.tkn_type.describe(), self.file.name, tkn.pos.line, tkn.pos.col, tkn.value,
            }) catch |err| {
                log.logErr(@errorName(err));
            };
        }
        std.fmt.format(self.log_file.writer(), "```\n{s}\n\n", .{"-" ** 10}) catch |err| {
            log.logErr(@errorName(err));
        };

        // for (self.lines.items) |line| {
        //     print("{d}\n", .{line});
        // }
    }
};

pub fn initLexer(filename: []const u8, logfile: std.fs.File) !Lexer {
    var self = Lexer{
        .tkns = ArrayList(Token).init(allocator),
        .lines = ArrayList(usize).init(allocator),
        .index = 0,
        .begin = 0,
        .line = 1,
        .col = 1,
        .length = 1,
        .file = undefined,
        .log_file = logfile,
    };
    self.file = (try file.readFile(filename, logfile));
    return self;
}
