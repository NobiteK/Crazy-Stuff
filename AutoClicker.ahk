/*
    Controls:
    F or Insert - Toggle ON/OFF
    End         - Close Script
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
DllCall("timeBeginPeriod", UInt, 1)

; --- Defaults ---
clickDelay := ""
mouseButton := "Left Mouse"
enabled := false
hotkeyToggle := "F"

; --- State variables ---
randomEnabled := false
cachedDelay := ""
cachedButton := "Left"
lastClick := 0

; --- Tray ---
Menu, Tray, NoStandard
Menu, Tray, Add, Toggle, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, AutoClicker [OFF]
Menu, Tray, Icon, %A_WinDir%\System32\main.cpl, 0
Menu, Tray, Default, Toggle

; --- GUI ---
margin := 40
gap := 18

Gui, Margin, %margin%, %margin%
Gui, Color, 0x23272E
Gui, Font, cWhite s10, Segoe UI
Gui, +AlwaysOnTop
Gui, +MinimizeBox +OwnDialogs

yPos := margin

Gui, Add, Text, cWhite x%margin% y%yPos%, Speed (ms):
Gui, Add, Text, vRndLabel cGreen x120 y%yPos% Hidden, [RND: ON]
yPos += 24
Gui, Add, Edit, vClickDelay w160 cBlack Background0x2D2D30 Number x40 y%yPos% hwndhEdit gUpdateDelay
Gui, Add, Button, vRandomBtn x205 y%yPos% w35 h24 gClickRandom, RND

SendMessage, 0x1501, 1, "Minimum: 1 ms",, ahk_id %hEdit%
yPos += gap + 24

Gui, Add, Text, cWhite x%margin% y%yPos%, Button:
yPos += 24
Gui, Add, DropDownList, vMouseButtonChoice w200 cWhite Background0x2D2D30 x%margin% y%yPos% gUpdateButton, Left Mouse|Right Mouse|Middle Mouse
GuiControl, ChooseString, MouseButtonChoice, %mouseButton%

yPos += gap + 24
Gui, Add, Text, cWhite x%margin% y%yPos%, Toggle key:
yPos += 24
Gui, Add, Button, vHotkeyBtn gSetHotkey w200 +0x4000 x%margin% y%yPos%, %hotkeyToggle%
Gui, Add, Progress, vIndicatorBar x8 y8 w12 h12 Background23272E -Border

Gui, Font, cGray s7, MS Shell Dlg
Gui, Add, Text, x20 y243 w255 h16 Right cGray, Made by NobiteK

winW := 280
winH := yPos + 24 + margin

SysGet, MonitorCount, MonitorCount
SysGet, Monitor1, Monitor, 1

foundSecondMonitor := false
Loop, %MonitorCount% {
    SysGet, Mon, Monitor, %A_Index%
    if (A_Index != 1 && MonLeft < Monitor1Left) {
        xPos := MonRight - winW - 5
        yPos := MonTop + 5
        foundSecondMonitor := true
        break
    }
}

if (foundSecondMonitor) {
    Gui, Show, x%xPos% y%yPos% w%winW% h%winH%, AutoClicker
} else {
    SysGet, Monitor1, Monitor, 1
    xPos := Monitor1Right - winW - 7
    yPos := Monitor1Top + 5
    Gui, Show, x%xPos% y%yPos% w%winW% h%winH%, AutoClicker
}

GuiControl,, IndicatorBar, 100
GuiControl, +cB00000, IndicatorBar

Hotkey, %hotkeyToggle%, ToggleScript, On
Hotkey, Insert, ToggleScript, On
Hotkey, End, EndScript, On
return

UpdateDelay:
    GuiControlGet, cachedDelay,, ClickDelay
return

UpdateButton:
    GuiControlGet, selectedButton,, MouseButtonChoice
    if (selectedButton = "Right Mouse") {
        cachedButton := "Right"
    } else if (selectedButton = "Middle Mouse") {
        cachedButton := "Middle"
    } else {
        cachedButton := "Left"
    }
return

GuiClose:
    DllCall("timeEndPeriod", UInt, 1)
    ExitApp
return

GuiMinimize:
    Gui, Hide
return

ClickRandom:
    randomEnabled := !randomEnabled
    hEdit := 0
    Loop % WinExist() {
        ControlGet, hEditTemp, Hwnd,, Edit1, A
        if (hEditTemp) {
            hEdit := hEditTemp
            break
        }
    }
    
    if (randomEnabled) {
        SendMessage, 0x1501, 1, "Minimum: 10 ms",, ahk_id %hEdit%
        GuiControl, Show, RndLabel
        GuiControl,, ClickDelay,
        cachedDelay := ""
    } else {
        SendMessage, 0x1501, 1, "Minimum: 1 ms",, ahk_id %hEdit%
        GuiControl, Hide, RndLabel
    }
return

SetHotkey:
    Gui, +OwnDialogs
    MsgBox, 64, Set Hotkey, Click OK and press a key to set hotkey
    Input, newHotkey, L1 M
    if (ErrorLevel = "Max") {
        Hotkey, %hotkeyToggle%, ToggleScript, Off
        hotkeyToggle := newHotkey
        Hotkey, %hotkeyToggle%, ToggleScript, On
        GuiControl,, HotkeyBtn, %hotkeyToggle%
    }
return

ToggleScript:
    enabled := !enabled
    if (enabled) {
        Gosub, UpdateDelay
        Gosub, UpdateButton
        
        if (cachedDelay = "" || !RegExMatch(cachedDelay, "^\d+$") || cachedDelay < 1) {
            MsgBox, Please enter a valid delay in milliseconds (minimum delay is 1 ms)!
            enabled := false
            return
        }
        if (randomEnabled && cachedDelay < 10) {
            MsgBox, With RND mode enabled, minimum delay is 10 ms!
            enabled := false
            return
        }
        
        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
        Menu, Tray, Tip, AutoClicker [ON]
        SoundBeep, 1000, 150
        GuiControl,, IndicatorBar, 100
        GuiControl, +c00B000, IndicatorBar

        lastClick := A_TickCount

        if (cachedDelay = 1) {
            SetTimer, MaxSpeedClick, -1
        } else {
            SetTimer, PreciseClick, %cachedDelay%
        }
    } else {
        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
        Menu, Tray, Tip, AutoClicker [OFF]
        SoundBeep, 400, 200
        GuiControl,, IndicatorBar, 100
        GuiControl, +cB00000, IndicatorBar
        SetTimer, MaxSpeedClick, Off
        SetTimer, PreciseClick, Off
    }
return

MaxSpeedClick:
    Loop {
        if (!enabled)
            break
        if (cachedButton = "Right") {
            DllCall("mouse_event", "UInt", 0x08, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
            DllCall("mouse_event", "UInt", 0x10, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        } else if (cachedButton = "Middle") {
            DllCall("mouse_event", "UInt", 0x20, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
            DllCall("mouse_event", "UInt", 0x40, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        } else {
            DllCall("mouse_event", "UInt", 0x02, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
            DllCall("mouse_event", "UInt", 0x04, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        }
        DllCall("Sleep", "UInt", 1)

        if (Mod(A_TickCount, 10) = 0)
            Sleep, 0
    }

    if (enabled)
        SetTimer, MaxSpeedClick, -1
return

PreciseClick:
    if (cachedButton = "Right") {
        DllCall("mouse_event", "UInt", 0x08, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        DllCall("mouse_event", "UInt", 0x10, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
    } else if (cachedButton = "Middle") {
        DllCall("mouse_event", "UInt", 0x20, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        DllCall("mouse_event", "UInt", 0x40, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
    } else {
        DllCall("mouse_event", "UInt", 0x02, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        DllCall("mouse_event", "UInt", 0x04, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
    }

    if (randomEnabled) {
        min_delay := max(10, cachedDelay - 70)
        Random, randomDelay, %min_delay%, %cachedDelay%
        DllCall("Sleep", "UInt", randomDelay)
    }
return

EndScript:
    DllCall("timeEndPeriod", UInt, 1)
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    SoundBeep, 1000, 80
    SoundBeep, 800, 80
    SoundBeep, 600, 80
    ExitApp
return

ExitScript:
    DllCall("timeEndPeriod", UInt, 1)
    ExitApp
return
