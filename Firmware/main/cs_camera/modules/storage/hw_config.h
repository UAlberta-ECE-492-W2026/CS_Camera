/**
 * Hardware Configuration for SD Card
 * Based on no-OS-FatFS library requirements
 */

#ifndef HW_CONFIG_H
#define HW_CONFIG_H

#include "sd_driver/sd_card.h"
#include "sd_driver/spi.h"

// Functions required by no-OS-FatFS library
size_t sd_get_num(void);
sd_card_t *sd_get_by_num(size_t num);
size_t spi_get_num(void);
spi_t *spi_get_by_num(size_t num);

#endif // HW_CONFIG_H
