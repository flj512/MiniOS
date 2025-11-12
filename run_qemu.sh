#!/bin/bash
# Script to run the program in QEMU Cortex-M55 simulator

QEMU=qemu-system-arm
ELF_IMAGE=hello.elf

# Check if ELF image exists
if [ ! -f "$ELF_IMAGE" ]; then
    echo "Error: $ELF_IMAGE not found. Please build the project first with 'make'."
    exit 1
fi


# Run QEMU with Cortex-M55
# Use semihosting and ensure exit codes are properly handled
$QEMU -machine mps3-an547 -cpu cortex-m55 \
    -kernel "$ELF_IMAGE" \
    -nographic \
    -semihosting

echo "return value $?"
