# Windows Support for Tokenizers

This document provides detailed instructions for building and using the tokenizers library on Windows.

## Prerequisites

### Required Software

1. **Rust Toolchain**
   - Install from [rustup.rs](https://rustup.rs/)
   - Ensure you have the MSVC toolchain: `rustup default stable-x86_64-pc-windows-msvc`

2. **Visual Studio Build Tools**
   - Install [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
   - Or install Visual Studio Community/Professional with C++ development tools
   - Required for the MSVC linker

3. **Go Programming Language**
   - Install from [golang.org](https://golang.org/dl/)
   - Version 1.18 or later

### Optional Software

- **Git** for cloning the repository
- **Make** (if you want to use Makefiles) - available through chocolatey, scoop, or WSL

## Building the Library

### Method 1: Using PowerShell Script (Recommended)

```powershell
# Clone the repository
git clone https://github.com/daulet/tokenizers.git
cd tokenizers

# Build for x86_64 (default)
.\build.ps1

# Build for ARM64
.\build.ps1 -Target aarch64-pc-windows-msvc

# Get help
.\build.ps1 -Help
```

### Method 2: Using Batch Script

```cmd
REM Clone the repository
git clone https://github.com/daulet/tokenizers.git
cd tokenizers

REM Build for x86_64 (default)
build.bat

REM Build for ARM64
build.bat --target aarch64-pc-windows-msvc

REM Get help
build.bat --help
```

### Method 3: Manual Build

```cmd
REM Install the target (if not already installed)
rustup target add x86_64-pc-windows-msvc

REM Build the Rust library
cargo build --release --target x86_64-pc-windows-msvc

REM Copy the library
copy target\x86_64-pc-windows-msvc\release\tokenizers.lib libtokenizers.lib

REM Build the Go bindings
set CGO_LDFLAGS=-L.
go build .
```

### Method 4: Using Make (if available)

```cmd
REM Build for current platform
make build

REM Build specifically for Windows
make build-windows

REM Clean build artifacts
make clean
```

## Supported Architectures

- **x86_64** (Intel/AMD 64-bit) - `x86_64-pc-windows-msvc`
- **ARM64** (ARM 64-bit) - `aarch64-pc-windows-msvc`

## Using Pre-built Binaries

Download pre-built libraries from the [releases page](https://github.com/daulet/tokenizers/releases):

- [Windows AMD64](https://github.com/daulet/tokenizers/releases/latest/download/libtokenizers.windows-amd64.tar.gz)
- [Windows ARM64](https://github.com/daulet/tokenizers/releases/latest/download/libtokenizers.windows-arm64.tar.gz)

Extract the archive and place `libtokenizers.lib` in your project directory.

## Environment Variables

Set the following environment variables for easier development:

```cmd
REM Set the library path
set CGO_LDFLAGS=-L.

REM Or set it permanently
setx CGO_LDFLAGS "-L."
```

## Running Tests

```cmd
REM Run all tests
go test -ldflags="-extldflags '-L.'" -v ./... -count=1

REM Run Windows-specific tests
go test -ldflags="-extldflags '-L.'" -v -tags windows ./... -count=1

REM Run benchmarks
go test -ldflags="-extldflags '-L.'" -bench=. -benchmem -benchtime=10s
```

## Troubleshooting

### Common Issues

1. **"cargo: command not found"**
   - Ensure Rust is installed and in your PATH
   - Restart your terminal after installation

2. **"MSVC linker not found"**
   - Install Visual Studio Build Tools
   - Ensure the MSVC toolchain is selected: `rustup default stable-x86_64-pc-windows-msvc`

3. **"cgo: C compiler not found"**
   - Install Visual Studio Build Tools with C++ development tools
   - Ensure `cl.exe` is in your PATH

4. **"cannot find -ltokenizers"**
   - Ensure `libtokenizers.lib` is in the current directory or set `CGO_LDFLAGS` correctly
   - Check that the library was built successfully

5. **"undefined reference" errors**
   - Ensure you're using the correct Windows system libraries
   - The CGO flags should include Windows-specific libraries

### Debug Build

For debugging, you can build without optimizations:

```cmd
cargo build --target x86_64-pc-windows-msvc
copy target\x86_64-pc-windows-msvc\debug\tokenizers.lib libtokenizers.lib
```

### Cross-compilation

To build for ARM64 on an x86_64 machine:

```cmd
rustup target add aarch64-pc-windows-msvc
cargo build --release --target aarch64-pc-windows-msvc
```

## Integration with IDEs

### Visual Studio Code

Add to your `.vscode/settings.json`:

```json
{
    "go.buildFlags": ["-ldflags", "-extldflags '-L.'"],
    "go.testFlags": ["-ldflags", "-extldflags '-L.'"]
}
```

### GoLand/IntelliJ

Set build flags in Run/Debug configurations:
- Build flags: `-ldflags="-extldflags '-L.'"`

## Performance Notes

- The Windows build uses static linking for better performance
- MSVC optimizations are enabled by default in release builds
- Consider using the native Windows allocator for better memory performance

## Contributing

When contributing Windows-specific changes:

1. Test on both x86_64 and ARM64 if possible
2. Update this documentation if needed
3. Ensure CI/CD passes for Windows builds
4. Follow the existing code style and patterns

## Support

For Windows-specific issues:

1. Check this documentation first
2. Search existing GitHub issues
3. Create a new issue with:
   - Windows version
   - Architecture (x86_64/ARM64)
   - Rust version (`rustc --version`)
   - Go version (`go version`)
   - Complete error messages
