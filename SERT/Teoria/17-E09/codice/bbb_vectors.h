#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

/*** Position of the exception table (vectors) ***/

/* ARM B1.8.1 
   Any implementation that includes the Security Extensions
   has the following vector tables:
	- One for exceptions taken to Secure Monitor mode. This is
	  the Monitor vector table, and is in the address space of
	  the Secure PL1&0 translation regime.
    - One for exceptions taken to Secure PL1 modes other than
      Monitor mode. This is the Secure vector table, and is in
	  the address space of the Secure PL1&0 translation regime.
    - One for exceptions taken to Non-secure PL1 modes. This is
      the Non-secure vector table, and is in the address space
	  of the Non-secure PL1&0 translation regime.
   For the Monitor vector table, MVBAR holds the Exception base address.
   For the Secure vector table: the Secure SCTLR.V bit determines the
   Exception base address:
      V == 0 The Secure VBAR holds the Exception base address.
      V == 1 Exception base address = 0xFFFF0000, the Hivecs setting.
   For the Non-secure vector table: the Non-secure SCTLR.V bit determines
   the Exception base address:
     V == 0 The Non-secure VBAR holds the Exception base address.
     V == 1 Exception base address = 0xFFFF0000, the Hivecs setting.
 */

static inline u32 *get_vectors_address(void)
{
	u32 v;

	/* read SCTLR (ARM B4.1.130) */
	__asm__ __volatile__("mrc p15, 0, %0, c1, c0, 0\n":"=r"(v)::);
	if (v & (1 << 13))
		return (u32 *) 0xffff0000;
	/* read VBAR (ARM B4.1.156) */
	__asm__ __volatile__("mrc p15, 0, %0, c12, c0, 0\n":"=r"(v)::);
	return (u32 *) v;
}

/*
vim: tabstop=8 softtabstop=8
*/

