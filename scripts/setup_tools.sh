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

# Download complete shared libraries for dynamic partition tools (lpmake, lpunpack)
LIBS=(
    libbase.so
    libbrillo-stream.so
    libbrillo.so
    libc++.so
    libchrome.so
    libcrypto-host.so
    libcrypto_utils.so
    libcutils.so
    libevent-host.so
    libext2_com_err-host.so
    libext2fs-host.so
    libext4_utils.so
    libfec.so
    liblog.so
    liblp.so
    liblz4.so
    libpcre2.so
    libprocessgroup.so
    libprotobuf-cpp-lite.so
    libselinux.so
    libsparse-host.so
    libsquashfs_utils.so
    libssl-host.so
    libz-host.so
    libziparchive.so
)
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