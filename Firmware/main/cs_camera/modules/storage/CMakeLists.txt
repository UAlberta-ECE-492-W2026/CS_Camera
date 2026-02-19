# Storage Module CMakeLists

add_library(storage STATIC
    sd_storage.c
    hw_config.c
)

target_include_directories(storage PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(storage
    pico_stdlib
    FatFs_SPI
)
