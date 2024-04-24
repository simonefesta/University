#include "beagleboneblack.h"

static isr_t ISR[NUM_IRQ_LINES];
unsigned long irqcount[NUM_IRQ_LINES] = { 0, };
unsigned long irq_level = 0ul;

void _bsp_irq(void)
{
	isr_t isr;
	u32 irqno;

	/* Cancel any soft irq */
	iomem(INTC_ISR_CLEAR_BASE + 0) = 0xffffffffUL;
	iomem(INTC_ISR_CLEAR_BASE + 8) = 0xffffffffUL;
	iomem(INTC_ISR_CLEAR_BASE + 16) = 0xffffffffUL;
	iomem(INTC_ISR_CLEAR_BASE + 24) = 0xffffffffUL;

	++irq_level;
	data_sync_barrier();

	for (;;) {
		if (iomem(INTC_PENDING_IRQ_BASE + 0) == 0 &&
			iomem(INTC_PENDING_IRQ_BASE + 8) == 0 &&
			iomem(INTC_PENDING_IRQ_BASE + 16) == 0 &&
			iomem(INTC_PENDING_IRQ_BASE + 24) == 0) {
			--irq_level;
			data_sync_barrier();
			return;
		}

		/* there are pending unmasked IRQs on some IC */

		/* read the (highest-priority) IRQ line number */
		irqno = iomem(INTC_SIR_IRQ);

		/* Do nothing if a spurious interrupt is detected 
		   (see AM335x TRM, 6.2.5) */
		if (irqno < NUM_IRQ_LINES) {
			isr = ISR[irqno];
			if (!isr)
				panic0();
			/* invoke the ISR (with IRQ disabled) */
			isr();
			/* just to be sure, in case the ISR has left enabled the IRQs */
			irq_disable();
			++irqcount[irqno];
		}

		/* (TRM 6.2.2) "After the return of the subroutine, the ISR sets the
		 * NEWIRQAGR/NEWFIQAGR bit to enable the processing of subsequent pending
		 * IRQs/FIQs and to restore ARM context [...] Because the writes are
		 * posted on an Interconnect bus, to be sure that the preceding writes
		 * are done before enabling IRQs/FIQs, a Data Synchronization Barrier is
		 * used. This operation ensure that the IRQ/FIQ line is de-asserted before
		 * IRQ/FIQ enabling. After that, the INTC processes any other pending
		 * interrupts or deasserts the IRQ/FIQ signal if there is no interrupt. */

		iomem(INTC_CONTROL) = NEWIRQAGR;
		data_sync_barrier();
	}
}

int register_isr(int n, isr_t func)
{
	if (n >= NUM_IRQ_LINES) {
		printf("ERROR in register_isr(): IRQ number %u is invalid\n", n);
		return 1;
	}
	if (ISR[n] != NULL) {
		printf("ERROR in register_isr(): line %u already registered\n", n);
		return 1;
	}
	ISR[n] = func;
	return 0;
}

/*
vim: tabstop=4 softtabstop=4
*/

