#!/bin/bash
# ==============================================================================
# OpenFOAM-13 Engines Packaging & Export Script for Jupiter CFD
# Mirrors the directory structure of D:\Jupiter-CFD_ver2.2\bin\common\OpenFoamEngines
# Source data read from OpenFOAM-13 and ThirdParty-13 (as recorded in TreL4.txt)
# ==============================================================================

set -e

# Terminal color formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  OpenFOAM-13 Engines Exporter for Jupiter CFD (WSL -> Windows)       ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# 1. Automatically locate OpenFOAM-13 and ThirdParty-13 source directories in WSL
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || pwd)"

if [ -n "$2" ] && [ -d "$2" ]; then
    ROOT_DIR="$2"
elif [ -d "$SCRIPT_DIR/OpenFOAM-13" ]; then
    ROOT_DIR="$SCRIPT_DIR"
elif [ -d "$HOME/OpenFOAM-Foundation/OpenFOAM-13" ]; then
    ROOT_DIR="$HOME/OpenFOAM-Foundation"
elif [ -d "$HOME/OpenFOAM-Foudation/OpenFOAM-13" ]; then
    ROOT_DIR="$HOME/OpenFOAM-Foudation"
elif [ -d "$SCRIPT_DIR/platforms" ]; then
    ROOT_DIR="$(dirname "$SCRIPT_DIR")"
else
    echo -e "${RED}[-] Error: OpenFOAM-13 source directory not found!${NC}"
    echo "    Please run the script from the directory containing OpenFOAM-13 or specify: $0 [DEST_DIR] [SOURCE_DIR]"
    exit 1
fi

OF_DIR="$ROOT_DIR/OpenFOAM-13"
TP_DIR="$ROOT_DIR/ThirdParty-13"
PLATFORM_SRC="$OF_DIR/platforms/linux64MingwDPInt32Opt"

echo -e "${CYAN}[+] OpenFOAM-13 source directory:${NC} $OF_DIR"
if [ -d "$TP_DIR" ]; then
    echo -e "${CYAN}[+] ThirdParty-13 source directory:${NC} $TP_DIR"
fi

if [ ! -d "$PLATFORM_SRC/bin" ] || [ ! -d "$PLATFORM_SRC/lib" ]; then
    echo -e "${RED}[-] Error: Built binaries not found at:${NC} $PLATFORM_SRC"
    echo "    Please verify that the OpenFOAM-13 cross-compilation has finished successfully."
    exit 1
fi

# 2. Determine target export destination (DEST_DIR)
DEFAULT_DEST="/mnt/d/KODAMA/OpenFOAM-13-Engines"
if [ ! -d "/mnt/d" ]; then
    DEFAULT_DEST="$HOME/OpenFOAM-13-Engines"
fi

DEST_DIR="${1:-$DEFAULT_DEST}"
echo -e "${CYAN}[+] Export destination:${NC} $DEST_DIR"

# Reference path from original Jupiter CFD (if available)
JUPITER_REF="/mnt/d/Jupiter-CFD-ver2.2/bin/common/OpenFoamEngines"
if [ ! -d "$JUPITER_REF" ] && [ -d "/mnt/d/Jupiter-CFD_ver2.2/bin/common/OpenFoamEngines" ]; then
    JUPITER_REF="/mnt/d/Jupiter-CFD_ver2.2/bin/common/OpenFoamEngines"
fi

# 3. Initialize directory tree matching Jupiter CFD layout
ENGINE_OF_DIR="$DEST_DIR/OpenFOAM-13/OpenFOAM-13"
ENGINE_TP_DIR="$DEST_DIR/OpenFOAM-13/ThirdParty-13"
OF_BIN_DIR="$ENGINE_OF_DIR/platforms/win64MingwDPInt32Opt/bin"
MPI_BIN_DIR="$ENGINE_TP_DIR/platforms/linux64Mingw/MPI/bin"
MPI_LIC_DIR="$ENGINE_TP_DIR/platforms/linux64Mingw/MPI/License"
TP_LIB_DIR="$ENGINE_TP_DIR/platforms/linux64MingwDPInt32/lib"

mkdir -p "$OF_BIN_DIR"
mkdir -p "$MPI_BIN_DIR"
mkdir -p "$MPI_LIC_DIR"
mkdir -p "$TP_LIB_DIR"
mkdir -p "$ENGINE_OF_DIR/bin"
mkdir -p "$ENGINE_OF_DIR/etc"

# 4. Copy root files: msmpisetup.exe & OpenFOAM_License.txt
echo -e "${GREEN}[+] 1/7: Copying MS-MPI installer and License...${NC}"
if [ -f "$JUPITER_REF/msmpisetup.exe" ]; then
    cp -f "$JUPITER_REF/msmpisetup.exe" "$DEST_DIR/"
    echo "    -> Copied msmpisetup.exe from original Jupiter CFD reference"
elif [ -f "$TP_DIR/opt/msmpi/msmpisetup.exe" ]; then
    cp -f "$TP_DIR/opt/msmpi/msmpisetup.exe" "$DEST_DIR/"
fi

if [ -f "$JUPITER_REF/OpenFOAM_License.txt" ]; then
    cp -f "$JUPITER_REF/OpenFOAM_License.txt" "$DEST_DIR/"
elif [ -f "$OF_DIR/COPYING" ]; then
    cp -f "$OF_DIR/COPYING" "$DEST_DIR/OpenFOAM_License.txt"
fi

# 5. Generate environment setup file setEnvVariables.bat for OpenFOAM-13
echo -e "${GREEN}[+] 2/7: Generating environment configuration file setEnvVariables.bat...${NC}"
cat << 'EOF' > "$DEST_DIR/OpenFOAM-13/setEnvVariables.bat"
@echo off
rem /*---------------------------------------------------------------------------*\
rem  =========                 |
rem  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
rem   \\    /   O peration     |
rem    \\  /    A nd           | Copyright (C) OpenFOAM Foundation
rem     \\/     M anipulation  |
rem -------------------------------------------------------------------------------
rem License
rem    This file is part of OpenFOAM.
rem
rem    OpenFOAM is free software: you can redistribute it and/or modify it
rem    under the terms of the GNU General Public License as published by
rem    the Free Software Foundation, either version 3 of the License, or
rem    (at your option) any later version.
rem
rem    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
rem    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
rem    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
rem    for more details.
rem
rem    You should have received a copy of the GNU General Public License
rem    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.
rem
rem   Description
rem    The .bat file sets up OpenFOAM-13 environment variables for Windows CMD
rem    or MS-DOS command prompt (Jupiter CFD Engine).
rem 

title  Jupiter OpenFOAM-13 Environment Terminal
set HOME=%~dp0
echo ********************************************************************************************
echo ***************************** Jupiter OpenFOAM-13 Session **********************************
echo ********************************************************************************************
echo Init settings for Jupiter OpenFoam at %HOME%
set TYPE=win64MingwDPInt32Opt
set TYPE_THIRDPARTY=linux64MingwDPInt32
set TYPE_THIRDPARTY_BOOST_AND_MPI=linux64Mingw
set HOME=%HOME:~0,-1%
set WM_PROJECT=OpenFOAM
set WM_PROJECT_VERSION=13
set "WM_PROJECT_DIR=%HOME%\%WM_PROJECT%-%WM_PROJECT_VERSION%"
set "WM_PROJECT_DIR=%WM_PROJECT_DIR:\=/%"
set WM_THIRD_PARTY_DIR=%HOME%\ThirdParty-%WM_PROJECT_VERSION%
set FOAM_SIGFPE=1
set PATH=%HOME%\%WM_PROJECT%-%WM_PROJECT_VERSION%\platforms\%TYPE%\bin\;%WM_THIRD_PARTY_DIR%\platforms\%TYPE_THIRDPARTY%\lib\;%WM_THIRD_PARTY_DIR%\platforms\%TYPE_THIRDPARTY_BOOST_AND_MPI%\MPI\bin\;%PATH%

EOF

# 6. Copy all executables (.exe)
echo -e "${GREEN}[+] 3/7: Copying all OpenFOAM-13 executables (.exe)...${NC}"
cp -f "$PLATFORM_SRC/bin"/*.exe "$OF_BIN_DIR/" 2>/dev/null || true
EXE_COUNT=$(ls -1 "$OF_BIN_DIR"/*.exe 2>/dev/null | wc -l)
echo "    -> Exported $EXE_COUNT .exe files"

# 7. Copy and convert libraries (.dll and .so) with NTFS case-sensitivity collision handling
echo -e "${GREEN}[+] 4/7: Copying libraries (.dll and .so) with case collision resolution...${NC}"
# MinGW cross-compiled OpenFOAM generates DLL files with .so extension
for so_file in "$PLATFORM_SRC/lib"/*.so; do
    if [ -f "$so_file" ]; then
        base_name="$(basename "$so_file" .so)"
        # Skip uppercase files that collide on case-insensitive Windows NTFS to prevent overwriting core libraries
        if [ "$base_name" = "libLagrangian" ] || [ "$base_name" = "libLagrangianFunctionObjects" ]; then
            continue
        fi
        cp -f "$so_file" "$OF_BIN_DIR/${base_name}.dll"
        cp -f "$so_file" "$OF_BIN_DIR/${base_name}.so"
    fi
done

# Ensure the lowercase liblagrangian library (containing Foam::lagrangian::cloud::debug) is preserved
cp -f "$PLATFORM_SRC/lib/liblagrangian.so" "$OF_BIN_DIR/liblagrangian.so"
cp -f "$PLATFORM_SRC/lib/liblagrangian.so" "$OF_BIN_DIR/liblagrangian.dll"
if [ -f "$PLATFORM_SRC/lib/liblagrangianFunctionObjects.so" ]; then
    cp -f "$PLATFORM_SRC/lib/liblagrangianFunctionObjects.so" "$OF_BIN_DIR/liblagrangianFunctionObjects.so"
    cp -f "$PLATFORM_SRC/lib/liblagrangianFunctionObjects.so" "$OF_BIN_DIR/liblagrangianFunctionObjects.dll"
fi

# Process Pstream variants: dummy and msmpi
if [ -f "$PLATFORM_SRC/lib/dummy/libPstream.so" ]; then
    cp -f "$PLATFORM_SRC/lib/dummy/libPstream.so" "$OF_BIN_DIR/libPstream.dll-dummy"
fi

if [ -f "$PLATFORM_SRC/lib/msmpi/libPstream.so" ]; then
    cp -f "$PLATFORM_SRC/lib/msmpi/libPstream.so" "$OF_BIN_DIR/libPstream.dll-msmpi"
    cp -f "$PLATFORM_SRC/lib/msmpi/libPstream.so" "$OF_BIN_DIR/libPstream.dll"
    cp -f "$PLATFORM_SRC/lib/msmpi/libPstream.so" "$OF_BIN_DIR/libPstream.so"
elif [ -f "$PLATFORM_SRC/lib/dummy/libPstream.so" ]; then
    cp -f "$PLATFORM_SRC/lib/dummy/libPstream.so" "$OF_BIN_DIR/libPstream.dll"
    cp -f "$PLATFORM_SRC/lib/dummy/libPstream.so" "$OF_BIN_DIR/libPstream.so"
fi

# Copy MinGW runtime dependency DLLs
MINGW_SYS_BIN="/usr/x86_64-w64-mingw32/sys-root/mingw/bin"
if [ -d "$MINGW_SYS_BIN" ]; then
    cp -f "$MINGW_SYS_BIN"/*.dll "$OF_BIN_DIR/" 2>/dev/null || true
fi

# Fallback to compatible runtime DLLs from original Jupiter CFD if available
if [ -d "$JUPITER_REF/OpenFOAM-v2412/OpenFOAM-v2412/platforms/win64MingwDPInt32Opt/bin" ]; then
    REF_BIN="$JUPITER_REF/OpenFOAM-v2412/OpenFOAM-v2412/platforms/win64MingwDPInt32Opt/bin"
    for rt_dll in libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll libz.dll; do
        if [ ! -f "$OF_BIN_DIR/$rt_dll" ] && [ -f "$REF_BIN/$rt_dll" ]; then
            cp -f "$REF_BIN/$rt_dll" "$OF_BIN_DIR/"
        fi
    done
fi

DLL_COUNT=$(ls -1 "$OF_BIN_DIR"/*.dll 2>/dev/null | wc -l)
echo "    -> Exported $DLL_COUNT .dll files to platforms/win64MingwDPInt32Opt/bin"

# 8. Generate .bat wrapper files for all OpenFOAM-13 solvers on Windows CMD
echo -e "${GREEN}[+] 5/7: Generating solver .bat wrappers (simpleFoam, pimpleFoam, interFoam...)...${NC}"
cat << 'EOF' > "$OF_BIN_DIR/simpleFoam.bat"
@echo off
foamRun.exe -solver incompressibleFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/pimpleFoam.bat"
@echo off
foamRun.exe -solver incompressibleFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/pisoFoam.bat"
@echo off
foamRun.exe -solver incompressibleFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/interFoam.bat"
@echo off
foamRun.exe -solver incompressibleVoF %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/compressibleInterFoam.bat"
@echo off
foamRun.exe -solver compressibleVoF %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/multiphaseInterFoam.bat"
@echo off
foamRun.exe -solver incompressibleMultiphaseVoF %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/compressibleMultiphaseInterFoam.bat"
@echo off
foamRun.exe -solver compressibleMultiphaseVoF %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/rhoSimpleFoam.bat"
@echo off
foamRun.exe -solver fluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/rhoPimpleFoam.bat"
@echo off
foamRun.exe -solver fluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/rhoCentralFoam.bat"
@echo off
foamRun.exe -solver shockFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/buoyantFoam.bat"
@echo off
foamRun.exe -solver fluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/buoyantReactingFoam.bat"
@echo off
foamRun.exe -solver multicomponentFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/reactingFoam.bat"
@echo off
foamRun.exe -solver multicomponentFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/twoPhaseEulerFoam.bat"
@echo off
foamRun.exe -solver multiphaseEuler %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/multiphaseEulerFoam.bat"
@echo off
foamRun.exe -solver multiphaseEuler %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/XiFoam.bat"
@echo off
foamRun.exe -solver XiFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/denseParticleFoam.bat"
@echo off
foamRun.exe -solver incompressibleDenseParticleFluid %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/driftFluxFoam.bat"
@echo off
foamRun.exe -solver incompressibleDriftFlux %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/solidDisplacementFoam.bat"
@echo off
foamRun.exe -solver solidDisplacement %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/solidEquilibriumDisplacementFoam.bat"
@echo off
foamRun.exe -solver solidDisplacement %*
EOF

cat << 'EOF' > "$OF_BIN_DIR/paraFoam.bat"
@echo off
setlocal
set "CASE_NAME=%~nx1"
if "%CASE_NAME%"=="" (
    for %%I in ("%CD%") do set "CASE_NAME=%%~nxI"
)
set "FOAM_FILE=%CD%\%CASE_NAME%.foam"
if not exist "%FOAM_FILE%" (
    type nul > "%FOAM_FILE%"
)
echo Created ParaView case file: %FOAM_FILE%
where paraview.exe >nul 2>&1
if %ERRORLEVEL% equ 0 (
    start "" paraview.exe "%FOAM_FILE%"
) else (
    echo Note: 'paraview.exe' is not found in system PATH.
    echo You can open '%FOAM_FILE%' directly with ParaView.
)
endlocal
EOF

echo "    -> Generated 21 solver/utility .bat wrappers for Windows CMD"

# 9. Copy bin/ directory (bash scripts + tools) and etc/ directory
echo -e "${GREEN}[+] 6/7: Copying OpenFOAM-13 bin and etc directories...${NC}"
cp -r "$OF_DIR/bin"/* "$ENGINE_OF_DIR/bin/" 2>/dev/null || true
cp -r "$OF_DIR/etc"/* "$ENGINE_OF_DIR/etc/" 2>/dev/null || true

# 10. Configure ThirdParty-13 (MPI Runtime, Scotch & Zoltan)
echo -e "${GREEN}[+] 7/7: Configuring ThirdParty-13 (MPI, Scotch & Zoltan)...${NC}"

# MS-MPI runtime binaries
if [ -d "$TP_DIR/platforms/linux64Mingw/MPI/bin" ]; then
    cp -f "$TP_DIR/platforms/linux64Mingw/MPI/bin"/* "$MPI_BIN_DIR/" 2>/dev/null || true
    echo "    -> Copied MS-MPI binaries from ThirdParty-13"
elif [ -d "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64Mingw/MPI/bin" ]; then
    cp -f "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64Mingw/MPI/bin"/* "$MPI_BIN_DIR/" 2>/dev/null || true
    echo "    -> Copied MS-MPI binaries from Jupiter CFD reference"
fi

# MPI License
if [ -d "$TP_DIR/opt/msmpi/License" ]; then
    cp -f "$TP_DIR/opt/msmpi/License"/* "$MPI_LIC_DIR/" 2>/dev/null || true
elif [ -f "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64Mingw/MPI/License/MPI-SDK-TPN.txt" ]; then
    cp -f "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64Mingw/MPI/License/MPI-SDK-TPN.txt" "$MPI_LIC_DIR/"
fi

# Scotch & Zoltan libraries (built natively in ThirdParty-13)
if [ -d "$TP_DIR/platforms/linux64MingwDPInt32/lib" ] && [ -f "$TP_DIR/platforms/linux64MingwDPInt32/lib/libscotch.dll" ]; then
    echo "    -> Exporting ThirdParty-13 cross-compiled libraries (Scotch & Zoltan)..."
    cp -f "$TP_DIR/platforms/linux64MingwDPInt32/lib"/*.dll "$TP_LIB_DIR/" 2>/dev/null || true
    cp -f "$TP_DIR/platforms/linux64MingwDPInt32/lib"/*.a "$TP_LIB_DIR/" 2>/dev/null || true
    # Also place Scotch DLLs into OF_BIN_DIR to ensure seamless runtime loading on Windows
    cp -f "$TP_DIR/platforms/linux64MingwDPInt32/lib"/*.dll "$OF_BIN_DIR/" 2>/dev/null || true
elif [ -f "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64MingwDPInt32/lib/libscotch.dll" ]; then
    echo "    -> Fallback: Copying libscotch.dll from Jupiter CFD reference..."
    cp -f "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64MingwDPInt32/lib/libscotch.dll" "$TP_LIB_DIR/"
    cp -f "$JUPITER_REF/OpenFOAM-v2412/ThirdParty-v2412/platforms/linux64MingwDPInt32/lib/libscotch.dll" "$OF_BIN_DIR/"
fi

# ThirdParty-13 include headers (scotch.h, zoltan.h, etc.)
TP_INC_DIR="$ENGINE_TP_DIR/platforms/linux64MingwDPInt32/include"
mkdir -p "$TP_INC_DIR"
if [ -d "$TP_DIR/platforms/linux64MingwDPInt32/include" ]; then
    cp -r "$TP_DIR/platforms/linux64MingwDPInt32/include"/* "$TP_INC_DIR/" 2>/dev/null || true
    echo "    -> Exported ThirdParty-13 include headers to $TP_INC_DIR"
fi

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  OPENFOAM-13 ENGINES EXPORT COMPLETED SUCCESSFULLY!                  ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "  Destination:                 ${YELLOW}$DEST_DIR${NC}"
echo -e "  Total Executables (.exe):    ${GREEN}$EXE_COUNT${NC}"
echo -e "  Total Dynamic Libs (.dll):   ${GREEN}$DLL_COUNT${NC}"
echo -e "  Environment Script:          ${YELLOW}$DEST_DIR/OpenFOAM-13/setEnvVariables.bat${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "  To integrate into Jupiter CFD:"
echo -e "  Copy directory '${YELLOW}$DEST_DIR/OpenFOAM-13${NC}' to '${YELLOW}D:\\Jupiter-CFD_ver2.2\\bin\\common\\OpenFoamEngines\\${NC}'"
echo -e "${BLUE}======================================================================${NC}"
