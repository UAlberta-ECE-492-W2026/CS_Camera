add_library(display STATIC
    lcd_controller.c
)

target_include_directories(display PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(display
    pico_stdlib
    hardware_spi
    pico_st7789
)