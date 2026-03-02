#ifndef SD_STORAGE_H
#define SD_STORAGE_H

#include <stdbool.h>

/**
 * Initialize the SD card storage system
 * @return true if successful, false otherwise
 * */

bool sd_storage_init(void);

bool sd_write_file(const char *filename, const uint8_t *data);
bool sd_read_file(const char *filename, uint8_t *buffer, size_t buffer_size);
    
void sd_storage_deinit(void);

 #endif /* SD_STORAGE_H */