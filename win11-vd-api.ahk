#Requires AutoHotkey v2.0
#SingleInstance Force

; Virtuelle Desktops über VirtualDesktopAccessor.dll (Ciantic)
; https://github.com/Ciantic/VirtualDesktopAccessor
;
; Lege VirtualDesktopAccessor.dll aus dem neuesten Release in denselben Ordner wie dieses Skript.
; Windows 11: lt. Autor mind. 24H2 Build 26100.2605 – ältere Builds können scheitern.

#Include "vda-init.ahk"

A_IconTip := "Win11 VD API: F14/F15 Ansicht, F16/F17 Fenster"

; Desktop-Ansicht (Wrap)
$F14:: VDA_GoToPrev()
$F15:: VDA_GoToNext()

; Aktives Fenster auf anderen Desktop verschieben (Wrap), ohne Ansicht zu wechseln
$F16:: VDA_MoveActiveNext()
$F17:: VDA_MoveActivePrev()

A_TrayMenu.Add("Hinweis", (*) => MsgBox(
    "F14 / F15 = virtueller Desktop (Ansicht), mit Wrap`n"
    "F16 / F17 = aktives Fenster auf nächsten / vorigen Desktop, mit Wrap`n`n"
    "DLL: VirtualDesktopAccessor.dll neben diesem Skript.`n"
    "Download: https://github.com/Ciantic/VirtualDesktopAccessor/releases`n`n"
    "Ziel-Fenster vorher fokussieren.",
    "Virtuelle Desktops (API)",
    "Iconi",
))
A_TrayMenu.Add("Beenden", (*) => ExitApp())
