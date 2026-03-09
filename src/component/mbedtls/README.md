# mbedtls

Sdkconfig binding and runtime Zig API for the ESP-IDF `mbedtls` component.

## ESP-IDF component

Maps to [`mbedtls`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/protocols/mbedtls.html).

## Module boundary

Provides sdkconfig options for the Mbed TLS cryptographic library: cipher suites (AES, GCM, CCM, ChaCha20), key exchange algorithms (RSA, ECDH, ECDSA), TLS protocol versions, certificate bundles, hardware acceleration (AES/SHA/MPI), SSL buffer sizes, and debug settings.

Also provides a runtime Zig API (`mbed_tls.zig`) wrapping mbedTLS `extern fn` symbols directly (no C shims — mbedTLS has a stable C ABI):

### Runtime API

- **SHA-256**: `sha256_init`, `sha256_starts`, `sha256_update`, `sha256_finish`, `sha256_free`, `sha256_hash`.
- **SHA-512**: `sha512_init`, `sha512_starts`, `sha512_update`, `sha512_finish`, `sha512_free`, `sha512_hash`.
- **HMAC**: `md_init`, `md_setup`, `md_hmac_starts`, `md_hmac_update`, `md_hmac_finish`, `md_hmac`, `md_free`.
- **ECP/ECDSA/MPI**: `mbedtls_mpi`, `mbedtls_ecp_point`, `mbedtls_ecp_group`, `mbedtls_ecdsa_verify`.
- **X.509**: `x509_crt_init`, `x509_crt_free`, `x509_crt_parse_der`, `x509_crt_parse`, `x509_crt_verify`.
- **ESP CA bundle**: `cert_helper.verifyWithEspBundle`.

Raw `extern fn` is used instead of C shims because mbedTLS provides a stable, well-defined C ABI that does not require struct initialization wrappers.

## Dependencies

- ESP-IDF: `mbedtls` (linked transitively).
