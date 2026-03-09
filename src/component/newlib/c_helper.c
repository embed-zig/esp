#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>

int32_t espz_open(const char *path, int32_t flags, int32_t mode) {
    return open(path, flags, mode);
}

int32_t espz_close(int32_t fd) {
    return close(fd);
}

int32_t espz_read(int32_t fd, void *buf, size_t count) {
    return (int32_t)read(fd, buf, count);
}

int32_t espz_write(int32_t fd, const void *buf, size_t count) {
    return (int32_t)write(fd, buf, count);
}

int32_t espz_lseek(int32_t fd, int32_t offset, int32_t whence) {
    return (int32_t)lseek(fd, offset, whence);
}

int32_t espz_fstat(int32_t fd, struct stat *buf) {
    return fstat(fd, buf);
}

int32_t espz_unlink(const char *path) {
    return unlink(path);
}

int32_t espz_rename(const char *old_path, const char *new_path) {
    return rename(old_path, new_path);
}

void *espz_opendir(const char *name) {
    return (void *)opendir(name);
}

int32_t espz_readdir(void *dirp, char *name_out, size_t name_buf_len, uint8_t *type_out) {
    struct dirent *ent = readdir((DIR *)dirp);
    if (!ent) return 0;
    strncpy(name_out, ent->d_name, name_buf_len - 1);
    name_out[name_buf_len - 1] = '\0';
    *type_out = ent->d_type;
    return 1;
}

int32_t espz_closedir(void *dirp) {
    return closedir((DIR *)dirp);
}
