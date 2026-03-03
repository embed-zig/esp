# esptool_py

Sdkconfig binding for the ESP-IDF `esptool_py` build component.

## ESP-IDF component

Build-time tooling component (`esptool.py`); no public runtime API reference.

## Module boundary

Provides sdkconfig bindings for flash programming parameters: flash mode (DIO/QIO/DOUT/QOUT), flash frequency, flash size, reset behavior before/after flashing, monitor baud rate, and octal flash support. These settings control `esptool.py` invocation during the build/flash workflow.

## Dependencies

No runtime dependencies (build-time only).
