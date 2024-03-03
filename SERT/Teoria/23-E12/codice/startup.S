	.text
	.code 32
#define		SYS_MODE	0x1f

	.global _reset
_reset:
	cpsid		if,#SYS_MODE
	ldr		sp,=stack0_top
	ldr		sp,[sp]
	b		_init

/*
vim: tabstop=8 softtabstop=8
*/

