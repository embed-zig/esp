const random = @import("../component/esp_random/random.zig");
const runtime = @import("embed").runtime;

pub const Rng = struct {
    pub fn fill(_: Rng, buf: []u8) runtime.rng.Error!void {
        random.fill(buf);
    }
};
