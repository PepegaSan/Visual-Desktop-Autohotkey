; Wird von win11-vd-api.ahk eingebunden – DLL laden und Helfer bereitstellen.

global VDA_hModule := 0
global VDA_GetDesktopCount := 0
global VDA_GetCurrentDesktopNumber := 0
global VDA_GoToDesktopNumber := 0
global VDA_MoveWindowToDesktopNumber := 0
global VDA_GetWindowDesktopNumber := 0

VDA_Init() {
    global VDA_hModule, VDA_GetDesktopCount, VDA_GetCurrentDesktopNumber, VDA_GoToDesktopNumber, VDA_MoveWindowToDesktopNumber, VDA_GetWindowDesktopNumber
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
