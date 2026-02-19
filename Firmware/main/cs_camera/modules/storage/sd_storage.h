/**
 * SD Storage Module - Interface
 * Handles SD card initialization and file system operations
 */

#ifndef SD_STORAGE_H
#define SD_STORAGE_H

#include <stdbool.h>
#include <stdint.h>

/**
 * Initialize the SD card storage system
 * @return true if successful, false otherwise
 */
bool storage_init(void);

/**
 * Write data to a file on the SD card
 * @param filename Name of the file to write to
 * @param data Pointer to data buffer
 * @param size Size of data in bytes
 * @return Number of bytes written, or -1 on error
 */
int storage_write_file(const char *filename, const void *data, uint32_t size);

/**
 * Read data from a file on the SD card
 * @param filename Name of the file to read from
 * @param buffer Buffer to store read data
 * @param size Maximum number of bytes to read
 * @return Number of bytes read, or -1 on error
 */
int storage_read_file(const char *filename, void *buffer, uint32_t size);

/**
 * Append data to a file (for data logging)
 * @param filename Name of the file to append to
 * @param data Pointer to data buffer
 * @param size Size of data in bytes
 * @return Number of bytes written, or -1 on error
 */
int storage_append_file(const char *filename, const void *data, uint32_t size);

/**
 * Unmount the SD card filesystem
 */
void storage_deinit(void);

#endif // SD_STORAGE_H
