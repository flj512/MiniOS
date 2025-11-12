/* Memory layout for Cortex-M55 with typical MPS3 configuration */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 8M
    RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 4M
}

ENTRY(Reset_Handler)

SECTIONS
{
    .vectors :
    {
        KEEP(*(.vectors))
        . = ALIGN(4);
    } > FLASH

    .text :
    {
        *(.text)
        *(.text*)
        . = ALIGN(4);
    } > FLASH
    
    .rodata :
    {
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } > FLASH

    .init_array :
    {
        __init_array_start = .;
        KEEP(*(.init_array*))
        __init_array_end = .;
        . = ALIGN(4);
    } > FLASH

    .fini_array :
    {
        __fini_array_start = .;
        KEEP(*(.fini_array*))
        __fini_array_end = .;
        . = ALIGN(4);
    } > FLASH

    .preinit_array :
    {
        __preinit_array_start = .;
        KEEP(*(.preinit_array))
        __preinit_array_end = .;
        . = ALIGN(4);
    } > FLASH

    /* Mark where initialized data is stored in FLASH */
    __data_init__ = .;

    /* Initialized data in RAM (loaded from FLASH at startup) */
    .data :
    {
        __data_start__ = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM AT > FLASH

    /* Uninitialized data in RAM */
    .bss (NOLOAD) :
    {
        __bss_start__ = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    /* Stack at the end of RAM */
    . = ALIGN(8);
    __StackLimit = .;
    . = . + 0x10000;
    __StackTop = .;

    _end = .;
    end = .;
}
