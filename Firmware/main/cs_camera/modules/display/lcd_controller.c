#include "lcd_controller.h"
#include "pico/stdlib.h"
#include "pico/st7789.h"

static const struct st7789_config lcd_config = {
    .spi      = PICO_DEFAULT_SPI_INSTANCE(),
    .gpio_din = PICO_DEFAULT_SPI_TX_PIN, // GP19
    .gpio_clk = PICO_DEFAULT_SPI_SCK_PIN, // GP18
    .gpio_cs  = -1,
    .gpio_dc  = 21,
    .gpio_rst = 20,
    .gpio_bl  = 22,
};

static const int lcd_width = LCD_WIDTH;
static const int lcd_height = LCD_HEIGHT;

#define COLOR_BLACK 0x0000
#define COLOR_WHITE 0xFFFF

bool display_init(void) {
    st7789_init(&lcd_config, lcd_width, lcd_height);
    return true;
}

void display_fill(uint16_t rgb565) {
    st7789_fill(rgb565);
}

void display_show_mask(const uint8_t *mask, int mask_width, int mask_height) {
    static uint16_t framebuf[LCD_WIDTH * LCD_HEIGHT];

    const int scale = 3;
    const int render_width = mask_width * scale;    // 64 * 3 = 192
    const int render_height = mask_height * scale;  // 64 * 3 = 192

    const int x_offset = (LCD_WIDTH - render_width) / 2;   // 24
    const int y_offset = (LCD_HEIGHT - render_height) / 2; // 24

    // Fill entire screen black first
    for (int i = 0; i < LCD_WIDTH * LCD_HEIGHT; i++) {
        framebuf[i] = COLOR_BLACK;
    }

    // Draw each mask pixel as a 3x3 block
    for (int y = 0; y < mask_height; y++) {
        for (int x = 0; x < mask_width; x++) {
            uint16_t color = mask[y * mask_width + x] ? COLOR_WHITE : COLOR_BLACK;

            int lcd_x_start = x_offset + x * scale;
            int lcd_y_start = y_offset + y * scale;

            for (int dy = 0; dy < scale; dy++) {
                for (int dx = 0; dx < scale; dx++) {
                    int lcd_x = lcd_x_start + dx;
                    int lcd_y = lcd_y_start + dy;
                    framebuf[lcd_y * LCD_WIDTH + lcd_x] = color;
                }
            }
        }
    }

    st7789_set_cursor(0, 0);
    st7789_write(framebuf, sizeof(framebuf));
}