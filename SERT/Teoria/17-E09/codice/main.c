#include "beagleboneblack.h"

static void led_cycle(void *arg __attribute__((unused)))
{
	static int state = 1;
	leds_off_mask(0xf);
	leds_on_mask(state);
	state = (state+1) & 0xf;
}

static void show_ticks(void *arg __attribute__((unused)))
{
	printf("Current ticks: %u\n", ticks);
}

static void banner(void)
{
	putcn('=', 65); putnl();
	printf("SERT: System Environment for Real-Time, version %u.%x\n"
			"Marco Cesati, SPRG, DICII, University of Rome Tor Vergata\n", 2022, 17);
	putcn('=', 65); putnl();
}


void main(void)
{
	banner();
	if (create_task(led_cycle, NULL, HZ, 5, HZ, "led_cycle") == -1) {
		puts("ERROR: cannot create task led_cycle\n");
		panic1();
	}
	if (create_task(show_ticks, NULL, 10*HZ, 5, 10*HZ, "show_ticks") == -1) {
		puts("ERROR: cannot create task show_ticks\n");
		panic1();
	}
	run_periodic_tasks();
}
