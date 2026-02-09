#ifndef WEBROOT_H
#define WEBROOT_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize web root directory with default content
 *
 * Creates /root/www-root/ directory and populates it with
 * embedded HTML files. Safe to call multiple times - only
 * creates files if they don't exist.
 *
 * @return 0 on success, -1 on error
 */
int webroot_init(void);

#ifdef __cplusplus
}
#endif

#endif // WEBROOT_H
