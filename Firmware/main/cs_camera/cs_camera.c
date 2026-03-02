#include <stdio.h>
#include "pico/stdlib.h"
#include "photodiode.h"
#include "lcd_controller.h"
#include "photodiode.h" 
#include "sd_storage.h"


int main()
{
    stdio_init_all();
    sleep_ms(2000); // Wait for USB serial to initialize
    printf("going to initialize sensor\n");
    sensor_init();
    printf("sensor initialized\n");

    // TESTING DISPLAY
    display_init();
    while (true) {
        display_fill(0x0000);
        sleep_ms(500);
        display_fill(0xffff);
        sleep_ms(500);
    
    if(!sd_storage_init()) {
        printf("Failed to initialize SD storage\n");
        return 1;
    }

    // Test writing to SD card
    const char *test_filename = "Ghassan.txt";
    const char *test_data = "Hello, SD card hello my boy اهلا وسهلا!";
    if (sd_write_file(test_filename, (const uint8_t *)test_data)) {
        printf("Successfully wrote to SD card: %s\n", test_filename);
    } else {
        printf("Failed to write to SD card\n");
    }

    sd_storage_deinit();    
    
    while (true) {
        printf("Hello, world 2!\n");
        
        sleep_ms(1000);
    }
}
