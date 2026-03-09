const cpu = @import("../component/esp_cpu/cpu.zig");
const runtime = @import("embed").runtime;

pub const System = struct {
    pub fn getCpuCount(_: System) runtime.system.Error!usize {
        const count = cpu.getCoreCount();
        if (count == 0) return runtime.system.Error.QueryFailed;
        return count;
    }
};
