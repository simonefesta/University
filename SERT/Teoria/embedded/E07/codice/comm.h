#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

#define NULL ((void *)0)
typedef void (*isr_t)(void);

extern volatile unsigned long ticks;

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

/*
vim: tabstop=8 softtabstop=8
*/

