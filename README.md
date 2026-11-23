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

**A fast, private and customizable open-source launcher for Android TV.**<br>
Forked from [FLauncher](https://github.com/osrosal/flauncher) (originally by [etienn01](https://gitlab.com/flauncher/flauncher)). No ads, no tracking and full D-pad remote control.

[Download](#download) • [Features](#features) • [Setup](#setup) • [More LeanBitLab apps](#more-leanbitlab-apps) • [Support](#support)

</div>

<table>
  <tr>
    <td><img src="docs/images/screenshot_1.png" width="160" alt="Home Screen"/></td>
    <td><img src="docs/images/screenshot_2.png" width="160" alt="Settings Overview"/></td>
    <td><img src="docs/images/screenshot_3.png" width="160" alt="Category & Layout"/></td>
    <td><img src="docs/images/screenshot_4.png" width="160" alt="Accessibility & Remap"/></td>
    <td><img src="docs/images/screensaver.gif" width="160" alt="OLED Screensaver"/></td>
  </tr>
</table>

## Why LTvLauncher

- **Private and ad-free**: no analytics, tracking, ads or network telemetry.
- **Continue Watching**: recency-sorted Watch Next media cards that automatically adapt to your active theme.
- **Status bar and weather**: Breezy Weather and Open-Meteo forecasts, rain alerts, a daily network data tracker and a quick WiFi shortcut.
- **System notifications**: floating remote-friendly overlays across any TV app, with a dedicated drawer and blocked apps manager.
- **Themes and OLED care**: 4 card styles, accent colors, day/night wallpapers, custom banners and an OLED burn-in protection screensaver.
- **TV inputs and remap**: switch HDMI and AV inputs directly, with a built-in accessibility service to fix the Home button on Google TV and Fire TV.

## Download

<table border="0">
  <tr>
    <td align="center"><a href="https://github.com/leanbitlab-org/LtvLauncher/releases/latest"><img alt="Get it on GitHub" src=".github/assets/get_it_on_github.png" height="70"></a></td>
    <td align="center"><a href="https://apt.izzysoft.de/fdroid/index/apk/com.leanbitlab.ltvL"><img alt="Get it on IzzyOnDroid" src=".github/assets/IzzyOnDroid.png" height="70"></a></td>
    <td align="center"><a href="https://go.aftvnews.com"><img alt="Downloader Code: 7259827" src=".github/assets/get_it_on_downloader.png" height="70"></a></td>
    <td align="center"><a href="https://github.com/leanbitlab-org/LtvLauncher/releases"><img alt="Pre-release" src=".github/badges/prerelease.png" height="70"></a></td>
  </tr>
</table>

**Which APK?**

| APK | Pick it if you want | Architecture |
| :--- | :--- | :--- |
| `LTvLauncher-universal-release.apk` (recommended) | Any Android TV or Fire TV device | Universal |
| `LTvLauncher-arm64-v8a-release.apk` | Chromecast with Google TV, Nvidia Shield TV, newer smart TVs | 64-bit ARM (`arm64-v8a`) |
| `LTvLauncher-armeabi-v7a-release.apk` | Fire TV Stick, older smart TVs, budget boxes | 32-bit ARM (`armeabi-v7a`) |

Install directly on TV devices using the Downloader app with quick code **7259827**.

## Features

| Area | Highlights |
| :--- | :--- |
| **Continue Watching** | Smart recency sorting for Watch Next program cards, theme-adaptive cards with focus indicators, clean toggle in settings |
| **Status bar & weather** | Breezy Weather and Open-Meteo forecasts, auto Kelvin conversion, precipitation warnings, daily network data tracker, WiFi shortcut |
| **Notifications** | Global floating overlay across any app, remote-friendly notification drawer, D-pad blocked apps manager |
| **Look & feel** | 4 visual themes (Modern, Premium, Classic, Capsule), accent color engine, day/night and OLED black backgrounds, custom banners |
| **TV inputs & accessibility** | Hardware input source selector (HDMI/AV), built-in Home Button Fix, OLED burn-in protection screensaver, navigation sound feedback |
| **Management & privacy** | Zero analytics or network telemetry, timestamped configuration backup and restore, category reordering and grid/row layouts |

## Setup

| Method | Target devices | Steps |
| :--- | :--- | :--- |
| **Default launcher** | Android TV (recommended) | **Settings → Accessibility → Set as default launcher** |
| **Home Button Fix** | Google TV and Fire TV | Enable in **Settings → Accessibility → Home Button Fix (Google TV)** |
| **Key Mapper** | Custom remote remap | Bind the remote Home button to LTvLauncher with [Key Mapper](https://github.com/keymapperorg/KeyMapper) |

On Google TV, the stock launcher overrides third-party selections. If pressing Home returns to Google TV, enable the Home Button Fix or disable the stock launcher via ADB.

<details>
<summary><b>Disable stock launcher via ADB</b></summary>

Disabling system packages carries risks, so proceed with care. Connect your computer to your TV via ADB (`adb connect <tv-ip-address>`) and run:

```shell
adb shell pm disable-user --user 0 com.google.android.apps.tv.launcherx
adb shell pm disable-user --user 0 com.google.android.tungsten.setupwraith
```

To re-enable at any time:

```shell
adb shell pm enable com.google.android.apps.tv.launcherx
adb shell pm enable com.google.android.tungsten.setupwraith
```

</details>

## More LeanBitLab apps

| App | What it is |
| :--- | :--- |
| [LeanType](https://github.com/LeanBitLab/LeanType) | Private, smart and customizable keyboard with AI, voice and offline options |
| [Lwidget](https://github.com/LeanBitLab/Lwidget) | Material You information widget with no internet permission |
| [RdTube](https://github.com/LeanBitLab/RdTube) | Private, fast video client for Reddit |

See [all LeanBitLab projects](https://github.com/LeanBitLab#-android-apps).

## Community

[Issues](https://github.com/leanbitlab-org/LtvLauncher/issues) • [Discussions](https://github.com/leanbitlab-org/LtvLauncher/discussions) • [Telegram](https://t.me/leanbitlab)

## Support

LTvLauncher is community-funded. If it improves your daily TV experience, consider backing it on [GitHub Sponsors](https://github.com/sponsors/LeanBitLab) or [Open Collective](https://opencollective.com/leanbitlab-org).

## Credits and license

Forked from [FLauncher](https://github.com/osrosal/flauncher) by [osrosal](https://github.com/osrosal), originally created as [FLauncher](https://gitlab.com/flauncher/flauncher) by [etienn01](https://github.com/etienn01). Thanks to all [contributors](https://github.com/leanbitlab-org/LtvLauncher/graphs/contributors).

Licensed under [GPL-3.0](LICENSE).
