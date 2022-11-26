#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;------------------------------------------------------------------------------------------------
;Color Picker
;"Ctrl + 1"(Hold)   - activate
;"Ctrl + 1"(Unhold) - copy color

Gui, -Caption +ToolWindow +LastFound +AlwaysOnTop +Border
Gui, Font, s12 cBlack ;Set font size & color
Gui, Add, Text, x5 y5 w75 center vupdatetxt, FFFFFF

showpad=0

^1:: ; Set the shortcut to be used in displaying color under mouse.
;gui,hide
MouseGetPos X, Y
PixelGetColor Color, X, Y, RGB
StringRight, color, color, 6

Gui, Color, %color%
CoordMode, Mouse, Screen   
MouseGetPos, mx, my
mx:=mx+40
my:=my-20
Gui, -Caption +ToolWindow +LastFound +AlwaysOnTop +Border
Gui, Show, NoActivate x%mX% y%mY% w85 h30
guicontrol,, updatetxt, %color%

SetTimer, killgui, 500
clipboard = %color%
return

killgui:
    gui, hide
    SetTimer, killgui, Off
Return
;------------------------------------------------------------------------------------------------
;Media Control
;"Alt + arrow down"  - Play/Pause
;"Alt + arrow Right" - Next
;"Alt + arrow Left"  - previous

;PgUp::Volume_Up
;PgDn::Volume_Down
!Right::Media_Next
!Left::Media_Prev
!Down::Media_Play_Pause
;------------------------------------------------------------------------------------------------
;"Ctrl + 2"          - Window on top ON/OFF

^2::  Winset, Alwaysontop, , A
Return ; Stop the script.
;------------------------------------------------------------------------------------------------
;Window Transparency
;"Ctrl + 3"          - Transparency ON/OFF

^3::
{
     TransparencyONOFF()
     return
}

TransparencyONOFF()
{
     static int := 1
     if (int = 1)
     {
      WinSet, Transparent, 150, A
          int++
     }
     else
     {
      WinSet, Transparent, OFF, A
          int--
     }
}
Return ; Stop the script.
;------------------------------------------------------------------------------------------------
;Windows Volum bar Hide/Show
;"Ctrl + 4"          - Volum bar Hide/Show

class VolumeOsd
{
    Exists()
    {
        return this.Handle() != 0
    }

    IsHidden()
    {
        if(!this.Exists())
        {
            return false
        }

        ;get the window's ShowWindow setting
        VarSetCapacity(wp, 44)
        NumPut(44, wp)
        DllCall("GetWindowPlacement", "UInt", this.Handle(), "UInt", &wp)
        state := NumGet(WP, 8, "UInt")

        ;2 = SW_SHOWMINIMIZED, we're checking if it's minimized or not
        return state = 2
    }

    Hide()
    {
        if(!this.Exists())
        {
            return false
        }

        if(this.IsHidden())
        {
            return true
        }

        ;6 = SW_MINIMIZE, we're minimizing the volume OSD window
        DllCall("ShowWindow", "UInt", this.Handle(), "Int", 6)
        return true
    }

    Show()
    {
        if(!this.Exists())
        {
            return false
        }

        if(!this.IsHidden())
        {
            return true
        }

        ;9 = SW_RESTORE, we're un-minimizing it
        DllCall("ShowWindow", "UInt", this.Handle(), "Int", 9)

        ;0 = SW_HIDE, this immediately "hides" it, because otherwise it will be displayed but invisible, blocking
        ;   clicks. we restore it, then hide it, so it won't interfere with the mouse, but next time the volume is
        ;   adjusted it will reappear like normal. there may be a better solution here, but this works ok.
        DllCall("ShowWindow", "UInt", this.Handle(), "Int", 0)

        return true
    }

    Handle()
    {
        ;the handle for the volume OSD window, if we find it
        static result := 0

        ;we previously did the searching already, so just return the handle we found
        if(result != 0)
        {
            return result
        }

        ;we will try 10 times, with increasing sleep delays between each attempt, to give the volume OSD time to be
        ;   created during logon
        loop 10
        {
            loop
            {
                ;find the parent window (hopefully the volume OSD window)
                parentHandle := DllCall("FindWindowEx", "uint", 0, "uint", parentHandle, "str", "NativeHWNDHost", "uint", 0)

                ;if there are no more matching windows, stop the loop
                if(parentHandle = 0)
                {
                    break
                }

                ;verify if the parent window has a matching child (this is how we know it's the right window)
                childHandle := DllCall("FindWindowEx", "uint", parentHandle, "uint", 0, "str", "DirectUIHWND", "uint", 0)

                ;if the child window isn't there, this definitely isn't the volume osd, skip to the next loop
                if(childHandle = 0)
                {
                    continue
                }

                ;if we previously found a match and now another, we can't be sure which one is the right one, so we fail
                if(result != 0)
                {
                    return 0
                }

                ;we found a match! store it to be checked and returned later
                result := parentHandle
            }

            ;if we didn't find the window (especially during startup), triggering a volume change can force it out
            if(result = 0)
            {
                ;but first, we'll wait a while to try again, waiting longer each time
                Sleep, 1000 * (A_Index ** 2)
                Send, {Volume_Up}
                Send, {Volume_Down}
            } else {
                ;we found the window! stop looping
                break
            }
        }

        return result
    }
}
^4::
{
     VolumeOsdHideShow()
     return
}

VolumeOsdHideShow()
{
     static int := 1
     if (int = 1)
     {
      VolumeOsd.Hide()
          int++
     }
     else
     {
      VolumeOsd.Show()
          int--
     }
}
Return
;------------------------------------------------------------------------------------------------
;Text autocomplete
::cn.::convasnoise@gmail.com
::dl3.::Digitallight3D@gmail.com
::nid.::noiseindata@gmail.com
Return ; Stop the script.
;------------------------------------------------------------------------------------------------ 
;"Shift + Esc"    - Exit the script
<+Esc::ExitApp 