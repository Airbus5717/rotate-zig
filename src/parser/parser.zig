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
    var j: usize = undefined;
    while (i < lexer.tkns.items.len) : (i += 1) {
        var item = lexer.tkns.items[i];
        resetPos(lexer, &item);
        // std.debug.print("bfr parse: {any}\n", .{item});
        switch (item.tkn_type) {
            .Import => {
                j = try import.parseImports(self, lexer, &i, false);
            },
            .Include => {
                j = try import.parseImports(self, lexer, &i, true);
            },
            .Let => {
                j = try variable.parseGVariables(self, lexer, &i);
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

pub fn resetPosSemicolon(lexer: *Lexer, tkn: *const Token) void {
    const len = tkn.value.len;
    lexer.col = tkn.pos.col + len;
    lexer.line = tkn.pos.line;
    lexer.index = tkn.pos.index;
    lexer.length = 1;
}
