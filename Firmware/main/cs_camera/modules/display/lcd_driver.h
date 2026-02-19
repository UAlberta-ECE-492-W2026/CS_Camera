/**
 * LCD Display Module - Interface
 * Handles LCD initialization, graphics rendering, and display output
 */

#ifndef LCD_DRIVER_H
#define LCD_DRIVER_H

#include <stdbool.h>
#include <stdint.h>

/**
 * Initialize the LCD display
 * @return true if successful, false otherwise
 */
bool display_init(void);

/**
 * Clear the display with a specific color
 * @param color RGB565 color value
 */
void display_clear(uint16_t color);

/**
 * Write a single pixel to the display
 * @param x X coordinate
 * @param y Y coordinate
 * @param color RGB565 color value
 */
void display_draw_pixel(uint16_t x, uint16_t y, uint16_t color);

/**
 * Draw a line on the display
 * @param x0 Start X coordinate
 * @param y0 Start Y coordinate
 * @param x1 End X coordinate
 * @param y1 End Y coordinate
 * @param color RGB565 color value
 */
void display_draw_line(uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1, uint16_t color);

/**
 * Draw a rectangle on the display
 * @param x X coordinate
 * @param y Y coordinate
 * @param w Width
 * @param h Height
 * @param color RGB565 color value
 */
void display_draw_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint16_t color);

/**
 * Display text on the screen
 * @param x X coordinate
 * @param y Y coordinate
 * @param text Text string to display
 * @param color RGB565 text color
 */
void display_text(uint16_t x, uint16_t y, const char *text, uint16_t color);

/**
 * Update/refresh the display
 */
void display_update(void);

// Standard RGB565 colors
#define COLOR_BLACK   0x0000
#define COLOR_WHITE   0xFFFF
#define COLOR_RED     0xF800
#define COLOR_GREEN   0x07E0
#define COLOR_BLUE    0x001F
#define COLOR_YELLOW  0xFFE0
#define COLOR_CYAN    0x07FF
#define COLOR_MAGENTA 0xF81F

#endif // LCD_DRIVER_H
