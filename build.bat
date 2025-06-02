@echo off
REM Batch build script for Windows
REM This script builds the tokenizers library for Windows

setlocal enabledelayedexpansion

set TARGET=x86_64-pc-windows-msvc
set SHOW_HELP=0

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :start_build
if /i "%~1"=="--help" set SHOW_HELP=1
if /i "%~1"=="-h" set SHOW_HELP=1
if /i "%~1"=="--target" (
    set TARGET=%~2
    shift
)
shift
goto :parse_args

:start_build
if %SHOW_HELP%==1 (
    echo Usage: build.bat [--target ^<target^>] [--help]
    echo.
    echo Options:
    echo   --target    Rust target triple ^(default: x86_64-pc-windows-msvc^)
    echo               Supported targets:
    echo               - x86_64-pc-windows-msvc ^(64-bit Intel/AMD^)
    echo               - aarch64-pc-windows-msvc ^(64-bit ARM^)
    echo   --help      Show this help message
    echo.
    echo Examples:
    echo   build.bat
    echo   build.bat --target aarch64-pc-windows-msvc
    goto :end
)

echo Building tokenizers library for Windows...
echo Target: %TARGET%

REM Check if Rust is installed
cargo --version >nul 2>&1
if errorlevel 1 (
    echo Error: Rust is not installed or not in PATH. Please install Rust from https://rustup.rs/
    exit /b 1
)

for /f "tokens=*" %%i in ('cargo --version') do set RUST_VERSION=%%i
echo Found Rust: %RUST_VERSION%

REM Check if target is installed
rustup target list --installed | findstr /c:"%TARGET%" >nul
if errorlevel 1 (
    echo Installing target %TARGET%...
    rustup target add %TARGET%
    if errorlevel 1 (
        echo Error: Failed to install target %TARGET%
        exit /b 1
    )
)

REM Build the library
echo Building library...
cargo build --release --target %TARGET%
if errorlevel 1 (
    echo Error: Build failed
    exit /b 1
)

REM Copy the library to the root directory
set LIB_PATH=target\%TARGET%\release\tokenizers.lib
if exist "%LIB_PATH%" (
    copy "%LIB_PATH%" libtokenizers.lib >nul
    echo Library built successfully: libtokenizers.lib
) else (
    echo Error: Library not found at %LIB_PATH%
    exit /b 1
)

REM Test the Go bindings
echo Testing Go bindings...
set CGO_LDFLAGS=-L.
go build .
if errorlevel 1 (
    echo Error: Go build failed
    exit /b 1
)

echo Build completed successfully!
echo You can now use the library with: go run -ldflags="-extldflags '-L.'" your_program.go

:end
endlocal
