void *__dso_handle = 0;
void _init(void) {}
void SystemInit(void) {
  // enable FPU
  __asm volatile(
      "LDR   R0, =0xE000ED88\n"
      "LDR   R1, [R0]\n"
      "ORR   R1, R1, #(0xF << 20)\n"
      "STR   R1, [R0]\n"
      "DSB   SY\n"
      "ISB   SY\n");
}
