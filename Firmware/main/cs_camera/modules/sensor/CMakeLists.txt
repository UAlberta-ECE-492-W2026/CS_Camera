# Sensor Module CMakeLists

add_library(sensor STATIC
    photodiode.c
)

target_include_directories(sensor PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(sensor
    pico_stdlib
    hardware_adc
)
