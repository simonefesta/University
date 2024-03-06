#include "beagleboneblack.h"

void mdelay(unsigned long msec)
{
	unsigned long tckd = (msec * HZ + 999) / 1000;
	u32 expire = ticks + tckd;
	while (time_before(ticks, expire))
		cpu_wait_for_interrupt();
}

/*
vim: tabstop=8 softtabstop=8
*/

