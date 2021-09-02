const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.c;
const print = std.debug.print;
const Lexer = @import("lexer/lexer.zig").Lexer;

pub const Errors = error{
    UNKNOWN_TOKEN,
    END_OF_FILE,
    NOT_CLOSED_STR,
    NOT_CLOSED_CHAR,
};

pub fn describe(err: Errors) []const u8 {
    switch (err) {
        Errors.END_OF_FILE => return "Reached end of file",
        Errors.NOT_CLOSED_STR => return "String not closed",
        Errors.NOT_CLOSED_CHAR => return "Char not closed",
        else => return "Unknown Token",
    }
}

pub fn advice(err: Errors) []const u8 {
    switch (err) {
        Errors.END_OF_FILE => return "Reached end of file",
        Errors.NOT_CLOSED_STR => return "Close string with double quotes",
        Errors.NOT_CLOSED_CHAR => return "Close char with single quote",
        else => return "Remove the unknown token",
    }
}

// compiler crashes logbegin
pub fn errorLog(error_type: Errors, location: bool, lexer: *Lexer) !void {
    try std.io.getStdErr().writer().print("{s}{s}error[{d:0>4}]: {s}{s}\n", .{ BOLD, LRED, @errorToInt(error_type), LCYAN, describe(error_type) });
    var i: usize = 0;
    while (lexer.src[lexer.index + i] != '\n') {
        i += 1;
    }
    var src: []const u8 = undefined;
    if (lexer.line == 1) {
        src = lexer.src[0..(lexer.index + i)];
    } else {
        src = lexer.src[lexer.lines.items[(lexer.lines.items.len - 1)]..(lexer.index + i)];
    }

    var distance: usize = undefined;
    if (lexer.length == 1) {
        distance = lexer.col;
    } else {
        distance = lexer.col - lexer.length;
    }

    if (location) {
        try std.io.getStdErr().writer().print("{s}{s}--> {s}:{d}:{d}\n", .{ BOLD, LGREEN, lexer.file, lexer.line, lexer.col });
        try std.io.getStdErr().writer().print("{d} {s}┃{s} {s}\n", .{ lexer.line, LYELLOW, RESET, src });
        try std.io.getStdErr().writer().print("  {s}┃{s}{s}{s}{s} {s}{s}\n", .{ LYELLOW, (" " ** 4096)[0..distance], LRED, ("^" ** 4096)[0..lexer.length], LYELLOW, advice(error_type), RESET });
    }
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
