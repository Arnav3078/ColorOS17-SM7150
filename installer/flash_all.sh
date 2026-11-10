#!/bin/bash
# ====================================================================
# Fastboot Flasher for ColorOS 17 on Samsung Galaxy M51
# ====================================================================

echo "===================================================================="
echo "    ColorOS 17 Flagship Port Flasher for Samsung Galaxy M51"
echo "===================================================================="
echo ""
echo "Ensure your device is connected in fastboot / fastbootd mode."
read -p "Press [Enter] to begin flashing..."

echo "[1/4] Checking device connection..."
fastboot devices

echo "[2/4] Flashing Boot & DTBO..."
[ -f "boot.img" ] && fastboot flash boot boot.img
[ -f "dtbo.img" ] && fastboot flash dtbo dtbo.img

echo "[3/4] Flashing Dynamic Super Partition..."
[ -f "super.img" ] && fastboot flash super super.img

echo "[4/4] Flashing finished!"
echo "NOTE: Wipe/Format data in recovery before rebooting into system."
