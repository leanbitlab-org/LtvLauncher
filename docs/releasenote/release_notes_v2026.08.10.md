### 💖 Support Our Work

As an open-source, community-funded project, we operate on a very limited budget. If LTvLauncher helps you daily, please consider supporting us on [GitHub Sponsors](https://github.com/sponsors/LeanBitLab) or [Open Collective](https://opencollective.com/leanbitlab-org). Sharing LTvLauncher with friends and family makes a huge difference!

## 🚀 What's New in v2026.08.10

### ✨ Highlights & Enhancements
- **Watch Next & Continue Watching Recency Sorting**:
  - Automatically sorts Continue Watching media cards by last watch timestamp, ensuring the most recently watched content always appears first.
  - Adapted continue-watching card shapes, glow indicators, and borders to harmoniously match the selected launcher theme (Modern, Classic, Premium, Capsule).
  - Cleaned up home screen ADB permission notices and moved toggle configuration cleanly into Settings.
- **Weather & Status Bar Harmonization**:
  - Added full Celsius / Fahrenheit / Kelvin auto-conversion for Breezy Weather integration to prevent high-temperature Kelvin display issues.
  - Unified weather typography and icon styling to match the launcher status bar.
  - Made weather display disabled by default for a minimalist initial experience.
- **Categorized Settings & TV Keypad Blocked Apps Management**:
  - Reorganized the settings screen into intuitive categories: Appearance, Applications, Status Bar & Weather, System & Integration, and Accessibility.
  - Redesigned the Blocked Notifications / Blocked Apps settings page with full D-pad keypad controls (Up/Down navigation, Left/Right quick remove, Clear All).

### 🐛 Bug Fixes & Refinements
- **Status Bar Focus & Alignment**:
  - Fixed status bar network widget D-pad focus jump by separating WiFi and VPN focus targets.
  - Aligned settings icon with the left edge of application tiles.
- **Large App Grid Scrolling**:
  - Fixed D-pad scrolling for off-screen sections (>6 sections) using fallback focus traversal and clamping scroll physics (#108).
- **Icon Caching & Stability**:
  - Resolved stale icon cache references when the application list changes.
  - Ensured newly installed applications respect category sort order immediately.

## 📦 Downloads (Choose Your Architecture)

| File | Target Devices | Architecture |
|:---|:---|:---|
| **`LTvLauncher-universal-release.apk`** | All Android TV & Fire TV devices (Universal) | Universal |
| **`LTvLauncher-arm64-v8a-release.apk`** | Chromecast with Google TV, Nvidia Shield, modern 64-bit Android TVs | 64-bit ARM (`arm64-v8a`) |
| **`LTvLauncher-armeabi-v7a-release.apk`** | Fire TV Stick (Lite, 4K, 4K Max), older smart TVs | 32-bit ARM (`armeabi-v7a`) |
