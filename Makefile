###
# GNU ARM Embedded Toolchain
CC=arm-none-eabi-gcc
CXX=arm-none-eabi-g++
LD=arm-none-eabi-ld
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
CP=arm-none-eabi-objcopy
OD=arm-none-eabi-objdump
NM=arm-none-eabi-nm
SIZE=arm-none-eabi-size
A2L=arm-none-eabi-addr2line

###
# Directory Structure
BINDIR=bin
INCDIR=inc
SRCDIR=src

###
# Find source files
ASOURCES=$(shell find -L $(SRCDIR) -name '*.s')
CSOURCES=$(shell find -L $(SRCDIR) -name '*.c')
CXXSOURCES=$(shell find -L $(SRCDIR) -name '*.cpp')
# Find header directories
INC=$(shell find -L $(INCDIR) -name '*.h' -exec dirname {} \; | uniq)
INCLUDES=$(INC:%=-I%)
# Find libraries
INCLUDES_LIBS=
LINK_LIBS=
# Create object list
OBJECTS=$(ASOURCES:%.s=%.o)
OBJECTS+=$(CSOURCES:%.c=%.o)
OBJECTS+=$(CXXSOURCES:%.cpp=%.o)
# Define output files ELF & IHEX
BINELF=outp.elf
BINHEX=outp.hex

# Use newlib-nano. To disable it, specify USE_NANO=
USE_NANO=--specs=nano.specs

# Use seimhosting or not
USE_SEMIHOST=--specs=rdimon.specs
USE_NOHOST=--specs=nosys.specs

###
# MCU FLAGS
MCFLAGS=-mcpu=cortex-m4 -mthumb -mlittle-endian \
-mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
# COMPILE FLAGS
DEFS=-DARM_MATH_CM4 -DSTM32F40_41xxx -D__FPU_PRESENT=1
CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -Wall
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11 -Wall
# LINKER FLAGS
LDSCRIPT=sections.ld
LDFLAGS =-T $(LDSCRIPT) $(MCFLAGS) $(INCLUDES_LIBS) $(LINK_LIBS)

###
# Build Rules
.PHONY: all release release-memopt debug clean

all: release-memopt

# release-memopt: DEFS+=-DCUSTOM_NEW -DNO_EXCEPTIONS
release-memopt: CFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin # -flto
release-memopt: CXXFLAGS+=-Os -fno-exceptions -ffunction-sections -fdata-sections -fno-builtin -fno-rtti # -flto
release-memopt: LDFLAGS+=-Os -Wl,-gc-sections # -flto
release-memopt: release

debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=$(USE_NANO) $(USE_SEMIHOST) -g
debug: release-memopt

release: LDFLAGS+=$(USE_NOHOST)
release: $(BINDIR)/$(BINHEX)

$(BINDIR)/$(BINHEX): $(BINDIR)/$(BINELF)
	$(CP) -O ihex $< $@
	@echo "Objcopy from ELF to IHEX complete!\n"

##
# C++ linking is used.
#
# Change
#   $(CXX) $(OBJECTS) $(LDFLAGS) -o $@ to 
#   $(CC) $(OBJECTS) $(LDFLAGS) -o $@ if
#   C linker is required.
$(BINDIR)/$(BINELF): $(OBJECTS)
	@$(CXX) $(OBJECTS) $(LDFLAGS) -o $@
	@echo "Linking complete\n"
	$(SIZE) $(BINDIR)/$(BINELF)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo "Compiled "$<"\n"

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@
	@echo "Compiled "$<"\n"

%.o: %.s
	$(CC) $(CFLAGS) $< -o $@
	@echo "Assambled "$<"\n"

clean:
	@rm -f $(OBJECTS) $(BINDIR)/$(BINELF) $(BINDIR)/$(BINHEX) $(BINDIR)/output.map
	@echo "Clean Finish "$<""
