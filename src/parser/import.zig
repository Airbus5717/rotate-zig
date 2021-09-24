const std = @import("std");

const Token = @import("../lexer/tokens.zig").Token;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const log = @import("../log.zig");
const parse = @import("./parser.zig");

pub const ImportStmt = struct {
    include: bool,
    value: *Token,
};

pub fn parseImports(parser: *parse.Parser, lexer: *Lexer, index: *usize, system: bool) log.Errors!usize {
    index.* += 1;

    if (index.* >= lexer.tkns.items.len) {
        if (system) {
            return log.Errors.EXP_STR_AFTER_INCLUDE;
        } else return log.Errors.EXP_STR_AFTER_IMPORT;
    }
    if (lexer.tkns.items[index.*].tkn_type != .String) {
        if (system) {
            return log.Errors.EXP_STR_AFTER_INCLUDE;
        } else return log.Errors.EXP_STR_AFTER_IMPORT;
    }
    index.* += 1;
    if (index.* >= lexer.tkns.items.len) {
        const item = lexer.tkns.items[index.* - 1];
        lexer.col = item.pos.col;
        lexer.line = item.pos.line;
        lexer.index = item.pos.index;
        lexer.length = item.value.len;
        return log.Errors.EXP_SEMICOLON;
    }
    if (lexer.tkns.items[index.*].tkn_type == .SemiColon) {
        parser.gstmts.append(parse.GStmts{ .IMPORT = ImportStmt{ .include = system, .value = &lexer.tkns.items[index.* - 1] } }) catch |err| {
            log.logErr(@errorName(err));
        };
        return (index.*);
    } else {
        const item = lexer.tkns.items[index.*];
        lexer.col = item.pos.col;
        lexer.line = item.pos.line;
        lexer.index = item.pos.index;
        lexer.length = item.value.len;
        return log.Errors.EXP_SEMICOLON;
    }
}
