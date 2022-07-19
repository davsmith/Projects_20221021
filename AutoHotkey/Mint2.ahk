;
; Mint.ahk
;
; Scripts for working on transactions and accounts in Mint.com
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 1/4/2021: Created from Template.ahk
;

;
; #########################
;   Global Initialization
; #########################

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Event ; Recommended for new scripts due to its superior speed and reliability.
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
        ; This macro requires caret browsing (F7) is turned on in Windows

    ^!b::
        Send ^f
        Send Appears on your
        Send {ESC}
        Send {Left}
        Send +{Down}+{End}
        Send ^c
    return

    ^!d::
        expand_selection()
        ; parse_details_to_notes()
    return

    ^!e::
        ; description := "Appears on your Charles Schwab (Aggressive Stocks) statement as ISHARES CORE S&P 500 ETF on 12/21/20"
        ; search_string := "as "
        description := "Appears on your Charles Schwab (Aggressive Stocks) statement as ISHARES CORE S&P 500 ETF on 12/21/20"
        substr := " as "
        StringGetPos, stock_start, description, %substr%
        if (stock_start >= 0)
        {
            stock_start += StrLen(substr)
            MsgBox, The string was found at position %stock_start%.
        }
        Else
            MsgBox, Not found
    return
    ; ###################
    ;   Utility Hotkeys
    ; ###################

    ; Brute force script to update links in OneNote to reflect the new year
    ::_21::
        Send ^k
        Send {end}
        Send {backspace 2}
        Send 21
        Send {left 19}
        Send {backspace 2}
        Send 21
        Send {enter}
        Send {left 2}
        Send {Down}
    return

    ::_enc::
        SendMode event
        Send !n
        Send `%7B
        Send !p
        Send {{}
        Send !a
        Send !n
        Send `%22
        Send !p
        Send `"
        Send !a
        Send !n
        Send `%3A
        Send !p
    Send :
        Send !a
        Send !n
        Send `%2C
        Send !p
        Send {,}
        Send !a
        Send !n
        Send `%3D
        Send !p
        Send `=
        Send !a
        Send !n
        Send `%20
        Send !p
        Send {space}
        Send !a
        Send !n
        Send `%7D
        Send !p
    Send {}}
    Send !a
    Send !n
    Send `%26
    Send !p
    Send &
    Send !a

    return

    ^F1::
        Send https://mint.intuit.com/transaction.event?startDate=01/01/2020&endDate=01/31/2020{Enter}
    return

    ^F2::
        Send https://mint.intuit.com/transaction.event?startDate=02/01/2020&endDate=02/29/2020{Enter}
    return

    ^3::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=03/01/2020&endDate=03/31/2020{Enter}
    ^4::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=04/01/2020&endDate=04/30/2020{Enter}
    ^5::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=05/01/2020&endDate=05/31/2020{Enter}
    ^6::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=06/01/2020&endDate=06/30/2020{Enter}
    ^7::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=07/01/2020&endDate=07/31/2020{Enter}
    ^8::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=08/01/2020&endDate=08/31/2020{Enter}
    ^9::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=09/01/2020&endDate=09/30/2020{Enter}
    ::_10::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=10/01/2020&endDate=10/31/2020{Enter}
    ::_11::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=11/01/2020&endDate=11/30/2020{Enter}
    ::_12::
        Send ^a
        Send https://mint.intuit.com/transaction.event?startDate=12/01/2020&endDate=12/31/2020{Enter}

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

        expand_selection()
        {
            SELECTION_COLOR = 0x676767
            PixelSearch, px, py, 0, 0, 3000, 3000, 0x676767, 0
            edit_details_x := Px + 300
            edit_details_y := Py + 35
            MouseMove %edit_details_x%, %edit_details_y%
            Click
            return
        }

        parse_details_to_notes()
        {
            Send ^f
            Send Appears on
            SetKeyDelay, 200
            Send {Escape}
            Send {Left}
            Send +{Down}
            Send +{End}
            Send ^c
            details_string := clipboard 
            stock_index := StringGetPos, location, details_string, "statement as"
            MsgBox %stock_index%

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