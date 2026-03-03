# bt (ESP-IDF Bluetooth component)

This directory represents the ESP-IDF `bt` component in ESPZ.

## What the ESP-IDF `bt` component is for

In ESP-IDF, `bt` is the core Bluetooth component that enables and configures Bluetooth on ESP chips.

At a high level, it provides:

- **Bluetooth subsystem enable/disable** (`CONFIG_BT_ENABLED`)
- **Host stack selection**
  - **Bluedroid** (dual-mode: Classic Bluetooth + BLE)
  - **NimBLE** (BLE-only, lower memory footprint)
- **Controller/host integration** (including VHCI transport paths)
- **Common Bluetooth runtime resources** (such as host alarm capacity via `CONFIG_BT_ALARM_MAX_NUM`)
- Base APIs and dependencies used by higher-level Bluetooth features (GAP, GATT, profiles, BLE Mesh, etc.)

## Current status in this repository

The Zig side in this directory now has two parts:

- **Typed sdkconfig mapping** (`config.zig`), including:
  - `CONFIG_BT_ENABLED`
  - `CONFIG_BT_ALARM_MAX_NUM`
  - Host/controller choice keys used by controller-only workflows (`CONFIG_BT_CONTROLLER_ONLY`, etc.)
- **Runtime VHCI HCI-transport binding surface** (`vhci.zig`), including:
  - HCI transport wrappers on VHCI (`esp_vhci_host_*`)

Scope note: this module intentionally does **not** implement a BLE host stack (ATT/GATT/SMP/GAP state machine).

## Proposed Zig API surface: HCI-only `VHci`

The `bt` module should expose one runtime struct named `VHci`, but only with **HCI transport methods** (no controller lifecycle API, no host stack API).

```zig
pub const VHci = struct {
    pub const EspError = i32; // esp_err_t

    pub const WriteResult = enum(u8) {
        ok,
        would_block,
        invalid_length,
    };

    pub const HciCallbacks = extern struct {
        on_writable: ?*const fn () callconv(.c) void,
        on_readable: ?*const fn (data: [*]u8, len: u16) callconv(.c) c_int,
    };

    // HCI transport only
    pub fn registerCallbacks(callbacks: *const HciCallbacks) EspError;
    pub fn canWrite() bool;
    pub fn tryWrite(packet: [*]const u8, len: u16) WriteResult;
};
```

Design boundary:

- `VHci` exposes only packet transport capability for HCI.
- No controller init/enable/disable APIs in this surface.
- No host protocol implementation (L2CAP/ATT/GATT/SMP/GAP) in this package.
- No HCI packet codec/helper in this package.

Cross-platform BLE host code should use `VHci` only as:

- writable signal (`on_writable` / `canWrite`)
- packet write (`tryWrite`, may return `would_block`)
- packet read callback (`on_readable`)

### Why no `read()` method?

ESP VHCI is callback-driven for RX path:

- TX path: host calls `tryWrite(...)`.
- RX path: controller pushes packets through `on_readable(data, len)`.

So in this transport model, `on_readable` is the read channel; there is no pull-style `read()` in the underlying C API.

## What this module will be useful for after bindings are implemented

After runtime bindings are aligned to this design, this module is mainly useful as:

1. **HCI packet transport adapter on ESP chips**
   - pass HCI packets between ESP controller and external Zig host stack.
2. **Asynchronous transport signals**
   - writable notification + readable callback wiring for event-driven host runtime.
3. **Typed build-time configuration**
   - keep Bluetooth-related sdkconfig keys explicit and auditable.

In short: this module focuses on Bluetooth configuration + HCI transport binding, while host protocol logic remains external to this package.

## References

- ESP-IDF Bluetooth API overview:  
  https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/bluetooth/index.html
- ESP-IDF Bluetooth main API (`esp_bt_main.h`):  
  https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/bluetooth/esp_bt_main.html
- ESP-IDF NimBLE host API:  
  https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/bluetooth/nimble/index.html
- ESP-IDF SDK Kconfig for `bt`:  
  https://raw.githubusercontent.com/espressif/esp-idf/master/components/bt/Kconfig
- ESP-IDF SDK common BT Kconfig (`CONFIG_BT_ALARM_MAX_NUM`):  
  https://raw.githubusercontent.com/espressif/esp-idf/master/components/bt/common/Kconfig.in
