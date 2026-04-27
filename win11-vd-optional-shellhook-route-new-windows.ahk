#Requires AutoHotkey v2.1
#SingleInstance Force
; =============================================================================
; OPTIONAL — separate from win11-vd-api.ahk (no DLL; uses COM + shell hook).
;
; Purpose: when a new top-level window appears, move it to ONE target virtual
; desktop — except windows matching any entry in ExcludedWindows.
;
; Modes:
;   "silent" — move the window only; your current desktop view stays put.
;   "active" — move the window AND switch to that desktop (jumps you there).
;
; Risks: relies on undocumented COM IIDs (can break after Windows updates).
; Run as admin only if you need to move elevated apps. Do not run two copies.
; Forum inspiration: https://www.autohotkey.com/boards/viewtopic.php?f=82&t=139235
; =============================================================================

Persistent

; --- User settings ---
; "silent" = background move only | "active" = also SwitchDesktop to target
RouteMode := "silent"

; 1 = first virtual desktop, 2 = second, … (must exist or Move throws)
TargetDesktopNumber := 1

; Windows that stay wherever Windows puts them (ahk_exe / class / title style)
ExcludedWindows := [
    'ahk_exe msedge.exe',
    'ahk_exe Code.exe',
]

MoveDelayMs := 100

; =============================================================================

shellHookMsg := DllCall('RegisterWindowMessage', 'str', 'SHELLHOOK')
OnMessage(shellHookMsg, ShellHookProc)
DllCall('RegisterShellHookWindow', 'ptr', A_ScriptHwnd)
OnExit(CleanupShellHook, 0)

CleanupShellHook(*) {
    global shellHookMsg
    OnMessage(shellHookMsg, ShellHookProc, 0)
    DllCall('DeregisterShellHookWindow', 'ptr', A_ScriptHwnd)
}

A_IconTip := "VD shellhook: route new windows → desktop " TargetDesktopNumber " (" RouteMode ")"

ShellHookProc(wParam, lParam, msg, hwnd) {
    global ExcludedWindows, TargetDesktopNumber, MoveDelayMs, RouteMode
    if wParam != 1 ; HSHELL_WINDOWCREATED
        return
    childHwnd := lParam
    if !childHwnd
        return
    for winTitle in ExcludedWindows {
        if WinExist(winTitle . ' ahk_id ' childHwnd)
            return
    }
    SetTimer(MoveWindowToDesktopSafe.Bind(childHwnd, TargetDesktopNumber, RouteMode), -MoveDelayMs)
}

MoveWindowToDesktopSafe(hwnd, desktopNumber, mode) {
    try
        MoveWindowToDesktop(hwnd, desktopNumber, mode)
    catch as err
        OutputDebug("win11-vd-shellhook: " err.Message "`n")
}

MoveWindowToDesktop(hwnd, desktopNumber, mode) {
    if VerCompare(A_OSVersion, '>=10.0.22000') {
        IID_IVirtualDesktopManagerInternal := '{53F5CA0B-158F-4124-900C-057158060B27}'
        IID_IVirtualDesktop := '{3f07f4be-b107-441a-af0f-39d82529072c}'
    } else {
        IID_IVirtualDesktopManagerInternal := '{f31574d6-b682-4cdc-bd56-1827860abec6}'
        IID_IVirtualDesktop := '{ff72ffdd-be7e-43fc-9c03-ad81681e88e4}'
    }
    SID_VirtualDesktopManager := '{c5e0cdca-7b6e-41b2-9fc4-d93975cc467b}'
    IID_IApplicationViewCollection := '{1841c6d7-4f9d-42c0-af41-8747538f10e5}'

    ImmersiveShell := ComObject('{C2F03A33-21F5-47FA-B4BB-156362A2F239}', '{00000000-0000-0000-C000-000000000046}')
    manager_internal := ComObjQuery(ImmersiveShell, SID_VirtualDesktopManager, IID_IVirtualDesktopManagerInternal)
    ComCall(3, manager_internal, 'uint*', &count := 0)
    if desktopNumber > count
        throw Error('Invalid desktop number (only ' count ' desktop(s)).',, desktopNumber)
    view_collection := ComObjQuery(ImmersiveShell, IID_IApplicationViewCollection, IID_IApplicationViewCollection)
    try ComCall(6, view_collection, 'ptr', hwnd, 'ptr*', view := ComValue(13, 0))
    catch
        return
    ComCall(6, manager_internal, 'ptr*', currentDesktop := ComValue(13, 0))
    ComCall(7, manager_internal, 'ptr*', desktops := ComValue(13, 0))
    GUID := Buffer(16, 0)
    DllCall('ole32\CLSIDFromString', 'str', IID_IVirtualDesktop, 'ptr', GUID)
    ComCall(4, desktops, 'uint', desktopNumber - 1, 'ptr', GUID, 'ptr*', destDesktop := ComValue(13, 0))
    if ComObjValue(currentDesktop) = ComObjValue(destDesktop)
        return
    ComCall(5, manager_internal, 'ptr', view, 'uint*', &canMove := 0)
    if !canMove
        return
    ComCall(4, manager_internal, 'ptr', view, 'ptr', destDesktop)
    if (mode = "active")
        ComCall(9, manager_internal, 'ptr', destDesktop) ; SwitchDesktop
}
