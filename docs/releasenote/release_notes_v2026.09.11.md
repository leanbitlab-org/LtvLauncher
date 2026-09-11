### 💖 Support Our Work

As an open-source, community-funded project, we operate on a very limited budget. If LTvLauncher helps you daily, please consider supporting us on [GitHub Sponsors](https://github.com/sponsors/LeanBitLab) or [Open Collective](https://opencollective.com/leanbitlab-org). Sharing LTvLauncher with friends and family makes a huge difference!

## 🚀 What's New in v2026.09.11

### ✨ Highlights & Enhancements
- **Watch Next & Continue Watching Upgrades**:
  - **Reorderable Home Section**: Continue Watching is now a first-class section in Launcher Sections, freely reorderable anywhere alongside categories and spacers.
  - **Recency Sorting**: Content automatically sorts by latest watch timestamp so your ongoing media is always front and center.
  - **Granular Display Settings**: Configure card sizes (Compact, Standard, Large), adjust maximum items, and toggle progress bars or descriptions.
  - **Category Title Synchronization**: Header cleanly syncs with the "Show category titles" preference.
  - **Contextual Actions & Per-App Blocklist**: Long-press any card to hide individual items, block source apps from recommendations, or jump directly to app settings.
  - **Theme-Adapted Cards**: Visual shapes, borders, and focus glows seamlessly adapt to Modern, Classic, Premium, and Capsule themes.
- **Snappy & OLED-Dark Settings Interface**:
  - **Refined Contrast**: Ultra-dark background (`#0A0A0A`) and card surfaces (`#0F0F0F`) optimized for OLED displays and high contrast.
  - **Instant Navigation**: Eliminated transition delay and route ghosting for snappy sub-page switches.
  - **Instant Remote Feedback**: Removed click animations and ink ripples across all settings tiles for immediate D-pad responsiveness.
  - **Streamlined Layout**: Categorized into modular panels with the section reordering guide positioned cleanly at the bottom.
  - **Dedicated Support & Donation**: Moved support tile below Accessibility with clean monochrome icon and dedicated QR donate dialog.
- **Weather & Status Bar Harmonization**:
  - Full Celsius, Fahrenheit, and Kelvin auto-conversion for Breezy Weather integration to eliminate temperature display glitches.
  - Weather icon and typography styled to match the status bar, with option to preserve current conditions during active weather warnings.
  - Made weather display disabled by default for a minimalist initial experience.
- **TV-Friendly Navigation & Keypad Controls**:
  - Redesigned Blocked Notifications / Blocked Apps settings page with full remote D-pad keypad controls (Up/Down navigation, Left/Right quick remove, Clear All).
  - TV apps automatically default to the top row above non-TV apps out of the box.
  - Smooth horizontal scrolling for card carousels and preserved status bar focus alignment.
- **Accessibility & System Integration**:
  - Added Start on Boot option for devices whose stock launcher intercepts HOME.
  - Enhanced Home Button Fix accessibility remapper for Google TV and Fire TV devices.
  - Improved D-pad scrolling for off-screen sections (>6 sections) via robust scrollable visibility context.
- **Expanded Localization**:
  - Added and updated translations for 10+ languages (French, German, Japanese, Portuguese, Russian, Italian, Hindi, Korean, Arabic, Turkish, Chinese, Ukrainian).

### 🐛 Bug Fixes & Refinements
- **Watch Next**: Resolved background-thread thumbnail loading and Android TV card click launch intents.
- **Status Bar**: Fixed WiFi/VPN focus jumps, aligned settings icon with app tiles, and kept icons stationary during focus shifts.
- **App List Integrity**: Preserved icon bindings when apps list updates, and ensured newly installed apps immediately respect category sorting.
- **Settings & Android TV**: Fixed notification access redirect on Android TV and added missing platform imports in MainActivity.

## 📦 Downloads (Choose Your Architecture)

| File | Target Devices | Architecture |
|:---|:---|:---|
| **`LTvLauncher-universal-release.apk`** | All Android TV & Fire TV devices (Universal) | Universal |
| **`LTvLauncher-arm64-v8a-release.apk`** | Chromecast with Google TV, Nvidia Shield, modern 64-bit Android TVs | 64-bit ARM (`arm64-v8a`) |
| **`LTvLauncher-armeabi-v7a-release.apk`** | Fire TV Stick (Lite, 4K, 4K Max), older smart TVs | 32-bit ARM (`armeabi-v7a`) |
