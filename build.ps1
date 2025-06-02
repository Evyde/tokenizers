# PowerShell build script for Windows
# This script builds the tokenizers library for Windows

param(
    [string]$Target = "x86_64-pc-windows-msvc",
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\build.ps1 [-Target <target>] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Target    Rust target triple (default: x86_64-pc-windows-msvc)"
    Write-Host "             Supported targets:"
    Write-Host "             - x86_64-pc-windows-msvc (64-bit Intel/AMD)"
    Write-Host "             - aarch64-pc-windows-msvc (64-bit ARM)"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build.ps1"
    Write-Host "  .\build.ps1 -Target aarch64-pc-windows-msvc"
    exit 0
}

Write-Host "Building tokenizers library for Windows..."
Write-Host "Target: $Target"

# Check if Rust is installed
try {
    $rustVersion = cargo --version
    Write-Host "Found Rust: $rustVersion"
} catch {
    Write-Error "Rust is not installed or not in PATH. Please install Rust from https://rustup.rs/"
    exit 1
}

# Check if target is installed
$installedTargets = rustup target list --installed
if ($installedTargets -notcontains $Target) {
    Write-Host "Installing target $Target..."
    rustup target add $Target
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install target $Target"
        exit 1
    }
}

# Build the library
Write-Host "Building library..."
cargo build --release --target $Target
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit 1
}

# Copy the library to the root directory
$libPath = "target\$Target\release\tokenizers.lib"
if (Test-Path $libPath) {
    Copy-Item $libPath "libtokenizers.lib"
    Write-Host "Library built successfully: libtokenizers.lib"
} else {
    Write-Error "Library not found at $libPath"
    exit 1
}

# Test the Go bindings
Write-Host "Testing Go bindings..."
$env:CGO_LDFLAGS = "-L."
go build .
if ($LASTEXITCODE -ne 0) {
    Write-Error "Go build failed"
    exit 1
}

Write-Host "Build completed successfully!"
Write-Host "You can now use the library with: go run -ldflags=`"-extldflags '-L.'`" your_program.go"
