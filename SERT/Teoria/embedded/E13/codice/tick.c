#include "beagleboneblack.h"


volatile unsigned long ticks = 0xfffffffful - (10*HZ);

static void isr_tick(void)
{
	/* clear the source interrupt on the device */
	iomem(DMTIMER1_TISR) = DMT1_OVF_IT_FLAG;
	if (time_after_eq(++ticks, next_release))
	    check_periodic_tasks();
	if (current->budget > 0)
	    decrease_cbs_budget(current);
}

void init_ticks(void)
{
	irq_disable();
	/* Assuming that the DMTimer1 module has already been activated */
	if (register_isr(Timer1_IRQ, isr_tick)) {
		irq_enable();
		panic0();
	}
	iomem(DMTIMER1_TLDR) = TICK_TLDR;
	iomem(DMTIMER1_TIER) = DMT1_OVF_IT_FLAG;
#if CONFIG_TICK_ADJUST
	iomem(DMTIMER1_TPIR) = TICK_TPIR;
	iomem(DMTIMER1_TNIR) = TICK_TNIR;
#else
	iomem(DMTIMER1_TPIR) = 0;
	iomem(DMTIMER1_TNIR) = 0;
#endif

	iomem(INTC_ILR_BASE + Timer1_IRQ) = 0x0;
	iomem_high(INTC_MIR_CLEAR_BASE + 8 * Timer1_IRQ_Bank, Timer1_IRQ_Mask);
	iomem(DMTIMER1_TCLR) = 0x3;	/* Auto-reload, start */
	loop_delay(10000);
	iomem(DMTIMER1_TTGR) = 1;
	next_release = ticks;
	irq_enable();
}

/*
vim: tabstop=8 softtabstop=8
*/

