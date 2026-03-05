#!/usr/bin/env bash
# Wrapper that activates ESP-IDF environment before running a command.
# Usage: idf_env_wrapper.sh <esp_idf_path> <command> [args...]
set -euo pipefail

ESP_IDF_PATH="$1"
shift

export IDF_PATH="$ESP_IDF_PATH"
source "$ESP_IDF_PATH/export.sh" >/dev/null 2>&1

exec "$@"
