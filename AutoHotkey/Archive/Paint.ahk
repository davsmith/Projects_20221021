;
; Paint.ahk
;
; Macros for use with the Microsoft Paint program included in Windows.
;
; Notes:
; --------------------------------------------------------------------------------------------
; 4/25/09:
; - Created the file with macros for use in GPS POI icon editing
;

;
; #########################
;   Global Initialization
; #########################
;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\debug.ahk
#include %A_ScriptDir%\Include\convert.ahk

Paint_Startup()



;
; ###############
;   Scope tools
; ###############
;
; The hotkeys listed below are only active if the active window is Microsoft Paint (contains - Paint in title)
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;
;********************************************************************
#ifwinactive - Paint

::_pc::
   Send ^n!n					; Ditch the existing drawing
   Send !Hre{Right}{Tab}                        ; Resize the default canvas to 16x16 (for Garmin waypoints)
   Send !M
   Send !H16
   Send !V16 
   Send {Enter}
   Send ^n!n					; Ditch the existing drawing
   SplitGrid()                                  ; Split Garmin screen shots into individual images
return



::_8::
   ReSaveAs8bit()
return

^D::
   Click 275,102
return

^E::
   LogFunctionStart(A_ThisFunc)
   MouseGetPos, MouseX, MouseY
   PixelGetColor, color, %MouseX%, %MouseY%
   strBlue := Substr(color,3,2)
   strGreen := Substr(color,5,2)
   strRed := Substr(color,7,2)
   strBlue := Convert(strBlue, "hex", "dec")
   strGreen := Convert(strGreen, "hex", "dec")
   strRed := Convert(strRed, "hex", "dec")

   Log("Calling SetPickerFields")
   SetPickerFields(strRed, strGreen, strBlue)
   LogFunctionEnd()
return

;
; ################
;   Global tools
; ################
;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************


SetPickerFields(nRed, nGreen, nBlue)
{
   LogFunctionStart(A_ThisFunc)
   IfWinExist, Button
   {
      WinActivate  ; Automatically uses the window found above.
      Sleep 750
      Click 184,209
      Sleep 500
      ControlSetText Edit4, %nRed%, Color
      ControlSetText Edit5, %nGreen%, Color
      ControlSetText Edit6, %nBlue%, Color
      Sleep 200
      ControlClick Button2, Color
      WinActivate  ; Automatically uses the window found above.
   }
   else
   {
      MsgBox Nope.
   }

goto SETPICKERFIELDS_EXIT
SETPICKERFIELDS_EXIT:
   LogFunctionEnd()

}


^M::
   result := convert("FF", "hex", "dec")
   MsgBox % "Value: " . result

;   ControlGetText nRed, Edit4, Edit
;   ControlGetText nGreen, Edit5, Edit
;   ControlGetText nBlue, Edit6, Edit
;   MsgBox % "Red:" . nRed . " Green:" . nGreen . " Blue:" . nBlue 
return

; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############

SplitGrid()
{
   ;-----------------------------------------------------------------------------
   ;
   ; Hard coded values for Garmin screen shots
   ;-----------------------------------------------------------------------------
   strScreenShotPath = e:\foldershare\home\geocaching\boston\symbols\screenshots

   nIconWidth = 16
   nIconHeight = 16

   nCellBorderX = 8
   nCellBorderY = 3

   nNumIconsPerRow = 2
   nNumRowsPerScreen = 2
   nNumScreens = 2 

   nScreenULX = 23
   nScreenULY = 178
   ;-----------------------------------------------------------------------------

   x1 := nScreenULX
   y1 := nScreenULY

   nIndex = 1
   nScreen = 1

   loop %nNumScreens%                                               ; Number of screens to parse
   {
      strScreenShot = %strScreenShotPath%\ScreenShot%nScreen%.bmp
      loop, %nNumRowsPerScreen%                                     ; Number of rows in a screen
      {
         loop, %nNumIconsPerRow%                                    ; Number icons in a row
         {
            Send !f!o
            Sleep 1000  
            clipboard := strScreenShot
            Send ^v{enter}
            Sleep 800 
            Send !HSER					; Set selection mode, and choose rectangle  
            MouseMove %x1%,%y1%				; Move the mouse to the UL corner of the icon to snip
            nDragWidth := nIconWidth - 1
            nDragHeight := nIconHeight - 1
            MouseClickDrag L, 0,0, %nDragWidth%, %nDragHeight%,, R		; Snip the specified size cell
            Send ^c                                     ; Copy the snipped selection
            Send !fn                                    ; Open a new blank document
            Send ^v                                     ; Paste in the newly snipped selection
            SetCurrentColorToColorKey()                 ; Set the current paint color to the Garmin color key
            ChooseFillTool()                            ; Set the drawing tool to fill
            FillCorners(nIconWidth, nIconHeight)        ; Fill in the area around the image with colorkey
            Send !fs                                    ; Save the image
            WinWaitActive, Save,, 3                     ; Wait for the Save dialog to launch 
            if (ErrorLevel)  
            {
               OutputDebug Timed out waiting for Save dialog to open
            }

            clipboard = Icon%nIndex%.bmp
            Send ^v{enter}                              ; Paste in the filename for the new image
            nIndex++
            x1 := x1 + nIconWidth + nCellBorderX        ; Index to the next cell in the row
         }
         x1 := nScreenULX                             ; Index to the next row in the screen
         y1 := y1 + nIconHeight + nCellBorderY
      }

      x1 := nScreenULX                                 ; Reset the UL corner, and start again with
      y1 := nScreenULY                                 ;  the next screen.
      nScreen++
   }

   return %nIndex%
}



SetCurrentColorToColorKey()
{
   Send !H1     ; Select Color 1 
   Send !HEC    ; Launch the "edit colors dialog"
   Send !R255   ; Set max red, and blue, min green to make purple (Garmin colorkey)
   Send !G0
   Send !U255
   Send {Enter}   ; Store as a custom color and exit

   return
}



ChooseFillTool()
{
   Send !HK
   return
}



FillCorners(nWidth, nHeight)
{
   nXPos = 13
   nYPos = 151

   nClickX := nXPos
   nClickY := nYPos
   MouseClick L, %nClickX%, %nClickY%

   nClickX := nXPos+nWidth-1
   nClickY := nYPos
   MouseClick L, %nClickX%, %nClickY%

   nClickX := nXPos
   nClickY := nYPos+nHeight-1
   MouseClick L, %nClickX%, %nClickY%

   nClickX := nXPos+nWidth-1
   nClickY := nYPos+nHeight-1 
   MouseClick L, %nClickX%, %nClickY%

   return
}



ReSaveAs8bit()
{
   loop, E:\FolderShare\Home\Geocaching\Boston\Symbols\Garmin\*.bmp 
   {
      OutputDebug, %a_loopfilefullpath%
      Send !FO
      WinWaitActive, Open,, 1        ; Wait for the window to launch 
      if (ErrorLevel)  
      {
         OutputDebug %a_loopfilepath%
         OutputDebug Timed Out waiting for Open dialog.
         Send {Enter}
         continue
      }
      
      clipboard = %a_loopfilefullpath%
      Send ^V
      Send {Enter}

      WinWaitActive, Paint,, 3        ; Wait for the window to launch 
      if (ErrorLevel)  
      {
         OutputDebug %a_loopfilepath%
         OutputDebug Timed Out waiting for Open dialog to close.
         continue
      }

      Send !FA
      WinWaitActive, Save As,, 3        ; Wait for the window to launch 
      if (ErrorLevel)  
      {
         OutputDebug %a_loopfilepath%
         OutputDebug Timed Out waiting for Save As dialog.
         continue
      }

      Sleep 100
      Send !T
      Send M2
      Send !n
      clipboard = %a_loopfilefullpath%
      Send ^V
      Send {Enter}

      Send !S
      Send !Y
      Send {Enter}
   }

RESAVE_EXIT:
   return
}



Paint_Startup()
{
   return
}


FunctionCallTemplate(byref strOutVar1, byref strOutVar2)
{
   LogFunctionStart("FunctionCallTemplate")

   strOutVar1 = "Hello"
   strOutVar2 = "There"

FUNCTIONCALLTEMPLATE_EXIT:
   LogFunctionEnd()
   return
}

Sum(nInput1, nInput2)
{
   return nInput1+nInput2
}