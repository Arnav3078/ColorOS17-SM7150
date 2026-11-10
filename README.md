# ColorOS 17 Flagship Port for Samsung Galaxy M51 (`m51` / SM7150)

[![Build ColorOS 17](https://github.com/Arnav3078/ColorOS17-SM7150/actions/workflows/build_coloros_m51.yml/badge.svg)](https://github.com/Arnav3078/ColorOS17-SM7150/actions/workflows/build_coloros_m51.yml)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

An automated GitHub Actions CI/CD pipeline to port **ColorOS 17** from a **Qualcomm Snapdragon Flagship** (OnePlus 12 / OPPO Find X7 Ultra) to the **Samsung Galaxy M51 (`SM-M515F`)**.

Built to deliver **100% flagship visual features, Parallel Processing Animations, Gaussian blurs, and Fluid Cloud**, paired with a **Zero-Lag optimization engine** specifically tuned for the Snapdragon 730G without putting any compilation strain on your local machine.

---

## 🌟 Highlights & Features

- **Flagship Snapdragon Donor**: Sourced from Snapdragon 8 Gen 3 flagship builds (OnePlus 12 `PJD110` / Find X7 Ultra `PHY110`) — no stripped-down mid-range Reno/A-series cuts.
- **Uncompromised Visuals & Animations**:
  - Full **Gaussian Blur** across Control Center, Notification Shade, Volume Panel, and App Folders (`persist.sys.sf.disable_blur=0`).
  - Flagship **Parallel Processing Animation Engine** for ultra-responsive gesture navigation and app launch scaling.
  - **Aqua Dynamics & Fluid Cloud** live notification pills.
  - **Luxury Lockscreen Depth Effects** and customized Always-On Display for Super AMOLED Plus.
- **Zero-Lag Engine for SM7150**:
  - Eliminates CPU micro-stutter by stripping heavy background profiling daemons (`oppo_log`, `olc`, `oplus_trace`, `dcs`, crash reporters).
  - SurfaceFlinger buffer latching & HWUI render-thread prioritization (`debug.sf.latch_unsignaled=1`, `debug.hwui.render_thread=true`).
  - ART runtime & Dalvik VM heap calibration for 6GB/8GB RAM.
- **Hardware Integration for Galaxy M51**:
  - **Fingerprint**: Custom side-mounted capacitive biometric mapping (`ro.oplus.display.fp.type=0`), preventing under-display FOD crash loops.
  - **Battery**: Custom 7000mAh power profile with accurate charging curves and endurance management.
  - **Display Cutout**: Centered punch-hole cutout coordinates with matched status-bar padding.
  - **Audio**: Dolby Atmos integration with Samsung SM7150 audio HAL.

---

## 📱 Hardware Status

| Feature | Status | Notes |
| :--- | :---: | :--- |
| **Boot & System UI** | ✅ Working | Fluid 60fps UI, Parallel Animation Engine active |
| **Gaussian Blurs** | ✅ Working | Quick Settings, lockscreen, and folders blur fully retained |
| **Display & Touch** | ✅ Working | Full Super AMOLED Plus 1080x2400 resolution, AOD |
| **Fingerprint Sensor** | ✅ Working | Physical side-mounted capacitive sensor |
| **Audio & Speaker** | ✅ Working | Dolby Atmos, headphone jack, earpiece, microphone |
| **Camera** | ✅ Working | Photo, video capture, flashlight |
| **Wi-Fi & Bluetooth** | ✅ Working | 2.4GHz/5GHz Wi-Fi, Bluetooth audio & LE accessories |
| **Mobile Data & Calls**| ✅ Working | 4G/LTE mobile data, SMS, standard cellular calls |
| **Battery Management**| ✅ Working | Native 7000mAh capacity curve & 25W charging |
| **VoLTE / IMS** | ❌ Bypassed | Proprietary Samsung closed-source RIL limitation on cross-OEM ports |

---

## 🚀 Building via GitHub Actions (Zero Local Laptop Strain)

This repository is designed to run the full porting, extraction, patching, and dynamic partition building process on **GitHub Actions Ubuntu Runners**, requiring **no build tools or compilation on your personal laptop**.

### How to Trigger the Build:
1. Go to your repository on GitHub: [`Arnav3078/ColorOS17-SM7150`](https://github.com/Arnav3078/ColorOS17-SM7150).
2. Click on the **Actions** tab.
3. In the left sidebar, click on **Build ColorOS 17 for Galaxy M51**.
4. Click the **Run workflow** dropdown button:
   - **Donor ROM URL**: Direct download link to the Snapdragon flagship ColorOS payload/zip (e.g. OnePlus 12 `PJD110` / Find X7 Ultra `PHY110`).
   - **Base Vendor URL**: URL to the Galaxy M51 / SM7150 base vendor archive.
   - **Repack Filesystem**: `EROFS` (recommended) or `EXT4`.
   - **Integrate KernelSU**: Check `true` to embed root directly into boot image.
   - **Release ROM**: Check `true` to auto-publish to GitHub Releases.
   - **Upload to GoFile**: Check `true` for a high-speed direct download mirror.
5. Click **Run workflow**.
6. The workflow will execute, extract the partitions, apply all M51 optimizations, generate the flashable `super.img`, assemble the ZIP, and provide the download link.

---

## 📲 Flashing Instructions

### Prerequisites
- Samsung Galaxy M51 (`SM-M515F`) with **Unlocked Bootloader**.
- OrangeFox Recovery or TWRP for Galaxy M51 installed.
- Back up all internal storage before proceeding.

### Method 1: Recovery Flash (Recommended)
1. Download the generated `ColorOS17_M51_SM7150_FlagshipPort_*.zip` from the GitHub Release or GoFile mirror.
2. Boot into Recovery (Hold `Volume Up` + `Power` with USB connected).
3. In Recovery, perform a **Format Data** (type `yes`).
4. Transfer the ROM ZIP to your device or microSD card / OTG.
5. Flash the ZIP: **Install -> Select ZIP -> Swipe to Flash**.
6. Once installation completes, reboot system.

### Method 2: FastbootD Flashing (PC)
1. Extract the ROM zip on your computer.
2. Reboot phone to FastbootD mode (`adb reboot fastboot`).
3. Connect phone to PC via USB.
4. On Windows: Run `flash_all.bat`.
   On Linux/macOS: Run `chmod +x flash_all.sh && ./flash_all.sh`.
5. Enter Recovery and **Format Data**, then reboot to system.

---

## 🛠️ Repository Architecture

```
ColorOS17-SM7150/
├── .github/
│   └── workflows/
│       └── build_coloros_m51.yml   # Master GitHub Actions CI workflow
├── device/
│   └── samsung/
│       └── m51/
│           ├── device.prop         # Hardware identifiers for SM-M515F
│           ├── tweaks.prop         # Zero-lag, parallel animation & HWUI tuning
│           ├── bloat_prune.list    # Telemetry and logging daemons to strip
│           ├── overlays/           # RRO Overlays (7000mAh, punch hole, side-FP)
│           └── sepolicy/           # SELinux compatibility rules
├── scripts/
│   ├── setup_tools.sh              # Sets up lpmake, payload-dumper, and utilities
│   ├── port_coloros.sh             # Core automated porting engine
│   └── make_super.sh               # lpmake dynamic super partition & zip builder
├── installer/
│   ├── META-INF/                   # Recovery updater-binary and update-script
│   ├── flash_all.bat               # 1-click Windows Fastboot flasher
│   └── flash_all.sh                # 1-click Linux/macOS Fastboot flasher
└── PLAN.md                         # Detailed technical implementation plan
```

---

## 📜 Credits & Acknowledgments
- **OPPO & OnePlus** for ColorOS and OxygenOS.
- **Samsung** for Galaxy M51 hardware foundation.
- **toraidl** for initial ColorOS porting tool research and smali concepts.
- **Arnav3078** for SM7150 development, device maintenance, and project architecture.
