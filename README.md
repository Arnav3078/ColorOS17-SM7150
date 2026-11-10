<h1 align="center">
  <img loading="lazy" src="readme-res/banner.png"/>
</h1>
<p align="center">
  <a href="https://github.com/Arnav3078/ColorOS17-SM7150/blob/main/LICENSE"><img loading="lazy" src="https://img.shields.io/github/license/Arnav3078/ColorOS17-SM7150?style=for-the-badge&logo=github"/></a>
  <a href="https://github.com/Arnav3078/ColorOS17-SM7150/commits/main"><img loading="lazy" src="https://img.shields.io/github/last-commit/Arnav3078/ColorOS17-SM7150/main?style=for-the-badge"/></a>
  <a href="https://github.com/Arnav3078/ColorOS17-SM7150/stargazers"><img loading="lazy" src="https://img.shields.io/github/stars/Arnav3078/ColorOS17-SM7150?style=for-the-badge"/></a>
  <a href="https://github.com/Arnav3078/ColorOS17-SM7150/actions/workflows/build_coloros_m51.yml"><img loading="lazy" src="https://img.shields.io/github/actions/workflow/status/Arnav3078/ColorOS17-SM7150/build_coloros_m51.yml?style=for-the-badge"/></a>
</p>
<p align="center">ColorOS 17 is a work-in-progress custom firmware port for Samsung Galaxy SM7150 devices.</p>

<p align="center">
  <a href="https://github.com/Arnav3078/ColorOS17-SM7150/discussions">🚀 Discussions</a>
  •
  <a href="https://t.me/sm7150">💬 Telegram</a>
</p>

# What is ColorOS for SM7150?
ColorOS for SM7150 is a custom firmware port for Samsung Galaxy SM7150 devices (Galaxy M51 / Galaxy A71), designed to bring a smooth, refined and complete ColorOS experience without compromising on animations, blur effects, or performance.
It is ported from Qualcomm Snapdragon flagship firmware (OnePlus 12 / OPPO Find X7 Ultra) and integrates device-specific hardware adaptations for the Snapdragon 730/730G platform.

The build system runs completely through GitHub Actions, automatically downloading firmware components, extracting system and vendor images, applying device patches, and generating flashable dynamic partition zip packages.

The goal is to deliver a fast, responsive and modern UX with full Gaussian blur, high-end parallel animations, and daily driver usability.

Any form of contribution, suggestions, bug report or feature request for the project will be welcome.

# Features
### Core features:
- Based on official Snapdragon Flagship ColorOS 17 firmware
- EROFS powered dynamic partitions
- Flagship Parallel Processing animation engine
- Native/live blur support (Control Center, folders, lockscreen)
- Aqua Dynamics and Fluid Cloud status notifications
- Luxury lockscreen depth effect & customizable AOD
- 7000mAh battery profile and charging curve for Galaxy M51
- Physical side-mounted capacitive fingerprint sensor support
- AMOLED color profile & display cutout alignment
- Debloated from useless OEM logging and telemetry daemons (oppo_log, olc, oplus_trace, dcs)
- Dolby Atmos audio integration
- Clean 60fps UI rendering tuned for Adreno 618 / SM7150
- Dual SIM cellular, LTE mobile data, SMS, Wi-Fi, and Bluetooth working
- VoLTE is not supported due to proprietary Samsung RIL limitations on cross-OEM ports

### Port-exclusive features:
- Automated GitHub Actions build workflow (no local compilation)
- FastbootD and Recovery (TWRP / OrangeFox) flashable zip generation
- KernelSU / Next-KernelSU root integration support
- HWUI and SurfaceFlinger rendering optimizations for zero-lag gesture flings

# Licensing
This project is licensed under the terms of the [GNU General Public License v3.0](LICENSE). External dependencies might be distributed under a different license, such as:
- [android-tools](https://github.com/nmeum/android-tools), licensed under the [Apache License 2.0](https://github.com/nmeum/android-tools/blob/master/LICENSE)
- [apktool](https://github.com/iBotPeaches/Apktool), licensed under the [Apache License 2.0](https://github.com/iBotPeaches/Apktool/blob/master/LICENSE.md)
- [erofs-utils](https://github.com/sekaiacg/erofs-utils/), dual license ([GPL-2.0](https://github.com/sekaiacg/erofs-utils/blob/dev/LICENSES/GPL-2.0), [Apache-2.0](https://github.com/sekaiacg/erofs-utils/blob/dev/LICENSES/Apache-2.0))
- [lpmake](https://android.googlesource.com/platform/system/extras/), licensed under the [Apache License 2.0](https://source.android.com/docs/setup/about/licenses)
- [payload-dumper-go](https://github.com/ssut/payload-dumper-go), licensed under the [Apache License 2.0](https://github.com/ssut/payload-dumper-go/blob/master/LICENSE)

# Credits
A special thanks goes to the following for their invaluable contributions in no particular order:
- **[toraidl](https://github.com/toraidl)** for ColorOS porting research and tools
- **OPPO & OnePlus** for ColorOS and OxygenOS
- *All SM7150 developers, testers and contributors ❤️*
