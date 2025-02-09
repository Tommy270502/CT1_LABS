#include <stdint.h>
#include <stdbool.h>

#define	LED_ADDR	0x60000100
#define	SW_ADDR	0x60000200

// declaration of the assembler functions
extern void out_word(uint32_t out_address, uint32_t out_value);
extern uint32_t in_word(uint32_t in_address);

int main(void) {
		uint32_t sw_val = 0;

    while (1) {
				// to be programmed ..
				sw_val = in_word(SW_ADDR);
    
				out_word(LED_ADDR, sw_val);
				// .. end to be programmed
    }   
    
		return 0;
}
