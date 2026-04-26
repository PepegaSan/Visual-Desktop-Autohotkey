# Visual Desktop AutoHotkey (win11-vd-api)

AutoHotkey **v2** scripts for **Windows 11** virtual desktops using **[VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor)** — switch desktop view and move the active window **without** relying on `Win`+`Ctrl`+`Shift`+arrow.

## License

- **This repository** (`.ahk`, `.ps1`, docs): **MIT** — see [`LICENSE`](LICENSE).
- **`VirtualDesktopAccessor.dll`**: third-party **MIT**-licensed binary (**Ciantic**). It is **committed here** for convenience and offline use, together with the upstream license copy under [`third-party/VirtualDesktopAccessor/LICENSE.txt`](third-party/VirtualDesktopAccessor/LICENSE.txt). Details: [`THIRD_PARTY.md`](THIRD_PARTY.md).

## Requirements

- **Windows 11** — upstream notes a minimum around **24H2 Build 26100.2605**; older builds may fail or crash. Update Windows or use an older upstream release at your own risk.
- **[AutoHotkey v2](https://www.autohotkey.com/)**
- **`VirtualDesktopAccessor.dll`** in the **same folder** as `win11-vd-api.ahk` (included when you clone this repo).

## Installation

### 1. Clone this repository

```powershell
git clone https://github.com/PepegaSan/Visual-Desktop-Autohotkey.git
cd Visual-Desktop-Autohotkey
```

### 2. DLL (already in the repo)

After clone, **`VirtualDesktopAccessor.dll`** is already next to the scripts. To **upgrade** to the newest upstream build (e.g. after a Windows update), run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\download-vda.ps1
```

Or install manually from [VirtualDesktopAccessor releases](https://github.com/Ciantic/VirtualDesktopAccessor/releases).

### 3. Run AutoHotkey

Double-click `win11-vd-api.ahk` or run from a terminal:

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" .\win11-vd-api.ahk
```

(Adjust the path if your AutoHotkey v2 install differs.)

## Default hotkeys

| Key   | Action |
|-------|--------|
| **F14** | Previous virtual desktop (view), wrap |
| **F15** | Next virtual desktop (view), wrap |
| **F16** | Move **active window** to next desktop (wrap); you stay on the current desktop |
| **F17** | Move **active window** to previous desktop (wrap) |

Edit `win11-vd-api.ahk` to change keys. Focus the target window before using F16/F17.

## Files

| File | Role |
|------|------|
| `win11-vd-api.ahk` | Entry script: hotkeys, tray menu |
| `vda-init.ahk` | Loads the DLL and exposes helper functions |
| `download-vda.ps1` | Optional: download latest `VirtualDesktopAccessor.dll` from upstream |
| `VirtualDesktopAccessor.dll` | Bundled third-party binary (see [`THIRD_PARTY.md`](THIRD_PARTY.md)) |
| `third-party/VirtualDesktopAccessor/LICENSE.txt` | Upstream **MIT** license (verbatim) |

## Disclaimer

Virtual desktop behavior depends on Windows and the upstream DLL. This project is provided as-is; see [LICENSE](LICENSE).
