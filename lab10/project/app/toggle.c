#include <stdint.h>
#include "toggle.h"
#include "write.h"


#define LED 0x60000100

static uint8_t value = 0xC6;

void toggle(void)
{
    value ^= ~0;
    write8(LED, value);
}
