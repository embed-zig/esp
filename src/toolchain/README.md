# toolchain

Sdkconfig binding for ESP-IDF compiler/toolchain configuration.

## ESP-IDF component

Maps to internal toolchain configuration (compiler flags, optimization, and diagnostics).

## Module boundary

Provides sdkconfig options for the C/C++ toolchain: optimization level (debug/size/performance), stack protection, warning flags, C++ exceptions/RTTI, colored diagnostics, CXX standard, and assertion behavior. No runtime Zig API.

## Dependencies

No runtime dependencies.
