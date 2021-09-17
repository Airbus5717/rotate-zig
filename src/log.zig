const std = @import("std");
const Lexer = @import("lexer/lexer.zig").Lexer;
const Parser = @import("parser/parser.zig").Parser;

pub const Errors = error{
    UNKNOWN_TOKEN,
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
};

pub fn describe(err: Errors) []const u8 {
    switch (err) {
        Errors.END_OF_FILE => return "Reached end of file",
        Errors.NOT_CLOSED_STR => return "String not closed",
        Errors.NOT_CLOSED_CHAR => return "Char not closed",
        Errors.EXP_STR_AFTER_IMPORT => return "String expected after keyword `import`",
        Errors.EXP_STR_AFTER_INCLUDE => return "String expected after keyword `include`",
        Errors.EXP_SEMICOLON => return "Semicolon expected",
        Errors.EXP_ID_AFTER_LET => return "Identifier expected after keyword `let`",
        Errors.NOT_ALLOWED_AT_GLOBAL => return "Found global token at its forbidden scope",
        else => return "Unknown Token",
    }
}

pub fn advice(err: Errors) []const u8 {
    switch (err) {
        Errors.END_OF_FILE => return "Reached end of file",
        Errors.NOT_CLOSED_STR => return "Close string with double quotes",
        Errors.NOT_CLOSED_CHAR => return "Close char with single quote",
        Errors.EXP_STR_AFTER_IMPORT => return "Add a string after keyword `import`",
        Errors.EXP_STR_AFTER_INCLUDE => return "Add a string after keyword `include`",
        Errors.EXP_SEMICOLON => return "Add a semicolon",
        Errors.EXP_ID_AFTER_LET => return "Add an Identifier after keyword `let`",
        Errors.NOT_ALLOWED_AT_GLOBAL => return "Don't put this token in global scope",
        else => return "Remove the unknown token",
    }
}

// compiler crashes logbegin
pub fn errorLog(error_type: Errors, location: bool, lexer: *Lexer) !void {
    std.debug.print("col: {d}, line: {d}\n{c}\n", .{ lexer.col, lexer.length, lexer.src[lexer.index] });
    try std.io.getStdErr().writer().print("{s}{s}error[{d:0>4}]: {s}{s}\n", .{ BOLD, LRED, @errorToInt(error_type), LCYAN, describe(error_type) });
    var i: usize = 0;
    while (lexer.src[lexer.index + i] != '\n') {
        i += 1;
    }
    // std.debug.print("{d}\n", .{i});
    var src: []const u8 = undefined;
    if (lexer.line == 1) {
        src = lexer.src[0..(lexer.index + i)];
    } else {
        src = lexer.src[lexer.lines.items[(lexer.lines.items.len - 1)]..(lexer.index + i)];
    }
    std.debug.print("{s}\n", .{src});

    // const distance = try std.math.sub(usize, lexer.col, lexer.length);
    // std.debug.print("{d}\n", .{distance});
    if (location) {
        try std.io.getStdErr().writer().print("{s}{s}--> {s}:{d}:{d}\n", .{ BOLD, LGREEN, lexer.file, lexer.line, lexer.col });
        try std.io.getStdErr().writer().print("{d} {s}┃{s} {s}\n", .{ lexer.line, LYELLOW, RESET, src });
        try std.io.getStdErr().writer().print("  {s}┃{s}{s}{s}{s} {s}{s}\n", .{ LYELLOW, (" " ** 2048)[0..lexer.col], LRED, ("^" ** 2048)[0..lexer.length], LYELLOW, advice(error_type), RESET });
    }
}

pub fn logInFile(file: std.fs.File, comptime fmt: []const u8, args: anytype) void {
    std.fmt.format(file.writer(), fmt, args) catch |err| {
        logErr(@errorName(err));
    };
}

pub fn printLog(error_type: Errors, lexer: *Lexer) void {
    errorLog(error_type, true, lexer) catch |err| {
        logErr(@errorName(err));
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
