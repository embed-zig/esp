const mbedtls = @import("mbedtls");

comptime {
    _ = mbedtls.mbed_tls;
    _ = mbedtls.mbed_tls.sha256_context;
    _ = mbedtls.mbed_tls.sha256_init;
    _ = mbedtls.mbed_tls.sha256_hash;
    _ = mbedtls.mbed_tls.sha512_context;
    _ = mbedtls.mbed_tls.md_context_t;
    _ = mbedtls.mbed_tls.md_info_from_type;
    _ = mbedtls.mbed_tls.x509_crt;
    _ = mbedtls.mbed_tls.crtBundleSet;
}

export fn zig_esp_main() callconv(.c) void {}
