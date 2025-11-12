#pragma once

#ifdef __cplusplus
extern "C" {
#endif

int os_init();
void os_run(void);
int os_create_thread(int (*entry)(void*), void* args);
void os_thread_yield(void);
void os_delay(int time);

#ifdef __cplusplus
}
#endif
