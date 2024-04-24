#include "beagleboneblack.h"

static void endless_led_blinking(void)
{
	int state = 1;

	for(;;) {
		mdelay(1000);
		leds_off_mask(0xf);
		leds_on_mask(state);
		state = (state+1) & 0xf;
		printf("Ticks: %u\n", ticks);
	}
}

static void banner(void)
{
	putcn('=', 65); putnl();
	printf("SERT: System Environment for Real-Time, version %u.%x\n"
           "Marco Cesati, SPRG, DICII, University of Rome Tor Vergata\n", 2020, 18);
	putcn('=', 65); putnl();
}


void main(void)
{
	banner();
	endless_led_blinking();
}
