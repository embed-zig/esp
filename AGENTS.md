# AGENTS.md
Agent guide for ESPZ.

## Table Of Contents
- [Project rules](#project-rules)
- [Environment and commands](#environment-and-commands)
- [Code conventions](#code-conventions)
- [Adding a component binding](#adding-a-component-binding)
- [Writing an example](#writing-an-example)
- [Change checklist](#change-checklist)
- [Non-goals](#non-goals)

## Project rules

- This repo is local-first. Do not assume PR gates or hosted CI.
- Do not introduce Bazel.
- Keep build orchestration in `build.zig` and `src/idf/build/`.
- Keep `src/component/<module>/` aligned 1:1 with ESP-IDF component boundaries.
- When adding or moving a component, update:
  - `src/esp_mod.zig`
  - `src/idf/cmake/component.zig`
  - `src/idf/sdkconfig/component.zig`
- Example apps live in `examples/<app>/`.

## Environment and commands

Use the Xtensa-capable Zig fork from
[embed-zig/esp-zig-bootstrap](https://github.com/embed-zig/esp-zig-bootstrap).

Recommended build style:

```bash
zig build hello_world-idf-build -Desp_idf=/path/to/esp-idf
```

Manual environment is also fine:

```bash
export ESP_IDF=/path/to/esp-idf
source "$ESP_IDF/export.sh"
```

Useful commands:

```bash
zig build
zig build test
zig build -l
zig build hello_world
zig build wifi_scan
zig build bt_vhci_smoke
```

Common workflow:

```bash
zig build <app>-configure -Desp_idf=/path/to/esp-idf
zig build <app>-idf-build -Desp_idf=/path/to/esp-idf
zig build <app>-flash -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-monitor -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-flash-monitor -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
```

Common options:

- `-Dbuild_config=<path>`
- `-Dbsp=<path>`
- `-Dbuild_dir=<dir>`
- `-Desp_idf=<path>`
- `-Didf_py=<path>`
- `-Dport=<serial>`
- `-Dbaud=<rate>`
- `-Dtimeout=<seconds>`

## Code conventions

### Zig

- Put imports at the top. Use `const std = @import("std");` first when needed.
- Run `zig fmt` after edits.
- Use `lowerCamelCase` for functions, `PascalCase` for types, `snake_case.zig` for files.
- Prefer explicit integer widths in config and schema code.
- Use `!T` and `try`; do not silently swallow errors.
- Use `@compileError` for invalid config or schema contracts.

### Component layout

- `esp_mod.zig` is runtime API only and should only re-export implementation files.
- `idf_mod.zig` holds build metadata and re-exports `sdkconfig.zig`.
- Keep `c_helper.c` shims thin: parameter conversion plus one ESP-IDF call.
- Prefix exported shim functions with `espz_`.

### Boards and examples

- Board files are declarative and export `pub const config` and `pub const pins`.
- Firmware imports board data through `@import("board")`.
- Do not hand-write `CMakeLists.txt` or `main/main.c` for examples.
- Prefer typed Zig wrappers over raw `extern fn` in firmware code.

### Docs and config completeness

- Every `src/component/<module>/` directory should include a `README.md`.
- Every `sdkconfig.zig` field should document the Kconfig key, meaning, and default.
- Do not rely on hidden ESP-IDF defaults for options owned by this repo.

## Adding a component binding

Each `src/component/<module>/` directory should usually contain:

- `README.md`
- `esp_mod.zig`
- `idf_mod.zig`
- `sdkconfig.zig`
- implementation `.zig` files
- optional `c_helper.c` / `c_helper.h`

Minimal `idf_mod.zig` responsibilities:

- declare `module_name`
- optionally declare `zig_root`
- declare `idf_requires`
- expose `embedded_files`
- re-export `sdkconfig`

Registration steps:

1. Add the module to `src/idf/cmake/component.zig`.
2. Re-export it from `src/esp_mod.zig`.
3. Re-export its sdkconfig surface from `src/idf/sdkconfig/component.zig`.
4. If it is a runtime module, add a compile test under `test/compile_test/<module>/`.

Compile-test layout:

```text
test/compile_test/<module>/
├── .gitignore
├── build.zig
├── build.zig.zon
├── board/esp32s3.zig
└── src/main.zig
```

Run compile tests with:

```bash
zig build test -Desp_idf=/path/to/esp-idf
```

## Writing an example

Typical example layout:

```text
examples/<app>/
├── build.zig
├── build.zig.zon
├── board/
└── src/main.zig
```

Guidelines:

- Use `esp.idf.build.registerApp(...)` in `build.zig`.
- Prefer `-Dbuild_config` and optional `-Dbsp`; `-Dboard` is deprecated compatibility only.
- Keep board-specific data in `board/`, not in firmware logic.
- Entry point is `export fn zig_esp_main() callconv(.c) void`.
- If you need an ESP-IDF C API, add a shim in the owning component instead of using raw FFI in the app.

## Change checklist

1. Run `zig fmt` on touched Zig files.
2. Run `zig build`.
3. Run `zig build test`.
4. If you changed a runtime component, make sure its compile test exists and still builds.
5. If you changed workflow wiring, build at least one example end-to-end.
6. If you changed runtime behavior, flash to hardware and verify it.
7. If you touched a component, update its `README.md`.
8. If you touched `sdkconfig.zig`, make sure docs stay complete.

## Non-goals

- No Bazel workflow.
- No fake runtime behavior in exposed APIs.
- No dependence on missing CI or PR infrastructure.
