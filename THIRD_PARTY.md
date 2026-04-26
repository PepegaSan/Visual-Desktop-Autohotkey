# Third-party components

## VirtualDesktopAccessor (DLL)

This repository **does not** ship the binary `VirtualDesktopAccessor.dll`.

- **Project:** [Ciantic / VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor)
- **License:** **MIT** (see upstream repository, e.g. the `LICENSE` file on the `rust` branch).
- **Copyright:** Jari Otto Oskari Pennanen and contributors (as stated in the upstream project).

### How this repo uses it

Users place `VirtualDesktopAccessor.dll` next to the AutoHotkey scripts, typically by:

- downloading a release asset from the upstream **Releases** page, or  
- running `download-vda.ps1`, which fetches the `.dll` from the latest GitHub release via the GitHub API.

### If you redistribute the DLL yourself

The MIT license requires that you **include the upstream copyright and permission notice** when you distribute copies of the DLL (or derivative builds). Keep a copy of the upstream `LICENSE` with your distribution. This repository’s own `LICENSE` file applies only to the AutoHotkey and PowerShell files maintained here, not to upstream binaries.

### Stability note

The DLL talks to **undocumented** Windows virtual-desktop APIs. Major Windows updates can require a newer DLL build from the upstream project.
