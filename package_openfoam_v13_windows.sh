#!/bin/bash
# ==============================================================================
# OpenFOAM-v13 Automated Windows Standalone Packaging Script
# ==============================================================================
set -e

# Default output directory if not provided as argument
DEST_DIR="${1:-/mnt/e/KODAMA/OpenFOAM-13-Engines}"

echo "======================================================================"
echo "  Packaging Standalone Portable OpenFOAM-13 for Windows"
echo "======================================================================"
echo "[+] Target output directory: $DEST_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PLATFORM_DIR="platforms/linux64MingwDPInt32Opt"

if [ ! -d "$PLATFORM_DIR/bin" ] || [ ! -d "$PLATFORM_DIR/lib" ]; then
    echo "[-] Error: Built binaries not found in $PLATFORM_DIR!"
    echo "    Please run ./build_openfoam_v13_windows.sh first."
    exit 1
fi

mkdir -p "$DEST_DIR/bin"
mkdir -p "$DEST_DIR/lib/dummy"
mkdir -p "$DEST_DIR/lib/msmpi"
mkdir -p "$DEST_DIR/etc"

echo "[+] Copying 149 Windows Executables (.exe)..."
cp -r $PLATFORM_DIR/bin/*.exe "$DEST_DIR/bin/"

echo "[+] Copying 152 Windows Dynamic Libraries (.so / .dll)..."
cp -r $PLATFORM_DIR/lib/*.so "$DEST_DIR/lib/" 2>/dev/null || true
cp -r $PLATFORM_DIR/lib/*.dll.a "$DEST_DIR/lib/" 2>/dev/null || true
cp -r $PLATFORM_DIR/lib/dummy/*.so "$DEST_DIR/lib/dummy/" 2>/dev/null || true
cp -r $PLATFORM_DIR/lib/msmpi/*.so "$DEST_DIR/lib/msmpi/" 2>/dev/null || true

echo "[+] Bundling MinGW-w64 runtime DLLs..."
MINGW_SYS_BIN="/usr/x86_64-w64-mingw32/sys-root/mingw/bin"
if [ -d "$MINGW_SYS_BIN" ]; then
    cp "$MINGW_SYS_BIN"/*.dll "$DEST_DIR/bin/" 2>/dev/null || true
    cp "$MINGW_SYS_BIN"/*.dll "$DEST_DIR/lib/" 2>/dev/null || true
fi

echo "[+] Copying OpenFOAM etc configuration directory..."
cp -r etc/* "$DEST_DIR/etc/"

echo "[+] Copying tutorials directory..."
mkdir -p "$DEST_DIR/tutorials"
cp -r tutorials/* "$DEST_DIR/tutorials/" 2>/dev/null || true

echo "[+] Creating 100% Portable Launchers (Bat and PowerShell)..."

cat << 'LAUNCHER_BAT' > "$DEST_DIR/openfoam13_terminal.bat"
@echo off
set OF_DIR=%~dp0
set OF_DIR=%OF_DIR:~0,-1%
set WM_PROJECT_DIR=%OF_DIR%
set PATH=%OF_DIR%\bin;%OF_DIR%\lib;%OF_DIR%\lib\dummy;%OF_DIR%\lib\msmpi;%PATH%
echo ============================================================
echo   OpenFOAM-13 Native Portable Windows Console Loaded!
echo   WM_PROJECT_DIR: %WM_PROJECT_DIR%
echo ============================================================
echo You can run solvers directly: blockMesh, snappyHexMesh, foamRun, etc.
echo.
cmd /k
LAUNCHER_BAT

cat << 'LAUNCHER_PS' > "$DEST_DIR/openfoam13_env.ps1"
# OpenFOAM-13 Portable PowerShell Environment Initializer
$OF_DIR = $PSScriptRoot
$env:WM_PROJECT_DIR = $OF_DIR.Replace('\', '/')
$env:PATH = "$OF_DIR\bin;$OF_DIR\lib;$OF_DIR\lib\dummy;$OF_DIR\lib\msmpi;" + $env:PATH

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  OpenFOAM-13 Native Windows Environment Loaded!" -ForegroundColor Green
Write-Host "  WM_PROJECT_DIR: $env:WM_PROJECT_DIR" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "You can now run: blockMesh.exe, snappyHexMesh.exe, foamRun.exe, etc." -ForegroundColor White
LAUNCHER_PS

chmod +x "$DEST_DIR/openfoam13_terminal.bat" 2>/dev/null || true

EXE_COUNT=$(ls -1 "$DEST_DIR/bin"/*.exe 2>/dev/null | wc -l)
LIB_COUNT=$(ls -1 "$DEST_DIR/lib"/*.so 2>/dev/null | wc -l)

echo "======================================================================"
echo "  PACKAGING COMPLETED SUCCESSFULLY!"
echo "======================================================================"
echo "  Destination:  $DEST_DIR"
echo "  Executables:  $EXE_COUNT .exe"
echo "  Libraries:    $LIB_COUNT .so (DLLs)"
echo "  Launchers:    openfoam13_terminal.bat (CMD) & openfoam13_env.ps1 (PS)"
echo "======================================================================"
echo "  -> You can now copy the '$DEST_DIR' folder to ANY Windows PC and"
echo "     double-click 'openfoam13_terminal.bat' to use OpenFOAM-13 directly!"
echo "======================================================================"
