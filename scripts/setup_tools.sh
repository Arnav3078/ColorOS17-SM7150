#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="$ROOT_DIR/bin"

mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR"

echo "[INFO] Setting up porting tools in $TOOLS_DIR..."

# Download Android dynamic partition tools (lpmake, lpunpack)
if [ ! -f "lpmake" ] || [ ! -f "lpunpack" ]; then
    echo "[INFO] Downloading lpmake and lpunpack..."
    curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/otatools/bin/lpmake" -o lpmake
    curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/otatools/bin/lpunpack" -o lpunpack
    chmod +x lpmake lpunpack
fi

# Download extract.erofs helper
if [ ! -f "extract.erofs" ]; then
    echo "[INFO] Downloading extract.erofs..."
    curl -sSL "https://raw.githubusercontent.com/toraidl/coloros_port/COS17/bin/Linux/x86_64/extract.erofs" -o extract.erofs
    chmod +x extract.erofs
fi

echo "[INFO] Toolchain setup complete."
ls -la "$TOOLS_DIR"
