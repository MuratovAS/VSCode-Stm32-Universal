########## Настройки

SET(LD_HEADER "")

# Адрес стека - конец оперативки => 0x20000000 + размер оперативки
SET(STM32_STACK_ADDRESS "0x20005000")
# Размера RAM и Flash
SET(STM32_FLASH_SIZE "20K")
SET(STM32_RAM_SIZE "20K")
# Адреса RAM и Flash
SET(STM32_FLASH_ORIGIN "0x08000000")
SET(STM32_RAM_ORIGIN "0x20000000")

########## Исходники
# Code
file(GLOB_RECURSE BOOT_CORE_SOURCES  "Boot/Core/Src/*.c")
file(GLOB_RECURSE BOOT_USER_SOURCES  "Boot/User/Src/*.c"  "Boot/User/Src/*.cpp")

include_directories(Boot/Core/Inc)
include_directories(Boot/User/Inc)

# lib
#file(GLOB_RECURSE BOOT_USER_LIB	"Boot/Lib/*/Src/*.c" "Boot/Lib/*/Src/*.cpp") #Automatic library initialization (I recommend not to use)
#include_directories(Boot/Lib/*/Inc) #Automatic library initialization (I recommend not to use)
#add_library(BOOT_USER_LIB         ${BOOT_USER_LIB})

# Driver
file(GLOB_RECURSE BOOT_HAL_SOURCES "Boot/Drivers/STM32F1xx_HAL_Driver/Src/*.c")

include_directories(Boot/Drivers/STM32F1xx_HAL_Driver/Inc)
include_directories(Boot/Drivers/CMSIS/Include)
include_directories(Boot/Drivers/CMSIS/Device/ST/STM32F1xx/Include)

add_library(BOOT_HAL	${BOOT_HAL_SOURCES})
add_library(BOOT_CMSIS	Boot/Core/Src/system_stm32f1xx.c
						Boot/startup_stm32f103xb.s)


########## Build
include(${PROJECT_SOURCE_DIR}/cmake/stm32f103.cmake)

# Конфигурируем файл - скрипт компилятора: заменяем переменные в файле на размеры и адреса 
CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/STM32F103C8Tx_FLASH.ld.in ${CMAKE_CURRENT_BINARY_DIR}/BOOT_STM32F103C8Tx_FLASH.ld)
SET(BOOT_LINKER_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/BOOT_STM32F103C8Tx_FLASH.ld)

#
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(LINKER_FLAGS "-lc -lrdimon -u _printf_float")
else()
	set(LINKER_RELEASE ",-flto")
endif()

# Конфигурируем файл - скрипт компилятора: заменяем переменные в файле на размеры и адреса 
#set(CMAKE_EXE_LINKER_FLAGS "-Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/APP_${PROJECT_NAME}.map,-gc-sections,-gc-sections -specs=nosys.specs -specs=nano.specs -T ${BOOT_LINKER_SCRIPT}")
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/APP_${PROJECT_NAME}.map,--gc-sections,--undefined=uxTopUsedPriority,--print-memory-usage${LINKER_RELEASE} -T ${BOOT_LINKER_SCRIPT} ${LINKER_FLAGS}")
#

# Собираем исходники пректа, модули, и т.д. в elf
add_executable(BOOT_${PROJECT_NAME}.elf ${BOOT_CORE_SOURCES} ${BOOT_USER_SOURCES} ${BOOT_USER_LIB} ${BOOT_LINKER_SCRIPT})
target_link_libraries(BOOT_${PROJECT_NAME}.elf BOOT_HAL BOOT_CMSIS)#Не забыть добавить Lib

# Конвертируем elf в hex и bin
set(BOOT_HEX_FILE ${CMAKE_CURRENT_BINARY_DIR}/BOOT_${PROJECT_NAME}.hex)
set(BOOT_BIN_FILE ${CMAKE_CURRENT_BINARY_DIR}/BOOT_${PROJECT_NAME}.bin)
add_custom_command(TARGET BOOT_${PROJECT_NAME}.elf POST_BUILD
		COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:BOOT_${PROJECT_NAME}.elf> ${BOOT_HEX_FILE}
		COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:BOOT_${PROJECT_NAME}.elf> ${BOOT_BIN_FILE}
		COMMENT "Building ${BOOT_HEX_FILE} \nBuilding ${BOOT_BIN_FILE}")

