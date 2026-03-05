extern fn esp_cpu_get_core_count() u32;

pub fn getCoreCount() usize {
    return @intCast(esp_cpu_get_core_count());
}
