# Makefile for password_manager

# Compiler and flags
CC = gcc
# Force x86_64 architecture for compatibility with Berkeley DB
CFLAGS = -Wall -Wextra -O2 -arch x86_64
# Add Berkeley DB include path (keg-only installation via Homebrew)
CPPFLAGS = -I/usr/local/opt/berkeley-db/include
# Add Berkeley DB library path (keg-only installation via Homebrew)
LDFLAGS = -L/usr/local/opt/berkeley-db/lib
LIBS = -ldb

# Target executable
TARGET = password_manager

# Source files
SRC = password_manager.c

# Build directories
BUILD_DIR = build
STATIC_DIR = $(BUILD_DIR)/static
DEBUG_DIR = $(BUILD_DIR)/debug

# Default target
all: $(TARGET)

# Regular build (dynamic linking)
$(TARGET): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $(BUILD_DIR)/$(TARGET) $(SRC) $(LDFLAGS) $(LIBS)
	@ln -sf $(BUILD_DIR)/$(TARGET) $(TARGET)
	@echo "Built $(TARGET) with dynamic linking"

# Static build
static: $(SRC)
	@mkdir -p $(STATIC_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $(STATIC_DIR)/$(TARGET) $(SRC) $(LDFLAGS) -static-libgcc $(LIBS)
	@ln -sf $(STATIC_DIR)/$(TARGET) $(TARGET)
	@echo "Built $(TARGET) with static linking"

# Debug build
debug: CFLAGS += -g -DDEBUG
debug: $(SRC)
	@mkdir -p $(DEBUG_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $(DEBUG_DIR)/$(TARGET) $(SRC) $(LDFLAGS) $(LIBS)
	@ln -sf $(DEBUG_DIR)/$(TARGET) $(TARGET)
	@echo "Built $(TARGET) in debug mode"

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TARGET)
	@echo "Cleaned build files"

# Install to system (requires sudo)
install: $(TARGET)
	install -m 755 $(BUILD_DIR)/$(TARGET) /usr/local/bin/
	@echo "Installed $(TARGET) to /usr/local/bin/"

# Help target
help:
	@echo "Available targets:"
	@echo "  all     : Build the password manager with dynamic linking (default)"
	@echo "  static  : Build the password manager with static linking"
	@echo "  debug   : Build with debug symbols"
	@echo "  clean   : Remove build files"
	@echo "  install : Install to /usr/local/bin (requires sudo)"
	@echo "  help    : Display this help message"

.PHONY: all static debug clean install help
EOFq






exit
'
