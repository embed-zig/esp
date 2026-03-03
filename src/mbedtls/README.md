# mbedtls

Sdkconfig binding for the ESP-IDF `mbedtls` component.

## ESP-IDF component

Maps to [`mbedtls`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/protocols/mbedtls.html).

## Module boundary

Provides sdkconfig options for the Mbed TLS cryptographic library: cipher suites (AES, GCM, CCM, ChaCha20), key exchange algorithms (RSA, ECDH, ECDSA), TLS protocol versions, certificate bundles, hardware acceleration (AES/SHA/MPI), SSL buffer sizes, and debug settings. No runtime Zig API.

## Dependencies

No runtime dependencies.
