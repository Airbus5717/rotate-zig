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
        self.gstmts.deinit();
    }

    pub fn outputStmts(self: *Parser, output: std.fs.File) void {
        log.logInFile(output, "## parser \n```\n", .{});
        for (self.gstmts.items) |item, index| {
            switch (item) {
                .IMPORT => |*item2| {
                    log.logInFile(output, "{d: ^5}: {any}\n\n", .{ index, item2.* });
                },
                .GVAR => |*item2| {
                    log.logInFile(output, "{d: ^5}: {any}\n\n", .{ index, item2.* });
                },
                .FUNC => |*item2| {
                    log.logInFile(output, "{d: ^5}: {any}\n\n", .{ index, item2.* });
                },
            }
        }
        log.logInFile(output, "```\n{s} \n", .{"-" ** 10});
    }

    pub fn parse(self: *Parser, lexer: *Lexer) void {
        parseNErrorHandle(self, lexer) catch |err| {
            log.printLog(err, lexer);
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
    self.done = false;
    var j: usize = undefined;
    var err_count: usize = 0;
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
            .Public => {},
            .Function => {
                j = try func.parseFunctions(self, lexer, &i, false);
            },
            .Struct => {
                // try parseStructlexer(item);
            },
            else => {
                self.done = false;
                err_count += 1;
                item = lexer.tkns.items[if (i > 0) i else 0];
                resetPos(lexer, &item);
                log.printLog(log.Errors.NOT_ALLOWED_AT_GLOBAL, lexer);
                if (err_count < 3) continue else return;
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

pub fn resetPosSemicolon(lexer: *Lexer, tkn: *const Token) void {
    const len = tkn.value.len;
    lexer.col = tkn.pos.col + len;
    lexer.line = tkn.pos.line;
    lexer.index = tkn.pos.index;
    lexer.length = 1;
}
