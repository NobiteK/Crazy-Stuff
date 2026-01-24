#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Font, cBlack s9, MS Shell Dlg
Gui, Add, Text, x20 y20 w260 h30 Center, Set shutdown time (in seconds):
Gui, Add, Edit, vShutdownTime x20 y60 w260 h24 +Number

Gui, Add, Text, x20 y100, Examples:
Gui, Add, Text, x20 y120, 1h  = 3600
Gui, Add, Text, x20 y140, 2h  = 7200
Gui, Add, Text, x20 y160, 3h  = 10800
Gui, Add, Text, x20 y180, 5h  = 18000

Gui, Add, Button, x45 y210 w100 h30 gSetShutdown +Default, OK
Gui, Add, Button, x155 y210 w100 h30 gAbortShutdown, Abort

Gui, Font, cGray s7
Gui, Add, Text, x20 y255 w272 h16 Right, Made by NobiteK

Gui, Show, w300 h275, Shutdown Timer
return

SetShutdown:
    Gui, Submit, NoHide
    if (ShutdownTime = "")
    {
        MsgBox, 48, Error, You must enter time in seconds!
        return
    }
    RunWait, shutdown -s -t %ShutdownTime%, , Hide
    MsgBox, 64, Set Successfully, Computer will shutdown in %ShutdownTime% seconds.
return

AbortShutdown:
    RunWait, shutdown -a, , Hide UseErrorLevel
    if (ErrorLevel != 0)
    {
        MsgBox, 48, Error, No scheduled shutdown found!
    }
    else
    {
        MsgBox, 64, Cancelled, Scheduled shutdown has been cancelled.
    }
return

GuiClose:
ExitApp
