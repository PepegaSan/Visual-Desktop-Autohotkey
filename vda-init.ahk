; Included by win11-vd-api.ahk — load the DLL and provide helpers.

global VDA_hModule := 0
global VDA_GetDesktopCount := 0
global VDA_GetCurrentDesktopNumber := 0
global VDA_GoToDesktopNumber := 0
global VDA_MoveWindowToDesktopNumber := 0
global VDA_GetWindowDesktopNumber := 0
; Optional (not every DLL build): pin = “show this window on all desktops”
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
            "Missing file:`n" dllPath "`n`n"
            "PowerShell: run .\download-vda.ps1`n"
            "or download manually from:`n"
            "https://github.com/Ciantic/VirtualDesktopAccessor/releases",
            "VirtualDesktopAccessor",
            "Icon!",
        )
        ExitApp
    }
    VDA_hModule := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
    if !VDA_hModule {
        MsgBox("LoadLibrary failed for:`n" dllPath, "VirtualDesktopAccessor", "Icon!")
        ExitApp
    }
    VDA_GetDesktopCount := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GetDesktopCount", "Ptr")
    VDA_GetCurrentDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GetCurrentDesktopNumber", "Ptr")
    VDA_GoToDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "GoToDesktopNumber", "Ptr")
    VDA_MoveWindowToDesktopNumber := DllCall("GetProcAddress", "Ptr", VDA_hModule, "AStr", "MoveWindowToDesktopNumber", "Ptr")
    if !VDA_GetDesktopCount || !VDA_GetCurrentDesktopNumber || !VDA_GoToDesktopNumber || !VDA_MoveWindowToDesktopNumber {
        MsgBox("GetProcAddress failed — DLL version may not match.", "VirtualDesktopAccessor", "Icon!")
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

; --- Pin single window (“show on all desktops”) ---

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
        MsgBox("No active window.", "VDA Pin", "Icon!")
        return -1
    }
    if !VDA_PinWindow {
        MsgBox("PinWindow is missing in this DLL build.", "VDA Pin", "Icon!")
        return -1
    }
    r := DllCall(VDA_PinWindow, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("PinWindow failed (-1).`nElevated window or unsupported window?", "VDA Pin", "Icon!")
    return r
}

VDA_UnpinActiveWindow() {
    global VDA_UnPinWindow
    hwnd := VDA_ActiveHwnd()
    if !hwnd {
        MsgBox("No active window.", "VDA Pin", "Icon!")
        return -1
    }
    if !VDA_UnPinWindow {
        MsgBox("UnPinWindow is missing in this DLL build.", "VDA Pin", "Icon!")
        return -1
    }
    r := DllCall(VDA_UnPinWindow, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("UnPinWindow failed (-1).", "VDA Pin", "Icon!")
    return r
}

VDA_TogglePinActiveWindow() {
    if !VDA_PinExportsOk() {
        MsgBox("Pin/Unpin/IsPinnedWindow missing in this DLL build.", "VDA Pin", "Icon!")
        return
    }
    if VDA_IsActiveWindowPinned()
        VDA_UnpinActiveWindow()
    else
        VDA_PinActiveWindow()
}

; --- Pin whole app (optional; for your own hotkeys) ---

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
        MsgBox("No active window.", "VDA Pin App", "Icon!")
        return -1
    }
    if !VDA_PinApp {
        MsgBox("PinApp is missing in this DLL build.", "VDA Pin App", "Icon!")
        return -1
    }
    r := DllCall(VDA_PinApp, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("PinApp failed (-1).", "VDA Pin App", "Icon!")
    return r
}

VDA_UnpinActiveApp() {
    global VDA_UnPinApp
    hwnd := VDA_ActiveHwnd()
    if !hwnd {
        MsgBox("No active window.", "VDA Pin App", "Icon!")
        return -1
    }
    if !VDA_UnPinApp {
        MsgBox("UnPinApp is missing in this DLL build.", "VDA Pin App", "Icon!")
        return -1
    }
    r := DllCall(VDA_UnPinApp, "Ptr", hwnd, "Int")
    if r = -1
        MsgBox("UnPinApp failed (-1).", "VDA Pin App", "Icon!")
    return r
}

VDA_TogglePinActiveApp() {
    global VDA_PinApp, VDA_UnPinApp, VDA_IsPinnedApp
    if !VDA_PinApp || !VDA_UnPinApp || !VDA_IsPinnedApp {
        MsgBox("PinApp/UnPinApp/IsPinnedApp missing in this DLL build.", "VDA Pin App", "Icon!")
        return
    }
    if VDA_IsActiveAppPinned()
        VDA_UnpinActiveApp()
    else
        VDA_PinActiveApp()
}

; --- Other helpers (no hotkeys here; use from your own scripts) ---

VDA_IsWindowOnCurrentDesktop(hwnd) {
    global VDA_IsWindowOnCurrentVirtualDesktop
    if !hwnd || !VDA_IsWindowOnCurrentVirtualDesktop
        return false
    return DllCall(VDA_IsWindowOnCurrentVirtualDesktop, "Ptr", hwnd, "Int") != 0
}

VDA_GoToDesktopIndex(n) {
    global VDA_GoToDesktopNumber
    if !VDA_GoToDesktopNumber {
        MsgBox("GoToDesktopNumber not loaded.", "VDA", "Icon!")
        return -1
    }
    r := DllCall(VDA_GoToDesktopNumber, "Int", n, "Int")
    if r = -1
        MsgBox("GoToDesktopNumber(" n ") failed (-1).", "VDA", "Icon!")
    return r
}

; New virtual desktop (Win11 DLL export). Returns new desktop index or -1.

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
            "Could not create a new desktop.`n`n"
            "Possible causes: old DLL, not Windows 11, or CreateDesktop unavailable.",
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
        MsgBox("GoToDesktopNumber(" targetIndex ") failed (-1).", "VDA", "Icon!")
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
        MsgBox("No active window.", "VDA", "Icon!")
        return
    }
    r := DllCall(VDA_MoveWindowToDesktopNumber, "Ptr", hwnd, "Int", targetIndex, "Int")
    if r = -1
        MsgBox("MoveWindowToDesktopNumber failed (-1).`nElevated window or unsupported window?", "VDA", "Icon!")
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

; Launch a program and move all top-level windows of that PID to desktopNumber (0 = first desktop).
; exePath = full path to .exe | args = rest of command line (e.g. '"C:\path\script.ahk"' for AutoHotkey) | workDir = working folder or ""
; Console-only apps with no window: times out and returns false.

VDA_RunOnDesktop(desktopNumber, exePath, args := "", workDir := "", timeoutSec := 45) {
    global VDA_MoveWindowToDesktopNumber
    if !VDA_MoveWindowToDesktopNumber {
        MsgBox("MoveWindowToDesktopNumber not loaded.", "VDA RunOnDesktop", "Icon!")
        return false
    }
    if !exePath {
        MsgBox("No exePath.", "VDA RunOnDesktop", "Icon!")
        return false
    }
    if InStr(exePath, "\") && !FileExist(exePath) {
        MsgBox("File not found:`n" exePath, "VDA RunOnDesktop", "Icon!")
        return false
    }
    line := '"' exePath '"'
    if args != ""
        line .= " " args
    pid := unset
    try {
        if workDir != ""
            Run line, workDir, , &pid
        else
            Run line, , , &pid
    } catch as err {
        MsgBox("Run failed:`n" err.Message, "VDA RunOnDesktop", "Icon!")
        return false
    }
    if !pid {
        MsgBox("Run returned no PID.", "VDA RunOnDesktop", "Icon!")
        return false
    }
    crit := "ahk_pid " pid
    deadline := A_TickCount + timeoutSec * 1000
    while A_TickCount < deadline {
        if WinExist(crit)
            break
        Sleep 50
    }
    if !WinExist(crit) {
        MsgBox("No window within " timeoutSec " s (PID " pid ").`nConsole-only apps often have no window.", "VDA RunOnDesktop", "Icon!")
        return false
    }
    list := WinGetList(crit)
    ok := true
    for hwnd in list {
        r := DllCall(VDA_MoveWindowToDesktopNumber, "Ptr", hwnd, "Int", desktopNumber, "Int")
        if r = -1
            ok := false
    }
    if !ok
        MsgBox("MoveWindowToDesktopNumber failed (-1) for at least one window.", "VDA RunOnDesktop", "Icon!")
    return ok
}

VDA_OnExit(*) {
    global VDA_hModule
    if VDA_hModule
        DllCall("FreeLibrary", "Ptr", VDA_hModule)
}

OnExit(VDA_OnExit, -1)
VDA_Init()
