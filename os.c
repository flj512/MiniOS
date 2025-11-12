#include "os.h"

#include <stdint.h>
#include <stdio.h>

// definitions
#define SYST_CSR (*(volatile unsigned int *)0xE000E010)
#define SYST_RVR (*(volatile unsigned int *)0xE000E014)
#define SYST_CVR (*(volatile unsigned int *)0xE000E018)
#define SYST_CALIB (*(volatile unsigned int *)0xE000E01C)

#define SCB_ICSR (*(volatile unsigned int *)0xE000ED04)

#define PENDSV_SET (1U << 28)

#define TRIGGER_CONTEX_SWITCH() SCB_ICSR |= PENDSV_SET
#define ENABLE_INTERUPT() __asm volatile("cpsie i")
#define DISABLE_INTERUPT() __asm volatile("cpsid i")

/* ------------------ Thread Control Block ------------------ */
typedef struct {
  uint32_t *sp;  // Store stack pointer
  int (*entry)(void *);
  void *args;
} tcb_t;

#define MAX_THREADS 8
static tcb_t tcb[MAX_THREADS];
static volatile int current = -1;
static volatile int next_free = 0;

/* ------------------ Stacks for threads ------------------ */
#define STACK_SIZE 256
static uint32_t stack_mem[MAX_THREADS][STACK_SIZE];

static void thread_fn(void) {
  int ret = tcb[current].entry(tcb[current].args);

  printf("thread %d exited, return value = %d\n", current, ret);
  tcb[current].entry = 0;
  os_thread_yield();
  __builtin_unreachable();
}
/* ----------------------------------------------------------
   Create a thread: prepare initial stack frame.
   ---------------------------------------------------------- */
int os_create_thread(int (*entry)(void *), void *args) {
  if (next_free >= MAX_THREADS) {
    return -1;
  }
  uint32_t *stack = &stack_mem[next_free][STACK_SIZE - 1];

  // Make room for hardware-stacked registers
  stack -= 8;

  stack[7] = 0x01000000;            // xPSR
  stack[6] = (uint32_t)&thread_fn;  // PC
  stack[5] = 0;                     // LR
  stack[4] = 0;                     // R12
  stack[3] = 0;                     // R3
  stack[2] = 0;                     // R2
  stack[1] = 0;                     // R1
  stack[0] = 0;                     // R0

  stack -= 8;  // R4-R11
  for (int i = 0; i < 8; i++) {
    stack[i] = 0;
  }

  tcb[next_free].entry = entry;
  tcb[next_free].args = args;
  tcb[next_free].sp = stack;

  return next_free++;
}

int check_valid_current(void) {
  if (current >= 0) {
    return 1;
  } else {
    current = 0;
    return 0;
  }
}
/* ----------------------------------------------------------
   Trigger context switch from SVC
   ---------------------------------------------------------- */
void SVC_Handler(void) { TRIGGER_CONTEX_SWITCH(); }

/* ----------------------------------------------------------
   Software-triggered yield
   ---------------------------------------------------------- */
void os_thread_yield(void) {
  asm("svc #0");  // Trigger SVC interrupt.
}

void os_schedule_thread_() {
  int active_thread = 0;
  for (int i = (current + 1) % MAX_THREADS, j = 0; j < MAX_THREADS;
       i = (i + 1) % MAX_THREADS, j++) {
    if (i != 0 && tcb[i].entry) {
      active_thread = 1;
      current = i;
      break;
    }
  }
  if (!active_thread) {
    current = 0;  // idle thread.
  }
}
/* ----------------------------------------------------------
   PendSV: performs thread schedule and context switch
   ---------------------------------------------------------- */
__attribute__((naked)) void PendSV_Handler(void) {
  __asm volatile(
      "push {lr}                  \n"  // PendSV_Handler will call
                                       // other functions, so save the LR
      "bl check_valid_current     \n"
      "cmp r0, #0                 \n"
      "beq 1f                     \n"  // if there is no thread started, skip
                                       // save current context
                                       // jump to label 1 (1f mean forward lebel
                                       // 1, 1b means backward lebal 1 this can
                                       // avoids name conflicts between asm
                                       // blocks
      "mrs r0, psp                \n"  // r0 = PSP (current thread SP)

      /* save r4-r11 on current PSP */
      "stmdb r0!, {r4-r11}        \n"

      /* save PSP to tcb[current].sp */
      "ldr r1, =current           \n"
      "ldr r2, [r1]               \n"  // r2 = current
      "ldr r3, =tcb               \n"
      "mov r4, %0                 \n"
      "mul r2, r2, r4             \n"  // r2 = current * sizeof(tcb_t)
      "add r3, r3, r2             \n"
      "str r0, [r3]               \n"  // tcb[current].sp = r0

      /* schedule thread */
      "1:                         \n"
      "bl os_schedule_thread_     \n"

      /* load next thread SP */
      "ldr r1, =current           \n"
      "ldr r2, [r1]               \n"
      "ldr r3, =tcb               \n"
      "mov r4, %0                 \n"
      "mul r2, r2, r4             \n"
      "add r3, r3, r2             \n"
      "ldr r0, [r3]               \n"

      /* restore r4-r11 */
      "ldmia r0!, {r4-r11}        \n"
      "msr psp, r0                \n"

      "pop {lr}                   \n"
      "bx lr                      \n" ::"I"(sizeof(tcb_t)));
}

void systick_init(unsigned int ticks) {
  SYST_RVR = ticks - 1;  // Reload value
  SYST_CVR = 0;          // Clear current value
  SYST_CSR = (1 << 2) |  // CLKSOURCE = processor clock
             (1 << 1) |  // TICKINT = enable interrupt
             (1 << 0);   // ENABLE = start
}

void SysTick_Handler(void) {
  TRIGGER_CONTEX_SWITCH();  // Request a thread switch
}
/* ----------------------------------------------------------
   Start OS: Set PSP to first thread & switch to thread mode
   ---------------------------------------------------------- */
void os_delay(int time) {
  for (int i = 0; i < time; i++)
    for (int j = 0; j < 300000000; j++) asm("nop");
}

int idle_thread(void *args) {
  while (1) {
    os_delay(1);
    printf("No thread, OS idle.\n");
  }
  return 0;
}
int os_init(void) { return os_create_thread(idle_thread, 0); }

void os_run(void) {
  // use PSP stack in thread mode
  DISABLE_INTERUPT();
  __asm volatile(
      // init PSP to idle thread's stack, the PSP will
      // point to the first running thread after the
      // next TRIGGER_CONTEX_SWITCH. here need a valid
      // PSP so that the following
      // PendSV excpetion can be handled correctly.
      "mov r0, %0            \n"
      "msr psp, r0           \n"
      // select PSP
      "mrs r1, control       \n"
      "orr r1, r1, #2        \n"  // SPSEL=1
      "msr control, r1       \n"
      "isb                   \n" ::"r"(tcb[0].sp));
  ENABLE_INTERUPT();

  // enable timer
  systick_init(100000);

  // trigger thread schedule immediately
  TRIGGER_CONTEX_SWITCH();

  __builtin_unreachable();
}
