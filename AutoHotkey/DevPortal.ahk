;
; Template.ahk
;
; Sets the general formatting for an AutoHotKey (AHK) script file.
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 12/27/09:
; - Changed the path for debug.ahk to point to the include directory.
; - Added default logging.
;
; 10/24/09:
; - Added comment space to the header
; - Moved the Startup call above the includes
; 
;
; 04/21/09:
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

DevPortal_Startup()

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
::_dpint::
    run https://dev.windows-int.com/en-us/dashboard/Application?appId=9WZDNCRFJBMP&logged_in=1
return

::_dpprod::
    run https://dev.windows.com/en-us/dashboard/Application?appId=9WZDNCRFJBMP&logged_in=1
return

#k:: 
    maxLoop := 20
    allDone := false

    while (!allDone)
    {
        onPage := WaitForPage("c:\temp\submission.png", 30, 1)
        while (!FindImageAndClick("c:\temp\incomplete.png", -250, 2, 1, 1, 1) && (maxLoop > 0))
        {
            Send {WheelDown 5}
            maxLoop--
        }

        if (maxLoop > 0)
        {
;           found := FindImageAndClick("c:\temp\incomplete.png", -250, 2, 2, 1, 1)
            onPage := WaitForPage("c:\temp\description.png", 30, 1)
            if (onPage) {
                Sleep 500
                PopulateAndSaveLanguage()
            } else {
                MsgBox Timed out.
            }
        } else {
            allDone := true
        }
    }

BLAH:
    MsgBox Done!
return

WaitForPage( imageName, timeout, interval )
{
   LogFunctionStart(A_ThisFunc)

    tries := timeout / interval
    foundIt := FindImageAndClick(imageName, 0, 0, tries, interval, 0)

goto WAITFORPAGE_EXIT
WAITFORPAGE_EXIT:
   LogFunctionEnd()
    return %foundIt%    
}


PopulateAndSaveLanguage()
{
    LogFunctionStart(A_ThisFunc)
    
    SendMode Event
    CoordMode Mouse Window
    FindImageAndClick("c:\temp\description.png", 100, 100, 5, .5, 1)
    
    Sleep 500
    Send ^a
    Send This is the Windows Store used for acquiring modern applications.{Tab 2}
    Send {Tab}{Enter}
    Sleep 500
    Send \\redmond\win\Users\DAVSMITH\Temp\store_splash.png{Enter}
    Sleep 500
    Send ^{End}
    Sleep 200
    FindImageAndClick("c:\temp\savebutton.png", 5, 5, 3, 1, 1)

goto POPULATEANDSAVELANGUAGE_EXIT
POPULATEANDSAVELANGUAGE_EXIT:
   LogFunctionEnd()
}

old_FindIncomplete(scrollStart:=0, scrollMax:=20)
{
    Send {WheelDown 20}
    Sleep 500
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, \\redmond\win\users\davsmith\temp\incomplete2.png

    if ErrorLevel = 2
        MsgBox Could not conduct the search.
    else if ErrorLevel = 1
    {
        MsgBox Icon could not be found on the screen, dude.
    }
    else
    {
        ; MsgBox The icon was found at %FoundX%x%FoundY%.
        adjX := FoundX - 250
        adjY := FoundY + 2
        Click %adjX%, %adjY%
     }
     return
}

::_old_z::
SendMode Event
CoordMode Mouse Window
Click 922, 530
Send This is the Windows Store used for acquiring modern applications.{Tab 2}
Send {Tab}{Enter}
Sleep 1000
Send \\redmond\win\Users\DAVSMITH\Temp\store_splash.png{Enter}
Sleep 500
Send ^{End}
Sleep 200

 ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, \\redmond\win\users\davsmith\temp\button.png

 if ErrorLevel = 2
    MsgBox Could not conduct the search.
 else if ErrorLevel = 1
 {
    MsgBox Icon could not be found on the screen, dude.
 }
 else
 {
    ; MsgBox The icon was found at %FoundX%x%FoundY%.
    adjX := FoundX + 5
    adjY := FoundY + 5
    Click %adjX%, %adjY%
 }

; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
DevPortal_Startup()
{
   LogFunctionStart(A_ThisFunc)

   ; This is an ugly check to make sure the function is only run once.
   global DevPortal_StartupCompleted
   IfEqual DevPortal_StartupCompleted, true, goto DEVPORTAL_STARTUP_EXIT
   gDevPortal_StartupCompleted = true

DEVPORTAL_STARTUP_EXIT:
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