#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>

#include "os.h"

extern "C" void initialise_monitor_handles(void);

int thread(void* args) {
  int n = *(int*)args;
  for (int i = 0; i < n + 5; i++) {
    os_delay(1);
    printf("Thread %d running %d\n", n, i);
    // os_thread_yield();
  }
  return n;
}

/**
 * Main function
 */
int main(void) {
  // enable semihosting
  initialise_monitor_handles();
  printf("OS testing......\n");

  os_init();

  std::vector<int> args{2, 6};
  for (auto& v : args) {
    os_create_thread(thread, &v);
  }

  os_run();

  return 0;
}
