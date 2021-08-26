const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const Token = @import("tokens.zig").Token;

pub const Lexer = struct {
    tkns: ArrayList(Token),
    index: usize,
    line: usize,
    col: usize,
    file: []const u8,

    pub fn freeLexer(self: *Lexer) void {
        self.tkns.deinit();
    }
};

pub fn initLexer(filename: []const u8) Lexer {
    var self = Lexer{
        .tkns = ArrayList(Token).init(allocator),
        .index = 0,
        .line = 1,
        .col = 1,
        .file = filename,
    };
    return self;
}
