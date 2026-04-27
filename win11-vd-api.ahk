#Requires AutoHotkey v2.0
#SingleInstance Force

; Virtual desktops via VirtualDesktopAccessor.dll (Ciantic)
; https://github.com/Ciantic/VirtualDesktopAccessor
;
; Keep VirtualDesktopAccessor.dll next to this script. Windows 11: author recommends at least 24H2 build 26100.2605.

; === Hotkey switches: only true = key is active ===
; (Implementations are in vda-init.ahk; here we only bind keys.)
VDA_HK_F14NextDesktop := true       ; F14 — next desktop (view, wrap); good for tabbing
VDA_HK_GoNext := false              ; F15 — next desktop; keep false if F15 is pin
VDA_HK_MoveActiveNext := true       ; F16 — move active window to next desktop (wrap)
VDA_HK_MoveActivePrev := false      ; F17 — move window to previous desktop; false if F17 creates desktop
VDA_HK_F17CreateDesktop := true     ; F17 — create new virtual desktop, then switch there
VDA_HK_TogglePinWindow := true      ; F15 — toggle “show active window on all desktops”

if (VDA_HK_GoNext && VDA_HK_TogglePinWindow) {
    MsgBox("Conflict: F15 cannot be both “next desktop” and “toggle pin”.", "win11-vd-api", "Icon!")
    ExitApp
}
if (VDA_HK_MoveActivePrev && VDA_HK_F17CreateDesktop) {
    MsgBox("Conflict: F17 cannot be both “move window back” and “new desktop”.", "win11-vd-api", "Icon!")
    ExitApp
}

; === Optional: on script start, launch apps onto a fixed virtual desktop (default: off) ===
; Helper: VDA_RunOnDesktop(desktop, exe, args, workDir) in vda-init.ahk
; desktop: 0 = first desktop, 1 = second, …
; Each list entry needs four keys: desktop, exe, args, workDir (use "" if unused).
; Multiple apps: multiple .Push lines. Then set VDA_RUN_ON_DESKTOP_AT_START := true and restart the script.
VDA_RUN_ON_DESKTOP_AT_START := false
VDA_RunOnDesktopList := []
; Example 1 — Notepad on second desktop (index 1); edit paths as needed:
; VDA_RunOnDesktopList.Push({ desktop: 1, exe: "C:\Windows\System32\notepad.exe", args: "", workDir: "" })
; Example 2 — AutoHotkey script: exe = AutoHotkey, args = script path in quotes:
; VDA_RunOnDesktopList.Push({ desktop: 0, exe: A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64.exe", args: '"' A_ScriptDir "\Example.ahk" '"', workDir: A_ScriptDir })
; Example 3 — another app in the same list (e.g. Paint on third desktop = index 2):
; VDA_RunOnDesktopList.Push({ desktop: 2, exe: "C:\Windows\System32\mspaint.exe", args: "", workDir: "" })

#Include "vda-init.ahk"

VDA_ApplyHotkeys() {
    global VDA_HK_F14NextDesktop, VDA_HK_GoNext, VDA_HK_MoveActiveNext, VDA_HK_MoveActivePrev, VDA_HK_F17CreateDesktop, VDA_HK_TogglePinWindow
    if VDA_HK_F14NextDesktop
        Hotkey("$F14", (*) => VDA_GoToNext(), "On")
    if VDA_HK_GoNext
        Hotkey("$F15", (*) => VDA_GoToNext(), "On")
    if VDA_HK_TogglePinWindow
        Hotkey("$F15", (*) => VDA_TogglePinActiveWindow(), "On")
    if VDA_HK_MoveActiveNext
        Hotkey("$F16", (*) => VDA_MoveActiveNext(), "On")
    if VDA_HK_MoveActivePrev
        Hotkey("$F17", (*) => VDA_MoveActivePrev(), "On")
    if VDA_HK_F17CreateDesktop
        Hotkey("$F17", (*) => VDA_CreateNewDesktopAndGo(), "On")
}

VDA_ApplyHotkeys()

if VDA_RUN_ON_DESKTOP_AT_START {
    for item in VDA_RunOnDesktopList
        VDA_RunOnDesktop(item.desktop, item.exe, item.args, item.workDir)
}

parts := []
if VDA_HK_F14NextDesktop
    parts.Push("F14=Desktop+")
if VDA_HK_GoNext
    parts.Push("F15=Desktop+")
if VDA_HK_TogglePinWindow
    parts.Push("F15=Pin all desktops (toggle)")
if VDA_HK_MoveActiveNext
    parts.Push("F16=Move win→next desktop")
if VDA_HK_MoveActivePrev
    parts.Push("F17=Move win→prev desktop")
if VDA_HK_F17CreateDesktop
    parts.Push("F17=New desktop")
tip := ""
for s in parts
    tip .= (tip ? " · " : "") s
A_IconTip := tip != "" ? "VD API: " tip : "VD API: (no hotkeys on — check switches in script)"

A_TrayMenu.Add("Help", (*) => MsgBox(
    "Flags at the top of this script (`VDA_HK_*`).`n`n"
    "Only lines set to true are active.`n`n"
    "F15 pin: same idea as “Show this window on all desktops” in Task View.`n`n"
    "DLL: VirtualDesktopAccessor.dll next to this script.`n"
    "https://github.com/Ciantic/VirtualDesktopAccessor/releases`n`n"
    "For F16 / move-window keys: focus the target window first.",
    "Virtual desktops (API)",
    "Iconi",
))
A_TrayMenu.Add("Exit", (*) => ExitApp())
