/* Cortex-M55 Startup Code */
.syntax unified
.arch armv8-m.main
.fpu softvfp
.thumb

/* Vector table */
.section .vectors, "a"
.type  __Vectors, %object
.globl __Vectors
__Vectors:
    .word   _estack
    .word   Reset_Handler
    .word   NMI_Handler
    .word   HardFault_Handler
    .word   MemManage_Handler
    .word   BusFault_Handler
    .word   UsageFault_Handler
    .word   0
    .word   0
    .word   0
    .word   0
    .word   SVC_Handler
    .word   DebugMon_Handler
    .word   0
    .word   PendSV_Handler
    .word   SysTick_Handler

.size  __Vectors, . - __Vectors

/* Reset Handler */
.section .text
.thumb_func
.globl Reset_Handler
Reset_Handler:
    /* Load stack pointer */
    ldr sp, =_estack

    /* Copy .data from Flash to RAM */
    ldr r0, =__data_start__
    ldr r1, =__data_end__
    ldr r2, =__data_init__
copy_data:
    cmp r0, r1
    bge copy_data_done
    ldr r3, [r2], #4
    str r3, [r0], #4
    b copy_data
copy_data_done:

    /* Zero .bss */
    ldr r0, =__bss_start__
    ldr r1, =__bss_end__
    mov r2, #0
clear_bss:
    cmp r0, r1
    bge bss_done
    str r2, [r0], #4
    b clear_bss
bss_done:

    /* For c++ support */
    bl __libc_init_array

    /* Enable FPU*/
    bl SystemInit

    /* Call main() */
    bl main

    /* Call _exit() if defined */
    bl _exit

    /* Infinite loop */
hang:
    b hang

/* Weak default handlers */
.weak NMI_Handler
.thumb_func
NMI_Handler: b .

.weak HardFault_Handler
.thumb_func
HardFault_Handler: b .

.weak MemManage_Handler
.thumb_func
MemManage_Handler: b .

.weak BusFault_Handler
.thumb_func
BusFault_Handler: b .

.weak UsageFault_Handler
.thumb_func
UsageFault_Handler: b .

.weak SVC_Handler
.thumb_func
SVC_Handler: b .

.weak DebugMon_Handler
.thumb_func
DebugMon_Handler: b .

.weak PendSV_Handler
.thumb_func
PendSV_Handler: b .

.weak SysTick_Handler
.thumb_func
SysTick_Handler: b .

.end
