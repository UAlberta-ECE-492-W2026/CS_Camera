#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "pico/stdlib.h"
#include "pico/rand.h"
// #include "pico/gpio.h"
#include "photodiode.h"
#include "lcd_controller.h"
#include "sd_storage.h"
#include "WalshMaskGenerator.h"
#include "ff.h"

#define MASK_NUM        1024
#define BUTTON_PIN      2  // GPIO pin connected to Button output
#define NUM_READINGS    500 // READING PER MASK (e.g., 10 readings per mask)
#define DELAY_MS        100
#define HEADERSIZE      1  // For example, if we want to store a header in the file (e.g., timestamp, mask info, etc.)

#define MASK_WIDTH      64
#define MASK_HEIGHT     64

#define LCD_WIDTH       240
#define LCD_HEIGHT      240

#define COLOR_BLACK     0x0000
#define COLOR_WHITE     0xFFFF

#define LINE_LENGTH     12 // max csv line length ("32767,32767\n")

#define GREEN_LED_PIN   0
#define RED_LED_PIN     1

#define NUM_IMP_INDICES 256
const uint16_t important_indices[NUM_IMP_INDICES] = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
    21, 22, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
    81, 82, 83, 84, 85, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 
    139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 192, 193, 194, 195, 196, 
    197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 256, 
    257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 
    272, 273, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 
    333, 334, 335, 336, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 
    395, 396, 397, 398, 399, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 
    458, 459, 460, 461, 462, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 
    522, 523, 524, 525, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 
    587, 588, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 704, 
    705, 706, 707, 708, 709, 710, 711, 712, 713, 714, 768, 769, 770, 771, 772, 
    773, 774, 775, 776, 777, 832, 833, 834, 835, 836, 837, 838, 839, 840, 896, 
    897, 898, 899, 900, 901, 902, 903, 960, 961, 962, 963, 964, 965, 966, 1024, 
    1025, 1026, 1027, 1028, 1029, 1088, 1089, 1090, 1091, 1092, 1152, 1153, 1154, 
    1155, 1216, 1217, 1218, 1280, 1281, 1344
};

#define NORMALIZATION   2048
static uint16_t black_val = 0;
static uint16_t white_val = 0;

/**
 * Initialize the TTP223 capacitive touch sensor
 */
void button_init(void) {
    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);  // Set as input
    printf("TTP223 initialized on GPIO %d\n", BUTTON_PIN);
}

/**
 * Check if TTP223 is pressed (button output is HIGH)
 * @return true if button is pressed, 0 otherwise
 */
bool button_is_pressed(void) {
    return gpio_get(BUTTON_PIN);
}

/**
 * Wait for TTP223 button press with optional timeout
 * This function blocks until the button is pressed
 */
void button_wait_for_press(void) {
    gpio_put(RED_LED_PIN, false);
    bool red_on = false;
    bool sd_present = false;

    printf("Waiting for TTP223 button press to start capture...\n");

    uint8_t counter = 0;
    while (!button_is_pressed() || !sd_present) {
        sd_present = !gpio_get(CD_PIN);
        counter = (counter + 1) % 10;
        if(counter == 0){
            red_on = !red_on;
        }

        gpio_put(RED_LED_PIN, red_on && !sd_present);
        gpio_put(GREEN_LED_PIN, sd_present);
        sleep_ms(50);  // Check every 50ms
    }
    sleep_ms(100);  // Debounce delay
    printf("Button pressed! Starting capture sequence...\n");
}

/**
 * a calibration sequence that updates our black and white values used for
 * data preprocessing and normalization
 */
void calibrate(void) {
    display_fill(COLOR_BLACK);
    sleep_ms(DELAY_MS);
    uint32_t average_reading = 0;
    for (int i = 0; i < NUM_READINGS; i++) {
        average_reading += sensor_read_sample();
        sleep_us(50);
    }
    average_reading /= NUM_READINGS;
    black_val = (uint16_t) average_reading;

    display_fill(COLOR_WHITE);
    sleep_ms(DELAY_MS);
    average_reading = 0;
    for (int i = 0; i < NUM_READINGS; i++) {
        average_reading += sensor_read_sample();
        sleep_us(50);
    }
    average_reading /= NUM_READINGS;
    white_val = (uint16_t) average_reading;
}

bool get_next_filename(char *out, size_t out_size, const char *prefix, const char *ext);

int main()
{
    // INITIALIZATION
    stdio_init_all();

    gpio_init(GREEN_LED_PIN);
    gpio_init(RED_LED_PIN);
    gpio_init(CD_PIN);
    
    gpio_set_dir(GREEN_LED_PIN, true);
    gpio_set_dir(RED_LED_PIN, true);
    gpio_set_dir(CD_PIN, GPIO_IN);
    
    gpio_put(GREEN_LED_PIN, false);
    gpio_put(RED_LED_PIN, true);
    gpio_pull_up(CD_PIN);

    while(true) {

        gpio_put(RED_LED_PIN, true);

        // Initialize TTP223 button
        button_init();

        if (!display_init()) {
            printf("Failed to initialize display\n");
            return 1;
        }

        if (!sensor_init()) {
            printf("Failed to initialize sensor\n");
            return 1;
        }

        // INITIALIZE BUFFERS FOR SENSOR READINGS AND MASKS
        uint16_t sensor_buffer[HEADERSIZE + MASK_NUM] = {0};
        int16_t mask_indices[HEADERSIZE + MASK_NUM] = {0};
        uint8_t mask_buffer[MASK_HEIGHT * MASK_WIDTH] = {0};
        uint16_t mask_index = 0;

        sensor_buffer[0] = 64;
        mask_indices[0] = -1;

        gpio_put(RED_LED_PIN, false);
        gpio_put(GREEN_LED_PIN, true);

        // WAIT FOR TTP223 BUTTON PRESS TO START CAPTURE SEQUENCE
        button_wait_for_press();
        
        // BUTTON PRESS: START CAPTURE SEQUENCE
        // GREEN LED ON TO INDICATE CAPTURE STARTED
        printf("starting...\n");

        gpio_put(GREEN_LED_PIN, true);
        gpio_put(RED_LED_PIN, false);

        // ----- Fisher-Yates shuffle to generate random, non-repeating sequence -----
        printf("starting shuffle...");
        static uint16_t all_indices[MASK_WIDTH * MASK_HEIGHT];
        for (uint16_t i = 0; i < MASK_WIDTH * MASK_HEIGHT; i++) {
            all_indices[i] = i;
        }

        // ----- Guarantee inclusion of important indices -----
        for(uint16_t i = 0; i < NUM_IMP_INDICES; i++) {
            uint16_t start = all_indices[i];
            uint16_t target = all_indices[important_indices[i]];

            all_indices[i] = target;
            all_indices[important_indices[i]] = start;
        }
        // ----- Guarantee inclusion of important indices -----
        
        for (uint16_t i = MASK_WIDTH * MASK_HEIGHT - 1; i > NUM_IMP_INDICES; i--) {
            // j must not land in the protected zone [0, NUM_IMP_INDICES)
            uint16_t j = NUM_IMP_INDICES + get_rand_32() % (i + 1 - NUM_IMP_INDICES);
            
            // swap the two elements
            uint16_t temp = all_indices[i];
            all_indices[i] = all_indices[j];
            all_indices[j] = temp;
        }
        printf(" Done!\n");
        // ----- Fisher-Yates shuffle to generate random, non-repeating sequence -----

        // ----- Take readings and save them into buffer -----
        for (int i = HEADERSIZE; i < MASK_NUM + HEADERSIZE; i++)
        {
            if(i % 10 == 0) {
                calibrate();
            }

            // STEP 1: DISPLAY MASK NUMBER ON LCD
            mask_index = all_indices[i];
            generate_walsh_mask(mask_index, MASK_WIDTH, MASK_HEIGHT, mask_buffer);
            display_show_mask(mask_buffer, MASK_WIDTH, MASK_HEIGHT);
            
            // STEP 2: WAIT FOR SOME TIME FOR THE MASK TO BE DISPLAYED
            sleep_ms(DELAY_MS);
            
            // STEP 3: CAPTURE SENSOR READINGS
            uint32_t average_reading = 0;
            for (int j = 0; j < NUM_READINGS; j++) {
                average_reading += sensor_read_sample();
                sleep_us(50);
            }

            uint32_t range = white_val - black_val;
            uint32_t floored = (average_reading < black_val) ? 0 : average_reading - black_val;
            uint16_t calibrated_reading = (uint16_t)((floored * NORMALIZATION) / range);
            
            sensor_buffer[i] = calibrated_reading;

            mask_indices[i] = mask_index;

            printf("%d. measuring mask %d: %d\n", i, mask_index, calibrated_reading);

            if(i % 5 == 0) {
                gpio_put(GREEN_LED_PIN, i % 10 == 0);
            }
        }
        // ----- Take readings and save them into buffer -----

        // ----- Save data into csv on the SD card -----
        char csv_data[(MASK_NUM + HEADERSIZE) * (LINE_LENGTH)];
        size_t data_size = 0;

        for (uint16_t i = 0; i < MASK_NUM + HEADERSIZE; i++) {
            data_size += snprintf(csv_data + data_size, sizeof(csv_data) - data_size, 
                                    "%d,%d\n", mask_indices[i], sensor_buffer[i]);
        }

        sd_storage_init();
        // WRITE BUFFER TO SD CARD
        char filename[32];
        get_next_filename(filename, sizeof(filename), "photo", "csv");
        if (sd_write_file(filename, csv_data, data_size)) {
            printf("Successfully wrote sensor data to SD card: %s (%zu bytes)\n", filename, data_size);
        } else {
            printf("Failed to write sensor data to SD card\n");
        }
        // ----- Save data into csv on the SD card -----

        gpio_put(GREEN_LED_PIN, true);
        gpio_put(RED_LED_PIN, false);

        // DEINITIALIZE SD STORAGE
        sd_storage_deinit();
    }
}

bool get_next_filename(char *out, size_t out_size, const char *prefix, const char *ext) {
    DIR dir;
    FILINFO fno;

    FRESULT res = f_opendir(&dir, "0:/");
    if (res != FR_OK) {
        snprintf(out, out_size, "%s1.%s", prefix, ext);
        return false;
    }

    int max_index = 0;
    size_t prefix_len = strlen(prefix);

    while (f_readdir(&dir, &fno) == FR_OK && fno.fname[0] != '\0') {
        // Check prefix matches
        if (strncmp(fno.fname, prefix, prefix_len) != 0)
            continue;

        // Check extension matches
        char *dot = strrchr(fno.fname, '.');
        if (!dot || strcmp(dot + 1, ext) != 0)
            continue;

        // Parse the number between prefix and extension
        int index = atoi(fno.fname + prefix_len);
        if (index > max_index)
            max_index = index;
    }

    f_closedir(&dir);
    snprintf(out, out_size, "%s%d.%s", prefix, max_index + 1, ext);
    return true;
}