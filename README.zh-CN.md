# ESP

面向 Zig 优先的 ESP-IDF 绑定，用纯 Zig 编写 ESP32 固件。

[English README](./README.md)

## 目录
- [前置要求](#前置要求)
- [快速开始](#快速开始)
- [仓库结构](#仓库结构)
- [核心概念](#核心概念)
- [常用命令](#常用命令)
- [构建选项](#构建选项)

## 前置要求

- Zig：使用支持 Xtensa 的 fork，[embed-zig/esp-zig-bootstrap](https://github.com/embed-zig/esp-zig-bootstrap)
- ESP-IDF v5.x

推荐写法：

```bash
cd examples/hello_world
zig build idf-build \
  -Dbuild_config=board/esp32s3_devkit/build_config.zig \
  -Dbsp=board/esp32s3_devkit/bsp.zig \
  -Desp_idf=/path/to/esp-idf
```

或者手动设置环境：

```bash
export ESP_IDF=/path/to/esp-idf
source "$ESP_IDF/export.sh"
```

## 快速开始

```bash
cd examples/hello_world
zig build flash-monitor \
  -Dbuild_config=board/esp32s3_devkit/build_config.zig \
  -Dbsp=board/esp32s3_devkit/bsp.zig \
  -Dport=/dev/cu.usbmodem1301 \
  -Desp_idf="$ESP_IDF" \
  -Dtimeout=15
```

## 仓库结构

```text
.
├── build.zig
├── src/
│   ├── esp_mod.zig          # 顶层 Zig API：esp.component / esp.hal / esp.runtime
│   ├── idf_mod.zig          # 顶层 IDF 辅助入口：sdkconfig / partition / build
│   ├── component/           # 与 ESP-IDF 组件 1:1 对齐的绑定
│   ├── hal/                 # 面向板级的硬件抽象
│   ├── runtime/             # 可复用运行时辅助
│   └── idf/                 # build、sdkconfig、partition 集成
├── test/
│   ├── convention_checks.zig
│   └── compile_test/
└── examples/
    ├── hello_world/
    ├── wifi/
    ├── bt_vhci_smoke/
    ├── aec_7210_8311/
    └── ota_led/
```

## 核心概念

### 组件绑定

`src/component/` 下的每个目录都对应一个 ESP-IDF 组件。

- `esp_mod.zig`：运行时 Zig API
- `idf_mod.zig`：构建元数据和 sdkconfig 导出
- `sdkconfig.zig`：该组件自维护的配置面
- `c_helper.c` / `c_helper.h`：可选的薄 C shim

### 固件示例

示例位于 `examples/<app>/` 下，通常包含：

- `build.zig`
- `board/`
- `src/main.zig`

示例构建时必须同时传入 `-Dbuild_config=...` 和 `-Dbsp=...`。

### 构建流程

`zig build` 负责驱动整个流程：

1. 从板级配置生成 sdkconfig 和 partition 数据
2. 脚手架生成临时 IDF 工程
3. 把 Zig 固件编译为静态库
4. 运行 `idf.py build`
5. 按需执行烧录和串口监视

## 常用命令

```bash
zig build
zig build test
zig build -l
```

构建单个示例：

```bash
zig build hello_world \
  -Dbuild_config=examples/hello_world/board/esp32s3_devkit/build_config.zig \
  -Dbsp=examples/hello_world/board/esp32s3_devkit/bsp.zig
zig build wifi_scan \
  -Dbuild_config=examples/wifi/scan/board/esp32s3_devkit/build_config.zig \
  -Dbsp=examples/wifi/scan/board/esp32s3_devkit/bsp.zig
zig build bt_vhci_smoke \
  -Dbuild_config=examples/bt_vhci_smoke/board/esp32s3_devkit/build_config.zig \
  -Dbsp=examples/bt_vhci_smoke/board/esp32s3_devkit/bsp.zig
```

示例工作流命令：

```bash
zig build <app>-configure -Dbuild_config=<path> -Dbsp=<path> -Desp_idf=/path/to/esp-idf
zig build <app>-idf-build -Dbuild_config=<path> -Dbsp=<path> -Desp_idf=/path/to/esp-idf
zig build <app>-flash -Dbuild_config=<path> -Dbsp=<path> -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-monitor -Dbuild_config=<path> -Dbsp=<path> -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-flash-monitor -Dbuild_config=<path> -Dbsp=<path> -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
```

## 构建选项

常用选项：

- `-Dbuild_config=<path>`：必填，板级配置文件
- `-Dbsp=<path>`：必填，板级 BSP 文件
- `-Dbuild_dir=<dir>`：生成产物目录
- `-Desp_idf=<path>`：ESP-IDF 根目录
- `-Didf_py=<path>`：显式指定 `idf.py`
- `-Dport=<serial>`：烧录和监视使用的串口
- `-Dbaud=<rate>`：串口波特率
- `-Dtimeout=<seconds>`：串口监视在 N 秒后自动退出
