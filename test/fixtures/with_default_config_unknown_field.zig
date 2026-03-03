const utils = @import("utils");

const DemoConfig = struct {
    enabled: bool = false,
};

pub fn main() void {
    _ = utils.withDefaultConfig(DemoConfig, .{
        .not_a_field = true,
    });
}
