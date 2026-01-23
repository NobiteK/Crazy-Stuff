#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Color, 0xF3F3F3, 0xF3F3F3
Gui, Font, cBlack s9, MS Shell Dlg
Gui, Add, Text, x20 y20 w260 h30 Center cBlack, Set shutdown time (in seconds):
Gui, Add, Edit, vShutdownTime x20 y60 w260 h24 +E0x200 -E0x1 +Number

Gui, Add, Text, x20 y100 cBlack, Examples:
Gui, Add, Text, x20 y120 cBlack, 1h  = 3600
Gui, Add, Text, x20 y140 cBlack, 2h  = 7200
Gui, Add, Text, x20 y160 cBlack, 3h  = 10800
Gui, Add, Text, x20 y180 cBlack, 5h  = 18000

Gui, Add, Button, x100 y210 w100 h30 gSetShutdown +0x1, OK

DllCall("UxTheme.dll\SetWindowTheme", "Ptr", WinExist(), "Str", "DarkMode_Explorer", "Ptr", 0)

Gui, Font, cGray s7, MS Shell Dlg
Gui, Add, Text, x20 y243 w272 h16 Right cGray, Made by NobiteK

Gui, Show, w300 h260, Shutdown Timer
return

SetShutdown:
    Gui, Submit, NoHide
    if (ShutdownTime = "")
    {
        MsgBox, 48, Error, You must enter time in seconds!
        return
    }
    if ShutdownTime is not integer
    {
        MsgBox, 48, Error, Please enter a whole number (seconds)!
        return
    }
    Run, shutdown -s -t %ShutdownTime%
    MsgBox, 64, Set Successfully, Computer will shutdown in %ShutdownTime% seconds.
    ExitApp
return

GuiClose:
ExitApp