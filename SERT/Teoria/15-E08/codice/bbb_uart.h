#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

#define UART0_BASE			0x44e09000

iomemdef(UART0_THR,			UART0_BASE + 0);
iomemdef(UART0_LSR,			UART0_BASE + 0x14);

#define LSR_TXFIFOE			(1u<<5)

/*
vim: tabstop=8 softtabstop=8
*/

