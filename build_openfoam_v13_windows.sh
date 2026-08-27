#!/bin/bash
# ==============================================================================
# OpenFOAM-v13 Automated Windows Cross-Compilation Turnkey Script
# Target: Windows x64 (Native PE32+ DLLs and EXEs)
# Host: openSUSE Leap 15.6 / Ubuntu / Debian WSL
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================================================"
echo "  Starting Automated Windows x64 Cross-Compilation for OpenFOAM-v13"
echo "======================================================================"

# 1. Check prerequisites
if ! command -v x86_64-w64-mingw32-g++ &> /dev/null; then
    echo "[-] Error: x86_64-w64-mingw32-g++ toolchain not found!"
    echo "    Please install: mingw64-cross-gcc mingw64-cross-gcc-c++ (openSUSE)"
    echo "    or: mingw-w64 (Ubuntu/Debian)"
    exit 1
fi

# 2. Apply Git Patch if patch file exists
if [ -f "openfoam_v13_windows_crosscompile.patch" ]; then
    echo "[+] Applying openfoam_v13_windows_crosscompile.patch..."
    git apply --whitespace=nowarn openfoam_v13_windows_crosscompile.patch || {
        echo "[!] Patch already applied or partially applied, continuing..."
    }
fi

# 3. Source environment
echo "[+] Sourcing OpenFOAM environment..."
export WM_COMPILER=Mingw
export WM_ARCH=linux64
source etc/bashrc

# 4. Build host-native wmake tools
echo "[+] Building host-native wmake tools (wmkdep, dirToString)..."
mkdir -p "$WM_PROJECT_DIR/wmake/platforms/linux64Gcc"
gcc -O3 "$WM_PROJECT_DIR/wmake/src/wmkdep.c" -o "$WM_PROJECT_DIR/wmake/platforms/linux64Gcc/wmkdep"
gcc -O3 "$WM_PROJECT_DIR/wmake/src/dirToString.c" -o "$WM_PROJECT_DIR/wmake/platforms/linux64Gcc/dirToString"

# 5. Build Dummy ThirdParty Libraries
echo "[+] Building Dummy ThirdParty decomposition stubs (metis, scotch, ptscotch)..."
(cd src/dummyThirdParty && ./Allwmake)

# 6. Build Core Source Libraries
echo "[+] Building OpenFOAM src libraries in parallel..."
(cd src && ./Allwmake -j $(nproc))

# 7. Build Applications (Solvers, Modules, Legacy, Utilities)
echo "[+] Building Applications, Solvers, and Utilities..."
(cd applications && ./Allwmake -j $(nproc))

echo "======================================================================"
echo "  BUILD COMPLETED SUCCESSFULLY!"
echo "======================================================================"
echo -n "Total Executables (.exe): "
ls -1 $WM_PROJECT_DIR/platforms/linux64MingwDPInt32Opt/bin/*.exe 2>/dev/null | wc -l || ls -1 $WM_PROJECT_DIR/platforms/linux64MingwDPInt32Opt/bin | wc -l
echo -n "Total DLLs (.so): "
ls -1 $WM_PROJECT_DIR/platforms/linux64MingwDPInt32Opt/lib/*.so 2>/dev/null | wc -l
echo "======================================================================"
