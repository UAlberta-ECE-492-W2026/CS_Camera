#include <stdio.h>
#include <string.h>

#include "ff.h" /* Obtains integer types */
#include "hw_config.h"
#include "sd_storage.h"
#include "f_util.h"


static FATFS fs;  // File system object for each SD card.
static bool initialized = false;


bool sd_storage_init(void) {
    if (initialized) {
        return true;  // Already initialized
    }

    // Initialize the SD card hardware
    if(!sd_init_driver()) {
        printf("Failed to initialize SD card driver\n");
        return false;
    }

    // Mount filesystem for the SD card
    FRESULT res = f_mount(&fs, "0:", 1);
    if (res != FR_OK) {
        printf("Failed to mount SD card filesystem: %d\n", res);
        return false;
    }
    initialized = true;
    printf("SD card storage initialized successfully\n");
    return true;
    
}

bool sd_write_file(const char *filename, const uint8_t *data) {
    if (!initialized) {
        printf("SD storage not initialized\n");
        return false;
    }

    FIL file;
    FRESULT res = f_open(&file, filename, FA_WRITE | FA_CREATE_ALWAYS);
    if (res != FR_OK) {
        printf("Failed to open file for writing: %d\n", res);
        return false;
    }

    UINT bytes_written;
    res = f_write(&file, data, strlen((const char *)data), &bytes_written);
    if (res != FR_OK || bytes_written != strlen((const char *)data)) {
        printf("Failed to write to file: %d\n", res);
        f_close(&file);
        return false;
    }

    f_close(&file);
    printf("File written successfully: %s\n", filename);
    return true;
}

bool sd_read_file(const char *filename, uint8_t *buffer, size_t buffer_size) {
    if (!initialized) {
        printf("SD storage not initialized\n");
        return false;
    }

    FIL file;
    FRESULT res = f_open(&file, filename, FA_READ);
    if (res != FR_OK) {
        printf("Failed to open file for reading: %d\n", res);
        return false;
    }

    UINT bytes_read;
    res = f_read(&file, buffer, buffer_size - 1, &bytes_read);
    if (res != FR_OK) {
        printf("Failed to read from file: %d\n", res);
        f_close(&file);
        return false;
    }

    buffer[bytes_read] = '\0';  // Null-terminate the buffer
    f_close(&file);
    printf("File read successfully: %s\n", filename);
    return true;
}

void sd_storage_deinit(void)
{
    if(initialized){
        f_unmount("0:");  // Unmount the filesystem
        initialized = false;    
        printf("SD card unmounted.\n");
    }
}