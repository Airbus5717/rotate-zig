const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.c_allocator;

const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const config = @import("../config.zig");
const log = @import("../log.zig");
const Stmts = @import("./statements.zig").Stmts;

pub const Parser = struct {
    stmts: ArrayList(Stmts),

    pub fn init() !Parser {
        return Parser{
            .stmts = ArrayList(Stmts).init(allocator),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.stmts.deinit();
    }

    pub fn parse(self: *Parser, lexer: *Lexer) !void {
        _ = self;
        for (lexer.tkns.items) |item, index| {
            _ = index;
            switch (item.tkn_type) {
                .Import => {},
                .Include => {},
                .Let => {},
                .Function => {},
                else => {},
            }
        }
    }
};
