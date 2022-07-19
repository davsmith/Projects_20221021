;
; Examples.ahk
;
; Scripts for demonstrating AutoHotkey functionality, including the VS Code plugin by cweijan.
;
; Notes:
;    - Including a dash in the filename will disable breakpoints in the debugger (weird!)
;    - Breakpoints don't work with hotstrings (but work with hotkeys from outside Code)
;
; --------------------------------------------------------------------------------------------
; 1/10/21:
;     - Created from Template.ahk
;

;
; #########################
;   Global Initialization
; #########################

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

Template_Startup()

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
    ^!h::
        MsgBox Hello there
    Return

    ::_gfd::
        colours := Object("red", 0xFF0000, "blue", 0x0000FF, "green", 0x00FF00)
        ; The above expression could be used directly in place of "colours" below:
        for k, v in colours
            s .= k "=" v "`n"
        MsgBox % s
    return

    ::_gf2::
        for window in ComObjCreate("Shell.Application").Windows
            windows .= window.LocationName " :: " window.LocationURL "`n"
        MsgBox % windows
    return

    ::myloop::
        fruit_list := ["apple", "banana", "orange"]
        for i, fruit in fruit_list
        {
            MsgBox %fruit%
        }
    return

    ; ###################
    ;   Utility Hotkeys
    ; ###################

    ; #############
    ;   Functions
    ; #############
    Template_Startup()
    {
        LogFunctionStart(A_ThisFunc)

        ; This is an ugly check to make sure the function is only run once.
        global Template_StartupCompleted
        IfEqual Template_StartupCompleted, true, goto TEMPLATE_STARTUP_EXIT
        gTemplate_StartupCompleted = true

    TEMPLATE_STARTUP_EXIT:
        LogFunctionEnd()

    return
}

Test_Function1()
{
    ; This is a comment to test a Test_Function1()
    MsgBox "This is a test"
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