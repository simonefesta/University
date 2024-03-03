#include "beagleboneblack.h"


volatile unsigned long ticks = 0xffffffff - 10*HZ;

static void isr_tick(void)
{
	/* clear the source interrupt on the device */
	iomem(DMTIMER0_IRQSTATUS) = OVF_IT_FLAG;
	++ticks;
	check_periodic_tasks();
}

void init_ticks(void)
{
	irq_disable();
	/* Assuming that the DMTimer0 module has already been activated */
	if (register_isr(Timer0_IRQ, isr_tick)) {
		irq_enable();
		puts("init_ticks(): cannot register isr\n");
		panic0();
	}
	iomem(DMTIMER0_TLDR) = TICK_TLDR;
	iomem(DMTIMER0_IRQENABLE_CLR) = TCAR_IT_FLAG | MAT_IT_FLAG;
	iomem(DMTIMER0_IRQENABLE_SET) = OVF_IT_FLAG;
	iomem(INTC_ILR_BASE + Timer0_IRQ) = 0x0;
	iomem(INTC_MIR_CLEAR_BASE + 8 * Timer0_IRQ_Bank)=Timer0_IRQ_Mask;

	iomem(DMTIMER0_TCLR) = 0x3; /* Auto-reload, start */
	loop_delay(10000);
	iomem(DMTIMER0_TTGR) = 1;
	irq_enable();
}

/*
vim: tabstop=8 softtabstop=8
*/

