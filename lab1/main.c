/* ------------------------------------------------------------------
 * --  _____       ______  _____                                    
 * -- |_   _|     |  ____|/ ____|                                   
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    
 * --   | | | '_ \|  __|  \___ \   Zurich University of             
 * --  _| |_| | | | |____ ____) |  Applied Sciences                 
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     
 * ------------------------------------------------------------------
 * -- main.c
 * ------------------------------------------------------------------
 */

#include <reg_ctboard.h>
#include "utils_ctboard.h"
#include <stdio.h>

#define ADDR_DIP_SWITCH_31_0 0x60000200
#define ADDR_ROTATY          0x60000211
#define ADDR_LED_31_0        0x60000100
#define ADDR_7_SEG_DS0       0x60000110
#define ADDR_7_SEG_DS1       0x60000111
#define ADDR_7_SEG_DS2       0x60000112
#define ADDR_7_SEG_DS3       0x60000113
#define ADDR_HEX_SWITCH      0x60000211

void writeString(uint8_t offset, char* string) {
    uint8_t u = 0;
    // Loop until the end of the string ('\0') is reached
    while (string[u] != '\0') {
        CT_LCD->ASCII[offset + u] = string[u];
        u++;
    }
}

void clearLCD() {
    for (int k = 0; k <= 40; k++) {
        CT_LCD->ASCII[k] = ' ';
    }
    writeString(22, "Thomas Perri CT1");
}

/* == main ================================================================ */
int main(void) {
    uint8_t seg_0_data, seg_1_data, seg_2_data, seg_3_data = 0; // Initialize seg_3_data
    uint32_t sw_data = 0;
    uint8_t rotary_data = 0;
    uint32_t counter_lcd = 0;
    uint32_t counter_segments = 0;
    uint32_t counter_pattern = 0;
    uint8_t i = 0;
    char rotary_char_buffer[5];
    clearLCD();

    // DIY - array for 7 segment patterns
    // Animation pattern array - 7 segment animation
    uint8_t seg_patterns[] = {
        0b11000000,  // All segments on (abcdef)
        0b11000001,  // Turn off segment a
        0b11000011,  // Turn off segments a, b
        0b11000111,  // Turn off segments a, b, c
        0b11001111,  // Turn off segments a, b, c, d
        0b11011111,  // Turn off segments a, b, c, d, e
        0b11111111,  // All segments off
        0b11111110,  // Turn on segment f
        0b11111100,  // Turn on segments e, f
        0b11111000,  // Turn on segments d, e, f
        0b11110000,  // Turn on segments c, d, e, f
        0b11100000   // Turn on segments b, c, d, e, f
    };

    uint8_t seg_pattern_mirrored[] = {
        0b11000000,  // All segments on (abcdef)
        0b11100000,  // Turn off segment a
        0b11110000,  // Turn off segments a, f (mirrored from a, b)
        0b11111000,  // Turn off segments a, f, e (mirrored from a, b, c)
        0b11111100,  // Turn off segments a, f, e, d (mirrored from a, b, c, d)
        0b11111110,  // Turn off segments a, f, e, d, c (mirrored from a, b, c, d, e)
        0b11111111,  // All segments off
        0b11111101,  // Turn on segment b (mirrored from f)
        0b11111011,  // Turn on segments b, c (mirrored from e, f)
        0b11110111,  // Turn on segments b, c, d (mirrored from d, e, f)
        0b11101111,  // Turn on segments b, c, d, e (mirrored from c, d, e, f)
        0b11011111   // Turn on segments b, c, d, e, f (mirrored from b, c, d, e, f)
    };

    uint8_t bin_to_Seg_patterns[] = {
        0b11000000,  // 0: All segments except G and DP on
        0b11111001,  // 1: Only segments B, C on
        0b10100100,  // 2: Segments A, B, D, E, G on
        0b10110000,  // 3: Segments A, B, C, D, G on
        0b10011001,  // 4: Segments B, C, F, G on
        0b10010010,  // 5: Segments A, C, D, F, G on
        0b10000010,  // 6: Segments A, C, D, E, F, G on
        0b11111000,  // 7: Segments A, B, C on
        0b10000000,  // 8: All segments on (A, B, C, D, E, F, G)
        0b10010000,  // 9: Segments A, B, C, D, F, G on
        0b10001000,  // A: Segments A, B, C, E, F, G on
        0b10000011,  // B: Segments C, D, E, F, G on
        0b11000110,  // C: Segments A, D, E, F on
        0b10100001,  // D: Segments B, C, D, E, G on
        0b10000110,  // E: Segments A, D, E, F, G on
        0b10001110   // F: Segments A, E, F, G on
    };

    uint8_t array_max_elements = sizeof(seg_patterns) / sizeof(seg_patterns[0]);

    // LCD display
    uint8_t toggle = 0;

    // INIT peripherals
    // init segments
    write_byte(ADDR_7_SEG_DS0, 0b10000000);
    write_byte(ADDR_7_SEG_DS1, 0b10000000);
    write_byte(ADDR_7_SEG_DS2, 0b10000000);
    write_byte(ADDR_7_SEG_DS3, 0b10000000);

    while (1) {
        // Task 1 - read from dip switches, write to leds
        sw_data = read_word(ADDR_DIP_SWITCH_31_0);
        rotary_data = (read_byte(ADDR_ROTATY) & 0x0F); // mask to only get data
        sprintf(rotary_char_buffer, "%d", rotary_data); // convert to string
        write_word(ADDR_LED_31_0, sw_data);

        // Task 2 - Toggle LCD between "Hello" and "World"
        if ((counter_lcd % 100000) == 0) {
            if (toggle) {
                toggle = 0;
                // Write "Hello" to LCD starting from position 18
                writeString(0, "Hello");
            } else {
                toggle = 1;
                // Write "World" to LCD starting from position 18
                writeString(0, "World");
            }
        }

        if ((counter_segments % 1000) == 0) {
            // Task 3 - Control of seven-segment displays
            seg_0_data = sw_data & 0x000F;
            seg_1_data = (sw_data & 0x00F0) >> 4; // Shift to match the bits correctly
        }

        if ((counter_pattern % 20000) == 0) {
            // Task 4 - Update the seven-segment pattern based on seg_patterns array
            seg_2_data = seg_pattern_mirrored[i];
            seg_3_data = seg_patterns[i]; // Use the full 8 bits for the pattern

            // Increment the pattern index
            if (i == array_max_elements - 1) {
                i = 0;  // Reset index when reaching the end of the array
            } else {
                i++;
            }
        }

        // Write data to the seven-segment displays and LCD
        
				// Check if the rotary_data is a single digit (0-9)
        if (rotary_data < 10) {
            // Write the rotary value to the LCD
            writeString(14, rotary_char_buffer);

            // Clear the second digit
            CT_LCD->ASCII[15] = ' ';
        } else {
            // For two digits, write the entire string
            writeString(14, rotary_char_buffer);
        }
				
        write_byte(ADDR_7_SEG_DS0, bin_to_Seg_patterns[seg_0_data]);
        write_byte(ADDR_7_SEG_DS1, bin_to_Seg_patterns[seg_1_data]);
        write_byte(ADDR_7_SEG_DS2, seg_2_data);
        write_byte(ADDR_7_SEG_DS3, seg_3_data);

        // Increment counters and reset if necessary
        counter_lcd++;
        counter_segments++;
        counter_pattern++;
    }
}
