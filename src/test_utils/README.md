# `test_utils`

`test_utils` is an ESPZ internal helper module for example/runtime observability.

## Scope

- Provide Zig-side formatting helpers used by examples (`runtime_report.zig`)
- Provide IDF runtime entry helper for hello-world style runtime reporting (`runtime_report.c`)
- Keep APIs small and deterministic for testing/log assertions

## Out of scope

- No board pin/peripheral driver ownership
- No product business logic

## Public Zig surface

```zig
pub const runtime_report = @import("runtime_report.zig");

pub const RuntimeReport = struct {
    pub fn logStartup(message: []const u8) void {}
    pub fn formatStableLine(seconds: u32, buffer: []u8) ![]const u8 {}
    pub fn formatUsageLine(comptime label: []const u8, usage: MemoryUsage, buffer: []u8) ![]const u8 {}
};
```

## IDF runtime entry symbol (component side)

```c
void zig_esp_main(void);
```
