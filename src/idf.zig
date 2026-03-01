//! ESPZ root module (ESP-IDF Zig binding package root).
//! 迁移后只保留 ESP-IDF 相关 binding，不包含跨平台抽象层。

pub const version = "0.1.0-dev";

test "idf root module loads" {
    try @import("std").testing.expect(version.len > 0);
}
