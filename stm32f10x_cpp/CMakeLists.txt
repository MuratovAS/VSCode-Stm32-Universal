cmake_minimum_required(VERSION 3.5.0)

########## Настройки
project(stm32f10x_cpp CXX C ASM)

# Дерективы препроцессора, нужные для библиотеки.
add_definitions(-DSTM32F103xB)

########## Build
if(FLASH_SECTION STREQUAL "Boot")
   include(Boot/Boot.cmake)
elseif(FLASH_SECTION STREQUAL "App")
   include(App/App.cmake)
endif()

########## Sys
#include(cmake/CompilerSelectro.cmake)

if(CMAKE_BUILD_TYPE STREQUAL "Release")

elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
   add_definitions(-DDEBUG)
endif()
