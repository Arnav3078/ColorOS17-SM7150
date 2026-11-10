#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="$ROOT_DIR/bin"

mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR"

echo "[INFO] Setting up porting tools in $TOOLS_DIR..."

# Download Android OTA & dynamic partition tools if missing
if [ ! -f "lpmake" ] || [ ! -f "lpunpack" ]; then
    echo "[INFO] Downloading lpmake and lpunpack..."
    curl -sSL "https://raw.githubusercontent.com/unix3dgamer/lpmake-prebuilt/main/lpmake" -o lpmake || \
    curl -sSL "https://github.com/affggh/lpmake-bin/raw/master/lpmake" -o lpmake
    curl -sSL "https://raw.githubusercontent.com/unix3dgamer/lpmake-prebuilt/main/lpunpack" -o lpunpack || \
    curl -sSL "https://github.com/affggh/lpmake-bin/raw/master/lpunpack" -o lpunpack
    chmod +x lpmake lpunpack
fi

# Download apktool
if [ ! -f "apktool.jar" ]; then
    echo "[INFO] Downloading apktool.jar..."
    curl -sSL "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar" -o apktool.jar
fi

# Download baksmali and smali
if [ ! -f "baksmali.jar" ] || [ ! -f "smali.jar" ]; then
    echo "[INFO] Downloading smali & baksmali..."
    curl -sSL "https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.5.2.jar" -o baksmali.jar
    curl -sSL "https://bitbucket.org/JesusFreke/smali/downloads/smali-2.5.2.jar" -o smali.jar
fi

# Download signapk
if [ ! -f "signapk.jar" ]; then
    echo "[INFO] Downloading signapk..."
    curl -sSL "https://raw.githubusercontent.com/appium-bup/sign/master/dist/signapk.jar" -o signapk.jar
fi

# Download extract-erofs helper
if [ ! -f "extract.erofs" ]; then
    echo "[INFO] Downloading extract.erofs..."
    curl -sSL "https://github.com/sekaiacg/erofs-utils/releases/download/v1.7.1/extract.erofs_linux_x86_64" -o extract.erofs || true
    chmod +x extract.erofs || true
fi

echo "[INFO] Toolchain setup complete."
ls -la "$TOOLS_DIR"
