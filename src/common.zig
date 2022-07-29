pub fn isID(c: u8) bool {
    return switch (c) {
        '_', 'a'...'z', 'A'...'Z', '0'...'9' => true,
        else => false,
    };
}
