#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

static inline void loop_delay(unsigned long d)
{
    while (d-- > 0)
	data_sync_barrier();
}

void main(void);

/*
vim: tabstop=8 softtabstop=8
*/

