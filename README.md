# win11-vd-api

AutoHotkey **v2** scripts for **Windows 11** virtual desktops using **[VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor)** — switch desktop view and move the active window **without** relying on `Win`+`Ctrl`+`Shift`+arrow.

## License

- **This repository** (`.ahk`, `.ps1`, docs): **MIT** — see [`LICENSE`](LICENSE).
- **`VirtualDesktopAccessor.dll`**: **not included**; it is a separate **MIT**-licensed project by **Ciantic** — see [`THIRD_PARTY.md`](THIRD_PARTY.md) and the [upstream repository](https://github.com/Ciantic/VirtualDesktopAccessor).

## Requirements

- **Windows 11** — upstream notes a minimum around **24H2 Build 26100.2605**; older builds may fail or crash. Update Windows or use an older upstream release at your own risk.
- **[AutoHotkey v2](https://www.autohotkey.com/)**
- **`VirtualDesktopAccessor.dll`** in the **same folder** as `win11-vd-api.ahk` (see installation below).

## Installation

### 1. Clone or copy this repo

```powershell
git clone https://github.com/YOUR_USER/win11-vd-api.git
cd win11-vd-api
```

(Replace the URL with your GitHub repo after you publish it.)

### 2. Obtain the DLL (pick one)

**A — PowerShell (recommended)** — downloads the first `.dll` asset from the [latest upstream release](https://github.com/Ciantic/VirtualDesktopAccessor/releases):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\download-vda.ps1
```

If execution policy blocks scripts globally, either use the line above (process scope) or run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\download-vda.ps1
```

**B — Manual** — open [VirtualDesktopAccessor releases](https://github.com/Ciantic/VirtualDesktopAccessor/releases), download the `.dll` from the latest release, rename if needed to **`VirtualDesktopAccessor.dll`**, and place it next to `win11-vd-api.ahk`.

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
| `download-vda.ps1` | Downloads `VirtualDesktopAccessor.dll` from the latest upstream release |
| `VirtualDesktopAccessor.dll` | **Not in git** — obtained per [THIRD_PARTY.md](THIRD_PARTY.md) |

## Publishing to GitHub (checklist)

1. Create a new empty repository on GitHub (no README if you already have one locally).
2. In this folder:

   ```powershell
   git init
   git add LICENSE THIRD_PARTY.md README.md .gitignore *.ahk *.ps1
   git commit -m "Initial commit: Win11 virtual desktop helpers for AutoHotkey v2"
   git branch -M main
   git remote add origin https://github.com/YOUR_USER/win11-vd-api.git
   git push -u origin main
   ```

3. Optionally set the repo **About** description and topics, e.g. `autohotkey`, `windows-11`, `virtual-desktop`, `powertoys-alternative`.

4. In `LICENSE`, replace `win11-vd-api contributors` with your name or GitHub handle if you prefer.

**Do not** commit `VirtualDesktopAccessor.dll`; it is ignored via `.gitignore` and documented in `THIRD_PARTY.md`.

## Disclaimer

Virtual desktop behavior depends on Windows and the upstream DLL. This project is provided as-is; see [LICENSE](LICENSE).
