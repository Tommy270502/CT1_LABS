#include "utils_ctboard.h"
#include "stdint.h"

#define ADDR_DIP_SWITCH_31_0 0x60000200
#define ADDR_DIP_SWITCH_7_0  0x60000200
#define ADDR_LED_31_24       0x60000103
#define ADDR_LED_23_16       0x60000102
#define ADDR_LED_15_8        0x60000101
#define ADDR_LED_7_0         0x60000100
#define ADDR_BUTTONS         0x60000210

// Define macros for bitmasks
#define BRIGHT 0b11000000
#define DARK   0b11001111
#define BUTTON_INPUT_MASK 0x0F   // Mask for the first 4 buttons (T0-T3)
#define BUTTON_T0_MASK    0b00000001
#define BUTTON_T1_MASK    0b00000010
#define BUTTON_T2_MASK    0b00000100
#define BUTTON_T3_MASK    0b00001000

// Bitmask to toggle bits 5 to 2
#define TOGGLE_MASK_5_TO_2 0b00111100  // Hex: 0x3C




int main(void)
{
    uint8_t led_value = 0;
    uint8_t button_values = 0;
    uint8_t prev_button_values = 0;
    uint8_t bit_manipulations = 0;
    uint8_t sw = 0;

    // Counter to execute main loop every 1000 iterations
    uint16_t loop_counter = 0;

    // Additional variables to track button events
    uint8_t button_T0_press_counter = 0;   // Counter for T0 presses
    uint8_t push_event_counter = 0;        // Counter for any button press (rising edge)

    while (1) {
        // Increment the loop counter
        loop_counter++;

        // Only execute the main loop logic every 1000 iterations
        if (loop_counter >= 1000) {
            // Reset the loop counter
            loop_counter = 0;

            // ---------- Task 3.1 ----------
            // Read DIP switch values
            sw = read_byte(ADDR_DIP_SWITCH_7_0);
            led_value = sw;
					
            // Set LED brightness based on mask
            led_value |= BRIGHT;
            led_value &= DARK;
						
						// Write the modified LED value
            write_byte(ADDR_LED_7_0, led_value);
            

            // ---------- Task 3.2 and 3.3 ----------
            // Read current button states and mask the input
            button_values = read_byte(ADDR_BUTTONS) & BUTTON_INPUT_MASK;

            // Detect rising edge for each button
            if ((button_values & BUTTON_T3_MASK) && !(prev_button_values & BUTTON_T3_MASK)) {
                // Button T3 pressed (rising edge): Set variable to DIP switch value
                bit_manipulations = sw;
            } else if ((button_values & BUTTON_T2_MASK) && !(prev_button_values & BUTTON_T2_MASK)) {
                // Button T2 pressed (rising edge): Toggle bits 5 to 2 using XOR
                bit_manipulations ^= TOGGLE_MASK_5_TO_2;
            } else if ((button_values & BUTTON_T1_MASK) && !(prev_button_values & BUTTON_T1_MASK)) {
                // Button T1 pressed (rising edge): Shift the variable left by one bit
                bit_manipulations = bit_manipulations << 1;
            } else if ((button_values & BUTTON_T0_MASK) && !(prev_button_values & BUTTON_T0_MASK)) {
                // Button T0 pressed (rising edge): Shift the variable right by one bit
                bit_manipulations = bit_manipulations >> 1;

                // Increment the T0 press counter
                button_T0_press_counter++;
            }

            // Increment the push event counter if any button is pressed
            if (button_values != 0 && prev_button_values == 0) {
                push_event_counter++;
            }
						
						

            // Display the button_T0_press_counter on LEDs 15-8
            write_byte(ADDR_LED_15_8, button_T0_press_counter);
						
						// Display the result of the bit manipulations on LEDs 23-16
            write_byte(ADDR_LED_23_16, bit_manipulations);

            // Display the push_event_counter on LEDs 31-24
            write_byte(ADDR_LED_31_24, push_event_counter);

            // Update the previous button state for the next iteration
            prev_button_values = button_values;
        }
    }
}