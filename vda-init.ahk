; Wird von win11-vd-api.ahk eingebunden – DLL laden und Helfer bereitstellen.

global VDA_hModule := 0
global VDA_GetDesktopCount := 0
global VDA_GetCurrentDesktopNumber := 0
global VDA_GoToDesktopNumber := 0
global VDA_MoveWindowToDesktopNumber := 0
global VDA_GetWindowDesktopNumber := 0
; Optional (nicht jede DLL-Version): Pin = „Fenster auf allen Desktops“
global VDA_PinWindow := 0
global VDA_UnPinWindow := 0
global VDA_IsPinnedWindow := 0
global VDA_PinApp := 0
global VDA_UnPinApp := 0
global VDA_IsPinnedApp := 0
global VDA_IsWindowOnCurrentVirtualDesktop := 0
global VDA_CreateDesktop := 0

VDA_Init() {
    global VDA_hModule, VDA_GetDesktopCount, VDA_GetCurrentDesktopNumber, VDA_GoToDesktopNumber, VDA_MoveWindowToDesktopNumber, VDA_GetWindowDesktopNumber
    global VDA_PinWindow, VDA_UnPinWindow, VDA_IsPinnedWindow, VDA_PinApp, VDA_UnPinApp, VDA_IsPinnedApp, VDA_IsWindowOnCurrentVirtualDesktop, VDA_CreateDesktop
    dllPath := A_ScriptDir "\VirtualDesktopAccessor.dll"
    if !FileExist(dllPath) {
        MsgBox(
            "Fehlende Datei:`n" dllPath "`n`n"
            "PowerShell: .\download-vda.ps1 ausführen`n"
            "oder manuell von:`n"
            "https://github.com/Ciantic/VirtualDesktopAccessor/releases",
            "VirtualDesktopAccessor",
            "Icon!",
        )
        ExitApp
    }
    VDA_hModule := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
    if !VDA_hModule {
        MsgBox("LoadLibrary fehlgeschlagen für:`n" dllPath, "VirtualDesktopAccessor", "Icon!")
        ExitApp
    }
    VDA_GetDesktopCount := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GetDesktopCount", "Ptr")
    VDA_GetCurrentDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GetCurrentDesktopNumber", "Ptr")
    VDA_GoToDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GoToDesktopNumber", "Ptr")
    VDA_MoveWindowToDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "MoveWindowToDesktopNumber", "Ptr")
    if !VDA_GetDesktopCount || !VDA_GetCurrentDesktopNumber || !VDA_GoToDesktopNumber || !VDA_MoveWindowToDesktopNumber {
        MsgBox("GetProcAddress fehlte – DLL-Version passt evtl. nicht.", "VirtualDesktopAccessor", "Icon!")
        ExitApp
    }
    VDA_GetWindowDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GetWindowDesktopNumber", "Ptr")
    VDA_PinWindow := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "PinWindow", "Ptr")
    VDA_UnPinWindow := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "UnPinWindow", "Ptr")
    VDA_IsPinnedWindow := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "IsPinnedWindow", "Ptr")
    VDA_PinApp := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "PinApp", "Ptr")
    VDA_UnPinApp := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "UnPinApp", "Ptr")
    VDA_IsPinnedApp := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "IsPinnedApp", "Ptr")
    VDA_IsWindowOnCurrentVirtualDesktop := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
    VDA_CreateDesktop := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "CreateDesktop", "Ptr")
}

VDA_PinExportsOk() {
    global VDA_PinWindow, VDA_UnPinWindow, VDA_IsPinnedWindow
    return VDA_PinWindow && VDA_UnPinWindow && VDA_IsPinnedWindow
}

VDA_ActiveHwnd() {
    try
        return WinGetID("A")
    catch
        return 0
}

; --- Pin einzelnes Fenster („auf allen Desktops anzeigen“) ---

VDA_IsActiveWindowPinned() {
    global VDA_IsPinnedWindow
    hwnd := VDA_ActiveHwnd()
    if !hwnd || !VDA_IsPinnedWindow
        return false
    return DllCall(VDA_IsPinnedWindow, "Ptr", hwnd, "Int") != 0
}

VDA_PinActiveWindow() {
    global VDA_PinWindow
    hwnd := VDA_ActiveHwnd()
    if !hwnd {
        MsgBox("Kein aktives Fenster.", "VDA Pin", "Icon!")
        return -1
    }
    if !VDA_PinWindow {
        MsgBox("PinWindow fehlt in dieser DLL-Version.", "VDA Pin", "Icon!")
        return -1
    }
    r := DllCall(VDA_PinWindow, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("PinWindow fehlgeschlagen (-1).`nAdmin-Fenster oder nicht unterstütztes Fenster?", "VDA Pin", "Icon!")
    return r
}

VDA_UnpinActiveWindow() {
    global VDA_UnPinWindow
    hwnd := VDA_ActiveHwnd()
    if !hwnd {
        MsgBox("Kein aktives Fenster.", "VDA Pin", "Icon!")
        return -1
    }
    if !VDA_UnPinWindow {
        MsgBox("UnPinWindow fehlt in dieser DLL-Version.", "VDA Pin", "Icon!")
        return -1
    }
    r := DllCall(VDA_UnPinWindow, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("UnPinWindow fehlgeschlagen (-1).", "VDA Pin", "Icon!")
    return r
}

VDA_TogglePinActiveWindow() {
    if !VDA_PinExportsOk() {
        MsgBox("Pin/Unpin/IsPinnedWindow fehlen in dieser DLL-Version.", "VDA Pin", "Icon!")
        return
    }
    if VDA_IsActiveWindowPinned()
        VDA_UnpinActiveWindow()
    else
        VDA_PinActiveWindow()
}

; --- Pin ganze App (optional, für eigene Hotkeys / später) ---

VDA_IsActiveAppPinned() {
    global VDA_IsPinnedApp
    hwnd := VDA_ActiveHwnd()
    if !hwnd || !VDA_IsPinnedApp
        return false
    return DllCall(VDA_IsPinnedApp, "Ptr", hwnd, "Int") != 0
}

VDA_PinActiveApp() {
    global VDA_PinApp
    hwnd := VDA_ActiveHwnd()
    if !hwnd {
        MsgBox("Kein aktives Fenster.", "VDA Pin App", "Icon!")
        return -1
    }
    if !VDA_PinApp {
        MsgBox("PinApp fehlt in dieser DLL-Version.", "VDA Pin App", "Icon!")
        return -1
    }
    r := DllCall(VDA_PinApp, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("PinApp fehlgeschlagen (-1).", "VDA Pin App", "Icon!")
    return r
}

VDA_UnpinActiveApp() {
    global VDA_UnPinApp
    hwnd := VDA_ActiveHwnd()
    if !hwnd {
        MsgBox("Kein aktives Fenster.", "VDA Pin App", "Icon!")
        return -1
    }
    if !VDA_UnPinApp {
        MsgBox("UnPinApp fehlt in dieser DLL-Version.", "VDA Pin App", "Icon!")
        return -1
    }
    r := DllCall(VDA_UnPinApp, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("UnPinApp fehlgeschlagen (-1).", "VDA Pin App", "Icon!")
    return r
}

VDA_TogglePinActiveApp() {
    global VDA_PinApp, VDA_UnPinApp, VDA_IsPinnedApp
    if !VDA_PinApp || !VDA_UnPinApp || !VDA_IsPinnedApp {
        MsgBox("PinApp/UnPinApp/IsPinnedApp fehlen in dieser DLL-Version.", "VDA Pin App", "Icon!")
        return
    }
    if VDA_IsActiveAppPinned()
        VDA_UnpinActiveApp()
    else
        VDA_PinActiveApp()
}

; --- Sonstige Helfer (ohne Hotkey; für eigene Skripte) ---

VDA_IsWindowOnCurrentDesktop(hwnd) {
    global VDA_IsWindowOnCurrentVirtualDesktop
    if !hwnd || !VDA_IsWindowOnCurrentVirtualDesktop
        return false
    return DllCall(VDA_IsWindowOnCurrentVirtualDesktop, "Ptr", hwnd, "Int") != 0
}

VDA_GoToDesktopIndex(n) {
    global VDA_GoToDesktopNumber
    if !VDA_GoToDesktopNumber {
        MsgBox("GoToDesktopNumber nicht geladen.", "VDA", "Icon!")
        return -1
    }
    r := DllCall(VDA_GoToDesktopNumber, "Int", n, "Int")
    if r = -1
        MsgBox("GoToDesktopNumber(" n ") fehlgeschlagen (-1).", "VDA", "Icon!")
    return r
}

; Neuer virtueller Desktop (Win11, DLL-Export). Rückgabe = Index des neuen Desktops oder -1.

VDA_CreateNewDesktop() {
    global VDA_CreateDesktop
    if !VDA_CreateDesktop
        return -1
    return DllCall(VDA_CreateDesktop, "Int")
}

VDA_CreateNewDesktopAndGo() {
    idx := VDA_CreateNewDesktop()
    if idx < 0 {
        MsgBox(
            "Neuer Desktop geht nicht.`n`n"
            "Mögliche Gründe: DLL zu alt, kein Windows 11, oder CreateDesktop nicht verfügbar.",
            "VDA",
            "Icon!",
        )
        return
    }
    VDA_GoToWrapped(idx)
}

VDA_ActiveWindowDesktopIndex() {
    global VDA_GetWindowDesktopNumber, VDA_GetCurrentDesktopNumber
    hwnd := WinGetID("A")
    if hwnd && VDA_GetWindowDesktopNumber {
        d := DllCall(VDA_GetWindowDesktopNumber, "Ptr", hwnd, "Int")
        if d != -1
            return d
    }
    return DllCall(VDA_GetCurrentDesktopNumber, "Int")
}

VDA_LastIndex() {
    global VDA_GetDesktopCount
    n := DllCall(VDA_GetDesktopCount, "Int")
    if n < 1
        return 0
    return n - 1
}

VDA_GoToWrapped(targetIndex) {
    global VDA_GoToDesktopNumber
    r := DllCall(VDA_GoToDesktopNumber, "Int", targetIndex, "Int")
    if r = -1
        MsgBox("GoToDesktopNumber(" targetIndex ") fehlgeschlagen (-1).", "VDA", "Icon!")
}

VDA_GoToPrev() {
    global VDA_GetCurrentDesktopNumber
    cur := DllCall(VDA_GetCurrentDesktopNumber, "Int")
    last := VDA_LastIndex()
    target := cur <= 0 ? last : cur - 1
    VDA_GoToWrapped(target)
}

VDA_GoToNext() {
    global VDA_GetCurrentDesktopNumber
    cur := DllCall(VDA_GetCurrentDesktopNumber, "Int")
    last := VDA_LastIndex()
    target := cur >= last ? 0 : cur + 1
    VDA_GoToWrapped(target)
}

VDA_MoveActiveToIndex(targetIndex) {
    global VDA_MoveWindowToDesktopNumber
    hwnd := WinGetID("A")
    if !hwnd {
        MsgBox("Kein aktives Fenster.", "VDA", "Icon!")
        return
    }
    r := DllCall(VDA_MoveWindowToDesktopNumber, "Ptr", hwnd, "Int", targetIndex, "Int")
    if r = -1
        MsgBox("MoveWindowToDesktopNumber fehlgeschlagen (-1).`nAdmin-Fenster oder nicht unterstütztes Fenster?", "VDA", "Icon!")
}

VDA_MoveActiveNext() {
    cur := VDA_ActiveWindowDesktopIndex()
    last := VDA_LastIndex()
    target := cur >= last ? 0 : cur + 1
    VDA_MoveActiveToIndex(target)
}

VDA_MoveActivePrev() {
    cur := VDA_ActiveWindowDesktopIndex()
    last := VDA_LastIndex()
    target := cur <= 0 ? last : cur - 1
    VDA_MoveActiveToIndex(target)
}

VDA_OnExit(*) {
    global VDA_hModule
    if VDA_hModule
        DllCall("FreeLibrary", "Ptr", VDA_hModule)
}

OnExit(VDA_OnExit, -1)
VDA_Init()
