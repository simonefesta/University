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

#define set_en_bit_in_fpexc() do { \
    int dummy; \
    __asm__ __volatile__ ("fmrx %0,fpexc\n\t" \
                         "orr  %0,%0,#0x40000000\n\t" \
                         "fmxr fpexc,%0" : "=r" (dummy) : :); \
} while (0)

#define read_coprocessor_access_control_register() ({ \
    u32 value; \
    __asm__ __volatile__ ("mrc p15, 0, %[reg], c1, c0, 2" : \
                          [reg] "=r" (value) : : "memory"); \
    value; })

#define write_coprocessor_access_control_register(value) \
    __asm__ __volatile__ ("mcr p15, 0, %[reg], c1, c0, 2" : : \
                          [reg] "r" (value) : "memory")

/*
vim: tabstop=8 softtabstop=8
*/

