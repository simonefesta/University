#include "beagleboneblack.h"

/* The CBS server is implemented as an EDF task with:
 * - period -> the CBS period Ts
 * - budget_max -> the maximum capacity Qs (same as deadline field)
 * - priority -> the current CBS absolute deadline
 *
 * The bandwith (or size) of the server is max_capacity/period 
 * Basically, the server cannot execute for more than max_capacity
 * ticks in an interval of period ticks */

/* It is possible to define several CBS servers. 
 * Currently we have just one, named cbs0 */

struct cbs_queue cbs0;

static void cbs_server(void *arg)
{
        struct cbs_queue *q = (struct cbs_queue *) arg;
        int i;

        /* look for the highest-priority pending worker job */
        for (i=0; i<q->num_workers; ++i)
                if (q->pending[i] > 0)
                        break;
        if (i == q->num_workers) {
                puts("\nWARNING: Useless activation of the CBS server\n");
                return; 
        }
        /* execute the worker job */
        q->workers[i](q->args[i]);
        /* carefully decrease the activation counter, which could be
         * increased by an interrupt handler */
        irq_disable();
        --q->pending[i];
        irq_enable();
}

void irqsafe_activate_cbs_worker(struct cbs_queue *q, int wid)
{
        struct task *t = q->task;
	unsigned long now = ticks;

        if (wid >= q->num_workers)
                panic0();

        q->pending[wid]++;
        t->released++;
        if (t->released == 1 && (time_before_eq(t->priority, now) ||
		    time_after_eq(now * t->budget_max + t->budget * t->period,
			t->priority * t->budget_max))) {
                        t->priority = now + t->period;
                        trigger_schedule = 1;
                        ++globalreleases;
	}
}

void activate_cbs_worker(struct cbs_queue *q, int wid)
{
        irq_disable();
        irqsafe_activate_cbs_worker(q, wid);
        irq_enable();
}

void decrease_cbs_budget(struct task *t)
{
        t->budget--;
        if (t->budget > 0)
                return;
        t->budget = t->budget_max; /* in no cases a CBS server has budget 0 */
        t->priority += t->period;
        /* force rescheduling */
        trigger_schedule = 1;
}

void test_cbs_job(void *arg)
{
        struct cbs_queue *q = (struct cbs_queue *) arg;
        struct task *t = q->task;
        static unsigned int count = 0;

        printf("\nCBS: #%u prio=%u nextrel=%u pending=%u budget=%u\n", 
                ++count, t->priority, t->releasetime, q->pending[0], t->budget);
}

int init_cbs(unsigned long max_cap, unsigned long period, struct cbs_queue *cbs_q, const char *name)
{
        int tid;

        cbs_q->num_workers = 0;
        data_sync_barrier();
        tid = create_task(cbs_server, cbs_q, period, 10, max_cap, CBS, name);
        /* we have a problem here, because create_task() (re-)enables
         * the interrupts on exit -- hence the CBS task might get be
         * scheduled right away. We cope with this situation by
         * defining a relatively long initial delay (phase) for the first
         * CBS's task's job */
        if (tid == -1)
                return -1;
        cbs_q->task = taskset + tid;
        data_sync_barrier();
        return 0;
}

int add_cbs_worker(struct cbs_queue *cbs_q, job_t worker_fn, void *worker_arg)
{
        int i = cbs_q->num_workers;
        if (i >= MAX_NUM_WORKERS)
                return -1;
        irq_disable();
        cbs_q->workers[i]       = worker_fn;
        cbs_q->args[i]          = worker_arg;
        cbs_q->pending[i]       = 0;
        cbs_q->num_workers++;
        irq_enable();
        return i;
}

/*
vim: tabstop=8 tabstop=8
*/
