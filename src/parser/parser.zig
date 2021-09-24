const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.c_allocator;

const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const config = @import("../config.zig");
const log = @import("../log.zig");
const Stmts = @import("./stmt.zig").Stmts;
const expr = @import("./expr.zig");
const variable = @import("./var.zig");
const import = @import("./import.zig");
const func = @import("func.zig");

const NodeEnum = enum {
    tkn,
    bin_op_tkn,
};

pub const Node = union(NodeEnum) {
    tkn: *Token,
    bin_op_tkn: expr.BinaryExprTkn,
};

pub const GStmtsEnum = enum {
    IMPORT,
    GVAR,
    FUNC,
};

pub const GStmts = union(GStmtsEnum) {
    IMPORT: import.ImportStmt,
    GVAR: variable.Variable,
    FUNC: func.Functions,
};

pub const Parser = struct {
    done: bool = false,
    gstmts: ArrayList(GStmts),

    pub fn deinit(self: *Parser) void {
        // temp solution to output to console
        self.outputStmts();
        self.gstmts.deinit();
    }

    pub fn outputStmts(self: *Parser) void {
        for (self.gstmts.items) |item| {
            std.debug.print("{any}\n", .{item});
        }
    }

    pub fn parse(self: *Parser, lexer: *Lexer) !void {
        parseNErrorHandle(self, lexer) catch |err| {
            // std.debug.print("reached err handling in parse function: {s},\n", .{@errorName(err)});
            if (log.isCustomError(err)) {
                log.printLog(err, lexer);
            } else {
                log.logErr(@errorName(err));
            }
            // log.errorLog(log.describe(err), log.advice(err), @errorToInt(err), true, lexer);
            self.done = false;
            return err;
        };
    }
};

pub fn init() !Parser {
    return Parser{
        .gstmts = ArrayList(GStmts).init(allocator),
    };
}

pub fn parseNErrorHandle(self: *Parser, lexer: *Lexer) log.Errors!void {
    var i: usize = 0;
    self.done = true;
    while (i < lexer.tkns.items.len) : (i += 1) {
        var item = lexer.tkns.items[i];
        resetPos(lexer, &item);
        // std.debug.print("bfr parse: {any}\n", .{item});
        switch (item.tkn_type) {
            .Import => {
                i = try import.parseImports(self, lexer, &i, false);
            },
            .Include => {
                i = try import.parseImports(self, lexer, &i, true);
            },
            .Let => {
                i = try variable.parseGVariables(self, lexer, &i);
            },
            .Function => {
                // try parseFunctions(item);
            },
            .Struct => {
                // try parseStructlexer(item);
            },
            else => {
                self.done = false;
                item = lexer.tkns.items[if (i > 0) i else 0];
                resetPos(lexer, &item);
                return log.Errors.NOT_ALLOWED_AT_GLOBAL;
            },
        }
    }
}

pub fn resetPos(lexer: *Lexer, tkn: *const Token) void {
    lexer.col = tkn.pos.col;
    lexer.line = tkn.pos.line;
    lexer.index = tkn.pos.index;
    lexer.length = tkn.value.len;
}
