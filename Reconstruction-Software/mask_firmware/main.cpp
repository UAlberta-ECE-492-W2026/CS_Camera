/*==========================================================================
 * FILE_NAME:   main.cpp (Codebook Generator)
 * 
 * PURPOSE:     Generates the complete 64x64 Walsh-Hadamard codebook (4096 masks) 
 *              using the shared hardware library. Saves the output as a flat 
 *              binary file (16 MB) to be verified against the MATLAB reference 
 *              model. This ensures the C++ hardware math is 100% accurate 
 *              before flashing it to the Pi Pico 2.
 * 
 * AUTHOR:      Cole Mckay (cdmckay1@ualberta.ca)
 * DATE:        March 5, 2026
 * VERSION:     1.0
 *
 * DEPENDENCIES: WalshMaskGenerator.h, WalshMaskGenerator.cpp
 *==========================================================================*/

#include <iostream>
#include <fstream>
#include "WalshMaskGenerator.h"

int main() {
    int img_width = 64;
    int img_height = 64;
    int total_masks = img_width * img_height;
    int pixels_per_mask = img_width * img_height;

    // Open a binary file for writing
    std::ofstream outfile("cpp_codebook.bin", std::ios::binary);
    if (!outfile) {
        std::cerr << "Failed to open file for writing." << std::endl;
        return 1;
    }

    std::cout << "Generating 4096 masks..." << std::endl;

    // Allocate a buffer for a single mask (4,096 bytes)
    uint8_t mask_buffer[4096];

    for (int index = 0; index < total_masks; ++index) {
        
        // 1. Generate the mask using the external hardware function
        generate_walsh_mask(index, img_width, img_height, mask_buffer);

        // 2. Write the entire 4096-byte buffer to the file in one shot
        outfile.write(reinterpret_cast<const char*>(mask_buffer), pixels_per_mask);
        
    }

    outfile.close();
    std::cout << "Codebook saved to cpp_codebook.bin" << std::endl;
    return 0;
}