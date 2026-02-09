# esp32s3-N16R8-breezybox

ESP-IDF project for the Lonely Binary ESP32-S3 N16R8 Gold Edition development board.

![Lonely Binary ESP32-S3 N16R8 Gold Edition](https://lonelybinary.com/cdn/shop/files/09.jpg?v=1755740745)

## About This Project

This project uses **BreezyBox** as a component to provide a Unix-like shell environment on the **ESP32-S3-N16R8** microcontroller. BreezyBox is a BusyBox-inspired interactive command-line interface that works on any ESP32 family chip, offering file operations, networking, scripting, virtual terminals, and ELF program execution.

This specific implementation targets the ESP32-S3 variant with 16MB Flash and 8MB PSRAM (N16R8), utilizing USB Serial JTAG for console access.

## Hardware

**Lonely Binary ESP32-S3 N16R8 Gold Edition**
- Dual-core Xtensa LX7 processor @ 240 MHz
- 16MB Flash memory
- 8MB PSRAM
- 2.4GHz WiFi + Bluetooth 5.0 LE
- Dual USB Type-C ports (power & data)
- Lead-free immersion gold finish PCB

## Prerequisites

- [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/get-started/) v4.4 or later
- Python 3.7+

## Build Instructions

### Linux
```bash
# Install dependencies from component manager
idf.py reconfigure

# Configure project (optional)
idf.py menuconfig

# Build the project
idf.py build

# Flash to device
idf.py -p /dev/ttyUSB0 flash

# Monitor serial output
idf.py -p /dev/ttyUSB0 monitor
```

### macOS
```bash
# Install dependencies from component manager
idf.py reconfigure

# Build the project
idf.py build

# Flash to device (replace cu.* with your actual port)
idf.py -p /dev/cu.usbserial-* flash

# Monitor serial output
idf.py -p /dev/cu.usbserial-* monitor
```

### Windows
```powershell
# Install dependencies from component manager
idf.py reconfigure

# Build the project
idf.py build

# Flash to device (replace COM3 with your actual port)
idf.py -p COM3 flash

# Monitor serial output
idf.py -p COM3 monitor
```

**Note:** Use `idf.py -p PORT flash monitor` to flash and monitor in one command.

## Usage

Once flashed and running, you'll see the BreezyBox shell prompt in your serial console:

```
$
```

Type `help` to see a list of available commands:

```bash
$ help
```

Available commands include file operations (ls, cat, cp, mv, rm), networking (wifi, httpd), system utilities (free, df, date), and more. BreezyBox provides a full Unix-like environment with scripting support, I/O redirection, and the ability to download and execute ELF programs.

### Installing Additional Apps

You can install additional applications from the [breezyapps](https://github.com/valdanylchuk/breezyapps) repository using the `eget` command:

```bash
$ eget valdanylchuk/breezyapps
```

The `eget` command downloads ELF binaries from GitHub releases and makes them executable on your device. Use the format `eget user/repo` to install apps from any compatible repository.

## Memory Configuration

The ESP32-S3-N16R8 has two types of RAM:
- **Internal SRAM**: ~400KB usable, very fast (CPU speed)
- **External PSRAM**: 8MB, slower (SPI speed ~80-120MHz)

### Enabling PSRAM

By default, only internal SRAM is used. To enable the 8MB PSRAM:

```bash
idf.py menuconfig
```

Navigate to: `Component config` → `ESP PSRAM`
1. Enable `Support for external, SPI-connected RAM`
2. Select `Octal Mode PSRAM` (required for N16R8 hardware)
3. Choose a memory allocation strategy (see below)

### Memory Allocation Strategies

**Conservative (Better Performance)**
- `Component config` → `ESP PSRAM` → `SPI RAM config`
- Set `SPI RAM access method` to `Make RAM allocatable using malloc() with MALLOC_CAP_SPIRAM`
- Keep ~160KB reserved for WiFi/DMA
- **Result**: Fast internal SRAM for critical operations, PSRAM for explicit large allocations
- **Use when**: You need low-latency operations or real-time control

**Aggressive (Maximum RAM)**
- `Component config` → `ESP PSRAM` → `SPI RAM config`
- Set `SPI RAM access method` to `Make RAM allocatable using malloc() as well`
- Enable `Allow .bss segment placed in external memory`
- Enable `Try to allocate memories of WiFi and LWIP in SPIRAM firstly`
- **Result**: ~7.5MB RAM available, simpler code (normal malloc uses PSRAM)
- **Use when**: Running shell commands, file operations, or data processing (recommended for BreezyBox)

### Performance Tradeoffs

| Feature | Internal SRAM | PSRAM |
|---------|---------------|-------|
| Speed | Very Fast | 2-3x slower |
| Size | ~400KB | 8MB |
| Best For | Interrupt handlers, DMA, WiFi buffers | File caching, large buffers, application data |

**For BreezyBox shell usage**, the aggressive approach is recommended. Shell commands, file operations, and downloaded ELF apps benefit from maximum available RAM, and the speed difference is negligible for interactive use.

### Checking Memory Usage

After flashing, type `free` in the shell to see memory usage:

```bash
$ free
SRAM:     300K free,    280K min,    400K total
PSRAM:    7.5M free,    7.5M min,    8.0M total
```

## Dependencies

Project uses the following components from ESP-IDF Component Manager:
- `espressif/cmake_utilities`
- `espressif/elf_loader`
- `espressif/zlib`
- `joltwallet/littlefs`
- `valdanylchuk/breezybox`

Dependencies are managed via `dependencies.lock` and installed to `managed_components/` during build.

## Project Structure

```
.
├── main/                   # Application source code
├── components/             # Custom components
├── CMakeLists.txt         # Project build configuration
├── partitions.csv         # Partition table
└── sdkconfig              # ESP-IDF configuration
```

## Author

Graham Greenfield <grahamg@gmail.com>

## License

MIT License - see [LICENSE](LICENSE) file for details.
