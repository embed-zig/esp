#include <stddef.h>
#include <stdint.h>

#include "mbedtls/sha256.h"
#include "mbedtls/sha512.h"
#include "mbedtls/md.h"
#include "mbedtls/bignum.h"
#include "mbedtls/ecp.h"
#include "mbedtls/ecdsa.h"
#include "mbedtls/x509_crt.h"
#include "esp_crt_bundle.h"

/* SHA-256 */
void espz_sha256_init(mbedtls_sha256_context *ctx)                     { mbedtls_sha256_init(ctx); }
int  espz_sha256_starts(mbedtls_sha256_context *ctx, int is224)        { return mbedtls_sha256_starts(ctx, is224); }
int  espz_sha256_update(mbedtls_sha256_context *ctx,
                         const uint8_t *input, size_t ilen)             { return mbedtls_sha256_update(ctx, input, ilen); }
int  espz_sha256_finish(mbedtls_sha256_context *ctx, uint8_t *output)  { return mbedtls_sha256_finish(ctx, output); }
void espz_sha256_free(mbedtls_sha256_context *ctx)                     { mbedtls_sha256_free(ctx); }
int  espz_sha256(const uint8_t *input, size_t ilen,
                  uint8_t *output, int is224)                           { return mbedtls_sha256(input, ilen, output, is224); }

/* SHA-512 */
void espz_sha512_init(mbedtls_sha512_context *ctx)                     { mbedtls_sha512_init(ctx); }
int  espz_sha512_starts(mbedtls_sha512_context *ctx, int is384)        { return mbedtls_sha512_starts(ctx, is384); }
int  espz_sha512_update(mbedtls_sha512_context *ctx,
                         const uint8_t *input, size_t ilen)             { return mbedtls_sha512_update(ctx, input, ilen); }
int  espz_sha512_finish(mbedtls_sha512_context *ctx, uint8_t *output)  { return mbedtls_sha512_finish(ctx, output); }
void espz_sha512_free(mbedtls_sha512_context *ctx)                     { mbedtls_sha512_free(ctx); }
int  espz_sha512(const uint8_t *input, size_t ilen,
                  uint8_t *output, int is384)                           { return mbedtls_sha512(input, ilen, output, is384); }

/* Message Digest / HMAC */
const mbedtls_md_info_t *espz_md_info_from_type(int md_type)           { return mbedtls_md_info_from_type((mbedtls_md_type_t)md_type); }
void espz_md_init(mbedtls_md_context_t *ctx)                           { mbedtls_md_init(ctx); }
int  espz_md_setup(mbedtls_md_context_t *ctx,
                    const mbedtls_md_info_t *info, int hmac)            { return mbedtls_md_setup(ctx, info, hmac); }
int  espz_md_hmac_starts(mbedtls_md_context_t *ctx,
                          const uint8_t *key, size_t keylen)            { return mbedtls_md_hmac_starts(ctx, key, keylen); }
int  espz_md_hmac_update(mbedtls_md_context_t *ctx,
                          const uint8_t *input, size_t ilen)            { return mbedtls_md_hmac_update(ctx, input, ilen); }
int  espz_md_hmac_finish(mbedtls_md_context_t *ctx, uint8_t *output)   { return mbedtls_md_hmac_finish(ctx, output); }
int  espz_md_hmac(const mbedtls_md_info_t *info,
                   const uint8_t *key, size_t keylen,
                   const uint8_t *input, size_t ilen,
                   uint8_t *output)                                     { return mbedtls_md_hmac(info, key, keylen, input, ilen, output); }
void espz_md_free(mbedtls_md_context_t *ctx)                           { mbedtls_md_free(ctx); }

/* MPI */
void espz_mpi_init(mbedtls_mpi *X)                                     { mbedtls_mpi_init(X); }
void espz_mpi_free(mbedtls_mpi *X)                                     { mbedtls_mpi_free(X); }
int  espz_mpi_read_binary(mbedtls_mpi *X,
                           const uint8_t *buf, size_t buflen)           { return mbedtls_mpi_read_binary(X, buf, buflen); }

/* ECP group */
void espz_ecp_group_init(mbedtls_ecp_group *grp)                       { mbedtls_ecp_group_init(grp); }
void espz_ecp_group_free(mbedtls_ecp_group *grp)                       { mbedtls_ecp_group_free(grp); }
int  espz_ecp_group_load(mbedtls_ecp_group *grp, int id)               { return mbedtls_ecp_group_load(grp, (mbedtls_ecp_group_id)id); }

/* ECP point */
void espz_ecp_point_init(mbedtls_ecp_point *pt)                        { mbedtls_ecp_point_init(pt); }
void espz_ecp_point_free(mbedtls_ecp_point *pt)                        { mbedtls_ecp_point_free(pt); }
int  espz_ecp_point_read_binary(const mbedtls_ecp_group *grp,
                                 mbedtls_ecp_point *P,
                                 const uint8_t *buf, size_t ilen)       { return mbedtls_ecp_point_read_binary(grp, P, buf, ilen); }

/* ECDSA */
int espz_ecdsa_verify(mbedtls_ecp_group *grp,
                       const uint8_t *buf, size_t blen,
                       const mbedtls_ecp_point *Q,
                       const mbedtls_mpi *r,
                       const mbedtls_mpi *s)                            { return mbedtls_ecdsa_verify(grp, buf, blen, Q, r, s); }

/* X.509 */
void espz_x509_crt_init(mbedtls_x509_crt *crt)                        { mbedtls_x509_crt_init(crt); }
void espz_x509_crt_free(mbedtls_x509_crt *crt)                        { mbedtls_x509_crt_free(crt); }
int  espz_x509_crt_parse_der(mbedtls_x509_crt *crt,
                              const uint8_t *buf, size_t buflen)        { return mbedtls_x509_crt_parse_der(crt, buf, buflen); }
int  espz_x509_crt_parse(mbedtls_x509_crt *crt,
                           const uint8_t *buf, size_t buflen)           { return mbedtls_x509_crt_parse(crt, buf, buflen); }
int  espz_x509_crt_verify(mbedtls_x509_crt *crt,
                            mbedtls_x509_crt *trust_ca,
                            void *ca_crl, void *cn,
                            uint32_t *flags,
                            void *f_vrfy, void *p_vrfy)                 { return mbedtls_x509_crt_verify(crt, trust_ca, ca_crl, cn, flags, f_vrfy, p_vrfy); }

/* ESP certificate bundle */
int  espz_crt_bundle_set(const uint8_t *bundle, size_t bundle_size)     { return esp_crt_bundle_set(bundle, bundle_size); }
