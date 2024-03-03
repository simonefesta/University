#include "beagleboneblack.h"


void main(void)
{
	int state = 1;

	for(;;) {
		loop_delay(10000000);
		iomem(GPIO1_CLEARDATAOUT) = 0xf << 21;
		iomem(GPIO1_SETDATAOUT) = state << 21;
		state = (state+1) & 0xf;
	}
}
