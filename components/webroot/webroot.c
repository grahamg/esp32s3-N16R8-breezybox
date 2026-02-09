#include "webroot.h"
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>
#include "esp_log.h"

static const char *TAG = "webroot";

// Embedded files (linked by CMakeLists.txt)
extern const uint8_t index_html_start[] asm("_binary_index_html_start");
extern const uint8_t index_html_end[]   asm("_binary_index_html_end");

int webroot_init(void)
{
    int ret = 0;

    // Create /root/www-root directory if it doesn't exist
    struct stat st;
    if (stat("/root/www-root", &st) != 0) {
        if (mkdir("/root/www-root", 0755) != 0) {
            ESP_LOGE(TAG, "Failed to create /root/www-root: %s", strerror(errno));
            return -1;
        }
        ESP_LOGI(TAG, "Created /root/www-root directory");
    }

    // Write index.html if it doesn't exist
    if (stat("/root/www-root/index.html", &st) != 0) {
        FILE *f = fopen("/root/www-root/index.html", "w");
        if (f == NULL) {
            ESP_LOGE(TAG, "Failed to create index.html: %s", strerror(errno));
            return -1;
        }

        size_t size = index_html_end - index_html_start;
        size_t written = fwrite(index_html_start, 1, size, f);
        fclose(f);

        if (written != size) {
            ESP_LOGE(TAG, "Failed to write complete index.html");
            ret = -1;
        } else {
            ESP_LOGI(TAG, "Created /root/www-root/index.html (%d bytes)", size);
        }
    } else {
        ESP_LOGI(TAG, "index.html already exists, skipping");
    }

    return ret;
}
