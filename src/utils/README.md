# utils

Internal shared Zig helpers used by component config modules.

## Mapping

This directory does not map to a standalone ESP-IDF component runtime binding.
It provides compile-time helpers that reduce duplicated config logic.

## Scope

- Exposes utility APIs for config assembly and overrides.
- Must stay dependency-light and deterministic.

## Current API

- `withDefaultConfig(...)` from `config_overrides.zig`: applies partial
  struct-literal overrides onto a config type with compile-time field checks.

