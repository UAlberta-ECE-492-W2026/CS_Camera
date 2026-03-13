#include "WalshMaskGenerator.h"

static uint32_t bit_reverse(uint32_t value, int num_bits) {
    uint32_t reversed_val = 0;

    for (int i = 0; i < num_bits; ++i) {
        uint32_t least_sig_bit = value & 1u;
        reversed_val = (reversed_val << 1u) | least_sig_bit;
        value >>= 1u;
    }

    return reversed_val;
}

static int fast_log2_int(int value) {
    int bits = 0;

    while ((1 << bits) < value) {
        bits++;
    }

    return bits;
}

void generate_walsh_mask(uint16_t index, int width, int height, uint8_t *buffer) {
    int bits_x = fast_log2_int(width);
    int bits_y = fast_log2_int(height);

    // Split 1D index into 2D sequency components
    uint32_t seq_index_x = index % width;
    uint32_t seq_index_y = index / width;

    // Convert to Gray code
    uint32_t gray_code_x = seq_index_x ^ (seq_index_x >> 1u);
    uint32_t gray_code_y = seq_index_y ^ (seq_index_y >> 1u);

    // Bit-reverse
    uint32_t rev_gray_x = bit_reverse(gray_code_x, bits_x);
    uint32_t rev_gray_y = bit_reverse(gray_code_y, bits_y);

    // Generate mask
    int pixel_idx = 0;

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            uint32_t bitwise_and_x = rev_gray_x & (uint32_t)x;
            uint32_t bitwise_and_y = rev_gray_y & (uint32_t)y;

            int popcount_x = __builtin_popcount(bitwise_and_x);
            int popcount_y = __builtin_popcount(bitwise_and_y);

            buffer[pixel_idx++] = ((popcount_x + popcount_y) % 2 == 0) ? 1 : 0;
        }
    }
}