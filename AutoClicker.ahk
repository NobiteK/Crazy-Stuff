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
holdEnabled := false
currentHoldHotkey := ""
keyboardKey := ""
settingKeyboardKey := false

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

; Speed + RND
Gui, Add, Text, cWhite x%margin% y%yPos%, Speed (ms):
Gui, Add, Text, vRndLabel cGreen x120 y%yPos% Hidden, [RND: ON]
yPos += 24
Gui, Add, Edit, vClickDelay w147 cBlack Background0x2D2D30 Number x40 y%yPos% hwndhEdit gUpdateDelay
Gui, Add, Button, vRandomBtn x193 y%yPos% w48 h24 gClickRandom, RND

SendMessage, 0x1501, 1, "Minimum: 1 ms",, ahk_id %hEdit%
yPos += gap + 24

; Button + HOLD
Gui, Add, Text, cWhite x%margin% y%yPos%, Button:
Gui, Add, Text, vHoldLabel cGreen x90 y%yPos% Hidden, [HOLD: ON]
yPos += 24
Gui, Add, DropDownList, vMouseButtonChoice w147 cWhite Background0x2D2D30 x%margin% y%yPos% gUpdateButton, Left Mouse|Right Mouse|Middle Mouse|Keyboard - "?"
GuiControl, ChooseString, MouseButtonChoice, %mouseButton%
Gui, Add, Button, vHoldBtn x193 y%yPos% w48 h24 gClickHold, HOLD

yPos += gap + 24

; Toggle key
Gui, Add, Text, cWhite x%margin% y%yPos%, Toggle key:
yPos += 24
Gui, Add, Button, vHotkeyBtn gSetHotkey w201 +0x4000 x%margin% y%yPos%, %hotkeyToggle%
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
    if (settingKeyboardKey)
        return

    GuiControlGet, selectedButton,, MouseButtonChoice
    if (selectedButton = "Right Mouse") {
        cachedButton := "Right"
        keyboardKey := ""
    } else if (selectedButton = "Middle Mouse") {
        cachedButton := "Middle"
        keyboardKey := ""
    } else if (selectedButton = "Left Mouse") {
        cachedButton := "Left"
        keyboardKey := ""
    } else if (InStr(selectedButton, "Keyboard")) {
        Gosub, SetKeyboardButton
    }

    if (holdEnabled && currentHoldHotkey != "") {
        oldHotkey := currentHoldHotkey
        if (keyboardKey != "") {
            currentHoldHotkey := keyboardKey
        } else {
            currentHoldHotkey := (cachedButton = "Right" ? "RButton" : (cachedButton = "Middle" ? "MButton" : "LButton"))
        }
        if (oldHotkey != currentHoldHotkey) {
            Hotkey, ~$*%oldHotkey%, HoldAutoFire, Off
            Hotkey, ~$*%currentHoldHotkey%, HoldAutoFire, On
        }
    }
return

SetKeyboardButton:
    Gui, +OwnDialogs
    MsgBox, 64, Set Button, Click OK and press a key to set button.

    settingKeyboardKey := true

    Input, newKey, L1 T5, {LControl}{RControl}{LShift}{RShift}{LAlt}{RAlt}{LWin}{RWin}{Space}{Enter}{Tab}{Backspace}{Delete}{Insert}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}

    capturedKey := ""
    sendKey := ""

    if (ErrorLevel = "EndKey:LControl" || ErrorLevel = "EndKey:RControl") {
        capturedKey := "Ctrl",  sendKey := "Ctrl"
    } else if (ErrorLevel = "EndKey:LShift" || ErrorLevel = "EndKey:RShift") {
        capturedKey := "Shift", sendKey := "Shift"
    } else if (ErrorLevel = "EndKey:LAlt" || ErrorLevel = "EndKey:RAlt") {
        capturedKey := "Alt",   sendKey := "Alt"
    } else if (ErrorLevel = "EndKey:LWin" || ErrorLevel = "EndKey:RWin") {
        capturedKey := "Win",   sendKey := "LWin"
    } else if (ErrorLevel = "EndKey:Space") {
        capturedKey := "Space", sendKey := "Space"
    } else if (ErrorLevel = "EndKey:Enter") {
        capturedKey := "Enter", sendKey := "Enter"
    } else if (ErrorLevel = "EndKey:Tab") {
        capturedKey := "Tab",   sendKey := "Tab"
    } else if (ErrorLevel = "EndKey:Backspace") {
        capturedKey := "Backspace", sendKey := "Backspace"
    } else if (ErrorLevel = "EndKey:Delete") {
        capturedKey := "Delete", sendKey := "Delete"
    } else if (ErrorLevel = "EndKey:Insert") {
        capturedKey := "Insert", sendKey := "Insert"
    } else if (ErrorLevel = "EndKey:Home") {
        capturedKey := "Home",  sendKey := "Home"
    } else if (ErrorLevel = "EndKey:End") {
        capturedKey := "End",   sendKey := "End"
    } else if (ErrorLevel = "EndKey:PgUp") {
        capturedKey := "PgUp",  sendKey := "PgUp"
    } else if (ErrorLevel = "EndKey:PgDn") {
        capturedKey := "PgDn",  sendKey := "PgDn"
    } else if (ErrorLevel = "EndKey:Up") {
        capturedKey := "Up",    sendKey := "Up"
    } else if (ErrorLevel = "EndKey:Down") {
        capturedKey := "Down",  sendKey := "Down"
    } else if (ErrorLevel = "EndKey:Left") {
        capturedKey := "Left",  sendKey := "Left"
    } else if (ErrorLevel = "EndKey:Right") {
        capturedKey := "Right", sendKey := "Right"
    } else if (ErrorLevel = "EndKey:F1") {
        capturedKey := "F1",  sendKey := "F1"
    } else if (ErrorLevel = "EndKey:F2") {
        capturedKey := "F2",  sendKey := "F2"
    } else if (ErrorLevel = "EndKey:F3") {
        capturedKey := "F3",  sendKey := "F3"
    } else if (ErrorLevel = "EndKey:F4") {
        capturedKey := "F4",  sendKey := "F4"
    } else if (ErrorLevel = "EndKey:F5") {
        capturedKey := "F5",  sendKey := "F5"
    } else if (ErrorLevel = "EndKey:F6") {
        capturedKey := "F6",  sendKey := "F6"
    } else if (ErrorLevel = "EndKey:F7") {
        capturedKey := "F7",  sendKey := "F7"
    } else if (ErrorLevel = "EndKey:F8") {
        capturedKey := "F8",  sendKey := "F8"
    } else if (ErrorLevel = "EndKey:F9") {
        capturedKey := "F9",  sendKey := "F9"
    } else if (ErrorLevel = "EndKey:F10") {
        capturedKey := "F10", sendKey := "F10"
    } else if (ErrorLevel = "EndKey:F11") {
        capturedKey := "F11", sendKey := "F11"
    } else if (ErrorLevel = "EndKey:F12") {
        capturedKey := "F12", sendKey := "F12"
    } else if (newKey != "") {
        capturedKey := newKey
        sendKey := newKey
    }

    if (capturedKey != "") {
        keyboardKey := sendKey
        cachedButton := "Keyboard"
        newLabel := "Keyboard - """ . capturedKey . """"
        GuiControl,, MouseButtonChoice, |Left Mouse|Right Mouse|Middle Mouse|%newLabel%
        GuiControl, ChooseString, MouseButtonChoice, %newLabel%
    } else {
        cachedButton := "Left"
        keyboardKey := ""
        GuiControl,, MouseButtonChoice, |Left Mouse|Right Mouse|Middle Mouse|Keyboard - "?"
        GuiControl, ChooseString, MouseButtonChoice, Left Mouse
    }

    settingKeyboardKey := false
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

ClickHold:
    if (holdEnabled) {
        holdEnabled := false
        GuiControl, Hide, HoldLabel
        GuiControl, Enable, HotkeyBtn
        Hotkey, %hotkeyToggle%, ToggleScript, On
        Hotkey, Insert, ToggleScript, On
        
        if (currentHoldHotkey != "") {
            Hotkey, ~$*%currentHoldHotkey%, HoldAutoFire, Off
            currentHoldHotkey := ""
        }
        
        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
        Menu, Tray, Tip, AutoClicker [OFF]
        SoundBeep, 400, 200
        GuiControl,, IndicatorBar, 100
        GuiControl, +cB00000, IndicatorBar
    } 
    else {
        Gosub, UpdateDelay
        
        if (cachedDelay = "" || !RegExMatch(cachedDelay, "^\d+$") || cachedDelay < 1) {
            MsgBox, 48, AutoClicker, Please enter a valid delay in milliseconds (minimum 1 ms) to enable HOLD mode!
            return
        }
        if (randomEnabled && cachedDelay < 10) {
            MsgBox, 48, AutoClicker, With RND mode enabled, minimum delay is 10 ms!
            return
        }

        if (cachedButton = "Keyboard" && keyboardKey = "") {
            MsgBox, 48, AutoClicker, Please set a keyboard key first!
            return
        }
        
        holdEnabled := true
        GuiControl, Show, HoldLabel
        GuiControl, Disable, HotkeyBtn
        Hotkey, %hotkeyToggle%, ToggleScript, Off
        Hotkey, Insert, ToggleScript, Off
        
        if (enabled) {
            enabled := false
            SetTimer, MaxSpeedClick, Off
            SetTimer, PreciseClick, Off
        }
        
        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
        Menu, Tray, Tip, AutoClicker [HOLD: ON]
        SoundBeep, 1000, 150
        GuiControl,, IndicatorBar, 100
        GuiControl, +c00B000, IndicatorBar
        
        if (cachedButton = "Keyboard") {
            currentHoldHotkey := keyboardKey
        } else {
            currentHoldHotkey := (cachedButton = "Right" ? "RButton" : (cachedButton = "Middle" ? "MButton" : "LButton"))
        }
        Hotkey, ~$*%currentHoldHotkey%, HoldAutoFire, On
    }
return

SetHotkey:
    Gui, +OwnDialogs
    MsgBox, 64, Set Hotkey, Click OK and press a key to set hotkey.
    Input, newHotkey, L1 M
    if (ErrorLevel = "Max") {
        Hotkey, %hotkeyToggle%, ToggleScript, Off
        hotkeyToggle := newHotkey
        Hotkey, %hotkeyToggle%, ToggleScript, On
        GuiControl,, HotkeyBtn, %hotkeyToggle%
    }
return

ToggleScript:
    if (holdEnabled) 
        return
    
    enabled := !enabled
    if (enabled) {
        Gosub, UpdateDelay
        
        if (cachedDelay = "" || !RegExMatch(cachedDelay, "^\d+$") || cachedDelay < 1) {
            MsgBox, 48, AutoClicker, Please enter a valid delay in milliseconds (minimum delay is 1 ms)!
            enabled := false
            return
        }
        if (randomEnabled && cachedDelay < 10) {
            MsgBox, 48, AutoClicker, With RND mode enabled, minimum delay is 10 ms!
            enabled := false
            return
        }

        if (cachedButton = "Keyboard" && keyboardKey = "") {
            MsgBox, 48, AutoClicker, Please set a keyboard key first!
            enabled := false
            return
        }
        
        Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
        Menu, Tray, Tip, AutoClicker [ON]
        SoundBeep, 1000, 150
        GuiControl,, IndicatorBar, 100
        GuiControl, +c00B000, IndicatorBar

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
        if (cachedButton = "Keyboard") {
            Send, {%keyboardKey%}
        } else if (cachedButton = "Right") {
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
    if (cachedButton = "Keyboard") {
        Send, {%keyboardKey%}
    } else if (cachedButton = "Right") {
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
        min_delay := max(1, Round(cachedDelay * 0.70))
        max_delay := Round(cachedDelay * 1.30)
        Random, randomDelay, %min_delay%, %max_delay%
        DllCall("Sleep", "UInt", randomDelay)
    }
return

HoldAutoFire:
    if (!holdEnabled)
        return
    while GetKeyState(currentHoldHotkey, "P") {
        if (cachedButton = "Keyboard") {
            Send, {%keyboardKey%}
        } else if (cachedButton = "Right") {
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
            min_delay := max(1, Round(cachedDelay * 0.70))
            max_delay := Round(cachedDelay * 1.30)
            Random, randomDelay, %min_delay%, %max_delay%
            DllCall("Sleep", "UInt", randomDelay)
        } else if (cachedDelay = 1) {
            DllCall("Sleep", "UInt", 1)
            if (Mod(A_TickCount, 10) = 0)
                Sleep, 0
        } else {
            DllCall("Sleep", "UInt", cachedDelay)
        }
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
