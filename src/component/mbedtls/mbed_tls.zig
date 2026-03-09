//! Zig bindings for mbedTLS APIs used by the runtime crypto suite.

const Handle = ?*anyopaque;

// ============================================================================
// SHA-256
// ============================================================================

pub const sha256_context = extern struct {
    _opaque: [128]u8 = @import("std").mem.zeroes([128]u8),
};

extern fn espz_sha256_init(ctx: *sha256_context) void;
extern fn espz_sha256_starts(ctx: *sha256_context, is224: c_int) c_int;
extern fn espz_sha256_update(ctx: *sha256_context, input: [*]const u8, ilen: usize) c_int;
extern fn espz_sha256_finish(ctx: *sha256_context, output: *[32]u8) c_int;
extern fn espz_sha256_free(ctx: *sha256_context) void;
extern fn espz_sha256(input: [*]const u8, ilen: usize, output: *[32]u8, is224: c_int) c_int;

pub fn sha256_init(ctx: *sha256_context) void {
    espz_sha256_init(ctx);
}
pub fn sha256_starts(ctx: *sha256_context, is224: c_int) c_int {
    return espz_sha256_starts(ctx, is224);
}
pub fn sha256_update(ctx: *sha256_context, input: [*]const u8, ilen: usize) c_int {
    return espz_sha256_update(ctx, input, ilen);
}
pub fn sha256_finish(ctx: *sha256_context, output: *[32]u8) c_int {
    return espz_sha256_finish(ctx, output);
}
pub fn sha256_free(ctx: *sha256_context) void {
    espz_sha256_free(ctx);
}
pub fn sha256_hash(input: [*]const u8, ilen: usize, output: *[32]u8, is224: c_int) c_int {
    return espz_sha256(input, ilen, output, is224);
}

// ============================================================================
// SHA-512 (also used for SHA-384)
// ============================================================================

pub const sha512_context = extern struct {
    _opaque: [256]u8 = @import("std").mem.zeroes([256]u8),
};

extern fn espz_sha512_init(ctx: *sha512_context) void;
extern fn espz_sha512_starts(ctx: *sha512_context, is384: c_int) c_int;
extern fn espz_sha512_update(ctx: *sha512_context, input: [*]const u8, ilen: usize) c_int;
extern fn espz_sha512_finish(ctx: *sha512_context, output: *[64]u8) c_int;
extern fn espz_sha512_free(ctx: *sha512_context) void;
extern fn espz_sha512(input: [*]const u8, ilen: usize, output: *[64]u8, is384: c_int) c_int;

pub fn sha512_init(ctx: *sha512_context) void {
    espz_sha512_init(ctx);
}
pub fn sha512_starts(ctx: *sha512_context, is384: c_int) c_int {
    return espz_sha512_starts(ctx, is384);
}
pub fn sha512_update(ctx: *sha512_context, input: [*]const u8, ilen: usize) c_int {
    return espz_sha512_update(ctx, input, ilen);
}
pub fn sha512_finish(ctx: *sha512_context, output: *[64]u8) c_int {
    return espz_sha512_finish(ctx, output);
}
pub fn sha512_free(ctx: *sha512_context) void {
    espz_sha512_free(ctx);
}
pub fn sha512_hash(input: [*]const u8, ilen: usize, output: *[64]u8, is384: c_int) c_int {
    return espz_sha512(input, ilen, output, is384);
}

// ============================================================================
// Message Digest (HMAC)
// ============================================================================

pub const md_context_t = extern struct {
    _opaque: [64]u8 = @import("std").mem.zeroes([64]u8),
};

pub const md_info_t = anyopaque;

pub const MD_SHA256: c_int = 6;
pub const MD_SHA384: c_int = 7;
pub const MD_SHA512: c_int = 8;

extern fn espz_md_info_from_type(md_type: c_int) ?*const md_info_t;
extern fn espz_md_init(ctx: *md_context_t) void;
extern fn espz_md_setup(ctx: *md_context_t, md_info: ?*const md_info_t, hmac: c_int) c_int;
extern fn espz_md_hmac_starts(ctx: *md_context_t, key: [*]const u8, keylen: usize) c_int;
extern fn espz_md_hmac_update(ctx: *md_context_t, input: [*]const u8, ilen: usize) c_int;
extern fn espz_md_hmac_finish(ctx: *md_context_t, output: [*]u8) c_int;
extern fn espz_md_hmac(
    md_info: ?*const md_info_t,
    key: [*]const u8,
    keylen: usize,
    input: [*]const u8,
    ilen: usize,
    output: [*]u8,
) c_int;
extern fn espz_md_free(ctx: *md_context_t) void;

pub fn md_info_from_type(md_type: c_int) ?*const md_info_t {
    return espz_md_info_from_type(md_type);
}
pub fn md_init(ctx: *md_context_t) void {
    espz_md_init(ctx);
}
pub fn md_setup(ctx: *md_context_t, md_info: ?*const md_info_t, hmac: c_int) c_int {
    return espz_md_setup(ctx, md_info, hmac);
}
pub fn md_hmac_starts(ctx: *md_context_t, key: [*]const u8, keylen: usize) c_int {
    return espz_md_hmac_starts(ctx, key, keylen);
}
pub fn md_hmac_update(ctx: *md_context_t, input: [*]const u8, ilen: usize) c_int {
    return espz_md_hmac_update(ctx, input, ilen);
}
pub fn md_hmac_finish(ctx: *md_context_t, output: [*]u8) c_int {
    return espz_md_hmac_finish(ctx, output);
}
pub fn md_hmac(
    md_info: ?*const md_info_t,
    key: [*]const u8,
    keylen: usize,
    input: [*]const u8,
    ilen: usize,
    output: [*]u8,
) c_int {
    return espz_md_hmac(md_info, key, keylen, input, ilen, output);
}
pub fn md_free(ctx: *md_context_t) void {
    espz_md_free(ctx);
}

// ============================================================================
// ECP / ECDSA / MPI (PKI)
// ============================================================================

pub const MBEDTLS_ECP_DP_SECP256R1: c_int = 3;
pub const MBEDTLS_ECP_DP_SECP384R1: c_int = 4;

pub const mbedtls_mpi = extern struct {
    _opaque: [32]u8 = @import("std").mem.zeroes([32]u8),
};

pub const mbedtls_ecp_point = extern struct {
    _opaque: [96]u8 = @import("std").mem.zeroes([96]u8),
};

pub const mbedtls_ecp_group = extern struct {
    _opaque: [256]u8 = @import("std").mem.zeroes([256]u8),
};

extern fn espz_mpi_init(X: *mbedtls_mpi) void;
extern fn espz_mpi_free(X: *mbedtls_mpi) void;
extern fn espz_mpi_read_binary(X: *mbedtls_mpi, buf: [*]const u8, buflen: usize) c_int;

extern fn espz_ecp_group_init(grp: *mbedtls_ecp_group) void;
extern fn espz_ecp_group_free(grp: *mbedtls_ecp_group) void;
extern fn espz_ecp_group_load(grp: *mbedtls_ecp_group, id: c_int) c_int;

extern fn espz_ecp_point_init(pt: *mbedtls_ecp_point) void;
extern fn espz_ecp_point_free(pt: *mbedtls_ecp_point) void;
extern fn espz_ecp_point_read_binary(
    grp: *const mbedtls_ecp_group,
    P: *mbedtls_ecp_point,
    buf: [*]const u8,
    ilen: usize,
) c_int;

extern fn espz_ecdsa_verify(
    grp: *mbedtls_ecp_group,
    buf: [*]const u8,
    blen: usize,
    Q: *const mbedtls_ecp_point,
    r: *const mbedtls_mpi,
    s: *const mbedtls_mpi,
) c_int;

pub fn mpi_init(X: *mbedtls_mpi) void {
    espz_mpi_init(X);
}
pub fn mpi_free(X: *mbedtls_mpi) void {
    espz_mpi_free(X);
}
pub fn mpi_read_binary(X: *mbedtls_mpi, buf: [*]const u8, buflen: usize) c_int {
    return espz_mpi_read_binary(X, buf, buflen);
}

pub fn ecp_group_init(grp: *mbedtls_ecp_group) void {
    espz_ecp_group_init(grp);
}
pub fn ecp_group_free(grp: *mbedtls_ecp_group) void {
    espz_ecp_group_free(grp);
}
pub fn ecp_group_load(grp: *mbedtls_ecp_group, id: c_int) c_int {
    return espz_ecp_group_load(grp, id);
}

pub fn ecp_point_init(pt: *mbedtls_ecp_point) void {
    espz_ecp_point_init(pt);
}
pub fn ecp_point_free(pt: *mbedtls_ecp_point) void {
    espz_ecp_point_free(pt);
}
pub fn ecp_point_read_binary(
    grp: *const mbedtls_ecp_group,
    P: *mbedtls_ecp_point,
    buf: [*]const u8,
    ilen: usize,
) c_int {
    return espz_ecp_point_read_binary(grp, P, buf, ilen);
}

pub fn ecdsa_verify(
    grp: *mbedtls_ecp_group,
    buf: [*]const u8,
    blen: usize,
    Q: *const mbedtls_ecp_point,
    r: *const mbedtls_mpi,
    s: *const mbedtls_mpi,
) c_int {
    return espz_ecdsa_verify(grp, buf, blen, Q, r, s);
}

// ============================================================================
// X.509 Certificates
// ============================================================================

pub const x509_crt = extern struct {
    _opaque: [512]u8 = @import("std").mem.zeroes([512]u8),
};

extern fn espz_x509_crt_init(crt: *x509_crt) void;
extern fn espz_x509_crt_free(crt: *x509_crt) void;
extern fn espz_x509_crt_parse_der(crt: *x509_crt, buf: [*]const u8, buflen: usize) c_int;
extern fn espz_x509_crt_parse(crt: *x509_crt, buf: [*]const u8, buflen: usize) c_int;
extern fn espz_x509_crt_verify(
    crt: *x509_crt,
    trust_ca: *x509_crt,
    ca_crl: Handle,
    cn: Handle,
    flags: *u32,
    f_vrfy: Handle,
    p_vrfy: Handle,
) c_int;

pub fn x509_crt_init(crt: *x509_crt) void {
    espz_x509_crt_init(crt);
}
pub fn x509_crt_free(crt: *x509_crt) void {
    espz_x509_crt_free(crt);
}
pub fn x509_crt_parse_der(crt: *x509_crt, buf: [*]const u8, buflen: usize) c_int {
    return espz_x509_crt_parse_der(crt, buf, buflen);
}
pub fn x509_crt_parse(crt: *x509_crt, buf: [*]const u8, buflen: usize) c_int {
    return espz_x509_crt_parse(crt, buf, buflen);
}
pub fn x509_crt_verify(
    crt: *x509_crt,
    trust_ca: *x509_crt,
    ca_crl: Handle,
    cn: Handle,
    flags: *u32,
    f_vrfy: Handle,
    p_vrfy: Handle,
) c_int {
    return espz_x509_crt_verify(crt, trust_ca, ca_crl, cn, flags, f_vrfy, p_vrfy);
}

// ============================================================================
// ESP certificate bundle (esp_crt_bundle)
// ============================================================================

extern fn espz_crt_bundle_set(bundle: [*]const u8, bundle_size: usize) c_int;

/// Replace the built-in bundle with a user-provided X.509 bundle (DER array).
pub fn crtBundleSet(bundle: []const u8) !void {
    if (espz_crt_bundle_set(bundle.ptr, bundle.len) != 0)
        return error.CrtBundleSetFailed;
}
