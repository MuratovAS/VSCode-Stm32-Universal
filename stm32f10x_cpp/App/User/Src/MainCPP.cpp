
#include "gpio.h"
#include "MainCPP.hpp"
#include "SecToMSec.hpp"

#ifdef DEBUG
#define T 1
#else
#define T 5
#endif

void setup()
{
}

void loop()
{
	uint32_t tmp = SecToMSec(T);
	HAL_Delay(tmp);
	HAL_GPIO_TogglePin(LED_GPIO_Port, LED_Pin);
}