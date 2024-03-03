#include "beagleboneblack.h"

#define WDT_Ticks (30*HZ)

static void rearm_watchdog(void *arg)
{
	arg = arg;
	iomem(WDT1_WTGR)++;
}

void init_watchdog(void)
{
	if (create_task(rearm_watchdog, NULL, WDT_Ticks, 1, WDT_Ticks, 
	                FPR, "watchdog") == -1) {

		puts("ERROR: cannot create task \"watchdog\"\n");
		panic0();
	}
}
