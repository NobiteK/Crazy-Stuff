/*
    Controls:
    = or F1  - Toggle ON/OFF
    End      - Close Script
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
DllCall("timeBeginPeriod", UInt, 1)

; --- Defaults ---
TEXT_TO_PASTE := "e"
INTERVAL      := 50
PRESS_ENTER   := false
hotkeyToggle  := "="

; --- State ---
enabled := false

; --- Tray ---
Menu, Tray, NoStandard
Menu, Tray, Add, Toggle, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, AutoMessage [OFF]
Menu, Tray, Icon, %A_WinDir%\System32\main.cpl, 6
Menu, Tray, Default, Toggle

; --- GUI ---
margin := 40
gap    := 10

Gui, Margin, %margin%, %margin%
Gui, Color, 0x23272E
Gui, Font, cWhite s10, Segoe UI
Gui, +AlwaysOnTop
Gui, +MinimizeBox +OwnDialogs

yPos := margin

Gui, Add, Text, cWhite x%margin% y%yPos%, Text:
yPos += 24
Gui, Add, Edit, vTextInput w200 cBlack Background0x2D2D30 x%margin% y%yPos%
GuiControl,, TextInput, %TEXT_TO_PASTE%
yPos += gap + 24

Gui, Add, Text, cWhite x%margin% y%yPos%, Interval (ms):
yPos += 24
Gui, Add, Edit, vIntervalInput w200 cBlack Background0x2D2D30 Number x%margin% y%yPos% hwndhEdit
GuiControl,, IntervalInput, %INTERVAL%
SendMessage, 0x1501, 1, "Minimum: 1 ms",, ahk_id %hEdit%
yPos += gap + 24

Gui, Add, Text, cWhite x%margin% y%yPos%, Toggle key:
yPos += 24
Gui, Add, Button, vHotkeyBtn gSetHotkey w200 +0x4000 x%margin% y%yPos%, %hotkeyToggle%
yPos += gap + 24

Gui, Add, CheckBox, vPressEnterCheck cWhite x%margin% y%yPos% gToggleEnter, Press Enter after paste
GuiControl,, PressEnterCheck, %PRESS_ENTER%

Gui, Add, Progress, vIndicatorBar x8 y8 w12 h12 Background23272E -Border

Gui, Font, cGray s7, MS Shell Dlg
Gui, Add, Text, x20 y253 w255 h16 Right cGray, Made by NobiteK

winW := 280
winH := 270

SysGet, MonitorCount, MonitorCount
SysGet, Monitor1, Monitor, 1

foundSecondMonitor := false
Loop, %MonitorCount% {
    SysGet, Mon, Monitor, %A_Index%
    if (A_Index != 1 && MonLeft < Monitor1Left) {
        xPos := MonRight - winW - 5
        yPos2 := MonTop + 5
        foundSecondMonitor := true
        break
    }
}

if (foundSecondMonitor) {
    Gui, Show, x%xPos% y%yPos2% w%winW% h%winH%, AutoMessage
} else {
    xPos := Monitor1Right - winW - 7
    yPos2 := Monitor1Top + 5
    Gui, Show, x%xPos% y%yPos2% w%winW% h%winH%, AutoMessage
}

GuiControl,, IndicatorBar, 100
GuiControl, +cB00000, IndicatorBar

Hotkey, %hotkeyToggle%, ToggleScript, On
Hotkey, F1, ToggleScript, On
Hotkey, End, EndScript, On
return

; --- Handlers ---
ToggleEnter:
    GuiControlGet, PressEnterCheck
    PRESS_ENTER := PressEnterCheck
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
        GuiControlGet, TEXT_TO_PASTE,, TextInput
        GuiControlGet, INTERVAL,, IntervalInput
        GuiControlGet, PressEnterCheck

        if (INTERVAL = "" || !RegExMatch(INTERVAL, "^\d+$") || INTERVAL < 1) {
            MsgBox, Please enter a valid interval in milliseconds (minimum is 1 ms)!
            enabled := false
            return
        }
        if (TEXT_TO_PASTE = "") {
            MsgBox, Please enter text to paste!
            enabled := false
            return
        }

        PRESS_ENTER := PressEnterCheck

        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
        Menu, Tray, Tip, AutoMessage [ON]
        SoundBeep, 1000, 150
        GuiControl,, IndicatorBar, 100
        GuiControl, +c00B000, IndicatorBar

        SendInput, %TEXT_TO_PASTE%
        if (PRESS_ENTER)
            SendInput {Enter}
        SetTimer, RePaste, %INTERVAL%
    } else {
        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
        Menu, Tray, Tip, AutoMessage [OFF]
        SoundBeep, 400, 200
        GuiControl,, IndicatorBar, 100
        GuiControl, +cB00000, IndicatorBar
        SetTimer, RePaste, Off
    }
return

RePaste:
    if (!enabled)
        return
    SendInput, %TEXT_TO_PASTE%
    if (PRESS_ENTER)
        SendInput {Enter}
return

GuiClose:
    DllCall("timeEndPeriod", UInt, 1)
    ExitApp
return

GuiMinimize:
    Gui, Hide
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
