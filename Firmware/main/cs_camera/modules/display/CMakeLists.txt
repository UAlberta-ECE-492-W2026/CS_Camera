add_library(display STATIC
    lcd_controller.c
    WalshMaskGenerator.c
)

target_include_directories(display PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(display
    pico_stdlib
    hardware_spi
    pico_st7789
)

# rest of your project
add_executable(display_test
    display_test.c
    lcd_controller.c
    WalshMaskGenerator.c
)

target_link_libraries(display_test
    pico_stdlib
    pico_rand
    hardware_spi
    pico_st7789
)

pico_enable_stdio_uart(display_test 0)
pico_enable_stdio_usb(display_test 1)

pico_add_extra_outputs(display_test)