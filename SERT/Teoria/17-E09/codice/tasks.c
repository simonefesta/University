#include "beagleboneblack.h"

struct task taskset[MAX_NUM_TASKS];
int num_tasks;

void init_taskset(void)
{
	int i;
	num_tasks = 0;
	for (i = 0; i < MAX_NUM_TASKS; i++) {
		taskset[i].valid = 0;
	}
}

int create_task(job_t job, void *arg, int period, int delay, \
                int priority, const char *name)
{
	int i;
	struct task *t;

	for (i = 0; i < MAX_NUM_TASKS; ++i) {
		if (!taskset[i].valid)
			break;
	}

	if (i == MAX_NUM_TASKS)
		return -1;

	t = taskset + i;

	t->job = job;
	t->arg = arg;
	t->name = name;
	t->period = period;
	t->priority = priority;
	t->releasetime = ticks + delay;
	t->released = 0;
	irq_disable();
	++num_tasks;
	t->valid = 1;
	irq_enable();
	printf("Task %s created, TID=%u\n", name, i);
	return i;
}

