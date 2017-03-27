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

PROJECT_TOP=$(shell pwd)

include $(PROJECT_TOP)/build/$(ARCHOPTS)/arch.mk
include $(PROJECT_TOP)/build/kernel.mk
include $(PROJECT_TOP)/src/project.mk

OBJECTS=$(ASOURCES:%.s=%.o)
OBJECTS+=$(CSOURCES:%.c=%.o)
OBJECTS+=$(CXXSOURCES:%.cpp=%.o)

BINDIR=$(PROJECT_TOP)/bin
BINELF=outp.elf
BINHEX=outp.hex


USE_NANO=--specs=nano.specs
USE_SEMIHOST=--specs=rdimon.specs
USE_NOHOST=--specs=nosys.specs

INCLUDES=$(INC:%=-I%)

CFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -Wall
CXXFLAGS=-c $(MCFLAGS) $(DEFS) $(INCLUDES) -std=c++11 -Wall

LDFLAGS =-T $(LDSCRIPT) $(MCFLAGS)

CFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin
CXXFLAGS+=-Os -fno-exceptions -ffunction-sections -fdata-sections -fno-builtin -fno-rtti
LDFLAGS+=-Os -Wl,-gc-sections


.PHONY: all release debug clean

all: release

memopt: CFLAGS+=-Os -ffunction-sections -fdata-sections -fno-builtin
memopt: CXXFLAGS+=-Os -fno-exceptions -ffunction-sections -fdata-sections -fno-builtin -fno-rtti
memopt: LDFLAGS+=-Os -Wl,-gc-sections
memopt: $(BINDIR)/$(BINHEX)

debug: CFLAGS+=-g
debug: CXXFLAGS+=-g
debug: LDFLAGS+=$(USE_NANO) $(USE_SEMIHOST) -g
debug: memopt

release: LDFLAGS+=$(USE_NOHOST)
release: memopt

$(BINDIR)/$(BINHEX): $(BINDIR)/$(BINELF)
	$(CP) -O ihex $< $@
	@echo "Objcopy from ELF to IHEX complete!\n"

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