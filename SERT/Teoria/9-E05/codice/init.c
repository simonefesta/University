#include "beagleboneblack.h"

static void init_gpio1(void)
{
	u32 mask = (1<<21)|(1<<22)|(1<<23)|(1<<24);
	iomem(CM_PER_GPIO1_CLKCTRL) = 0x40002;
	iomem_low(GPIO1_OE, mask);
	iomem_high(GPIO1_IRQSTATUS_CLR_0, mask);
	iomem_high(GPIO1_IRQSTATUS_CLR_1, mask);
}

static void fill_bss(void)
{
	extern u32 _bss_start, _bss_end;
	u32 *p;
	for (p = &_bss_start; p < &_bss_end; ++p)
		*p = 0UL;
}

void _init(void)
{
	init_gpio1();
	fill_bss();
	main();
}
