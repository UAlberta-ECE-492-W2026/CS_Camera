/*==========================================================================
 * FILE_NAME:   WalshMaskGenerator.h
 *
 * PURPOSE:     Declares the C++ function for generating 2D Walsh-Hadamard 
 *              masks on the fly. Designed to be a shared library between 
 *              the desktop verification scripts and the Pi Pico 2 firmware.
 * 
 * AUTHOR:      Cole Mckay (cdmckay1@ualberta.ca)
 * DATE:        March 5, 2026
 * VERSION:     1.0
 *
 * INPUTS:      index  - The 0-indexed mask number (e.g., 0 to 4095)
 *              width  - Mask width (e.g., 64)
 *              height - Mask height (e.g., 64)
 * 
 * OUTPUTS:     buffer - Pointer to a pre-allocated array of size (width * height).
 *              Filled with 1s (White) and 0s (Black).
 *
 * DEPENDENCIES: <stdint.h>
 *==========================================================================*/

#ifndef WALSH_MASK_GENERATOR_H
#define WALSH_MASK_GENERATOR_H

#include <stdint.h>

void generate_walsh_mask(uint16_t index, int width, int height, uint8_t* buffer);

#endif // WALSH_MASK_GENERATOR_H