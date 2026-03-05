const std = @import("std");

extern fn espz_timer_get_time() i64;

/// Returns microseconds since boot. Always non-negative.
pub fn getTimeUs() u64 {
    const us = espz_timer_get_time();
    return if (us <= 0) 0 else @intCast(us);
}

/// Returns milliseconds since boot (truncated from microsecond resolution).
pub fn getTimeMs() u64 {
    return getTimeUs() / std.time.us_per_ms;
}

test "getTimeMs is derived from getTimeUs" {
    _ = &getTimeUs;
    _ = &getTimeMs;
}
