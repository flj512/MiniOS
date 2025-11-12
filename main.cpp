#include <cstdint>
#include <cstdio>
#include <string>

extern "C" void initialise_monitor_handles(void);

class TestA {
public:
    TestA():val_(102){

    }
    void increase()
    {
        val_++;
    }
    int get()
    {
        return val_;
    }
private:
    int val_;
};

TestA a;

/**
 * Main function
 */
int main(void)
{
    initialise_monitor_handles();

    /* Standard printf will now use semihosting through our _write implementation */
    printf("Hello, World from Cortex-M55!\n");
    printf("This is a C++ program running on QEMU using semihosting for printf\n");

    /* Example of formatted output using printf */
    int value = 42;
    float pi = 3.14159;
    printf("Formatted output: integer = %d, pi = %.3f\n", value, pi);

    /* Loop for a while to ensure output is processed */
    for(int counter = 0; counter < 10; counter++) {
        printf("Still running... Counter: %d\n", counter);  // Provide periodic status via semihosting
        
    }
    
    printf("Program finished successfully!\n");
    //fflush(stdout);
    return a.get();
}