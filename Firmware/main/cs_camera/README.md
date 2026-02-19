# CS Camera - Modular Firmware Structure

## Project Structure

```
Firmware/main/
├── main.c                       # Main entry point
├── CMakeLists.txt              # Root build configuration
├── pico_sdk_import.cmake       # Pico SDK import
│
├── modules/
│   ├── storage/                # SD Card Module
│   │   ├── sd_storage.h        # Storage API
│   │   ├── sd_storage.c        # Storage implementation
│   │   ├── hw_config.h         # SD card hardware config
│   │   ├── hw_config.c
│   │   └── CMakeLists.txt      # Builds 'storage' library
│   │
│   ├── sensor/                 # Photodiode/ADC Module
│   │   ├── photodiode.h        # Sensor API
│   │   ├── photodiode.c        # Sensor implementation
│   │   └── CMakeLists.txt      # Builds 'sensor' library
│   │
│   └── display/                # LCD Display Module
│       ├── lcd_driver.h        # Display API
│       ├── lcd_driver.c        # Display implementation (stub)
│       └── CMakeLists.txt      # Builds 'display' library
│
└── ../lib/
    └── no-OS-FatFS/            # External FatFS library (shared)
```

## How It Works

### Single Project, Multiple Modules
- **One** Pico project with **one** root `CMakeLists.txt`
- Each module is a **library** (not a separate project)
- All modules compile together into **one** `.uf2` file

### Module Independence
- **Storage**: Handles SD card, file system, data logging
- **Sensor**: Handles photodiode ADC sampling
- **Display**: Handles LCD graphics and rendering
- **Main**: Coordinates all modules, implements application logic

### Clean Interfaces
Each module exposes a simple API:
- `module_init()` - Initialize the module
- `module_*()` - Module-specific functions
- Modules don't depend on each other

## Building the Project

### Using VS Code Pico Extension

1. **Open the main folder** in VS Code:
   - File → Open Folder → Select `Firmware/main/`

2. **Configure the project**:
   - Pico extension should detect the project automatically
   - Select Pico2 board if prompted

3. **Compile**:
   - Click "Compile" in the Pico extension
   - Or use CMake Tools extension

4. **Flash to Pico**:
   - Hold BOOTSEL button, connect Pico
   - Copy `build/cs_camera.uf2` to the Pico drive

### Manual Build

```bash
cd Firmware/main
mkdir build
cd build
cmake ..
make
```

## Module APIs

### Storage Module
```c
#include "modules/storage/sd_storage.h"

bool storage_init(void);
int storage_write_file(const char *filename, const void *data, uint32_t size);
int storage_append_file(const char *filename, const void *data, uint32_t size);
```

### Sensor Module
```c
#include "modules/sensor/photodiode.h"

bool sensor_init(void);
uint16_t sensor_read_sample(void);
uint16_t sensor_read_voltage_mv(void);
```

### Display Module
```c
#include "modules/display/lcd_driver.h"

bool display_init(void);
void display_clear(uint16_t color);
void display_text(uint16_t x, uint16_t y, const char *text, uint16_t color);
```

## Next Steps

### Display Module
The display module is currently a **stub**. To implement:
1. Determine your LCD type (ST7735, ILI9341, etc.)
2. Add LCD driver library or implement SPI communication
3. Update `lcd_driver.c` with actual initialization and drawing

### Sensor Module
- Currently implements basic ADC reading
- TODO: Add DMA-based continuous sampling
- TODO: Add data buffering for high-speed acquisition

### Storage Module
- Fully functional for basic file operations
- Tested with FatFS library
- Ready for data logging

## Pin Configuration

### SD Card (SPI1)
- GPIO 10: SCK
- GPIO 11: MOSI
- GPIO 12: MISO
- GPIO 13: CS

### Photodiode
- GPIO 26: ADC0 (Analog input)

### LCD (To be configured)
- TBD based on your LCD module

## Adding New Modules

1. Create folder: `modules/new_module/`
2. Create files: `new_module.h`, `new_module.c`, `CMakeLists.txt`
3. In module `CMakeLists.txt`:
   ```cmake
   add_library(new_module STATIC new_module.c)
   target_include_directories(new_module PUBLIC ${CMAKE_CURRENT_LIST_DIR})
   target_link_libraries(new_module pico_stdlib)
   ```
4. In root `CMakeLists.txt`:
   ```cmake
   add_subdirectory(modules/new_module)
   target_link_libraries(cs_camera new_module)
   ```
