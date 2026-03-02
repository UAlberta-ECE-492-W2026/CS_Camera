
/*

This file should be tailored to match the hardware design.

There should be one element of the spi[] array for each hardware SPI used.

There should be one element of the sd_cards[] array for each SD card slot.
The name is should correspond to the FatFs "logical drive" identifier.
(See http://elm-chan.org/fsw/ff/doc/filename.html#vol)
In general, this should correspond to the (zero origin) array index.
The rest of the constants will depend on the type of
socket, which SPI it is driven by, and how it is wired.

*/

#include <assert.h>
#include <string.h>
//
#include "my_debug.h"
//
#include "hw_config.h"
//
#include "ff.h" /* Obtains integer types */
//
#include "diskio.h" /* Declarations of disk functions */

/* 
SPI1 Configuration:
| Signal | GPIO | Pin | Description            |
| ------ | ---- | --- | ---------------------- |
| SCK    | 10   | 14  | SPI clock              |
| MOSI   | 11   | 15  | Master Out, Slave In   |
| MISO   | 12   | 16  | Master In, Slave Out   |
| CS     | 13   | 17  | Chip Select            |
| GND    | -    | 18  | Ground                 |
| 3.3V   | -    | 36  | 3.3 volt power         |
*/

// Hardware Configuration of SPI "objects"
// Note: multiple SD cards can be driven by one SPI if they use different slave
// selects.
static spi_t spis[] = {  // One for each SPI.
    {   // We can change these if we end up using a different SPI 
        .hw_inst = spi1,  // SPI component
        .miso_gpio = 12,  // GPIO number (not Pico pin number)
        .mosi_gpio = 11,
        .sck_gpio = 10,

        // .baud_rate = 1000 * 1000
        .baud_rate = 12500 * 1000
        // .baud_rate = 25 * 1000 * 1000 // Actual frequency: 20833333.
    }};

// Hardware Configuration of the SD Card "objects"
static sd_card_t sd_cards[] = {  // One for each SD card
    {
        .pcName = "0:",   // Name used to mount device
        .spi = &spis[0],  // Pointer to the SPI driving this card
        .ss_gpio = 13,    // The SPI slave select GPIO for this SD card
        .use_card_detect = false,
        .card_detect_gpio = 22,  // Card detect (unused)
        .card_detected_true = -1  // What the GPIO read returns when a card is
                                 // present.
    }};

/* ********************************************************************** */
size_t sd_get_num() { return count_of(sd_cards); }
sd_card_t *sd_get_by_num(size_t num) {
    assert(num <= sd_get_num());
    if (num <= sd_get_num()) {
        return &sd_cards[num];
    } else {
        return NULL;
    }
}
size_t spi_get_num() { return count_of(spis); }
spi_t *spi_get_by_num(size_t num) {
    assert(num <= spi_get_num());
    if (num <= spi_get_num()) {
        return &spis[num];
    } else {
        return NULL;
    }
}

/* [] END OF FILE */
