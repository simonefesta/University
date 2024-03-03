#include "beagleboneblack.h"

static void heartbeat(void *arg __attribute__((unused)))
{
	static int state = 0;
	if (state)
		led0_on();
	else
		led0_off();
	state = 1 - state;
}

static void show_ticks(void *arg __attribute__((unused)))
{
	printf("Current ticks: %u\n", ticks);
}

static void banner(void)
{
	putcn('=', 65); putnl();
	printf("SERT: System Environment for Real-Time, version %u.%x\n"
           "Marco Cesati, SPRG, DICII, University of Rome Tor Vergata\n", 2021, 01);
	putcn('=', 65); putnl();
}


static void very_long_job(void *arg)
{
	unsigned long now = ticks + HZ*50;
	arg = arg;
	while (time_before(ticks, now)) {
		printf("%8u\r", now-ticks);
		cpu_wait_for_interrupt();
	}
}

static void idle_task(void)
{
	for (;;) {
		led3_off();
		cpu_wait_for_interrupt();
	}
}

void main(void)
{
	banner();
	if (create_task(heartbeat, NULL, HZ, HZ, HZ, EDF, "heartbeat") == -1) {
		puts("ERROR: cannot create task heartbeat\n");
		panic1();
	}
	if (create_task(show_ticks, NULL, 10*HZ, 5, 10*HZ, EDF, "show_ticks") == -1) {
		puts("ERROR: cannot create task show_ticks\n");
		panic1();
	}
	if (create_task(very_long_job, NULL, 60*HZ, 100, 60*HZ, EDF, "very_long_job") == -1) {
		puts("ERROR: cannot create task very_long_job\n");
		panic1();
	}
	idle_task();
}
