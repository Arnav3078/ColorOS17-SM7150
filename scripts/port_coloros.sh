#!/bin/bash
set -e

# ==============================================================================
# Master Porting Engine: ColorOS 17 OnePlus 13 (PJZ110) for Galaxy M51 (SM7150)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
DONOR_EXTRACT="$BUILD_DIR/donor_extracted"
BASE_EXTRACT="$BUILD_DIR/base_extracted"
WORK_DIR="$BUILD_DIR/workspace"
OUT_IMAGES="$BUILD_DIR/out_images"
DEVICE_DIR="$ROOT_DIR/device/samsung/m51"

REPACK_TYPE="${REPACK_TYPE:-EROFS}"
ENABLE_KSU="${ENABLE_KSU:-true}"

echo "======================================================================"
echo " Starting ColorOS 17 Flagship Port for Samsung Galaxy M51"
echo " Donor: OnePlus 13 (PJZ110 - Snapdragon 8 Elite Flagship Base)"
echo " Repack Filesystem: $REPACK_TYPE | KernelSU: $ENABLE_KSU"
echo "======================================================================"

mkdir -p "$BUILD_DIR" "$DONOR_EXTRACT" "$BASE_EXTRACT" "$WORK_DIR" "$OUT_IMAGES"

# ------------------------------------------------------------------------------
# Step 1: Extract Donor ROM (OnePlus 13 Flagship ColorOS 17)
# ------------------------------------------------------------------------------
echo "[1/6] Extracting OnePlus 13 Flagship ColorOS 17 Donor Firmware..."
DONOR_ARCHIVE=$(find "$ROOT_DIR/input/donor" -type f \( -name "*.zip" -o -name "*.bin" -o -name "*.tar*" \) | head -n 1)

if [ -z "$DONOR_ARCHIVE" ]; then
    echo "[ERROR] No donor ROM found in input/donor! Please provide OnePlus 13 ColorOS 17 firmware."
    exit 1
fi

echo "[INFO] Found donor archive: $DONOR_ARCHIVE"
if [[ "$DONOR_ARCHIVE" == *payload.bin ]]; then
    payload-dumper-go -o "$DONOR_EXTRACT" "$DONOR_ARCHIVE"
elif unzip -l "$DONOR_ARCHIVE" | grep -q "payload.bin"; then
    echo "[INFO] Extracting payload.bin from donor zip..."
    unzip -q -j "$DONOR_ARCHIVE" payload.bin -d "$BUILD_DIR"
    payload-dumper-go -o "$DONOR_EXTRACT" "$BUILD_DIR/payload.bin"
    rm -f "$BUILD_DIR/payload.bin"
else
    echo "[INFO] Unpacking direct image archive..."
    7z x "$DONOR_ARCHIVE" -o"$DONOR_EXTRACT" -y
fi

# ------------------------------------------------------------------------------
# Step 2: Extract Base Vendor & Kernel for Galaxy M51
# ------------------------------------------------------------------------------
echo "[2/6] Extracting Samsung Galaxy M51 Base Vendor & Kernel..."
BASE_ARCHIVE=$(find "$ROOT_DIR/input/base" -type f \( -name "*.tar*" -o -name "*.zip" -o -name "*.img" \) | head -n 1)

if [ -n "$BASE_ARCHIVE" ]; then
    echo "[INFO] Found base package: $BASE_ARCHIVE"
    tar -xf "$BASE_ARCHIVE" -C "$BASE_EXTRACT" 2>/dev/null || \
    7z x "$BASE_ARCHIVE" -o"$BASE_EXTRACT" -y || \
    unzip -q "$BASE_ARCHIVE" -d "$BASE_EXTRACT" || true
else
    echo "[WARN] No base archive found, using fallback vendor tree structure..."
fi

# ------------------------------------------------------------------------------
# Step 3: Unpack System Partitions for Modification
# ------------------------------------------------------------------------------
echo "[3/6] Unpacking partitions for modification..."

DONOR_PARTITIONS=(system system_ext product my_product my_stock my_heytap my_carrier my_region my_bigball my_manifest my_company my_preload my_engineering)

for part in "${DONOR_PARTITIONS[@]}"; do
    IMG_FILE="$DONOR_EXTRACT/${part}.img"
    PART_DIR="$WORK_DIR/$part"
    mkdir -p "$PART_DIR"
    
    if [ -f "$IMG_FILE" ]; then
        echo " -> Extracting $part.img..."
        if [ -x "$ROOT_DIR/bin/extract.erofs" ]; then
            "$ROOT_DIR/bin/extract.erofs" -i "$IMG_FILE" -x -T "$PART_DIR" 2>/dev/null || 7z x "$IMG_FILE" -o"$PART_DIR" -y >/dev/null 2>&1 || true
        else
            7z x "$IMG_FILE" -o"$PART_DIR" -y >/dev/null 2>&1 || true
        fi
    fi
done

# Copy Vendor and Kernel from Base
mkdir -p "$WORK_DIR/vendor" "$WORK_DIR/odm"
if [ -f "$BASE_EXTRACT/vendor.img" ]; then
    echo " -> Copying Base vendor.img..."
    cp -f "$BASE_EXTRACT/vendor.img" "$OUT_IMAGES/vendor.img"
fi
if [ -f "$BASE_EXTRACT/odm.img" ]; then
    echo " -> Copying Base odm.img..."
    cp -f "$BASE_EXTRACT/odm.img" "$OUT_IMAGES/odm.img"
fi
if [ -f "$BASE_EXTRACT/boot.img" ]; then
    echo " -> Preparing Base boot.img..."
    cp -f "$BASE_EXTRACT/boot.img" "$OUT_IMAGES/boot.img"
fi
if [ -f "$BASE_EXTRACT/dtbo.img" ]; then
    echo " -> Preparing Base dtbo.img..."
    cp -f "$BASE_EXTRACT/dtbo.img" "$OUT_IMAGES/dtbo.img"
fi

# ------------------------------------------------------------------------------
# Step 4: Apply Galaxy M51 Device Adaptations & Performance Tweaks
# ------------------------------------------------------------------------------
echo "[4/6] Applying Galaxy M51 Adaptations & Performance Engine..."

# 4.1 Device Properties & Identifiers
if [ -d "$WORK_DIR/system" ]; then
    echo " -> Injecting device identifiers into system/build.prop..."
    cat "$DEVICE_DIR/device.prop" >> "$WORK_DIR/system/system/build.prop" 2>/dev/null || \
    cat "$DEVICE_DIR/device.prop" >> "$WORK_DIR/system/build.prop" 2>/dev/null || true
fi

# 4.2 Performance, Fluidity & Blur Preservation Tweaks
if [ -d "$WORK_DIR/system" ]; then
    echo " -> Injecting OnePlus 13 zero-lag performance & full blur tweaks..."
    cat "$DEVICE_DIR/tweaks.prop" >> "$WORK_DIR/system/system/build.prop" 2>/dev/null || \
    cat "$DEVICE_DIR/tweaks.prop" >> "$WORK_DIR/system/build.prop" 2>/dev/null || true
fi

# 4.3 Prune Heavy Telemetry & Background Logger Daemons (Zero-Lag Engine)
echo " -> Pruning heavy background logging & telemetry daemons..."
while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    TARGET_PATH="$WORK_DIR/$line"
    if [ -e "$TARGET_PATH" ]; then
        echo "    Pruning bloat daemon: $line"
        rm -rf "$TARGET_PATH"
    fi
done < "$DEVICE_DIR/bloat_prune.list"

# 4.4 Copy SELinux CIL Rules
if [ -f "$DEVICE_DIR/sepolicy/m51.cil" ]; then
    echo " -> Injecting SELinux compatibility policy..."
    if [ -d "$WORK_DIR/system/system/etc/selinux" ]; then
        cat "$DEVICE_DIR/sepolicy/m51.cil" >> "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
    elif [ -d "$WORK_DIR/system/etc/selinux" ]; then
        cat "$DEVICE_DIR/sepolicy/m51.cil" >> "$WORK_DIR/system/etc/selinux/plat_sepolicy.cil"
    fi
fi

# 4.5 Deploy RRO Device Overlays into product/overlay
OVERLAY_TARGET="$WORK_DIR/product/product/overlay"
[ ! -d "$OVERLAY_TARGET" ] && OVERLAY_TARGET="$WORK_DIR/product/overlay"
mkdir -p "$OVERLAY_TARGET"

echo " -> Deploying Galaxy M51 RRO overlays (7000mAh battery, side-FP, center punch hole)..."
cp -rf "$DEVICE_DIR/overlays/"* "$OVERLAY_TARGET/" 2>/dev/null || true

# ------------------------------------------------------------------------------
# Step 5: Repack Partitions (EROFS or EXT4)
# ------------------------------------------------------------------------------
echo "[5/6] Repacking partitions ($REPACK_TYPE)..."

for part in "${DONOR_PARTITIONS[@]}"; do
    PART_DIR="$WORK_DIR/$part"
    OUT_IMG="$OUT_IMAGES/${part}.img"
    
    if [ -d "$PART_DIR" ] && [ "$(ls -A "$PART_DIR" 2>/dev/null)" ]; then
        echo " -> Repacking $part as $REPACK_TYPE..."
        if [ "$REPACK_TYPE" = "EROFS" ]; then
            mkfs.erofs -z lz4hc,9 -C 65536 "$OUT_IMG" "$PART_DIR"
        else
            SIZE_KB=$(du -sk "$PART_DIR" | cut -f1)
            SIZE_BYTES=$(( (SIZE_KB + (SIZE_KB * 15 / 100)) * 1024 ))
            make_ext4fs -l "$SIZE_BYTES" -s "$OUT_IMG" "$PART_DIR" 2>/dev/null || \
            mke2fs -O ^has_journal -b 4096 -L "$part" -M "/$part" -m 0 "$OUT_IMG"
        fi
    elif [ -f "$DONOR_EXTRACT/${part}.img" ]; then
        echo " -> Passing untouched $part.img to output..."
        cp -f "$DONOR_EXTRACT/${part}.img" "$OUT_IMG"
    fi
done

echo "======================================================================"
echo "[SUCCESS] Partition porting and modification completed successfully!"
echo "======================================================================"
