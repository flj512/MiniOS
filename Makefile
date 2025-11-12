TOOLCHAIN := arm-none-eabi
CC := $(TOOLCHAIN)-gcc
CXX := $(TOOLCHAIN)-g++
LD := $(TOOLCHAIN)-ld
OBJCOPY := $(TOOLCHAIN)-objcopy
OBJDUMP := $(TOOLCHAIN)-objdump
SIZE := $(TOOLCHAIN)-size

# Target: Cortex-M55
MARCH := -march=armv8.1-m.main+dsp
MTHUMB := -mthumb
MFPU := -mfpu=fpv5-sp-d16 -mfloat-abi=hard

# Compiler flags
TARGET_FLAGS := $(MARCH) $(MTHUMB) $(MFPU)
CFLAGS :=  ${TARGET_FLAGS} -Wall -O0 -g -I./cmsis/CMSIS/Core/Include
CXXFLAGS := $(CFLAGS) -fno-exceptions -fno-rtti
LDFLAGS :=  -nostartfiles -nodefaultlibs -nostdlib -T cortex_m55.ld --specs=nano.specs --specs=rdimon.specs -Wl,-Map=hello.map -Wl,--gc-sections -Wl,--print-memory-usage
LDLIBS :=   -Wl,--start-group -lc -lgcc -lrdimon -lstdc++ -lm -Wl,--end-group

# Source files
SRCS_C := impl.c os.c
SRCS_CXX := main.cpp
SRCS_S := startup.s

# Object files
OBJS_C := $(SRCS_C:.c=.o)
OBJS_CXX := $(SRCS_CXX:.cpp=.o)
OBJS_S := $(SRCS_S:.s=.o)
OBJS := $(OBJS_C) $(OBJS_CXX) $(OBJS_S)

# Output files
TARGET := hello.elf
TARGET_HEX := hello.hex

# Default target
all: $(TARGET) $(TARGET_HEX)

# Build rules
$(TARGET): $(OBJS)
	@echo "Linking $@..."
	$(CXX) $(TARGET_FLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)


$(TARGET_HEX): $(TARGET)
	@echo "Creating hex $@..."
	$(OBJCOPY) -O ihex $< $@

%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	@echo "Compiling $<..."
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o: %.s
	@echo "Assembling $<..."
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	@echo "Cleaning..."
	rm -f $(OBJS) $(TARGET) $(TARGET_HEX) hello.map

.PHONY: all clean
