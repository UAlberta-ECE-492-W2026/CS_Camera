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

project(cs_camera C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()
add_subdirectory(lib/no-OS-FatFS/FatFs_SPI build)
# Add modules 
# add subdirectory for each module to be included in the build 
add_subdirectory(modules/display)
add_subdirectory(modules/sensor)
add_subdirectory(modules/storage)

# Add executable. Default name is the project name, version 0.1

add_executable(cs_camera cs_camera.c)
pico_set_program_name(cs_camera "cs_camera")
pico_set_program_version(cs_camera "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(cs_camera 0)
pico_enable_stdio_usb(cs_camera 1)

# Add the standard library to the build
# we add the display, sensor and storage modules as dependencies to ensure they are built before the main executable
target_link_libraries(cs_camera
        pico_stdlib
        FatFs_SPI
        display
        sensor
        storage
)

# Add the standard include files to the build
target_include_directories(cs_camera PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

pico_add_extra_outputs(cs_camera)

