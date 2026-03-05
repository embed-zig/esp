#!/usr/bin/env bash
#
# Run src/<module>/test/ compile tests.
#
# Usage:
#   ./test/test_compile.sh -Desp_idf=/path/to/esp-idf          # run all
#   ./test/test_compile.sh -Desp_idf=/path/to/esp-idf lwip heap # run specific modules
#
# Stops on first failure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Separate module names from zig build flags
MODULES=()
ZIG_ARGS=()
for arg in "$@"; do
    case "$arg" in
        -*) ZIG_ARGS+=("$arg") ;;
        *)  MODULES+=("$arg") ;;
    esac
done

# If no modules specified, discover all
if [ ${#MODULES[@]} -eq 0 ]; then
    for test_dir in "$ROOT_DIR"/src/*/test; do
        [ -f "$test_dir/build.zig" ] || continue
        MODULES+=("$(basename "$(dirname "$test_dir")")")
    done
fi

PASS=0

for module in "${MODULES[@]}"; do
    test_dir="$ROOT_DIR/src/$module/test"
    if [ ! -f "$test_dir/build.zig" ]; then
        printf "ERROR: src/%s/test/build.zig not found\n" "$module"
        exit 1
    fi

    printf "\n══ %-30s ══\n" "$module"
    (cd "$test_dir" && zig build idf-build "${ZIG_ARGS[@]}")
    PASS=$((PASS + 1))
    printf "  ✓ %s\n" "$module"
done

printf "\n══ All %d module(s) passed ══\n" "$PASS"
