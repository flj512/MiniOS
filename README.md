# Cortex-M55 OS Testing Framework for QEMU

This is a multitasking OS testing framework for the ARM Cortex-M55 microcontroller running on QEMU. It implements a simple preemptive OS with thread scheduling, context switching, and timer-based multitasking capabilities.

## Project Structure

- **startup.s** - Assembly startup code that initializes the CPU and calls main()
- **main.cpp** - Main C++ program demonstrating thread creation and execution
- **os.c/os.h** - Simple OS kernel with thread management, scheduling, and context switching
- **impl.c** - Implementation functions including FPU initialization
- **cortex_m55.ld** - Linker script defining memory layout for Cortex-M55
- **Makefile** - Build configuration
- **run_qemu.sh** - Script to run the program in QEMU

## Features

- **Multithreading**: Create and manage multiple threads with `os_create_thread()`
- **Preemptive Scheduling**: Timer-based context switching between threads
- **Context Switching**: Full register preservation and restoration during task switches
- **PendSV Handler**: Efficient context switching implementation using ARM's PendSV exception
- **SysTick Integration**: Timer-based thread scheduling and switching
- **C++ Support**: Full C++ compilation with constructors/destructors
- **FPU Support**: Hardware FPU initialization and usage
- **Semihosting**: Debug output via QEMU's semihosting feature

## Prerequisites

You need to have the ARM embedded toolchain installed:

```bash
# Ubuntu/Debian
sudo apt-get install gcc-arm-none-eabi g++-arm-none-eabi binutils-arm-none-eabi

# Or use the full arm embedded toolchain
sudo apt-get install arm-none-eabi-gcc arm-none-eabi-g++ arm-none-eabi-binutils
```

And QEMU with ARM support:

```bash
sudo apt-get install qemu-system-arm
```

## Building

To build the project:

```bash
make clean
make
```

This will create:
- `hello.elf` - ELF executable
- `hello.hex` - Hexadecimal file

## Running in QEMU

To run the program in QEMU:

```bash
bash run_qemu.sh
```

Or manually:

```bash
qemu-system-arm -machine mps3-an547 -cpu cortex-m55 \
    -kernel hello.elf \
    -nographic \
    -semihosting
```

You should see output showing multiple threads running concurrently:
```
OS testing......
Thread 2 running 0
Thread 6 running 0
No thread, OS idle.
Thread 2 running 1
Thread 6 running 1
Thread 2 running 2
Thread 6 running 2
...
```

To exit QEMU, press `Ctrl+A` then `X`.

## OS Architecture

The OS implementation includes:
1. **Thread Control Blocks (TCB)**: Data structures to manage thread state
2. **Stack Management**: Separate stacks for each thread
3. **Context Switching**: Save/restore registers via PendSV exception
4. **Scheduling**: Round-robin scheduling algorithm
5. **Timer Integration**: SysTick-based preemption every 100ms (configurable)
6. **Idle Thread**: Background thread when no other threads are active

## Thread API

- `os_init()` - Initialize the OS
- `os_create_thread(entry, args)` - Create a new thread with entry function
- `os_run()` - Start the OS scheduler
- `os_thread_yield()` - Voluntarily yield the CPU to another thread
- `os_delay(time)` - Simple delay function

## Memory Layout

- **ITCM0 (0x00000000-0x0007FFFF)**: Instruction Tightly Coupled Memory (512KB)
- **QSPI (0x28000000-0x287FFFFF)**: Read-only flash memory (8MB)
- **RAM (0x20000000-0x2007FFFF)**: Read-write memory (512KB)
