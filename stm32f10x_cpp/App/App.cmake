########## Настройки

SET(LD_HEADER "_app_addr = ORIGIN(FLASH);")

# Адрес стека - конец оперативки => 0x20000000 + размер оперативки
SET(STM32_STACK_ADDRESS "0x20005000")
# Размера RAM и Flash
SET(STM32_FLASH_SIZE "44K")
SET(STM32_RAM_SIZE "20K")
# Адреса RAM и Flash
SET(STM32_FLASH_ORIGIN "0x08005000")
SET(STM32_RAM_ORIGIN "0x20000000")

########## Исходники
# Code
file(GLOB_RECURSE APP_CORE_SOURCES	"App/Core/Src/*.c")
file(GLOB_RECURSE APP_USER_SOURCES	"App/User/Src/*.c"  "App/User/Src/*.cpp")

include_directories(App/Core/Inc)
include_directories(App/User/Inc)

# lib
#file(GLOB_RECURSE APP_USER_LIB		"App/Lib/*/Src/*.c" "App/Lib/*/Src/*.cpp") #Automatic library initialization (I recommend not to use)
file(GLOB_RECURSE LIB_SecToMSec		"App/Lib/SecToMSec/Src/*.c" "App/Lib/SecToMSec/Src/*.cpp") 

#include_directories(App/Lib/*/Inc) #Automatic library initialization (I recommend not to use)
include_directories(App/Lib/SecToMSec/Inc) 

add_library(SecToMSec         ${LIB_SecToMSec})

# Driver
file(GLOB_RECURSE APP_HAL_SOURCES	"App/Drivers/STM32F1xx_HAL_Driver/Src/*.c")

include_directories(App/Drivers/STM32F1xx_HAL_Driver/Inc)
include_directories(App/Drivers/CMSIS/Include)
include_directories(App/Drivers/CMSIS/Device/ST/STM32F1xx/Include)

add_library(APP_HAL 	${APP_HAL_SOURCES})
add_library(APP_CMSIS	App/Core/Src/system_stm32f1xx.c
						App/startup_stm32f103xb.s)

########## Build
include(${PROJECT_SOURCE_DIR}/cmake/stm32f103.cmake)

# Конфигурируем файл - скрипт компилятора: заменяем переменные в файле на размеры и адреса 
CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/STM32F103C8Tx_FLASH.ld.in ${CMAKE_CURRENT_BINARY_DIR}/APP_STM32F103C8Tx_FLASH.ld)
SET(APP_LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/build/APP_STM32F103C8Tx_FLASH.ld)

#
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(LINKER_FLAGS "-lc -lrdimon -u _printf_float")
else()
	set(LINKER_RELEASE ",-flto")
endif()

# Конфигурируем файл - скрипт компилятора: заменяем переменные в файле на размеры и адреса 
#set(CMAKE_EXE_LINKER_FLAGS "-Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/APP_${PROJECT_NAME}.map,-gc-sections,-gc-sections -specs=nosys.specs -specs=nano.specs -T ${APP_LINKER_SCRIPT}")
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/APP_${PROJECT_NAME}.map,--gc-sections,--undefined=uxTopUsedPriority,--print-memory-usage${LINKER_RELEASE} -T ${APP_LINKER_SCRIPT} ${LINKER_FLAGS}")
#

# Собираем исходники пректа, модули, и т.д. в elf
add_executable(APP_${PROJECT_NAME}.elf ${APP_CORE_SOURCES} ${APP_USER_SOURCES} ${APP_USER_LIB})
target_link_libraries(APP_${PROJECT_NAME}.elf APP_HAL APP_CMSIS SecToMSec)#Не забыть добавить Lib

# Конвертируем elf в hex и bin
set(APP_HEX_FILE ${CMAKE_CURRENT_BINARY_DIR}/APP_${PROJECT_NAME}.hex)
set(APP_BIN_FILE ${CMAKE_CURRENT_BINARY_DIR}/APP_${PROJECT_NAME}.bin)
add_custom_command(TARGET APP_${PROJECT_NAME}.elf POST_BUILD
		COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:APP_${PROJECT_NAME}.elf> ${APP_HEX_FILE}
		COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:APP_${PROJECT_NAME}.elf> ${APP_BIN_FILE}
		COMMENT "Building ${APP_HEX_FILE} \nBuilding ${APP_BIN_FILE}")

