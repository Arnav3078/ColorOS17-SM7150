@echo off
title ColorOS 17 Flasher for Samsung Galaxy M51
color 0B
echo ====================================================================
echo      ColorOS 17 Flagship Port Flasher for Samsung Galaxy M51
echo ====================================================================
echo.
echo Make sure your phone is booted into Fastboot or FastbootD mode!
echo Connect your phone via USB and press any key to continue...
pause >nul

echo.
echo [1/4] Checking device connection...
fastboot devices
echo.

echo [2/4] Flashing Boot & DTBO...
if exist boot.img (
    echo - Flashing boot.img...
    fastboot flash boot boot.img
)
if exist dtbo.img (
    echo - Flashing dtbo.img...
    fastboot flash dtbo dtbo.img
)

echo.
echo [3/4] Flashing Dynamic Super Partition...
if exist super.img (
    echo - Flashing super.img (this may take several minutes)...
    fastboot flash super super.img
)

echo.
echo [4/4] Flashing complete!
echo.
echo IMPORTANT: Enter recovery and wipe/format data before rebooting system!
echo.
pause
