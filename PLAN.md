# Architectural Strategy & Porting Specifications: ColorOS 17 for Galaxy M51

## 1. Flagship Donor ROM Selection
Choosing the **OnePlus 13 (`PJZ110`)** (Snapdragon 8 Elite / `SM8750`) guarantees:
1. **Parallel Processing 2.0 Engine & Tidal Engine**: The multi-threaded animation pipeline introduced in ColorOS 17 remains intact.
2. **Fluid Cloud & Aqua Dynamics**: Dynamic status capsules and interactive notification banners.
3. **Advanced Blur**: Full Gaussian blur in Control Center and lockscreen shaders without falling back to flat translucent colors.
4. **Desktop & Windowing Features**: Freeform floating windows and full multitasking capabilities.
5. **Architectural Alignment**: Qualcomm Snapdragon architecture keeps graphics (Adreno), display composition, and audio interfaces aligned with the Snapdragon 730G (`SM7150`).

## 2. Zero-Lag Optimization for Snapdragon 730G
To deliver flagship fluidity on a mid-range Snapdragon 730G platform with Adreno 618:
- **Pruning Heavy Daemons**: OnePlus 13 ColorOS 17 flagship firmware runs continuous debugging and logging daemons designed for internal testbeds (`oppo_log`, `olc`, `oplus_trace`, `dcs`, `athena_log`). These background services cause constant CPU core spikes on mid-range chips. Pruning them recovers substantial CPU headroom while leaving 100% of user-facing UI and apps functioning.
- **SurfaceFlinger Buffer Latching**: `debug.sf.latch_unsignaled=1` allows frames to latch without waiting for fences, avoiding dropped frames during gesture flings.
- **HWUI Render Thread**: Prioritizing Android's HWUI render thread ensures UI thread draw calls never get pre-empted by background worker threads.
- **Dalvik Heap Calibration**: Heap start size (16MB), growth limit (256MB), and maximum heap (512MB) balanced for 6GB/8GB RAM to prevent memory thrashing.

## 3. Hardware Integration & HAL Bridges
- **Side Fingerprint**: OnePlus 13 natively uses ultrasonic/optical in-display biometrics. The configuration overrides `ro.oplus.display.fp.type=0` and maps biometric service requests directly to the standard Android `android.hardware.biometrics.fingerprint@2.1` HAL used by Samsung M51's physical power-button sensor.
- **Display Cutout**: Center punch-hole camera overlay injected into `framework-res` and `SystemUI` to ensure notification icons are positioned with adequate margin around the camera sensor.
- **Battery Capacity**: Injected `power_profile.xml` sets the true capacity to 7000mAh.
- **VoLTE Bypass**: Samsung's proprietary `libsitril` IPC is incompatible with generic/cross-OEM Qualcomm RILs. Bypassing IMS VoLTE retry loops prevents modem daemon crash loops and preserves cellular standby battery life.
