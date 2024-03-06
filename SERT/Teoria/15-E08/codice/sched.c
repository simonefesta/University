#include "beagleboneblack.h"

volatile unsigned long globalreleases = 0;

void check_periodic_tasks(void)
{
	unsigned long now = ticks;
	struct task *f;
	int i;

	for (i = 0, f = taskset; i < num_tasks; ++f) {
		if (!f->valid)
			continue;
		if (time_after_eq(now, f->releasetime)) {
			++f->released;
			f->releasetime += f->period;
			++globalreleases;
		}
		++i;
	}
}

static inline struct task *select_best_task(void)
{
	unsigned long maxprio;
	struct task *best, *f;
	int i;

	maxprio = MAXUINT;
	best = NULL;
	for (i = 0, f = taskset; i < num_tasks; ++f) {
		if (f - taskset >= MAX_NUM_TASKS)
			panic0();
		if (!f->valid)
			continue;
		++i;
		if (f->released == 0)
			continue;
		if (f->priority < maxprio) {
			maxprio = f->priority;
			best = f;
		}
	}
	return best;
}

void run_periodic_tasks(void)
{
	struct task *best;
	unsigned long state;

	for (;;) {
		state = globalreleases;
		best = select_best_task();
		if (best != NULL && state == globalreleases) {
			best->job(best->arg);
			best->released--;
		}
	}
}

