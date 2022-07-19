;
; OneNote.ahk
;
; Utility functions and hot keys for OneNote 2013
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 05/28/15:
; - Created the template file and formatted various sections
;

;
; #########################
;   Global Initialization
; #########################

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SendMode Event ; Required for SetKeyDelay

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

OneNote_Startup()

;
; NOTE:  Include order is important for auto execute functionality.
; If multiple start up scripts are required among the included files,
; validate that all start up scripts are being run
;
; Otherwise, call the startup functions from the parent startup.
;
#include %A_ScriptDir%\_Include\tools.ahk
#include %A_ScriptDir%\_Include\debug.ahk


;
; ###############
;   Scope tools
; ###############
;
;********************************************************************
#ifwinactive - OneNote
;********************************************************************

;
; Format the selected text as "code" (i.e. Consolas - 10)
;
^!c::
   LogFunctionStart(A_ThisHotKey)
   Sleep 500 
   Send !h
   Send f
   Send f
   Send Consolas{Tab}
   Send 10{Enter}{Esc}
   LogFunctionEnd()
return

;
; Format the selected text as "normal" (i.e. Calibri - 11)
;
^!n::
   LogFunctionStart(A_ThisHotKey)
   Sleep 500 
   Send !h
   Send f
   Send f
   Send Calibri{Tab}
   Send 11{Enter}{Esc}
   LogFunctionEnd()
return


^!b::
   Sleep 500
   Send {AppsKey}ah{enter}
return


;
; Cycles through all of the spelling issues
; choosing to ignore each one.
;
; Search over when a dialog pops up saying no
; more errors exist.
;
^!i::
    Sleep 500
    SetKeyDelay 100
    Send !rs
    loopCount = 0

    while (loopCount < 100)
    {
        loopCount++
        IfWinNotExist ,,The spelling check
        {
            Send i
            Sleep 100
        }
        else
        {
            ControlClick OK
            return 
        }
    }
    ; MsgBox Ended.
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

::_link::
;# Weekend Scripter: Use PowerShell to Easily Modify Registry Property Values
    SendMode Event ; Required for SetKeyDelay
    SetKeyDelay 1000
    SendInput ONe
    Sleep 1000
    SendInput {Up}
    SendInput {Up}
    Sleep 1000
    SEndInput TWo
return

^!Q::
    Send {Up}
return


; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
OneNote_Startup()
{
   LogFunctionStart(A_ThisFunc)

   global gOneNote_StartupCompleted
   IfEqual gOneNote_StartupCompleted, true, goto ONENOTE_STARTUP_EXIT
   gOneNote_StartupCompleted = true

ONENOTE_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


/*
MsgBox Hello!  No quotes required.
MsgBox %a_scriptdir%  `% is required for variables


FunctionCallTemplate(byref strOutVar1, byref strOutVar2)
{
   LogFunctionStart(A_ThisFunc)

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
*/