#include <stdio.h>
#include "pico/stdlib.h"
#include "photodiode.h" // 


int main()
{
    stdio_init_all();
    sleep_ms(10000); // Wait for USB serial to initialize
    printf("going to initialize sensor\n");
    sensor_init();
    printf("sensor initialized\n");


    while (true) {
        printf("Hello, world 2!\n");
        
        sleep_ms(1000);
    }
}
