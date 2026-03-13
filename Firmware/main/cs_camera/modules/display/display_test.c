#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/rand.h"
#include "lcd_controller.h"
#include "WalshMaskGenerator.h"

#define MASK_WIDTH   64
#define MASK_HEIGHT  64
#define TEST_DELAY_MS 200

int main(void) {
    stdio_init_all();
    sleep_ms(3000);

    printf("Starting display-only Walsh mask test...\n");

    if (!display_init()) {
        printf("Display init failed\n");
        return 1;
    }

    static uint8_t mask_buffer[MASK_WIDTH * MASK_HEIGHT];
    uint16_t mask_index;

    display_fill(0x0000);
    sleep_ms(2500);


    while (true) {
        for (uint16_t i = 0; i < 100; i++) {
            printf("Displaying mask %u\n", i);

            mask_index = get_rand_32() % 4096;
            generate_walsh_mask(mask_index, MASK_WIDTH, MASK_HEIGHT, mask_buffer);
            display_show_mask(mask_buffer, MASK_WIDTH, MASK_HEIGHT);

            sleep_ms(TEST_DELAY_MS);
        }

        display_fill(0x0000);
        sleep_ms(1000);
    }

    return 0;
}