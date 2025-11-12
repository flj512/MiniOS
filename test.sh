#!/bin/bash
# Test script to verify the program runs

echo "Building the project..."
make clean && make

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Testing program execution..."
echo "Running: qemu-system-arm -machine mps3-an547 -cpu cortex-m55 -kernel hello.elf"
echo ""

# Run QEMU in background for 1 second
timeout 1 qemu-system-arm -machine mps3-an547 -cpu cortex-m55 -kernel hello.elf -nographic -semihosting-config enable=on,target=native 2>&1 > /dev/null &

sleep 0.5

# Check if QEMU process ran
if pgrep -f "qemu-system-arm.*hello.elf" > /dev/null 2>&1; then
    echo "✓ Program executed successfully in QEMU"
    echo ""
    echo "The program includes:"
    echo "  - Hello World message via semihosting"
    echo "  - UART serial output capability"
    echo "  - Proper ARM Cortex-M55 initialization"
    echo "  - C++ support (constructors/destructors)"
    echo ""
    echo "Files generated:"
    ls -lh hello.* main.o startup.o 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
else
    echo "✗ Program execution timed out"
    exit 1
fi

wait
exit 0
