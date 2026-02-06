/* hw_config.c - Hardware configuration for SD card */

#include <string.h>
#include "hw_config.h"

// Hardware Configuration of SPI "objects"
static spi_t spis[] = {
    {
        .hw_inst = spi1,      // SPI component
        .miso_gpio = 12,      // GPIO 12 (Pin 16)
        .mosi_gpio = 11,      // GPIO 11 (Pin 15) 
        .sck_gpio = 10,       // GPIO 10 (Pin 14)
        .baud_rate = 12500 * 1000  // 12.5 MHz
    }
};

// Hardware Configuration of the SD Card "objects"
static sd_card_t sd_cards[] = {
    {
        .pcName = "0:",           // Name used to mount device
        .spi = &spis[0],          // Pointer to the SPI driving this card
        .ss_gpio = 13,            // GPIO 13 (Pin 17) - Chip Select
        .use_card_detect = false, // No card detect for now
        .card_detect_gpio = 0,
        .card_detected_true = 0
    }
};

/* ********************************************************************** */
size_t sd_get_num() { 
    return sizeof(sd_cards) / sizeof(sd_cards[0]); 
}

sd_card_t *sd_get_by_num(size_t num) {
    if (num < sd_get_num()) {
        return &sd_cards[num];
    }
    return NULL;
}

size_t spi_get_num() { 
    return sizeof(spis) / sizeof(spis[0]); 
}

spi_t *spi_get_by_num(size_t num) {
    if (num < spi_get_num()) {
        return &spis[num];
    }
    return NULL;
}
