/* Cortex-M55 Startup Code */
.syntax unified
.arch armv8-m.main
.thumb

.section .vectors, "a"
.align 2
.globl __Vectors
__Vectors:
    .word   __StackTop           /* Top of Stack */
    .word   Reset_Handler        /* Reset Handler */
    .word   NMI_Handler          /* NMI Handler */
    .word   HardFault_Handler    /* Hard Fault Handler */
    .word   MemManage_Handler    /* MPU Fault Handler */
    .word   BusFault_Handler     /* Bus Fault Handler */
    .word   UsageFault_Handler   /* Usage Fault Handler */
    .word   0                    /* Reserved */
    .word   0                    /* Reserved */
    .word   0                    /* Reserved */
    .word   0                    /* Reserved */
    .word   SVC_Handler          /* SVCall Handler */
    .word   DebugMon_Handler     /* Debug Monitor Handler */
    .word   0                    /* Reserved */
    .word   PendSV_Handler       /* PendSV Handler */
    .word   SysTick_Handler      /* SysTick Handler */

.section .text
.thumb_func
.globl Reset_Handler
Reset_Handler:
    /* Load stack pointer */
    ldr sp, =__StackTop
    
    /* Copy initialized data from flash to RAM */
    ldr r0, =__data_start__
    ldr r1, =__data_end__
    ldr r2, =__data_init__
    
    cmp r0, r1
    beq copy_data_done
    
copy_data:
    ldr r3, [r2], #4
    str r3, [r0], #4
    cmp r0, r1
    bne copy_data
    
copy_data_done:
    /* Clear BSS section */
    ldr r0, =__bss_start__
    ldr r1, =__bss_end__
    mov r2, #0
    
    cmp r0, r1
    beq bss_done
    
clear_bss:
    str r2, [r0], #4
    cmp r0, r1
    bne clear_bss
    
bss_done:
    /* Call C++ constructors */
    ldr r0, =__preinit_array_start
    ldr r1, =__preinit_array_end
    bl call_array
    
    ldr r0, =__init_array_start
    ldr r1, =__init_array_end
    bl call_array
    
    /* Jump to main */
    bl main
    
    /* Call _exit with return value from main */
    bl _exit

    /* Infinite loop */
    b .

call_array:
    cmp r0, r1
    beq call_array_end
    ldm r0!, {r2}
    push {r0, r1}
    blx r2
    pop {r0, r1}
    b call_array
call_array_end:
    bx lr

/* Exception Handlers - weak definitions */
.weak NMI_Handler
.thumb_func
NMI_Handler:
    b .

.weak HardFault_Handler
.thumb_func
HardFault_Handler:
    b .

.weak MemManage_Handler
.thumb_func
MemManage_Handler:
    b .

.weak BusFault_Handler
.thumb_func
BusFault_Handler:
    b .

.weak UsageFault_Handler
.thumb_func
UsageFault_Handler:
    b .

.weak SVC_Handler
.thumb_func
SVC_Handler:
    b .

.weak DebugMon_Handler
.thumb_func
DebugMon_Handler:
    b .

.weak PendSV_Handler
.thumb_func
PendSV_Handler:
    b .

.weak SysTick_Handler
.thumb_func
SysTick_Handler:
    b .

.end
