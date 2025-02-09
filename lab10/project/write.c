#include <stdint.h>
#include "write.h"
#include "reg_ctboard.h"


void write8(uint32_t to, uint8_t what) {
	CT_LED->BYTE.LED7_0 = what;
	to = 0; // not needed as we only write to leds7_0
}