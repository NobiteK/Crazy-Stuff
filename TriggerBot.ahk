/*
    Controls:
    LAlt - Hold TriggerBot
    PgUp - Toggle Script ON/OFF
    End - Close Script
    
    Delays:
    Shot Delay: 80-200ms (random)
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

Menu, Tray, NoStandard
Menu, Tray, Add, Toggle TriggerBot, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, TriggerBot [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
Menu, Tray, Default, Toggle TriggerBot

Threshold := 15
enabled := false
global lastShotTime := 0

PgUp::
enabled := !enabled
if (enabled) {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
    Menu, Tray, Tip, TriggerBot [ON]
    SoundBeep, 1000, 150  ; ON - higher pitch
} else {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    Menu, Tray, Tip, TriggerBot [OFF]
    SoundBeep, 400, 200  ; OFF - lower pitch
}
return

*~$LAlt::
if (!enabled) {
    return
}
MouseGetPos, MouseX, MouseY
PixelGetColor, Color1, (MouseX+2), (MouseY+2)
StringSplit, Colorz, Color1
Color1B = 0x%Colorz3%%Colorz4%
Color1G = 0x%Colorz5%%Colorz6%
Color1R = 0x%Colorz7%%Colorz8%
Color1B += 0
Color1G += 0
Color1R += 0

while (GetKeyState("LAlt", "P"))
{
    BlockInput, MouseMove
    Random, checkDelay, 80, 200
    sleep %checkDelay%
    MouseGetPos, MouseX, MouseY
    PixelGetColor, Color2, (MouseX+2), (MouseY+2)
    StringSplit, Colorz, Color2
    Color2B = 0x%Colorz3%%Colorz4%
    Color2G = 0x%Colorz5%%Colorz6%
    Color2R = 0x%Colorz7%%Colorz8%
    Color2B += 0
    Color2G += 0
    Color2R += 0
    if (Color1R > (Color2R + Threshold)) or (Color1R < (Color2R - Threshold)) or (Color1G > (Color2G + Threshold)) or (Color1G < (Color2G - Threshold)) or (Color1B > (Color2B + Threshold)) or (Color1B < (Color2B - Threshold))
    {
        currentTime := A_TickCount
        if (currentTime - lastShotTime >= 600) {
            send {LButton}
            lastShotTime := currentTime
        }
    }
}
BlockInput, MouseMoveOff
Return

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