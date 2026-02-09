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

### Running the Web Server

The project includes a sample web root at `/root/www-root/` with an HTML page describing the project. To start the HTTP server:

```bash
$ httpd /root/www-root
```

Then access the web interface at `http://<device-ip>/` from your browser. The default page provides project information, hardware specs, and links to resources.

## WiFi Configuration

### Using BreezyBox WiFi Commands

The easiest way to configure WiFi is from within the BreezyBox shell. WiFi credentials are stored in NVS (non-volatile storage) and persist across reboots.

**Scan for available networks:**
```bash
$ wifi scan
```

**Connect to a network:**
```bash
$ wifi connect MyNetwork MyPassword
```

For open networks (no password):
```bash
$ wifi connect MyNetwork
```

**Check connection status:**
```bash
$ wifi status
```

**Disconnect from WiFi:**
```bash
$ wifi disconnect
```

**Forget saved credentials:**
```bash
$ wifi forget
```

Once connected, the device will automatically reconnect on subsequent boots.

### Pre-configuring WiFi via menuconfig

You can also configure default WiFi credentials through the ESP-IDF build system. This is useful for automated provisioning or factory configuration.

```bash
idf.py menuconfig
```

Navigate to: `Component config` → `BreezyBox Configuration` (if available) or manually edit `sdkconfig`:

```
CONFIG_BREEZYBOX_WIFI_SSID="YourNetworkName"
CONFIG_BREEZYBOX_WIFI_PASSWORD="YourPassword"
```

Note: Runtime configuration via the `wifi` command takes precedence over any build-time defaults.

### Getting the IP Address

After connecting to WiFi, check the assigned IP address:

```bash
$ wifi status
Connected to: MyNetwork
IP address: 192.168.1.100
```

Use this IP to access the web server or SSH into the device.

## Memory Configuration

The ESP32-S3-N16R8 has two types of RAM:
- **Internal SRAM**: ~400KB usable, very fast (CPU speed)
- **External PSRAM**: 8MB, slower (SPI speed ~80-120MHz)

**This project is pre-configured with the aggressive PSRAM strategy**, providing ~7.5MB of usable RAM for optimal shell and application performance.

### PSRAM Configuration (Already Enabled)

The project comes with PSRAM enabled using aggressive allocation. If you need to modify this:

```bash
idf.py menuconfig
```

Navigate to: `Component config` → `ESP PSRAM`
1. Enable `Support for external, SPI-connected RAM`
2. Select `Octal Mode PSRAM` (required for N16R8 hardware)
3. Choose a memory allocation strategy (see below)

### Memory Allocation Strategies

**Aggressive (Maximum RAM) - CONFIGURED**

This project uses the aggressive strategy by default:
- Normal `malloc()` automatically uses PSRAM
- BSS segment placed in external memory
- WiFi and LWIP buffers in PSRAM
- **Result**: ~7.5MB RAM available, simpler code
- **Best for**: Shell commands, file operations, data processing (perfect for BreezyBox)

**Conservative (Better Performance) - Optional**

If you need to switch to conservative for real-time operations:
- `Component config` → `ESP PSRAM` → `SPI RAM config`
- Set `SPI RAM access method` to `Make RAM allocatable using malloc() with MALLOC_CAP_SPIRAM`
- Keep ~160KB reserved for WiFi/DMA
- **Result**: Fast internal SRAM for critical operations, PSRAM for explicit allocations
- **Use when**: Adding motor control, audio processing, or hard timing requirements

### Performance Tradeoffs: Real-Time Apps vs Command-Line Shell Apps

**Understanding Memory Speed:**

| Memory Type | Speed | Size | Access Time |
|-------------|-------|------|-------------|
| **Internal SRAM** | Very Fast (CPU speed ~240MHz) | ~400KB | Single cycle |
| **External PSRAM** | Slower (SPI ~80-120MHz) | 8MB | 2-3x slower |

**Which Strategy to Use?**

| Application Type | Recommended Strategy | Why? |
|------------------|---------------------|------|
| **Real-Time Apps** (motor control, audio processing, robotics, interrupt-heavy code) | **Conservative** | Critical operations need fast SRAM. Microsecond-level latency matters. Keep interrupt handlers, DMA buffers, and time-critical data in fast internal memory. |
| **Command-Line Shell Apps** (BreezyBox, file managers, web servers, data logging) | **Aggressive** | Human interaction is slow (~100ms scale). File operations, text processing, and shell commands don't need microsecond speed. The 2-3x memory slowdown is imperceptible to users. Benefit: 20x more RAM (8MB vs 400KB). |

**For This BreezyBox Project:**

The **aggressive approach is strongly recommended** because:
- Shell commands execute in milliseconds - PSRAM speed is more than adequate
- File operations benefit from large buffers (can cache entire files in RAM)
- Downloaded ELF apps have access to ~7.5MB instead of ~300KB
- Virtual terminals (4x ~10KB buffers) fit easily in PSRAM
- Simpler code - no need for special `heap_caps_malloc()` calls

**When to use Conservative instead:**
Only if you're adding real-time features like motor control, audio streaming, or hard timing requirements where every microsecond counts.

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
├── components/
│   ├── breezybox/         # BreezyBox shell component (fork)
│   └── webroot/           # Web root initialization component
├── CMakeLists.txt         # Project build configuration
├── partitions.csv         # Partition table
└── sdkconfig              # ESP-IDF configuration
```

## Author

Graham Greenfield <grahamg@gmail.com>

## License

MIT License - see [LICENSE](LICENSE) file for details.
