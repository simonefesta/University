#include "beagleboneblack.h"

struct task *current;

volatile unsigned long globalreleases = 0;
volatile unsigned long trigger_schedule = 0;
volatile unsigned long next_release;

void check_periodic_tasks(void)
{
	unsigned long now = ticks, nr = now + 1;
	struct task *f;
	int i;

	for (i = 0, f = taskset+1; i < num_tasks; ++f) {
		if (!f->valid)
			continue;
		if (time_after_eq(now, f->releasetime)) {
			f->releasetime += f->period;
			if (f->budget == 0) { /* not CBS */
				++f->released;
				trigger_schedule = 1;
				++globalreleases;
			}
		}
		if (!i || time_after(nr, f->releasetime))
			nr = f->releasetime;
		++i;
	}
	next_release = nr;
}

static inline struct task *select_best_task(void)
{
	unsigned long maxprio;
	struct task *best, *f;
	int i, edf, fpr;

	maxprio = MAXUINT;
	edf = fpr = 0;
	best = &taskset[0];
	for (i = 0, f = taskset+1; i < num_tasks; ++f) {
		if (f - taskset >= MAX_NUM_TASKS)
			panic0();
		if (!f->valid)
			continue;
		++i;
		if (f->released == 0)
			continue;
		if (fpr) { /* there are pending FPR jobs */
			if (f->deadline != 0)
				continue; /* an EDF job cannot win */
			if (f->priority < maxprio) {
				maxprio = f->priority;
				best = f; /* replace FPR champion */
			}
			continue;
		}
		/* still no pending FPR jobs */
		if (f->deadline == 0) {
			fpr = 1; /* this is the first FPR job */
			maxprio = f->priority;
			best = f;
			continue;
		}
		/* this pending job is EDF, and no FPR pending jobs found up to now */
		if (!edf || time_before(f->priority, maxprio)) {
			edf = 1;
			maxprio = f->priority;
			best = f; /* replace EDF champion */
		}
	}
	return best;
}

struct task *schedule(void)
{
	static int do_not_enter = 0;
	struct task *best;
	unsigned long oldreleases;

	if (do_not_enter != 0)
		return NULL;

	do_not_enter = 1;
	do {
		oldreleases = globalreleases;
		irq_enable();
		best = select_best_task();
		irq_disable();
	} while (oldreleases != globalreleases);
	trigger_schedule = 0;
	if (best == current)
		best = NULL;
	else
		led3_on();
	do_not_enter = 0;
	return best;
}

#define save_regs(regs) \
	__asm__ __volatile__("stmia %0,{r4-r11}" \
	: : "r" (regs) : "memory")

#define load_regs(regs) \
	__asm__ __volatile__("ldmia %0,{r4-r11}" \
			: : "r" (regs) : "r4", "r5", "r6", "r7", "r8", \
			"r9", "r10", "r11", "memory")

#define switch_stacks(from, to) \
	__asm__ __volatile__("str sp,%0\n\t" \
						 "ldr sp,%1" \
	: : "m" ((from)->sp), "m" ((to)->sp) \
	: "sp", "memory")

#define naked_return() __asm__ __volatile__("bx lr")

void _switch_to(struct task *) __attribute__ ((naked));

void _switch_to(struct task *to)
{
		irq_disable();
		save_regs(current->regs);
		load_regs(to->regs);
		switch_stacks(current, to);
		current = to;
		irq_enable();
		naked_return();
}
