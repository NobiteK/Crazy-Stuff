/*
    Controls:
    = or F1 - Toggle ON/OFF
    End - Close Script
*/

TEXT_TO_PASTE := "hello" ;      ; Text to be auto-pasted
INTERVAL := 15000               ; Interval in milliseconds (15000 ms = 15 seconds)

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

Menu, Tray, NoStandard 
Menu, Tray, Add, Toggle AutoPaste, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, AutoPaste [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
Menu, Tray, Default, Toggle AutoPaste

enabled := false

=::
enabled := !enabled
if (enabled) {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
    Menu, Tray, Tip, AutoPaste [ON]
    SoundBeep, 1000, 150
    tmp := clipboard
    Clipboard := TEXT_TO_PASTE
    SendInput ^v{Enter}
    Clipboard := tmp
    SetTimer, RePaste, %INTERVAL%
} else {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    Menu, Tray, Tip, AutoPaste [OFF]
    SoundBeep, 400, 200
    SetTimer, RePaste, Off
}
return

RePaste:
if (!enabled)
    return
tmp := clipboard
Clipboard := TEXT_TO_PASTE
SendInput ^v{Enter}
Clipboard := tmp
return

F1::
GoSub, =
return

End::
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
SoundBeep, 1000, 80
SoundBeep, 800, 80
SoundBeep, 600, 80
ExitApp
return

ToggleScript:
GoSub, =
return

ExitScript:
GoSub, End
return