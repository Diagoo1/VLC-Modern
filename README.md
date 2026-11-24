<p align="center"><img src="res/app_icon.png" width="120" alt="VLC Modern icon"></p>
<h1 align="center">VLC Modern</h1>
<p align="center">A native Windows media player built with Delphi, VCL, and LibVLC.</p>
<p align="center"><a href="README_AR.md">العربية</a> · <a href="#screenshots">Screenshots</a> · <a href="#build-from-source">Build from source</a> · <a href="https://github.com/Diagoo1/VLC-Modern/issues/new">Report an issue</a></p>

---

## Screenshots

![VLC Modern main player](docs/screenshots/player.png)

**Main player.** The video canvas, seek bar, and rounded transport dock make up the primary workspace.

| Opening media | Preferences | Audio effects |
| --- | --- | --- |
| ![Open Media](docs/screenshots/open-media.png) | ![Preferences](docs/screenshots/preferences.png) | ![Equalizer](docs/screenshots/equalizer.png) |
| Network streams, discs, and capture devices. | Sidebar navigation and playback preferences. | Presets, preamp, and individual frequency bands. |

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
