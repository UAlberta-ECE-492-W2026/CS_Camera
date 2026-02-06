# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.2.0)
set(toolchainVersion 14_2_Rel1)
set(picotoolVersion 2.2.0-a4)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico2 CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(sd_card_reading C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1

add_executable(sd_card_reading 
    sd_card_reading.c 
    hw_config.c
)

# add subdirectories
add_subdirectory(lib/no-OS-FatFS/FatFs_SPI build) 


pico_set_program_name(sd_card_reading "sd_card_reading")
pico_set_program_version(sd_card_reading "0.1")

# Modify the below lines to enable/disable output over UART/USB
# WE DISABLED UART OUTPUT HERE
pico_enable_stdio_uart(sd_card_reading 0)
pico_enable_stdio_usb(sd_card_reading 1)

# Add the standard library to the build 
target_link_libraries(sd_card_reading 
        pico_stdlib
        FatFs_SPI
)

# Add the standard include files to the build
target_include_directories(sd_card_reading PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

pico_add_extra_outputs(sd_card_reading)

