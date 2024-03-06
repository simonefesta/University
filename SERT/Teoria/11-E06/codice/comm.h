#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

static inline
void loop_delay(unsigned long d)
{
    while (d-- > 0)
	data_sync_barrier();
}

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
int printf(const char *p, ...);

/*
vim: tabstop=8 softtabstop=8
*/

