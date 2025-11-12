# Cortex-M55 Hello World for QEMU

This is a minimal Hello World C++ program for the ARM Cortex-M55 microcontroller running on QEMU.

## Project Structure

- **startup.s** - Assembly startup code that initializes the CPU and calls main()
- **main.cpp** - Main C++ program with UART initialization and hello world output
- **cortex_m55.ld** - Linker script defining memory layout
- **Makefile** - Build configuration
- **run_qemu.sh** - Script to run the program in QEMU

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
- `hello.bin` - Binary file
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
    -serial stdio
```

You should see the output:
```
Hello, World from Cortex-M55!
This is a C++ program running on QEMU
```

To exit QEMU, press `Ctrl+A` then `X`.

## Features

- **C++ Support**: Full C++ compilation with constructors/destructors
- **UART Output**: Prints output via UART0 (115200 baud)
- **Memory Management**: Proper initialization of data, BSS, and stack
- **Exception Handlers**: Minimal exception handler stubs

## Architecture

The program flow:
1. CPU starts at Reset_Handler (from vector table)
2. Stack pointer is loaded
3. Data section is copied from FLASH to RAM
4. BSS section is cleared
5. C++ constructors are called
6. main() is executed
7. Program enters infinite loop
