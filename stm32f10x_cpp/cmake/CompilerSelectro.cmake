SET(CMAKE_SYSTEM_NAME Cortex)
SET(CMAKE_SYSTEM_VERSION 1)

set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(AS arm-none-eabi-as)
set(AR arm-none-eabi-ar)
set(OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_OBJCOPY ${OBJCOPY})
set(OBJDUMP arm-none-eabi-objdump)
set(SIZE arm-none-eabi-size)