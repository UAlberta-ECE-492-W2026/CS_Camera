%==========================================================================
% FUNCTION_NAME: generate_walsh_mask.m
% PURPOSE:       Generates a 2D Walsh-Hadamard mask for a given index and 
%                resolution using sequency ordering (Gray code + bit reversal).
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          March 5, 2026
% VERSION:       1.0
%
% INPUTS:        index      - (Integer) The 0-indexed mask number (e.g., 0 to 4095)
%                resolution - (1x2 Array) The [height, width] of the mask
% OUTPUTS:       mask       - (2D Logical Array) The generated binary mask (1=White, 0=Black)
%
% DEPENDENCIES:  None
%==========================================================================
% REVISION HISTORY:
% 0.0 - Create File
% 1.0 - Added 2D separable logic with bit-reversal for correct sequency
%       and updated variables to be self-documenting.
%==========================================================================

function mask = generate_walsh_mask(index, resolution)
    
    img_height = resolution(1);
    img_width  = resolution(2);
    
    % Calculate the number of bits required to represent each dimension.
    bits_y = log2(img_height);
    bits_x = log2(img_width);
    
    % 1. Split the 1D mask index into 2D Sequency components (X and Y)
    seq_index_x = mod(index, img_width);
    seq_index_y = floor(index / img_width);
    
    % 2. Convert standard sequency indices to Gray Code
    gray_code_x = bitxor(uint32(seq_index_x), bitshift(uint32(seq_index_x), -1));
    gray_code_y = bitxor(uint32(seq_index_y), bitshift(uint32(seq_index_y), -1));
    
    % 3. Bit-Reverse the Gray codes to map them to physical spatial frequencies
    rev_gray_x = bit_reverse(gray_code_x, bits_x);
    rev_gray_y = bit_reverse(gray_code_y, bits_y);
    
    % 4. Create 2D coordinate grids for the physical pixels
    [x_coords, y_coords] = meshgrid(0:img_width-1, 0:img_height-1);
    
    % 5. Perform Bitwise AND between the reversed Gray codes and the coordinates
    bitwise_and_x = bitand(rev_gray_x, uint32(x_coords));
    bitwise_and_y = bitand(rev_gray_y, uint32(y_coords));
    
    % 6. Calculate Parity (Population Count) for the X-axis
    popcount_x = zeros(img_height, img_width);
    for bit_pos = 1:bits_x
        popcount_x = popcount_x + double(bitget(bitwise_and_x, bit_pos));
    end
    
    % 7. Calculate Parity (Population Count) for the Y-axis
    popcount_y = zeros(img_height, img_width);
    for bit_pos = 1:bits_y
        popcount_y = popcount_y + double(bitget(bitwise_and_y, bit_pos));
    end
    
    % 8. Combine the X and Y parities. Even parity = White (1), Odd = Black (0)
    total_parity = mod(popcount_x + popcount_y, 2);
    mask = (total_parity == 0);
    
end

% --- HELPER FUNCTION ---
function reversed_val = bit_reverse(value, num_bits)
    % Reverses the bit order of a given unsigned integer
    reversed_val = uint32(0);
    value = uint32(value);
    
    for i = 1:num_bits
        least_sig_bit = bitand(value, uint32(1));       
        reversed_val  = bitor(bitshift(reversed_val, 1), least_sig_bit); 
        value         = bitshift(value, -1);          
    end
end