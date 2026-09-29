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

if ! command -v flex &> /dev/null; then
    echo "[-] Error: flex lexer generator not found!"
    echo "    Please install: flex (openSUSE/Ubuntu/Debian)"
    exit 1
fi

if ! command -v bison &> /dev/null; then
    echo "[-] Error: bison parser generator not found!"
    echo "    Please install: bison (openSUSE/Ubuntu/Debian)"
    exit 1
fi

# 2. Apply Git Patches if patch files exist
if [ -f "openfoam_v13_windows_crosscompile.patch" ]; then
    echo "[+] Applying openfoam_v13_windows_crosscompile.patch to OpenFOAM-13..."
    git apply --whitespace=nowarn openfoam_v13_windows_crosscompile.patch || {
        echo "[!] OpenFOAM patch already applied or partially applied, continuing..."
    }
fi

TP_DIR="$(cd "$SCRIPT_DIR/../ThirdParty-13" 2>/dev/null && pwd)"
if [ -d "$TP_DIR" ]; then
    TP_PATCH=""
    if [ -f "$TP_DIR/thirdparty_v13_windows_crosscompile.patch" ]; then
        TP_PATCH="$TP_DIR/thirdparty_v13_windows_crosscompile.patch"
    elif [ -f "$SCRIPT_DIR/thirdparty_v13_windows_crosscompile.patch" ]; then
        TP_PATCH="$SCRIPT_DIR/thirdparty_v13_windows_crosscompile.patch"
    fi

    if [ -n "$TP_PATCH" ]; then
        echo "[+] Applying thirdparty_v13_windows_crosscompile.patch to ThirdParty-13..."
        (cd "$TP_DIR" && git apply --whitespace=nowarn "$TP_PATCH" 2>/dev/null) || {
            echo "[!] ThirdParty patch already applied or partially applied, continuing..."
        }
    fi
fi

# 3. Source environment
echo "[+] Sourcing OpenFOAM environment..."
export WM_COMPILER=Mingw
export WM_ARCH=linux64
export WM_MPLIB=MSMPI
export WM_OSTYPE=MSwindows
export WM_NCOMPPROCS=$(nproc)
source etc/bashrc

# 4. Build host-native wmake tools
echo "[+] Building host-native wmake tools (wmkdep, dirToString)..."
mkdir -p "$WM_PROJECT_DIR/wmake/platforms/linux64Mingw"
mkdir -p "$WM_PROJECT_DIR/wmake/platforms/linux64Gcc"
gcc -O3 "$WM_PROJECT_DIR/wmake/src/dirToString.c" -o "$WM_PROJECT_DIR/wmake/platforms/linux64Mingw/dirToString"
flex -o "$WM_PROJECT_DIR/wmake/src/lex.yy.c" "$WM_PROJECT_DIR/wmake/src/wmkdep.l"
gcc -O3 "$WM_PROJECT_DIR/wmake/src/lex.yy.c" -o "$WM_PROJECT_DIR/wmake/platforms/linux64Mingw/wmkdep"
rm -f "$WM_PROJECT_DIR/wmake/src/lex.yy.c"
cp "$WM_PROJECT_DIR/wmake/platforms/linux64Mingw/"* "$WM_PROJECT_DIR/wmake/platforms/linux64Gcc/"

# 5. Build ThirdParty libraries (Scotch & Zoltan)
echo "[+] Building ThirdParty libraries (Scotch & Zoltan)..."
if [ -d "$WM_THIRD_PARTY_DIR" ]; then
    (cd "$WM_THIRD_PARTY_DIR" && ./Allwmake)
else
    echo "[!] Warning: WM_THIRD_PARTY_DIR ($WM_THIRD_PARTY_DIR) not found, skipping ThirdParty build."
fi

# 6. Bootstrap Pstream & OpenFOAM circular dependency
echo "[+] Bootstrapping OSspecific and Pstream..."
wmakeLnInclude -u src/OpenFOAM
wmakeLnInclude -u src/OSspecific/MSwindows
wmakeLnInclude -u src/Pstream/dummy

(cd src/OSspecific/MSwindows && ./Allwmake)
(cd src/Pstream/dummy && wmake libo .)

echo "[+] Building Core libOpenFOAM.so..."
(cd src/OpenFOAM && wmake -j $(nproc))

echo "[+] Building Pstream shared libraries (dummy & msmpi)..."
(cd src/Pstream && ./Allwmake)

# 7. Build remaining Core and Advanced Libraries
echo "[+] Building OpenFOAM src libraries in parallel..."
(cd src && ./Allwmake -j $(nproc))

# 8. Build Applications (Solvers, Modules, Legacy, Utilities)
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
