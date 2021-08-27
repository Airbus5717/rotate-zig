const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const Lexer = @import("lexer/lexer.zig").Lexer;

pub const Errors = error{
    UNKNOWN_TOKEN,
    END_OF_FILE,
};

pub fn describe(err: Errors) []const u8 {
    switch (err) {
        Errors.END_OF_FILE => return "Reached end of file",
        else => return "Unknown Token",
    }
}

pub fn advice(err: Errors) []const u8 {
    switch (err) {
        Errors.END_OF_FILE => return "File is empty or not enough code for compiling",
        else => return "Remove the unknown token",
    }
}

// compiler crashes logbegin
pub fn errorLog(error_type: Errors, location: bool, lexer: *Lexer) !void {
    try std.io.getStdErr().writer().print("{s}{s}error[{d:0>4}]: {s}{s}\n", .{ BOLD, LRED, @errorToInt(error_type) - 60, LCYAN, describe(error_type) });

    if (location and lexer.col < 250 and lexer.length < 250) {
        try std.io.getStdErr().writer().print("{s}{s}--> {s}:{d}:{d}\n", .{ BOLD, LGREEN, lexer.file, lexer.line, lexer.col });
        try std.io.getStdErr().writer().print("{d} {s}┃{s} {s}\n", .{ lexer.line, LYELLOW, RESET, "line stuff" });
        try std.io.getStdErr().writer().print("  {s}┃{s}{s}{s}{s} {s}{s}\n", .{ LYELLOW, (" " ** 4096)[0..lexer.col], LRED, ("^" ** 4096)[0..lexer.length], LYELLOW, advice(error_type), RESET });
    }
}
// zig fmt: on

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
