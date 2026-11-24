# VLC Modern

![VLC Modern artwork](res/splash_screen.png)

A Windows desktop media player built with Delphi 13, VCL, and LibVLC. It supports local media, network streams, playlists, subtitles, an equalizer, and video adjustments.

## Build

Install Delphi 13 with its Win32 compiler and the Windows SDK resource compiler. Make `dcc32` available on PATH and run `build.bat` from the project root.

For playback, place matching 32-bit LibVLC runtime files (`libvlc.dll`, `libvlccore.dll`, and `plugins/`) beside the executable in `bin/`. Obtain the runtime separately from VideoLAN.

## Project layout

| Path | Contents |
| --- | --- |
| `src/core` | Playback integration and settings |
| `src/forms` | Player and dialogs |
| `src/ui` | Custom controls and window rendering |
| `res` | Embedded artwork and page layouts |
