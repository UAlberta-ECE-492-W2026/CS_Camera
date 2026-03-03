#include <stdio.h>
#include "pico/stdlib.h"
#include "photodiode.h"
#include "lcd_controller.h"
#include "sd_storage.h"

#define MASK_NUM 1000

int main()
{
    // TEST CODE ---------------------------------------------------------------
    stdio_init_all();
    sleep_ms(2000); // Wait for USB serial to initialize
    printf("going to initialize sensor\n");
    sensor_init();
    printf("sensor initialized\n");

    // TESTING DISPLAY FOR 10 SECONDS
    display_init();
    for (int i = 0; i < 10; i++) {
        display_fill(0x0000);
        sleep_ms(500);
        display_fill(0xffff);
        sleep_ms(500);
    }
    
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
    // END OF TEST CODE --------------------------------------------------------



    // INITIALIZATION
    stdio_init_all();

    if (!display_init()) {
        printf("Failed to initialize display\n");
        return 1;
    }

    if (!sensor_init()) {
        printf("Failed to initialize sensor\n");
        return 1;
    }

    if (!sd_storage_init()) {
        printf("Failed to initialize SD storage\n");
        return 1;
    }

    // INITIALIZE BUFFER FOR SENSOR READINGS
    uint16_t sensor_buffer[MASK_NUM];

    // BUTTON PRESS: START CAPTURE SEQUENCE
    // GREEN LED ON TO INDICATE CAPTURE STARTED

    for (int i = 0; i < MASK_NUM; i++)
    {
        // STEP 1: DISPLAY MASK

        // STEP 2: CAPTURE SENSORE READING

        // STEP 3: PUSH READING TO BUFFER

        // STEP 4: WAIT FOR SOME TIME (e.g., 500 MILLISECONDS)
        // TODO: TEST WITH DIFFERENT DELAYS
        sleep_ms(500);
    }

    // WRITE BUFFER TO SD CARD
    

    
}
