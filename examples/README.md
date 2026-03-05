# Examples

示例目录只保留示例本身；每个示例的构建、烧录、监控与运行结果都写在该示例自己的 `README.md` 中。

当前示例：

- `hello_world/`：最小启动日志与运行期内存占用观测示例。
- `wifi/scan/`：Wi-Fi STA 扫描与 AP 列表示例。
- `wifi/sta/`：Wi-Fi STA 最小启动示例。
- `wifi/ap/`：Wi-Fi SoftAP 最小启动示例。
- `lcd_battery/`：SZP 板卡 LCD 电量条显示示例。
- `bt_vhci_smoke/`：Bluetooth VHCI 传输接口的纯 Zig 用法示例。
- `aec_7210_8311/`：ES7210+ES8311 音频回声消除（AEC+MASE+NS+AGC）演示。

说明：示例的 SDK 配置由 Zig 聚合生成（`zig build <app>-sdkconfig`），不依赖 `sdkconfig.defaults`；示例级配置入口位于 `examples/<app>/board/*.zig`（每块板一个文件，包含模块配置与 partition 定义）。
