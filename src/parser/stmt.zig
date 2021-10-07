const std = @import("std");
const ArrayList = std.ArrayList;

// pub const StmtsTag = enum {};
pub const Stmts = union {
    fn_call: bool,
};
