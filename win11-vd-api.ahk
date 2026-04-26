#Requires AutoHotkey v2.0
#SingleInstance Force

; Virtuelle Desktops über VirtualDesktopAccessor.dll (Ciantic)
; https://github.com/Ciantic/VirtualDesktopAccessor
;
; DLL neben diesem Skript. Windows 11: lt. Autor mind. 24H2 Build 26100.2605.

; === Hotkey-Schalter: nur true = Taste ist aktiv ===
; (Funktionen stehen in vda-init.ahk; hier nur Tasten zuordnen.)
VDA_HK_F14NextDesktop := true       ; F14 – nächster Desktop (Ansicht, Wrap) – gut zum Durchtabben
VDA_HK_GoNext := false              ; F15 – nächster Desktop; aus lassen, wenn F15 = Pin
VDA_HK_MoveActiveNext := true       ; F16 – aktives Fenster → nächster Desktop (Wrap)
VDA_HK_MoveActivePrev := false      ; F17 – Fenster → voriger Desktop; aus, wenn F17 = neuer Desktop
VDA_HK_F17CreateDesktop := true     ; F17 – neuen virtuellen Desktop anlegen, dann dorthin wechseln
VDA_HK_TogglePinWindow := true      ; F15 – aktives Fenster auf allen Desktops ein/aus

if (VDA_HK_GoNext && VDA_HK_TogglePinWindow) {
    MsgBox("Konflikt: F15 kann nicht gleichzeitig „nächster Desktop“ und „Pin umschalten“ sein.", "win11-vd-api", "Icon!")
    ExitApp
}
if (VDA_HK_MoveActivePrev && VDA_HK_F17CreateDesktop) {
    MsgBox("Konflikt: F17 kann nicht gleichzeitig „Fenster zurück“ und „neuer Desktop“ sein.", "win11-vd-api", "Icon!")
    ExitApp
}

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

parts := []
if VDA_HK_F14NextDesktop
    parts.Push("F14=Desktop+")
if VDA_HK_GoNext
    parts.Push("F15=Desktop+")
if VDA_HK_TogglePinWindow
    parts.Push("F15=Fenster auf allen Desktops (Toggle)")
if VDA_HK_MoveActiveNext
    parts.Push("F16=Fenster→nächster Desktop")
if VDA_HK_MoveActivePrev
    parts.Push("F17=Fenster→voriger Desktop")
if VDA_HK_F17CreateDesktop
    parts.Push("F17=Neuer Desktop")
tip := ""
for s in parts
    tip .= (tip ? " · " : "") s
A_IconTip := tip != "" ? "VD API: " tip : "VD API: (keine Hotkeys aktiv – Schalter im Skript)"

A_TrayMenu.Add("Hinweis", (*) => MsgBox(
    "Schalter ganz oben im Skript (`VDA_HK_*`).`n`n"
    "Aktiv nur was auf true steht.`n`n"
    "F15 Pin: aktives Fenster wie „auf allen Desktops anzeigen“.`n`n"
    "DLL: VirtualDesktopAccessor.dll neben diesem Skript.`n"
    "https://github.com/Ciantic/VirtualDesktopAccessor/releases`n`n"
    "F16/F17: Ziel-Fenster vorher fokussieren.",
    "Virtuelle Desktops (API)",
    "Iconi",
))
A_TrayMenu.Add("Beenden", (*) => ExitApp())
