/**
 * SD Storage Module - Implementation
 */

#include "sd_storage.h"
#include "hw_config.h"
#include <stdio.h>
#include <string.h>
#include "ff.h"  // FatFS

static FATFS fs;
static bool is_mounted = false;

// Stub for FatFS get_fattime (RTC disabled)
DWORD get_fattime(void) {
    // Return a fixed date/time: Jan 1, 2026, 00:00:00
    return ((2026 - 1980) << 25) | (1 << 21) | (1 << 16);
}

bool storage_init(void) {
    FRESULT fr;
    
    // Mount the SD card
    fr = f_mount(&fs, "0:", 1);
    if (fr != FR_OK) {
        printf("ERROR: Could not mount SD card filesystem (%d)\n", fr);
        return false;
    }
    
    is_mounted = true;
    printf("SD card mounted successfully\n");
    return true;
}

int storage_write_file(const char *filename, const void *data, uint32_t size) {
    if (!is_mounted) {
        return -1;
    }
    
    FIL fil;
    FRESULT fr;
    UINT bw;
    
    char path[256];
    snprintf(path, sizeof(path), "0:/%s", filename);
    
    fr = f_open(&fil, path, FA_CREATE_ALWAYS | FA_WRITE);
    if (fr != FR_OK) {
        printf("ERROR: Could not open file %s (%d)\n", filename, fr);
        return -1;
    }
    
    fr = f_write(&fil, data, size, &bw);
    f_close(&fil);
    
    if (fr != FR_OK) {
        printf("ERROR: Could not write to file %s (%d)\n", filename, fr);
        return -1;
    }
    
    return (int)bw;
}

int storage_read_file(const char *filename, void *buffer, uint32_t size) {
    if (!is_mounted) {
        return -1;
    }
    
    FIL fil;
    FRESULT fr;
    UINT br;
    
    char path[256];
    snprintf(path, sizeof(path), "0:/%s", filename);
    
    fr = f_open(&fil, path, FA_READ);
    if (fr != FR_OK) {
        printf("ERROR: Could not open file %s (%d)\n", filename, fr);
        return -1;
    }
    
    fr = f_read(&fil, buffer, size, &br);
    f_close(&fil);
    
    if (fr != FR_OK) {
        printf("ERROR: Could not read from file %s (%d)\n", filename, fr);
        return -1;
    }
    
    return (int)br;
}

int storage_append_file(const char *filename, const void *data, uint32_t size) {
    if (!is_mounted) {
        return -1;
    }
    
    FIL fil;
    FRESULT fr;
    UINT bw;
    
    char path[256];
    snprintf(path, sizeof(path), "0:/%s", filename);
    
    // Open for append (create if doesn't exist)
    fr = f_open(&fil, path, FA_OPEN_APPEND | FA_WRITE);
    if (fr != FR_OK) {
        printf("ERROR: Could not open file %s for append (%d)\n", filename, fr);
        return -1;
    }
    
    fr = f_write(&fil, data, size, &bw);
    f_close(&fil);
    
    if (fr != FR_OK) {
        printf("ERROR: Could not append to file %s (%d)\n", filename, fr);
        return -1;
    }
    
    return (int)bw;
}

void storage_deinit(void) {
    if (is_mounted) {
        f_unmount("0:");
        is_mounted = false;
    }
}
