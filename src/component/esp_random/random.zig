extern fn esp_fill_random(buf: [*]u8, len: usize) void;

pub fn fill(buf: []u8) void {
    if (buf.len == 0) return;
    esp_fill_random(buf.ptr, buf.len);
}
