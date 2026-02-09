#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_console.h"
#include "breezybox.h"

static const char *TAG = "v0.0.1";

void app_main(void)
{
    ESP_LOGI(TAG, "Starting shell...");

    // For use with USB Serial JTAG REPL
    ESP_ERROR_CHECK(breezybox_start(8192, 5));

    ESP_LOGI(TAG, "Shell started");

    while(1) {
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}
