const std = @import("std");

pub fn withDefaultConfig(comptime ConfigType: type, overrides: anytype) ConfigType {
    const OverridesType = @TypeOf(overrides);
    switch (@typeInfo(OverridesType)) {
        .@"struct" => {},
        else => @compileError("withDefaultConfig expects a struct literal for overrides"),
    }

    var cfg: ConfigType = .{};

    inline for (std.meta.fields(OverridesType)) |field| {
        if (!@hasField(ConfigType, field.name)) {
            @compileError(std.fmt.comptimePrint(
                "withDefaultConfig unknown field '{s}' for {s}",
                .{ field.name, @typeName(ConfigType) },
            ));
        }

        @field(cfg, field.name) = @field(overrides, field.name);
    }

    return cfg;
}

test "withDefaultConfig applies partial overrides" {
    const Demo = struct {
        enabled: bool = false,
        threshold: i64 = 10,
    };

    const cfg = withDefaultConfig(Demo, .{ .enabled = true });
    try std.testing.expectEqual(true, cfg.enabled);
    try std.testing.expectEqual(@as(i64, 10), cfg.threshold);
}
