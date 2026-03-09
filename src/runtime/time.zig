const esp_timer = @import("../component/esp_timer/timer.zig");
const freertos = @import("../component/freertos/task.zig");

pub const Time = struct {
    pub fn nowMs(_: Time) u64 {
        return esp_timer.getTimeMs();
    }

    pub fn sleepMs(_: Time, ms: u32) void {
        freertos.delay(freertos.msToTicks(ms, tick_rate_hz));
    }

    const tick_rate_hz: u32 = 100;
};
