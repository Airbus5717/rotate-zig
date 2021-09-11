const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.c_allocator;

const Token = @import("../lexer/tokens.zig").Token;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const Lexer = @import("../lexer/lexer.zig").Lexer;
const config = @import("../config.zig");
const log = @import("../log.zig");

const Import = struct {
    sys: bool,
    path: Token,
};

const GStatments = enum(u8) {
    Imports,
    GlobalVars,
    Functions,
    Structs,
};

const ParserPos = packed struct {
    parsed_type: GStatments,
    index: usize,
};

const Parser = struct {
    imports: ArrayList(Import),
    loc: ArrayList(ParserPos),

    pub fn init() Parser {
        return Parser{
            .loc = ArrayList(ParserPos).init(allocator),
            .imports = ArrayList(Import).init(allocator),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.imports.deinit();
    }

    pub fn outputParser(self: *Parser) !void {
        const output = try std.fs.cwd().openFile(
            config.log_output,
            .{ .write = true },
        );
        defer output.close();
        try output.seekFromEnd(0);
        try std.fmt.format(output.writer(), "{s} parser init {s}\n", .{ "=" ** 10, "=" ** 10 });
        for (self.imports.items) |item, index| {
            try std.fmt.format(output.writer(), "{any}{d}\n", .{ item, index });
        }
        for (self.loc.items) |item, index| {
            try std.fmt.format(output.writer(), "{any}{d}\n", .{ item, index });
        }
        try std.fmt.format(output.writer(), "{s} parser done {s}\n", .{ "=" ** 10, "=" ** 10 });
    }
};

pub fn parseRotate(lexer: *Lexer) Parser {
    var parse = Parser.init();
    _ = parse.imports;
    var i: usize = 0;
    while (i < lexer.tkns.items.len) : (i += 1) {
        // std.debug.print("{s}: {s}\n", .{ lexer.tkns.items[i].tkn_type.describe(), lexer.tkns.items[i].value });
        switch (lexer.tkns.items[i].tkn_type) {
            TokenType.Import => parseImports(&i, lexer, &parse, false),
            TokenType.Include => parseImports(&i, lexer, &parse, true),
            else => {},
        }
    }
    return parse;
}

fn parseImports(i: *usize, lexer: *Lexer, parser: *Parser, sys: bool) void {
    if (lexer.tkns.items[i.* + 1].tkn_type == .String) {
        i.* += 1;
        if (lexer.tkns.items[i.* + 1].tkn_type == .SemiColon) {
            i.* += 1;
            parser.imports.append(Import{ .sys = sys, .path = lexer.tkns.items[i.* - 1] }) catch |err| {
                log.logErr(@errorName(err));
                return;
            };
            parser.loc.append(.{ .parsed_type = .Imports, .index = parser.imports.items.len - 1 }) catch |err| {
                log.logErr(@errorName(err));
                return;
            };
        } else {
            log.printLog(log.Errors.EXPECTED_SEMICOLON, lexer);
        }
    } else {
        if (sys) {
            log.printLog(log.Errors.EXPECTED_STR_AFTER_INCLUDE, lexer);
        } else log.printLog(log.Errors.EXPECTED_STR_AFTER_IMPORT, lexer);
    }
}
