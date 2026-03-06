/*==========================================================================
 * FILE_NAME:   WalshMaskGenerator.cpp
 *
 * PURPOSE:     Implements the bitwise logic to generate 2D Walsh-Hadamard 
 *              masks using sequency ordering, Gray code, and bit-reversal. 
 *              Optimized for fast execution on embedded hardware (Pi Pico 2) 
 *              to avoid storing a 16MB codebook in flash memory.
 * 
 * AUTHOR:      Cole Mckay (cdmckay1@ualberta.ca)
 * DATE:        March 5, 2026
 * VERSION:     1.0
 *
 * DEPENDENCIES: WalshMaskGenerator.h
 *==========================================================================*/

#include "WalshMaskGenerator.h"

// --- HELPER FUNCTIONS ---

static uint32_t bit_reverse(uint32_t value, int num_bits) {
    uint32_t reversed_val = 0;
    for (int i = 0; i < num_bits; ++i) {
        uint32_t least_sig_bit = value & 1;
        reversed_val = (reversed_val << 1) | least_sig_bit;
        value >>= 1;
    }
    return reversed_val;
}

static int fast_log2(int value) {
    int bits = 0;
    while ((1 << bits) < value) {
        bits++;
    }
    return bits;
}

// --- MAIN GENERATOR FUNCTION ---

void generate_walsh_mask(uint16_t index, int width, int height, uint8_t* buffer) {
    int bits_x = fast_log2(width);
    int bits_y = fast_log2(height);

    // 1. Split 1D index into 2D Sequency components
    uint32_t seq_index_x = index % width;
    uint32_t seq_index_y = index / width;

    // 2. Convert to Gray Code
    uint32_t gray_code_x = seq_index_x ^ (seq_index_x >> 1);
    uint32_t gray_code_y = seq_index_y ^ (seq_index_y >> 1);

    // 3. Bit-Reverse
    uint32_t rev_gray_x = bit_reverse(gray_code_x, bits_x);
    uint32_t rev_gray_y = bit_reverse(gray_code_y, bits_y);

    // 4. Generate the grid
    int pixel_idx = 0;
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            
            uint32_t bitwise_and_x = rev_gray_x & x;
            uint32_t bitwise_and_y = rev_gray_y & y;

            int popcount_x = __builtin_popcount(bitwise_and_x);
            int popcount_y = __builtin_popcount(bitwise_and_y);

            // Calculate parity and write directly to the provided buffer
            buffer[pixel_idx++] = ((popcount_x + popcount_y) % 2 == 0) ? 1 : 0;
        }
    }
}