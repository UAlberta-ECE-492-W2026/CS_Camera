# Display Module CMakeLists

add_library(display STATIC
    lcd_driver.c
)

target_include_directories(display PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(display
    pico_stdlib
    hardware_spi
)
