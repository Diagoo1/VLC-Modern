<p align="center"><img src="res/app_icon.png" width="120" alt="VLC Modern icon"></p>
<h1 align="center">VLC Modern</h1>
<p align="center">A native Windows media player built with Delphi, VCL, and LibVLC.</p>
<p align="center"><a href="README_AR.md">العربية</a> · <a href="#screenshots">Screenshots</a> · <a href="#build-from-source">Build from source</a> · <a href="https://github.com/Diagoo1/VLC-Modern/issues/new">Report an issue</a></p>

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/tag/v0.1.0"><img src="https://img.shields.io/badge/Status-Public%20Beta-D97706" alt="Status: Public Beta"></a> <img src="https://img.shields.io/badge/Platform-Windows%20x86-1473E6" alt="Platform: Windows x86"> <img src="https://img.shields.io/badge/Language-Delphi%2013-E62431" alt="Language: Delphi 13"> <img src="https://img.shields.io/badge/UI-VCL-6D4AFF" alt="UI: VCL"> <img src="https://img.shields.io/badge/Playback-LibVLC%203.0.20-E56A16" alt="Playback: LibVLC 3.0.20"> <img src="https://img.shields.io/badge/Theme-Dark-333333" alt="Theme: Dark"></p>

> **Public Beta.** VLC Modern is in active development. You may encounter bugs or unfinished features. This build is available for testing and feedback.

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v0.1.0/VLC-Modern-v0.1.0-Public-Beta-Full-Windows.zip"><img alt="Download for Windows" src="https://img.shields.io/badge/Download-Windows%20ZIP-1473E6?style=for-the-badge"></a> <a href="https://github.com/Diagoo1/VLC-Modern/issues/new"><img alt="Report a bug" src="https://img.shields.io/badge/Report%20a%20bug-GitHub-586069?style=for-the-badge"></a></p>

<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v0.1.0/VLC-Modern-v0.1.0-Public-Beta-Lite-Windows.zip"><strong>Download Lite</strong></a></p>

- **Full** includes the LibVLC playback plugins and FFmpeg. Precise MP4 clipping uses the bundled encoder on 64-bit Windows.
- **Lite** includes the player and its core DLLs. Install the LibVLC plugins to enable playback and select FFmpeg separately for precise clipping.
- **YouTube** uses the portable Node.js runtime included in both editions on 64-bit Windows.
- **Settings → Playback Components** reopens the component installer and synchronizes selected packages. Restart the player after installing or updating the LibVLC plugins.
<p align="center"><a href="https://github.com/Diagoo1/VLC-Modern/releases/download/v0.1.0/VLC-Modern-v0.1.0-Public-Beta-Full-Windows.zip">Download for Windows</a> · <a href="https://github.com/Diagoo1/VLC-Modern/issues/new">Report a bug</a> · <a href="https://github.com/Diagoo1/VLC-Modern/releases/tag/v0.1.0">v0.1.0 Beta</a></p>

---

## Screenshots

![VLC Modern main player](docs/screenshots/player.png)

**Main player.** The VLC Modern splash screen on startup, with the rounded control dock below.

| Opening media | Preferences | Audio effects |
| --- | --- | --- |
| ![Open Media](docs/screenshots/open-media.png) | ![Preferences](docs/screenshots/preferences.png) | ![Equalizer](docs/screenshots/equalizer.png) |
| Network streams, discs, and capture devices. | Sidebar navigation and playback preferences. | Presets, preamp, and individual frequency bands. |

| Playlist | Fullscreen | Live TV and IPTV |
| --- | --- | --- |
| ![Playlist during playback](docs/screenshots/playlist.png) | ![Fullscreen dock](docs/screenshots/fullscreen.png) | ![IPTV setup](docs/screenshots/iptv.png) |
| Docked queue with the active item highlighted. | Rounded floating dock over the video. | Source selection and connection fields. |

### Light Mode

![VLC Modern playing Cartoon Sky in Light Mode](docs/screenshots/light-player.png)

**Main player.** Light Mode applies to the title bar, menus, and playback controls while the video keeps its original colors.

| Settings | Equalizer |
| --- | --- |
| [![General settings in Light Mode](docs/screenshots/light-preferences.png)](docs/screenshots/light-preferences.png) | [![Audio equalizer in Light Mode](docs/screenshots/light-equalizer.png)](docs/screenshots/light-equalizer.png) |
| Theme selector and playback components. | Presets, preamp, and per-band gain. |

Choose **Light**, **Dark**, or **Follow system** under **Settings → General → Theme**. The default is **Follow system**. Theme changes apply when the player restarts.

### Live TV, network streams, and conversion

Each screenshot opens at full size.

| Live TV / IPTV | Open Network Stream | Convert & Stream Media |
| --- | --- | --- |
| [![Live TV and IPTV source setup](docs/screenshots/iptv.png)](docs/screenshots/iptv.png) | [![Network source and caching setup](docs/screenshots/open-media.png)](docs/screenshots/open-media.png) | [![Media conversion setup](docs/screenshots/convert-stream.png)](docs/screenshots/convert-stream.png) |
| Connect an Xtream Codes or Stalker / MAC provider, open an M3U URL or file, or try playback samples. | Enter an HTTP, RTSP, or RTMP source and set the network cache. Other tabs cover discs and capture devices. | Choose a local file or URL, an output profile, and a destination. The screenshot shows H.264 + AAC in MP4. |

The IPTV source workflow was informed by [IPTVnator](https://github.com/4gray/iptvnator). The screenshots above show VLC Modern. See the [IPTVnator project site](https://4gray.github.io/iptvnator/) for its own interface and features.

[Browse full-size screenshots and captions →](docs/SCREENSHOTS.md)

## Features

| Area | Features |
| --- | --- |
| Playback | Local media, network streams, playlists, playback speed, and fullscreen controls |
| Audio and video | Equalizer, audio filters, and picture adjustments |
| Subtitles | Track selection, external subtitle files, and synchronization |
| Live TV | IPTV source setup and playlist import |
| Windows interface | Dark dialogs, custom menus, seek preview, and taskbar playback controls |

## Build from source

1. Install Delphi 13 with its Win32 compiler, Windows SDK, and PowerShell 7.
2. Put `dcc32` on PATH and run `build.bat` from the repository root.
3. Place the matching **32-bit LibVLC** runtime files beside the executable.

```text
bin/
  VLCModern.exe
  libvlc.dll
  libvlccore.dll
  plugins/
```

Obtain the runtime from [VideoLAN](https://www.videolan.org/vlc/).

## Project layout

| Path | Contents |
| --- | --- |
| `src/core` | Playback integration and settings |
| `src/forms` | Main window and dialogs |
| `src/ui` | Custom controls, menus, and rendering |
| `res` | Application icon, startup artwork, and embedded layouts |
| `tools` | Build scripts |

VLC Modern is an independent project that uses VideoLAN’s LibVLC.
