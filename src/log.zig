const std = @import("std");
const expect = @import("std").testing.expect;

const Lexer = @import("lexer/lexer.zig").Lexer;
const parser = @import("parser/parser.zig");
const Parser = parser.Parser;

pub const Errors = error{
    UNKNOWN_TOKEN,
    UNIMPLEMENTED,
    END_OF_FILE,
    NOT_CLOSED_STR,
    NOT_CLOSED_CHAR,
    EXP_STR_AFTER_IMPORT,
    EXP_STR_AFTER_INCLUDE,
    EXP_SEMICOLON,
    EXP_ID_AFTER_LET,
    EXP_EQUAL_AFTER_ID,
    EXP_VALUE_AFTER_EQL,
    NOT_ALLOWED_AT_GLOBAL,
    NO_MUT_GL_VARS,
    REQUIRE_VALUE,
    EXIT_FAILURE,
};

pub fn isCustomError(err: Errors) bool {
    switch (err) {
        Errors.UNKNOWN_TOKEN,
        Errors.UNIMPLEMENTED,
        Errors.END_OF_FILE,
        Errors.NOT_CLOSED_STR,
        Errors.NOT_CLOSED_CHAR,
        Errors.EXP_STR_AFTER_IMPORT,
        Errors.EXP_STR_AFTER_INCLUDE,
        Errors.EXP_SEMICOLON,
        Errors.EXP_ID_AFTER_LET,
        Errors.EXP_EQUAL_AFTER_ID,
        Errors.EXP_VALUE_AFTER_EQL,
        Errors.NOT_ALLOWED_AT_GLOBAL,
        Errors.NO_MUT_GL_VARS,
        Errors.REQUIRE_VALUE,
        Errors.EXIT_FAILURE,
        => return true,
        else => return false,
    }
    return false;
}

pub fn locationNeeded(err: Errors) bool {
    switch (err) {
        Errors.END_OF_FILE => return false,
        else => return true,
    }
}

pub fn describe(err: Errors) []const u8 {
    switch (err) {
        Errors.UNKNOWN_TOKEN => return "Unknown Token",
        Errors.END_OF_FILE => return "Reached end of file",
        Errors.UNIMPLEMENTED => return "TODO: Error string",
        Errors.NOT_CLOSED_STR => return "String not closed",
        Errors.NOT_CLOSED_CHAR => return "Char not closed",
        Errors.EXP_STR_AFTER_IMPORT => return "String expected after keyword `import`",
        Errors.EXP_STR_AFTER_INCLUDE => return "String expected after keyword `include`",
        Errors.EXP_SEMICOLON => return "Semicolon expected",
        Errors.EXP_ID_AFTER_LET => return "Identifier expected after keyword `let`",
        Errors.EXP_EQUAL_AFTER_ID => return "Equal expected after identifier",
        Errors.EXP_VALUE_AFTER_EQL => return "Variable requires a value",
        Errors.NO_MUT_GL_VARS => return "Global variables cannot be mutable",
        Errors.NOT_ALLOWED_AT_GLOBAL => return "Found global token at its forbidden scope",

        else => return "TODO err msg",
    }
}

pub fn advice(err: Errors) []const u8 {
    switch (err) {
        Errors.UNKNOWN_TOKEN => return "Remove the unknown token",
        Errors.END_OF_FILE => return "Reached end of file",
        Errors.UNIMPLEMENTED => return "Error string unimplemented",
        Errors.NOT_CLOSED_STR => return "Close string with double quotes",
        Errors.NOT_CLOSED_CHAR => return "Close char with single quote",
        Errors.EXP_STR_AFTER_IMPORT => return "Add a string after keyword `import`",
        Errors.EXP_STR_AFTER_INCLUDE => return "Add a string after keyword `include`",
        Errors.EXP_SEMICOLON => return "Add a semicolon",
        Errors.EXP_ID_AFTER_LET => return "Add an Identifier after keyword `let`",
        Errors.EXP_EQUAL_AFTER_ID => return "Add an equal symbol `=` after identifier",
        Errors.EXP_VALUE_AFTER_EQL => return "Add a value to variable",
        Errors.NO_MUT_GL_VARS => return "Remove the mutable `mut` keyword",
        Errors.NOT_ALLOWED_AT_GLOBAL => return "Remove this token",

        else => return "Error message unimplemented",
    }
}

// compiler crashes logbegin
pub fn errorLog(error_describe: []const u8, error_advice: []const u8, err_num: usize, location: bool, lexer: *Lexer) !void {
    // std.debug.print("col: {d}, line: {d}\n{c}\n", .{ lexer.col, lexer.length, lexer.file.code[lexer.index] });
    try std.io.getStdErr().writer().print("{s}{s}error[{d:0>4}]: {s}{s}{s}\n", .{
        BOLD,
        LRED,
        err_num,
        LCYAN,
        error_describe,
        RESET,
    });

    // std.debug.print("{d}, {any}, {d}\n", .{lexer.file.code.len, lexer.lines.items, lexer.line - 1});
    try std.io.getStdErr().writer().print("{s}{s}--> {s}:{d}:{d}{s}\n", .{
        BOLD,
        LGREEN,
        lexer.file.name,
        lexer.line,
        lexer.col,
        RESET,
    });
    if (location) {
        var i: usize = 0;
        while (lexer.file.code[lexer.index + i] != '\n') {
            i += 1;
        }
        // std.debug.print("index: {d}\n", .{i});
        var src: []const u8 = undefined;
        if (lexer.line == 1) {
            src = lexer.file.code[0..(lexer.index + i)];
        } else {
            const lines = lexer.lines.items;
            src = lexer.file.code[lines[lexer.line - 2]..(lexer.index + i)];
        }
        // std.debug.print("{s}\n", .{src});
        // const distance = try std.math.sub(usize, lexer.col, lexer.length);
        // std.debug.print("{d}\n", .{distance});
        try std.io.getStdErr().writer().print("{d} {s}┃{s} {s}\n", .{
            lexer.line,
            LYELLOW,
            RESET,
            src,
        });
        try std.io.getStdErr().writer().print("  {s}┃{s}{s}{s}{s} {s}{s}\n", .{
            LYELLOW,
            (" " ** 2048)[0..lexer.col],
            LRED,
            ("^" ** 2048)[0..lexer.length],
            LYELLOW,
            error_advice,
            RESET,
        });
    }
}

pub fn logInFile(file: std.fs.File, comptime fmt: []const u8, args: anytype) void {
    std.fmt.format(file.writer(), fmt, args) catch |err| {
        logErr(@errorName(err));
    };
}

pub fn printLog(error_type: Errors, lexer: *Lexer) void {
    errorLog(
        describe(error_type),
        advice(error_type),
        @errorToInt(error_type),
        locationNeeded(error_type),
        lexer,
    ) catch |err| {
        std.debug.print("print Log err: {s}\n", .{@errorName(err)});
        // logErr(@errorName(err));
    };
}

pub fn logErr(err: []const u8) void {
    std.log.err("{s}", .{err});
}

// colors
const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const BLUE = "\x1b[34m";
const PINK = "\x1b[35m";
const CYAN = "\x1b[36m";
const BLACK = "\x1b[30m";
const WHITE = "\x1b[37m";
// text visuals
const BOLD = "\x1b[1m";
const FAINT = "\x1b[2m";
// lighter colors
const DEFAULT = "\x1b[39m";
const LGRAY = "\x1b[90m";
const LRED = "\x1b[91m";
const LGREEN = "\x1b[92m";
const LYELLOW = "\x1b[93m";
const LBLUE = "\x1b[94m";
const LMAGENTA = "\x1b[95m";
const LCYAN = "\x1b[96m";
const LWHITE = "\x1b[97m";
// reset colors
const RESET = "\x1b[0m";

test "Error enum" {
    std.debug.print("{d}", .{@errorToInt(Errors.UNKNOWN_TOKEN)});
    try expect(@errorToInt(Errors.UNKNOWN_TOKEN) == 60);
}
