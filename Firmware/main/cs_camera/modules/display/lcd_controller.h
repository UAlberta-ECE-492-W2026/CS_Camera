#include <stdint.h>
#include <stdbool.h>

#define LCD_WIDTH   240
#define LCD_HEIGHT  240

bool display_init(void);
void display_fill(uint16_t rgb565);

void display_show_mask(const uint8_t *mask, int mask_width, int mask_height);