#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

#define NULL ((void *)0)
#define MAXUINT (0xffffffffu)

typedef void (*isr_t)(void);
typedef void (*job_t)(void *);

extern volatile unsigned long ticks;
extern volatile unsigned long trigger_schedule;
extern volatile unsigned long globalreleases;

static inline
void loop_delay(unsigned long d)
{
    while (d-- > 0)
        data_sync_barrier();
}

#define time_after(a,b)      ((long)((b)-(a))<0)
#define time_before(a,b)     time_after(b,a)
#define time_after_eq(a,b)   ((long)((a)-(b))>=0)
#define time_before_eq(a,b)  time_after_eq(b,a)

#define        MAX_NUM_TASKS   32

#define FPR 0
#define EDF 1
#define CBS 2

struct task {
    int valid;
    job_t job;
    void *arg;
    u32 sp;
    u32 regs[8];
    unsigned long releasetime;
    unsigned long released;
    unsigned long period;
    unsigned long priority;
    union {
        unsigned long deadline;
        unsigned long budget_max;
    };
    unsigned long budget;
    const char *name;
};

#define MAX_NUM_WORKERS 8

struct cbs_queue {
    struct task *task;
    int num_workers;
    job_t workers[MAX_NUM_WORKERS];
    void *args[MAX_NUM_WORKERS];
    unsigned int pending[MAX_NUM_WORKERS];
};

extern int num_tasks;
extern struct task taskset[MAX_NUM_TASKS];
extern struct task *current;
extern volatile unsigned long next_release;
extern struct cbs_queue cbs0;

void main(void);
void panic0(void);
void panic1(void);
void panic2(void);
int putc(int);
int puts(const char *);
int putnl(void);
int puth(unsigned long);
int putu(unsigned long);
int putd(long);
int putf(double,int);
int putcn(int,int);
int printf(const char *, ...);
int register_isr(int, isr_t);
void init_ticks(void);
void mdelay(unsigned long);
void init_taskset(void);
int create_task(job_t, void *, int, int, int, int, const char *);
void check_periodic_tasks(void);
struct task *schedule(void);
void _sys_schedule(void);
void init_watchdog(void);
void activate_cbs_worker(struct cbs_queue *, int);
void decrease_cbs_budget(struct task *);
int init_cbs(unsigned long, unsigned long, struct cbs_queue *, const char *);
int add_cbs_worker(struct cbs_queue *, job_t, void *);
void test_cbs_job(void *arg);

/*
vim: tabstop=8 softtabstop=8
*/

