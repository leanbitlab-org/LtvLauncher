# LTvLauncher

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/banner_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset=".github/assets/banner_light.svg">
  <img alt="LTvLauncher Banner" src=".github/assets/banner_light.svg">
</picture>

<div align="center">

[![Latest Release](https://img.shields.io/github/v/release/leanbitlab-org/LtvLauncher?style=flat-square&color=4f46e5&label=Release)](https://github.com/leanbitlab-org/LtvLauncher/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/leanbitlab-org/LtvLauncher/total?style=flat-square&color=059669&label=Downloads)](https://github.com/leanbitlab-org/LtvLauncher/releases)
[![Stars](https://img.shields.io/github/stars/leanbitlab-org/LtvLauncher?style=flat-square&color=dc2626&label=Stars)](https://github.com/leanbitlab-org/LtvLauncher/stargazers)
[![License: GPL v3](https://img.shields.io/badge/License-GPL_v3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)
[![Sponsor](https://img.shields.io/badge/Sponsor-LeanBitLab-db2777?style=flat-square&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/LeanBitLab)
[![Donate on Open Collective](https://img.shields.io/badge/Donate-Open_Collective-1f6feb?style=flat-square&logo=opencollective&logoColor=white)](https://opencollective.com/leanbitlab-org)

**A fast, private, and customizable open-source launcher for Android TV.**  
*Forked from [FLauncher](https://github.com/osrosal/flauncher) (originally by [etienn01](https://gitlab.com/flauncher/flauncher)).*

[Screenshots](#-screenshots) • [Download APKs](#-download) • [Features](#-features) • [Setup Guide](#-setup-guide) • [Community](#-community--contributing) • [Other Projects](https://github.com/LeanBitLab#-android-projects)

</div>

---

## 🚀 Overview

**LTvLauncher** is an open-source, private, and ad-free launcher designed specifically for Android TV, Google TV, and Fire TV devices. Built with Flutter, it delivers a responsive, remote-friendly interface focused on simplicity, speed, and deep customization.

With native D-pad navigation, recency-sorted Continue Watching rows, customizable categories, dynamic weather & status bar widgets, TV input source switching, system-wide notification overlays, and OLED screensavers, LTvLauncher gives you total control over your TV home screen without intrusive ads or algorithmic noise.

---

## 📸 Screenshots

<table>
  <tr>
    <td align="center"><b>Home Screen</b></td>
    <td align="center"><b>Settings Overview</b></td>
    <td align="center"><b>Category & Layout</b></td>
    <td align="center"><b>Accessibility & Remap</b></td>
    <td align="center"><b>OLED Screensaver</b></td>
  </tr>
  <tr>
    <td><img src="docs/images/screenshot_1.png" width="180" alt="Home Screen"/></td>
    <td><img src="docs/images/screenshot_2.png" width="180" alt="Settings Overview"/></td>
    <td><img src="docs/images/screenshot_3.png" width="180" alt="Category & Layout"/></td>
    <td><img src="docs/images/screenshot_4.png" width="180" alt="Accessibility & Remap"/></td>
    <td><img src="docs/images/screensaver.gif" width="180" alt="OLED Screensaver"/></td>
  </tr>
</table>

---

## ✨ Features

### 🎬 Continue Watching & Channels
- **Smart Recency Sorting**: Automatically aggregates and sorts Watch Next program cards by their latest playback timestamp, ensuring your most recently watched shows and movies always appear first.
- **Theme-Adaptive Cards**: Media cards automatically adapt to the active visual style, including glowing focus indicators, border outlines, and corner radiuses.
- **Clean Settings Configuration**: Toggle the Continue Watching channel directly from Settings without cluttering the home screen with persistent permission warnings.

### 🌤️ Status Bar & Weather Integration
- **Breezy Weather Integration**: Seamless support for local weather forecasts via Breezy Weather and Open-Meteo.
- **Smart Unit Conversion**: Automatic Kelvin-to-Celsius/Fahrenheit auto-detection and conversion to prevent temperature anomalies.
- **Weather Indicators**: Configurable precipitation/rain warning icons and customizable refresh intervals.
- **Live Data Consumption Tracker**: Monitor daily network bandwidth (WiFi, Ethernet, or Mobile) directly from the status bar.
- **Quick WiFi Shortcut**: Network status icon doubles as a 1-click shortcut to system WiFi settings.
- **Stable Focus Traversal**: Precise remote focus alignment preventing focus jumps when navigating the status bar.

### 🔔 System Notifications & TV Keypad Control
- **Global Floating Overlays**: Receive real-time notification alerts overlaid across any running TV app.
- **Notification Drawer**: Dedicated remote-friendly panel to view, inspect, and manage system notifications.
- **Intuitive Blocked Apps Manager**: Clean TV remote D-pad controls (Up/Down navigation, Left/Right quick removal, and Clear All) to block unwanted notifications.

### 🎨 Themes, Customization & Banners
- **4 Distinct Visual Themes**: Choose between **Modern / Default**, **Premium**, **Classic**, and **Capsule** card styles.
- **Accent Color Engine**: Personalize the launcher with multiple vibrant color swatches and presets.
- **Dynamic Wallpapers**: Time-based automatic switching between day and night backgrounds, or a true pitch-black background for OLED displays.
- **Custom Banner Support**: Assign custom banner images to sideloaded and unthemed Android TV apps.
- **High-Visibility Focus Indicators**: Double-border focus indicator ensuring sharp cursor visibility on any background, complete with edge bump resistance.

### 📺 TV Inputs & Accessibility
- **Hardware Input Source Selector**: Quickly switch between HDMI 1, HDMI 2, AV, and component inputs directly from the launcher.
- **Built-in Home Button Fix**: Seamless accessibility remapper service for Google TV and Fire TV devices that override default launchers.
- **Burn-in Protection Screensaver**: Minimal OLED screensaver with 30-second clock position shifting.
- **Audio Feedback**: Remote key navigation sound feedback.

### 💾 Privacy & Data Management
- **100% Ad-Free & Private**: No analytics, no ads, no trackers, zero network telemetry.
- **Multiple Backups & Restore Dialog**: Export configuration backups with timestamps and restore them via a D-pad friendly picker.
- **Category Customization**: Reorder, rename, hide, and organize apps in grid or row layouts with remote arrow keys.

---

## 📥 Download

<table border="0">
  <tr>
    <td align="center" valign="middle">
      <a href="https://github.com/leanbitlab-org/LtvLauncher/releases/latest">
        <img alt="Get it on GitHub" src=".github/assets/get_it_on_github.png" height="75">
      </a>
    </td>
    <td align="center" valign="middle">
      <a href="https://apt.izzysoft.de/fdroid/index/apk/com.leanbitlab.ltvL">
        <img alt="Get it on IzzyOnDroid" src=".github/assets/IzzyOnDroid.png" height="75">
      </a>
    </td>
    <td align="center" valign="middle">
      <a href="https://go.aftvnews.com">
        <img alt="Downloader Code: 7259827" src=".github/assets/get_it_on_downloader.png" height="75">
      </a>
    </td>
    <td align="center" valign="middle">
      <a href="https://github.com/leanbitlab-org/LtvLauncher/releases">
        <img alt="Pre-release" src=".github/badges/prerelease.png" height="75">
      </a>
    </td>
  </tr>
</table>

### Architecture Matrix

| File | Target Devices | Architecture |
|:---|:---|:---|
| **`LTvLauncher-universal-release.apk`** | **Recommended** for any Android TV or Fire TV device | Universal |
| **`LTvLauncher-arm64-v8a-release.apk`** | Chromecast with Google TV (4K/HD), Nvidia Shield TV, newer smart TVs | 64-bit ARM (`arm64-v8a`) |
| **`LTvLauncher-armeabi-v7a-release.apk`** | Fire TV Stick (Lite, 4K, 4K Max), older smart TVs, budget boxes | 32-bit ARM (`armeabi-v7a`) |

> [!TIP]
> **Fast Installation via the Downloader App (Fire TV & Android TV)**:
> 1. Open the **Downloader** app by AFTVnews on your TV (available on Amazon Appstore & Google Play Store).
> 2. Enter quick code **`7259827`** in the URL / search box.
> 3. Downloader will automatically download and prompt you to install the latest LTvLauncher release.

---

## 🛠️ Setup Guide

### Method 1: Via Built-in Settings (Recommended for Android TV)
This is the easiest and native way:
1. Open **Settings -> Accessibility -> Set as default launcher**.
2. Select **LTvLauncher** from the system home app picker or default apps list.

> [!NOTE]
> On **Google TV**, the stock launcher (`com.google.android.apps.tv.launcherx`) registers its HOME intent with priority 2, which overrides third-party launcher selections. If your device returns to Google TV when pressing Home, use **Method 2**.

### Method 2: Home Button Fix (Google TV & Fire TV)
If your device blocks changing the default launcher, use LTvLauncher's built-in Home Button Fix:
1. Open **Settings -> Accessibility**.
2. Select **Home Button Fix (Google TV)**.
3. Turn on the accessibility service for **LTvLauncher** in your system settings.

Once enabled, LTvLauncher automatically intercepts Home button presses and brings you straight to your custom home screen.

### Method 3: Remap the Home button via Key Mapper
If you prefer key remapping:
1. Install [Key Mapper](https://github.com/keymapperorg/KeyMapper).
2. Create a trigger for your remote's **Home** button.
3. Bind the action to launch **LTvLauncher**.

### Method 4: Disable the default launcher via ADB

> [!WARNING]
> Disabling system packages carries risks. Proceed with caution and ensure you have ADB debugging enabled on your TV.

Connect your computer to your TV via ADB (`adb connect <tv-ip-address>`) and run:

```shell
# Disable the default Google TV launcher
$ adb shell pm disable-user --user 0 com.google.android.apps.tv.launcherx

# Disable setup fallback to prevent auto-reenabling
$ adb shell pm disable-user --user 0 com.google.android.tungsten.setupwraith
```

To re-enable the default launcher at any time:
```shell
$ adb shell pm enable com.google.android.apps.tv.launcherx
$ adb shell pm enable com.google.android.tungsten.setupwraith
```

---

## 📱 More Android Projects by LeanBitLab

Discover our complete suite of privacy-first, open-source Android applications and utilities:  
👉 **[Explore All LeanBitLab Android Projects](https://github.com/LeanBitLab#-android-projects)**

---

## 🤝 Community & Contributing

- **Bug Reports & Feature Requests**: [Open a GitHub Issue](https://github.com/leanbitlab-org/LtvLauncher/issues)
- **Discussions & Feedback**: [GitHub Discussions](https://github.com/leanbitlab-org/LtvLauncher/discussions)
- **Official Telegram Channel**: [@LeanBitLab](https://t.me/leanbitlab)

---

## 💖 Support the Project

Building and maintaining a lightweight, ad-free Android TV launcher requires hardware testing across various TV chipsets, display profiles, and continuous development.

If LTvLauncher improves your daily TV experience, please consider supporting our work!

<div align="left">
  <a href="https://github.com/sponsors/LeanBitLab">
    <img src="https://img.shields.io/static/v1?label=Sponsor%20on%20GitHub&message=%E2%9D%A4&logo=GitHub&color=%23db2777" height="38" alt="Sponsor LeanBitLab on GitHub"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://opencollective.com/leanbitlab-org">
    <img src="https://img.shields.io/static/v1?label=Donate%20on&message=Open%20Collective&logo=opencollective&logoColor=white&color=%231f6feb" height="38" alt="Donate to LeanBitLab on Open Collective"/>
  </a>
</div>

---

## 📜 Credits & Acknowledgments

- **[FLauncher](https://gitlab.com/flauncher/flauncher)** by [etienn01](https://github.com/etienn01) — The original TV launcher project.
- **[FLauncher (Fork)](https://github.com/osrosal/flauncher)** by [osrosal](https://github.com/osrosal) — The foundation for this fork.
- All [contributors](https://github.com/leanbitlab-org/LtvLauncher/graphs/contributors) and open-source supporters!

---

## ⚖️ License

LTvLauncher is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
See the [LICENSE](LICENSE) file for details.
