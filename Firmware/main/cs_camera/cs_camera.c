#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "pico/rand.h"
// #include "pico/gpio.h"
#include "photodiode.h"
#include "lcd_controller.h"
#include "sd_storage.h"
#include "WalshMaskGenerator.h"

#define MASK_NUM        1024
#define TTP223_PIN      2  // GPIO pin connected to TTP223 output
#define NUM_READINGS    500 // READING PER MASK (e.g., 10 readings per mask)
#define DELAY_MS        200
#define HEADERSIZE      2  // For example, if we want to store a header in the file (e.g., timestamp, mask info, etc.)

#define MASK_WIDTH      64
#define MASK_HEIGHT     64

#define LCD_WIDTH       240
#define LCD_HEIGHT      240

#define COLOR_BLACK     0x0000
#define COLOR_WHITE     0xFFFF

#define LINE_LENGTH     12 // max csv line length ("32767,32767\n")

// TODO: ADD GREEN AND RED LED INDICATOR
// TODO: 

/**
 * Initialize the TTP223 capacitive touch sensor
 */
void ttp223_init(void) {
    gpio_init(TTP223_PIN);
    gpio_set_dir(TTP223_PIN, GPIO_IN);  // Set as input
    printf("TTP223 initialized on GPIO %d\n", TTP223_PIN);
}

/**
 * Check if TTP223 is pressed (button output is HIGH)
 * @return true if button is pressed, 0 otherwise
 */
bool ttp223_is_pressed(void) {
    return gpio_get(TTP223_PIN);
}

/**
 * Wait for TTP223 button press with optional timeout
 * This function blocks until the button is pressed
 */
void ttp223_wait_for_press(void) {
    printf("Waiting for TTP223 button press to start capture...\n");
    while (!ttp223_is_pressed()) {
        sleep_ms(50);  // Check every 50ms
    }
    sleep_ms(100);  // Debounce delay
    printf("Button pressed! Starting capture sequence...\n");
}

int main()
{
    // INITIALIZATION
    stdio_init_all();

    for(uint8_t i = 0; i < 20; i++) {
        printf("Waiting to initialize... %d/20\n", i+1);
        sleep_ms(1000);
    }

    // Initialize TTP223 button
    ttp223_init();

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

    // INITIALIZE BUFFERS FOR SENSOR READINGS AND MASKS
    uint16_t sensor_buffer[MASK_NUM + HEADERSIZE];  // INCLUDING THE CALIBRATION READING AS THE FIRST 2 ENTRIES
    int16_t mask_indices[MASK_NUM + HEADERSIZE];
    uint32_t average_reading;
    uint8_t mask_buffer[MASK_HEIGHT * MASK_WIDTH];
    uint16_t mask_index;

    printf("starting...\n");

    // WAIT FOR TTP223 BUTTON PRESS TO START CAPTURE SEQUENCE
    // ttp223_wait_for_press();

    // BUTTON PRESS: START CAPTURE SEQUENCE
    // GREEN LED ON TO INDICATE CAPTURE STARTED

    // CALIBRATION SEQUENCE (DISPLAY CALIBRATION MASKS AND CAPTURE SENSOR READINGS)
    display_fill(COLOR_BLACK);
    average_reading = 0;
    for (int i = 0; i < NUM_READINGS; i++) {
        average_reading += sensor_read_sample();
        sleep_us(50);
    }
    average_reading /= NUM_READINGS;
    sensor_buffer[0] = (uint16_t)average_reading;
    mask_indices[0] = -1;

    display_fill(COLOR_WHITE);
    average_reading = 0;
    for (int i = 0; i < NUM_READINGS; i++) {
        average_reading += sensor_read_sample();
        sleep_us(50);
    }
    average_reading /= NUM_READINGS;
    sensor_buffer[1] = (uint16_t)average_reading;
    mask_indices[1] = -1;

    for (int i = 0; i < MASK_NUM; i++)
    {
        // STEP 1: DISPLAY MASK NUMBER ON LCD
        mask_index = get_rand_32() % (MASK_WIDTH * MASK_HEIGHT);
        generate_walsh_mask(mask_index, MASK_WIDTH, MASK_HEIGHT, mask_buffer);
        display_show_mask(mask_buffer, MASK_WIDTH, MASK_HEIGHT);
        
        // STEP 2: WAIT FOR SOME TIME FOR THE MASK TO BE DISPLAYED
        sleep_ms(DELAY_MS/2);
        
        // STEP 3: CAPTURE SENSOR READINGS
        average_reading = 0;
        for (int i = 0; i < NUM_READINGS; i++) {
            average_reading += sensor_read_sample();
            sleep_us(50);
        }
        average_reading /= NUM_READINGS;
        sensor_buffer[i + HEADERSIZE] = (uint16_t)average_reading;
        mask_indices[i + HEADERSIZE] = mask_index;
    }

    char csv_data[(MASK_NUM + HEADERSIZE) * (LINE_LENGTH)];
    size_t data_size = 0;

    for (uint16_t i = 0; i < MASK_NUM + HEADERSIZE; i++) {
        data_size += snprintf(csv_data + data_size, sizeof(csv_data) - data_size, 
                                "%d,%d\n", mask_indices[i], sensor_buffer[i]);
    }

    // WRITE BUFFER TO SD CARD
    const char *filename = "sensor_data.csv";
    if (sd_write_file(filename, csv_data, data_size)) {
        printf("Successfully wrote sensor data to SD card: %s (%zu bytes)\n", filename, data_size);
    } else {
        printf("Failed to write sensor data to SD card\n");
    }

    // DEINITIALIZE SD STORAGE
    sd_storage_deinit();
}
