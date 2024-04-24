#ifndef _BEAGLEBONEBLACK_H_
#error You must not include this sub-header file directly
#endif

#define compiler_barrier() \
    __asm__ __volatile__ ("" ::: "memory")

#define data_memory_barrier() \
    __asm__ __volatile__ ("dmb sy" ::: "memory")

#define data_sync_barrier() \
    __asm__ __volatile__ ("dsb sy" ::: "memory")

#define instr_sync_barrier() \
    __asm__ __volatile__ ("isb sy" ::: "memory")

/*
vim: tabstop=8 softtabstop=8
*/

