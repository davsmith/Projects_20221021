;
; Everyday.ahk
;
; Brings together a set of scripts which are used frequently.
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
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

Everyday_Startup()

;
; NOTE:  Include order is important for auto execute functionality.
; If multiple start up scripts are required among the included files,
; validate that all start up scripts are being run
;
; Otherwise, call the startup functions from the parent startup.
;
#include %A_ScriptDir%\onenote.ahk
#include %A_ScriptDir%\DevPortal.ahk
#include %A_ScriptDir%\_Include\tools.ahk
#include %A_ScriptDir%\_Include\debug.ahk


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
;********************************************************************

;
; Send keboard strokes for the word "Maple" if
; the text underscore ABC is typed while in a window
; with Microsoft in the title.
;
::_ACE::
   LogFunctionStart(A_ThisHotKey)
   Send Maple
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
::_T::
  Send Transportation
return


^j::
Send {F2}{Home}{DELETE}{ENTER}
return

^!m::
    Send {Home}_{Tab 3}
return

^!a::
    Send {Home}_{Tab}Dividend & Cap Gains{Enter}
    Sleep 1500
    Send {Tab 5}
return

^!d::
    Send ^s
    Send [American Funds (529A) - Josh-Cash]
    Send {Tab 3}
    Send 250
    Send {Tab}
    Send [American Funds (529A) - Zach-Cash]
    Send {Tab 3}
    Send 250
    Send !O
    Sleep 500
    Send !a
return


^!u::
    if not A_IsAdmin
    {
        DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """", str, A_WorkingDir, int, 1)
        ExitApp
    }
return

::_projectsn::
    Sleep 150
    Run \\redmond\win\users\davsmith\projects
return

::_projectsl::
    Run D:\OneDrive - LiveDog\OneDrive\Projects
return

::_sep::
    run powershell set-executionpolicy RemoteSigned
return

::_mydocs::
    run %a_mydocuments%
return 

::_psscripts::
    onedriveFolder := GetOneDriveDir()
    run %onedriveFolder%\projects\powershell
return

::_ahkscripts::
    onedriveFolder := GetOneDriveDir()
    run %onedriveFolder%\projects\autohotkey
return

::_copyprofile::
    onedriveFolder := GetOneDriveDir()
    FileCreateDir %a_mydocuments%\WindowsPowerShell
    FileCopy %onedriveFolder%\projects\powershell\profile.ps1, %a_mydocuments%\WindowsPowerShell, 1
return

::_ise::
    run C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe
return

; ###################
;   Utility Hotkeys
; ###################
::_ise::
    run C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe
return

; #############
;   Functions
; #############
Everyday_Startup()
{
   LogFunctionStart(A_ThisFunc)

   Tools_Startup()
   Debug_Startup()
   OneNote_Startup()
   DevPortal_Startup()

EVERYDAY_STARTUP_EXIT:
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