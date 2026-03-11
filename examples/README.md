# Examples

示例目录只保留示例本身；每个示例的构建、烧录、监控与运行结果都写在该示例自己的 `README.md` 中。

当前示例：

- `hello_world/`：最小启动日志与运行期内存占用观测示例。
- `link_attr/`：Zig 链接属性、段布局与内存地址演示。
- `led_strip/`：WS2812 RGB LED 彩虹效果示例。
- `bt_vhci_smoke/`：Bluetooth VHCI 传输接口的纯 Zig 用法示例。
- `lcd_battery/`：SZP 板卡 LCD 电量条显示示例。
- `ota_led/`：从数据分区切换红绿 LED 固件的 OTA 演示。
- `esp_sr/`：ESP-SR AEC/NS/AGC 算法体积与内存基准示例。
- `aec_7210_8311/`：ES7210+ES8311 音频回声消除（AEC+MASE+NS+AGC）演示。
- `aec_7210_8311_loopback/`：ES7210+ES8311 实时 AEC 回环测试示例。
- `wifi/scan/`：Wi-Fi STA 扫描与 AP 列表示例。
- `wifi/sta/`：Wi-Fi STA 最小启动示例。
- `wifi/ap/`：Wi-Fi SoftAP 最小启动示例。

说明：

- 示例的 SDK 配置由 Zig 聚合生成，不依赖 `sdkconfig.defaults`；常用工作流步骤为 `zig build generate-sdkconfig`、`zig build build`、`zig build flash`、`zig build monitor` 与 `zig build flash-monitor`。
- 统一使用 `-Dbuild_config=board/<name>/build_config.zig` 与 `-Dbsp=board/<name>/bsp.zig` 选择板级配置与运行时 BSP。
- 示例级 board 目录统一采用拆分结构：`build_config.zig` 负责 build-time sdkconfig/profile，`bsp.zig` 负责运行时板级导出，例如 `pins`、外设接线与 helper。
