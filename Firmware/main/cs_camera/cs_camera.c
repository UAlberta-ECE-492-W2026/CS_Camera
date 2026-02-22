#include <stdio.h>
#include "pico/stdlib.h"
#include "photodiode.h"
#include "lcd_controller.h"

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
    }

    while (true) {
        printf("Hello, world 2!\n");
        
        sleep_ms(1000);
    }
}
