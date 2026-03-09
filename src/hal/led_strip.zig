const led_strip = @import("../component/led_strip/led_strip.zig");
const hal_led_strip = @import("embed").hal.led_strip;

pub const Driver = struct {
    strip: ?led_strip.LedStrip = null,
    pixel_count: u32 = 0,

    pub fn initRmt(gpio_num: i32, pixel_count: u32) led_strip.Error!Driver {
        const strip = try led_strip.LedStrip.initRmt(.{
            .gpio_num = gpio_num,
            .max_leds = pixel_count,
        }, .{});
        return .{
            .strip = strip,
            .pixel_count = pixel_count,
        };
    }

    pub fn deinit(self: *Driver) void {
        if (self.strip) |s| {
            s.deinit() catch {};
            self.strip = null;
        }
    }

    pub fn setPixel(self: *Driver, index: u32, color: hal_led_strip.Color) void {
        if (index >= self.pixel_count) return;
        if (self.strip) |s| {
            s.setPixel(index, color.r, color.g, color.b) catch {};
        }
    }

    pub fn getPixelCount(self: *Driver) u32 {
        return self.pixel_count;
    }

    pub fn refresh(self: *Driver) void {
        if (self.strip) |s| {
            s.refresh() catch {};
        }
    }
};
