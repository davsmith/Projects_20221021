;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk

Template_Startup()


;
; ###############
;   Scope tools
; ###############
;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;
;********************************************************************
#ifwinactive Microsoft



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

; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
GUI_Startup()
{
   return
}


; #######
;   GUI
; #######
#D::
   Gui, Add, Text,vlblFirst,  First name:           ; Add a text label for the first name edit box
   Gui, Add, Text,vlbLast,    Last name:            ; Add a text label for the last name edit box
   Gui, Add, Edit, vebFirstName ym                  ; The ym option starts a new column of controls.
   Gui, Add, Edit, vebLastName                      ; The value of the edit box is assigned to FirstName
   Gui, Add, Button, default gShowNames w100, OK    ; The label ShowNames is run when OK is clicked 
   GuiControl,,ebFirstName, Dave                    ; Set the default contents using the variable name as label
   GuiControl,,ebLastName, Smith
   Gui, Show, w250 , Simple Input Example           ; Show the dialog box at a width of 250 pixels
return  ; End of auto-execute section. The script is idle until the user does something.

ShowNames:
GuiClose:
ButtonOK:
   Gui, Submit  ; Save the input from the user to each control's associated variable.
   MsgBox First name: %ebFirstName%`nLast name: %ebLastName%
return


#G::
   Gui, Font, underline
   Gui, Add, Text, cBlue gLaunchLiveSearch, Click here to launch Live Search
   Gui, Font, norm
   Gui, Show
return

LaunchLiveSearch:
   Run www.live.com
   Gui, Destroy 
return

#C::
   GuiControlGet, ctrlContents 
   MsgBox, %ctrlContents%
return