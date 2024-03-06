ENTRY(_reset)

mem_start = 0x80000000;
mem_length = 512*0x100000; /* 512 MiB */
mem_end	  = mem_start + mem_length;

MEMORY
{
	ram (rwx) : ORIGIN = mem_start, LENGTH = mem_length
}

SECTIONS
{
    .text : {
        *(.text)
        . = ALIGN(4);
    } > ram
    .rodata : {
        *(.rodata)
        . = ALIGN(4);
    } > ram
    .data : {
        *(.data)
        . = ALIGN(4);
    } > ram
    .bss : {
        _bss_start = .;
        *(.bss)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > ram
}
