const std = @import("std");

pub fn getDigits(num: usize) usize {
    var count: usize = 0;
    var tmp = num;
    if (tmp < 9) {
        return 1;
    } else {
        while (tmp > 0) {
            tmp /= 10;
            count += 1;
        }
    }
    return count;
}
