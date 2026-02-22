#include "lcd_controller.h"
#include "pico/stdlib.h"
#include "pico/st7789.h"

static const struct st7789_config lcd_config = {
    .spi      = PICO_DEFAULT_SPI_INSTANCE(),
    .gpio_din = PICO_DEFAULT_SPI_TX_PIN, // GP19
    .gpio_clk = PICO_DEFAULT_SPI_SCK_PIN, //GP18
    .gpio_cs  = -1,
    .gpio_dc  = 20,
    .gpio_rst = 21,
    .gpio_bl  = 22,
};

static const int lcd_width = 240;
static const int lcd_height = 240;

bool display_init(void) {
    st7789_init(&lcd_config, lcd_width, lcd_height);
    return true;
}

void display_fill(uint16_t rgb565) {
    st7789_fill(rgb565);
}