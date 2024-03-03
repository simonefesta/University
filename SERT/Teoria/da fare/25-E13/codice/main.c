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

static void show_ticks(void *arg __attribute__ ((unused)))
{
	printf("\nCurrent ticks: %u\n", ticks);
	activate_cbs_worker(&cbs0, 0);
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

const unsigned long small_primes[] =
    { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
       53, 59, 61, 67, 71, 73, 79, 83, 89, 97 };

void factor_ticks(void *arg __attribute__ ((unused)))
{
    unsigned long v = ticks;
    int i;
	gpio1_on(6);
	printf("%u: ", v);
    i = 0;
    while (v > 1 && i < 25) {
        unsigned long w = v / small_primes[i];
        if (v == w * small_primes[i]) {
            printf("%u ", small_primes[i]);
            v = w;
            continue;
        }
        ++i;
    }
    if (v > 1)
		printf("[%u]", v);
    putnl();
	gpio1_off(6);
}

int raise(int n) { return n; }

void main(void)
{
	banner();
	gpio1_on(2);
	if (create_task(heartbeat, NULL, HZ, HZ, HZ, FPR, "heartbeat") == -1) {
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
	if (create_task(factor_ticks, NULL, 17, 1, 1, FPR, "factor_ticks") == -1) {
		puts("ERROR: cannot create task drive_gpio");
		panic1();
	}

	idle_task();
}
