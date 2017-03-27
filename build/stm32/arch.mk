MCFLAGS+=-mcpu=cortex-m4 -mthumb -mlittle-endian \
-mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork
DEFS+=-DARM_MATH_CM4 -DSTM32F40_41xxx -D__FPU_PRESENT=1

LDSCRIPT+=$(PROJECT_TOP)/arch/stm32/script/sections.ld
ASOURCES+=$(shell find -L $(PROJECT_TOP)/arch/stm32/source -name '*.s')
CSOURCES+=$(shell find -L $(PROJECT_TOP)/arch/stm32/source -name '*.c')

INC+=$(PROJECT_TOP)/arch/stm32/include/cpu
INC+=$(PROJECT_TOP)/arch/stm32/include/kernel