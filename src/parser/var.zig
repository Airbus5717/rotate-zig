const std = @import("std");

const Token = @import("../lexer/tokens.zig").Token;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const log = @import("../log.zig");
const parse = @import("./parser.zig");
const typeChecker = @import("./type.zig");
const expr = @import("./expr.zig");
const Expr = expr.Expr;
const LiteralExpr = expr.LiteralExpr;

pub const Variable = struct {
    global: bool = undefined,
    immutable: bool = true,
    var_type: TokenType = undefined,
    id: *[]const u8 = undefined,
    value: Expr,
};

pub const VariableWithType = struct {
    var_type: TokenType = undefined,
    id: []const u8 = undefined,
};

pub fn parseGVariables(parser: *parse.Parser, lexer: *Lexer, index: *usize) log.Errors!usize {
    var gvar: parse.GStmts = undefined;
    index.* += 1;
    if (index.* >= lexer.tkns.items.len) {
        return log.Errors.EXP_ID_AFTER_LET;
    } else if (lexer.tkns.items[index.*].tkn_type != .Identifier) {
        parse.resetPos(lexer, &lexer.tkns.items[index.*]);
        return if (lexer.tkns.items[index.*].tkn_type == .Mutable) log.Errors.NO_MUT_GL_VARS else log.Errors.EXP_ID_AFTER_LET;
    }
    index.* += 1;
    if (index.* >= lexer.tkns.items.len) {
        parse.resetPos(lexer, &lexer.tkns.items[index.* - 1]);
        return log.Errors.EXP_EQUAL_AFTER_ID;
    }
    if (lexer.tkns.items[index.*].tkn_type != .Equal) {
        parse.resetPos(lexer, &lexer.tkns.items[index.*]);
        return log.Errors.EXP_EQUAL_AFTER_ID;
    }
    index.* += 1;
    if (index.* >= lexer.tkns.items.len) {
        parse.resetPos(lexer, &lexer.tkns.items[index.* - 1]);
        return log.Errors.EXP_VALUE_AFTER_EQL;
    } else if (typeChecker.isLiteral(lexer.tkns.items[index.*].tkn_type)) {
        gvar = parse.GStmts{
            .GVAR = Variable{
                .global = true,
                .immutable = true,
                .id = &lexer.tkns.items[index.* - 2].value,
                .var_type = typeChecker.getType(lexer.tkns.items[index.*].tkn_type),
                .value = Expr{
                    .literal = LiteralExpr{
                        .tkn = &lexer.tkns.items[index.*],
                    },
                },
            },
        };
    } else {
        parse.resetPos(lexer, &lexer.tkns.items[index.*]);
        return log.Errors.EXP_VALUE_AFTER_EQL;
    }
    index.* += 1;
    if (index.* >= lexer.tkns.items.len) {
        parse.resetPosSemicolon(lexer, &lexer.tkns.items[index.* - 1]);
        return log.Errors.EXP_SEMICOLON;
    }
    if (lexer.tkns.items[index.*].tkn_type != .SemiColon) {
        parse.resetPosSemicolon(lexer, &lexer.tkns.items[index.*]);
        _ = parser.gstmts.pop();
        return log.Errors.EXP_SEMICOLON;
    } else {
        parser.gstmts.append(gvar) catch |err| {
            log.logErr(@errorName(err));
            return index.*;
        };
    }
    return index.*;
}
