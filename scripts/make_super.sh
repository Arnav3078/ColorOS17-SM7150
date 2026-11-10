#!/bin/bash
set -e

# ==============================================================================
# Dynamic Super Builder & Flashable ZIP Packaging for Galaxy M51
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUT_IMAGES="$ROOT_DIR/build/out_images"
OUT_DIR="$ROOT_DIR/out"
LPMAKE="$ROOT_DIR/bin/lpmake"
export LD_LIBRARY_PATH="$ROOT_DIR/bin/lib64:${LD_LIBRARY_PATH:-}"
INSTALLER_DIR="$ROOT_DIR/installer"

[ ! -x "$LPMAKE" ] && LPMAKE="lpmake"

mkdir -p "$OUT_DIR" "$ROOT_DIR/build/zip_temp"

echo "======================================================================"
echo "[6/6] Generating Dynamic super.img and Assembling Flashable ZIP"
echo "======================================================================"

# Samsung Galaxy M51 Super Partition Spec (Matching UN1CA-SM7150 8GB dynamic partition table)
SUPER_SIZE=8053063680
GROUP_NAME="qti_dynamic_partitions"
GROUP_SIZE=8048869376

LPMAKE_ARGS=(
    --metadata-size 65536
    --super-name super
    --metadata-slots 2
    --device super:${SUPER_SIZE}
    --group ${GROUP_NAME}:${GROUP_SIZE}
)

echo "[INFO] Scanning output images for lpmake..."
TOTAL_PART_SIZE=0
for img in "$OUT_IMAGES"/*.img; do
    [ ! -f "$img" ] && continue
    part_name=$(basename "$img" .img)
    
    # Skip non-super partitions like boot, dtbo, vbmeta
    if [[ "$part_name" =~ ^(boot|dtbo|vbmeta|recovery)$ ]]; then
        continue
    fi
    
    img_size=$(stat -c%s "$img")
    TOTAL_PART_SIZE=$((TOTAL_PART_SIZE + img_size))
    echo " -> Adding partition to super: $part_name (size: $img_size bytes)"
    LPMAKE_ARGS+=(--partition "${part_name}:readonly:${img_size}:${GROUP_NAME}" --image "${part_name}=${img}")
done

echo "[INFO] Total super partition data size: $TOTAL_PART_SIZE bytes (Max Group: $GROUP_SIZE)"

# If total size fits in super partition, run lpmake
if [ "$TOTAL_PART_SIZE" -le "$GROUP_SIZE" ]; then
    LPMAKE_ARGS+=(--sparse --output "$OUT_IMAGES/super.img")
    echo "[INFO] Executing lpmake..."
    if "$LPMAKE" "${LPMAKE_ARGS[@]}"; then
        echo "[SUCCESS] Dynamic super.img built successfully!"
    else
        echo "[WARN] lpmake failed, packaging individual sparse images..."
    fi
else
    echo "[WARN] Partition contents exceed physical super partition size ($TOTAL_PART_SIZE > $GROUP_SIZE). Packaging dynamic partitions for sparse flashing..."
fi

# ------------------------------------------------------------------------------
# Assemble Flashable ROM ZIP
# ------------------------------------------------------------------------------
TIMESTAMP=$(date +"%Y%m%d_%H%M")
ZIP_NAME="ColorOS17_M51_SM7150_FlagshipPort_${TIMESTAMP}.zip"
ZIP_TEMP="$ROOT_DIR/build/zip_temp"

echo "[INFO] Assembling flashable ZIP structure in $ZIP_TEMP..."
rm -rf "$ZIP_TEMP"/*
mkdir -p "$ZIP_TEMP/META-INF/com/google/android" "$ZIP_TEMP/firmware"

# Copy updater-script and update-binary
cp -rf "$INSTALLER_DIR/META-INF" "$ZIP_TEMP/"
cp -f "$INSTALLER_DIR/flash_all.bat" "$ZIP_TEMP/"
cp -f "$INSTALLER_DIR/flash_all.sh" "$ZIP_TEMP/"

# Copy firmware / boot images
[ -f "$OUT_IMAGES/boot.img" ] && cp -f "$OUT_IMAGES/boot.img" "$ZIP_TEMP/boot.img"
[ -f "$OUT_IMAGES/dtbo.img" ] && cp -f "$OUT_IMAGES/dtbo.img" "$ZIP_TEMP/dtbo.img"

if [ -f "$OUT_IMAGES/super.img" ]; then
    cp -f "$OUT_IMAGES/super.img" "$ZIP_TEMP/super.img"
else
    echo "[INFO] Copying individual partition images into zip..."
    cp -f "$OUT_IMAGES"/*.img "$ZIP_TEMP/"
fi

# Create ZIP
echo "[INFO] Compressing flashable ROM: $ZIP_NAME..."
cd "$ZIP_TEMP"
7z a -tzip -mx=1 "$OUT_DIR/$ZIP_NAME" ./*

cd "$OUT_DIR"
md5sum "$ZIP_NAME" > "${ZIP_NAME}.md5"
sha256sum "$ZIP_NAME" > "${ZIP_NAME}.sha256"

echo "======================================================================"
echo "[SUCCESS] ROM Build Complete!"
echo "Flashable ZIP: $OUT_DIR/$ZIP_NAME"
echo "MD5 Checksum: $(cat "${ZIP_NAME}.md5")"
echo "======================================================================"
