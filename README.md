# ESPZ

ESPZ 是一个**单 package** 的 ESP-IDF Zig binding 仓库。

## 目录结构

```text
.
├── build.zig
├── build.zig.zon
├── src/
│   ├── idf.zig
│   ├── boards/
│   ├── event/
│   ├── net/
│   ├── wifi/
│   ├── mbed_tls/
│   ├── bt/
│   ├── i2c/
│   ├── timer/
│   └── ledc/
├── cmake/
└── examples/
```

## 约束

- 只做 ESP-IDF binding（不做跨平台抽象层）。
- 对外入口固定为 `src/idf.zig`。
- 示例统一放在 `examples/`。
