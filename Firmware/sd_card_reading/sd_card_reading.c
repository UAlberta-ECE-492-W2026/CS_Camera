#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "ff.h"  // FatFS

// Stub for FatFS get_fattime (RTC disabled)
DWORD get_fattime(void) {
    // Return a fixed date/time: Jan 1, 2026, 00:00:00
    return ((2026 - 1980) << 25) | (1 << 21) | (1 << 16);
}

int main()
{
    stdio_init_all();
    
    printf("SD Card FatFS Example\n");
    
    // FatFS objects
    FATFS fs;
    FIL fil;
    FRESULT fr;
    UINT bw;
    
    // Mount the SD card
    fr = f_mount(&fs, "0:", 1);
    if (fr != FR_OK) {
        printf("ERROR: Could not mount filesystem (%d)\r\n", fr);
        while (1) {
            sleep_ms(1000);
        }
    }
    printf("Filesystem mounted!\n");
    
    // Open a file for writing
    fr = f_open(&fil, "0:/test.txt", FA_CREATE_ALWAYS | FA_WRITE);
    if (fr != FR_OK) {
        printf("ERROR: Could not open file (%d)\r\n", fr);
    } else {
        // Write to the file
        const char *text = "Mazen says Hello from Pico! Mr.\n";
        f_write(&fil, text, strlen(text), &bw);
        printf("Wrote %d bytes to test.txt\n", bw);
        
        // Close the file
        f_close(&fil);
    }
    
    // Unmount
    f_unmount("0:");
    
    printf("Done!\n");
    
    while (true) {
        sleep_ms(1000);
    }
}

