const std = @import("std");

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

pub const Errors = enum {
    UNKNOWN_TOKEN,
    pub fn describe(self: Error) []u8 {
        switch (self) {
            UKNOWN_TOKEN => return "Uknown Token",
            else => return "Uknown Error",
        }
    }
    pub fn advice(self: Error) []u8 {
        switch (self) {
            UKNOWN_TOKEN => return "Remove the unknown token",
            else => return "Uknown Error",
        }
    }
};

pub fn logErr(err: []const u8) void {
    std.log.err("{s}", .{err});
}

pub fn logWarn(warn: []const u8) void {
    std.log.warn("{s}", .{warn});
}

pub fn logInfo(info: []const u8) void {
    std.log.info("{s}", .{info});
}
