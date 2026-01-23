/*
    Controls:
    PgUp - Toggle Script ON/OFF
    End - Close Script
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

Menu, Tray, NoStandard 
Menu, Tray, Tip, DoorSpam [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132

Menu, Tray, NoStandard
Menu, Tray, Add, Toggle DoorSpam, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, DoorSpam [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
Menu, Tray, Default, Toggle DoorSpam

enabled := false

\::
enabled := !enabled
if (enabled) {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
    Menu, Tray, Tip, DoorSpam [ON]
    SoundBeep, 1000, 150  ; ON - higher pitch
} else {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    Menu, Tray, Tip, DoorSpam [OFF]
    SoundBeep, 400, 200  ; OFF - lower pitch
}
return

*~$XButton1::
if (!enabled)
    return

while (GetKeyState("XButton1", "P")) {
    Send, e
    Sleep, 10
}
return

Home::
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
SoundBeep, 1000, 80
SoundBeep, 800, 80
SoundBeep, 600, 80
ExitApp
return

ToggleScript:
    GoSub, \
return

ExitScript:
    GoSub, Home
return