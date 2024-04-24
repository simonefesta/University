#include "beagleboneblack.h"

static void init_gpio1(void)
{
	u32 mask = (1<<21)|(1<<22)|(1<<23)|(1<<24);
	mask |= (1 << 2) | (1 << 3) | (1 << 6) | (1 << 7);
	iomem(CM_PER_GPIO1_CLKCTRL) = 0x40002;
	iomem_low(GPIO1_OE, mask);
	iomem_high(GPIO1_IRQSTATUS_CLR_0, mask);
	iomem_high(GPIO1_IRQSTATUS_CLR_1, mask);
	/* Set pin mux so as to export gpio1[2,3,6,7] signals to header P8 */
	/* Fast slew rate, received disabled, internal pull-up resistor
	 * disabled, mode 0b111 (P8[3,4,5,6] <--> gpio1[6,7,2,3]) */
	iomem(CM_CONF_GPMC_AD2) = 0x0f;
	iomem(CM_CONF_GPMC_AD3) = 0x0f;
	iomem(CM_CONF_GPMC_AD6) = 0x0f;
	iomem(CM_CONF_GPMC_AD7) = 0x0f;
	/* Initialize output lines as 'ground' */
	gpio1_off(2);
	gpio1_off(3);
	gpio1_off(6);
	gpio1_off(7);
}

static void fill_bss(void)
{
	extern u32 _bss_start, _bss_end;
	u32 *p;
	for (p = &_bss_start; p < &_bss_end; ++p)
		*p = 0UL;
}

static void init_intc(void)
{
	   /* We globally disabled all interrupts in _reset() */
	   /* Now we disable each interrupt individually */
	   iomem(INTC_MIR_SET_BASE + 0) = 0xffffffffUL;
	   iomem(INTC_MIR_SET_BASE + 8) = 0xffffffffUL;
	   iomem(INTC_MIR_SET_BASE + 16) = 0xffffffffUL;
	   iomem(INTC_MIR_SET_BASE + 24) = 0xffffffffUL;

	   /* Disable the threshold mechanism */
	   iomem(INTC_THRESHOLD) = 0xff;

	   irq_enable();
}

static void init_vectors(void)
{
	extern void _reset(void);
	extern void _irq_handler(void);
	volatile u32 *vectors = get_vectors_address();
#define LDR_PC_PC 0xe59ff018
	vectors[0] = LDR_PC_PC; /* Reset / Reserved */
	vectors[1] = LDR_PC_PC; /* Undefined instruction */
	vectors[2] = LDR_PC_PC; /* Software interrupt */
	vectors[3] = LDR_PC_PC; /* Prefetch abort */
	vectors[4] = LDR_PC_PC; /* Data abort */
	vectors[5] = LDR_PC_PC; /* Hypervisor trap */
	vectors[6] = LDR_PC_PC; /* Interrupt request (IRQ) */
	vectors[7] = LDR_PC_PC; /* Fast interrupt request (FIQ) */
	vectors[8] = (u32) _reset;		/* Reset / Reserved */
	vectors[9] = (u32) panic0;		/* Undefined instruction */
	vectors[10] = (u32) panic2; /* Software interrupt */
	vectors[11] = (u32) panic0; /* Prefetch abort */
	vectors[12] = (u32) panic2; /* Data abort */
	vectors[13] = (u32) panic0; /* Hypervisor trap */
	vectors[14] = (u32) _irq_handler;   /* Interrupt request (IRQ) */
	vectors[15] = (u32) panic0; /* Fast interrupt request (FIQ) */
#undef LDR_PC_PC
}


static void init_vfp(void)
{
	u32 v = read_coprocessor_access_control_register();
	v |= (1u << 20) | (1u << 22);
	write_coprocessor_access_control_register(v);
	data_sync_barrier();
	set_en_bit_in_fpexc();
}

void _init(void)
{
	init_vfp();
	init_vectors();
	init_gpio1();
	fill_bss();
	init_intc();
	init_taskset();
	calibrate_udelay();
	init_ticks();
	if (init_cbs(30,250, &cbs0, "cbs0") == -1)
		panic0();
	if (add_cbs_worker(&cbs0, test_cbs_job, &cbs0) == -1)
		panic0();
	init_watchdog();
	main();
}

