#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="$ROOT_DIR/bin"
LIB_DIR="$TOOLS_DIR/lib64"

mkdir -p "$TOOLS_DIR" "$LIB_DIR"
cd "$TOOLS_DIR"

echo "[INFO] Setting up porting tools in $TOOLS_DIR..."

# Download Android dynamic partition tools (lpmake, lpunpack)
if [ ! -f "lpmake" ] || [ ! -f "lpunpack" ]; then
    echo "[INFO] Downloading lpmake and lpunpack..."
    curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/otatools/bin/lpmake" -o lpmake
    curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/otatools/bin/lpunpack" -o lpunpack
    chmod +x lpmake lpunpack
fi

# Download required shared libraries for lpmake (libbase.so, libc++.so, liblp.so, etc.)
LIBS=(libbase.so libc++.so liblp.so liblog.so libsparse-host.so libcrypto-host.so libcutils.so libz-host.so)
for lib in "${LIBS[@]}"; do
    if [ ! -f "$LIB_DIR/$lib" ]; then
        curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/otatools/lib64/$lib" -o "$LIB_DIR/$lib" 2>/dev/null || true
    fi
done

# Download extract.erofs helper
if [ ! -f "extract.erofs" ]; then
    echo "[INFO] Downloading extract.erofs..."
    curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/bin/Linux/x86_64/extract.erofs" -o extract.erofs
    chmod +x extract.erofs
fi

echo "[INFO] Toolchain setup complete."
ls -la "$TOOLS_DIR"