;
; Experiments.ahk
;
; Scripts for experimenting with functionality in AutoHotkey.
;
; Notes:
;    - Once functionality is understood, the code should be moved to Examples.ahk
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

^!h::
    MsgBox Hello!
Return