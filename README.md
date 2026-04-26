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

### 1. Clone this repository (or download a ZIP)

```powershell
git clone https://github.com/PepegaSan/Visual-Desktop-Autohotkey.git
cd Visual-Desktop-Autohotkey
```

Alternatively, on GitHub use **Code → Download ZIP** and extract the folder.

### 2. DLL (already in the repo)

After clone or ZIP extract, **`VirtualDesktopAccessor.dll`** is already next to the scripts. To **upgrade** to the newest upstream build (e.g. after a Windows update), run:

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

## Hotkeys (short)

Edit the flags at the **top** of **`win11-vd-api.ahk`** (lines like `VDA_HK_F14NextDesktop := true`). Only switches set to **`true`** do anything. Restart the script after changes.

**Defaults:**

| Key | Action |
|-----|--------|
| **F14** | **Next** virtual desktop (switch view only, wraps at the end) |
| **F15** | Toggle “show active window on **all** desktops” (pin / unpin) |
| **F16** | Move the active window to the **next** desktop (you stay on the current one) |
| **F17** | **Create** a new virtual desktop and switch to it |

To disable a key, set its `VDA_HK_*` line to **`false`**.

**Notes:** `VDA_HK_GoNext` would put “next desktop” on **F15** as well — that **conflicts** with pin on F15, so leave it `false` by default. **`VDA_HK_MoveActivePrev`** would move the window to the **previous** desktop on **F17** — that **conflicts** with **`VDA_HK_F17CreateDesktop`**. To get “move window to previous desktop” on F17 again, set `VDA_HK_F17CreateDesktop` to `false` and `VDA_HK_MoveActivePrev` to `true`, or bind `VDA_GoToPrev()` from `vda-init.ahk` to another key yourself.

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
