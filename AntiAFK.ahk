/*
    Controls:
    PgUp - Toggle ON/OFF
    End - Close Script
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; --- State ---
enabled := false

; --- Tray ---
Menu, Tray, NoStandard
Menu, Tray, Add, Toggle AntiAFK, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, AntiAFK [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
Menu, Tray, Default, Toggle AntiAFK

PgUp::
enabled := !enabled
if (enabled) {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
    Menu, Tray, Tip, AntiAFK [ON]
    SoundBeep, 1000, 150  ; ON - higher pitch
    SetTimer, AntiAFK, 500
} else {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    Menu, Tray, Tip, AntiAFK [OFF]
    SoundBeep, 400, 200  ; OFF - lower pitch
    SetTimer, AntiAFK, Off
}
return

AntiAFK:
{
    Random, HoldTime, 200, 700
    Random, KeyIndex, 1, 4
    Keys := ["w", "a", "s", "d"]
    Key := Keys[KeyIndex]

    SendInput, {%Key% down}
    Sleep, %HoldTime%
    SendInput, {%Key% up}

    Random, JumpChance, 1, 100
    if (JumpChance <= 30) {
        SendInput, {Space}
    }

    Random, CrouchChance, 1, 100
    if (CrouchChance <= 20) {
        SendInput, {Ctrl down}
        Sleep, 400
        SendInput, {Ctrl up}
    }

    Random, NumberKeyChance, 1, 100
    if (NumberKeyChance <= 25) {
        Random, NumberKey, 1, 3
        Random, NumberDelay, 1500, 4500
        SendInput, {%NumberKey%}
        Sleep, %NumberDelay%
    }
}
return

End::
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
SoundBeep, 1000, 80
SoundBeep, 800, 80
SoundBeep, 600, 80
ExitApp
return

ToggleScript:
    GoSub, PgUp
return

ExitScript:
    GoSub, End
return
