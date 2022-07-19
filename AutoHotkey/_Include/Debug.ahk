;
; Debug.ahk
;
; Sets hotkeys and shortcuts to facilitate debugging of autohotkey scripts.
;
; Goal of this script is largely to consolidate many of the hotkey definitions into one
; script so we know which hotkeys are available, and to disable all debugging hotkeys
; by closing a single script file.
;
; If, in the process of writing new script files, it's necessary to define temporary hotkeys
; do so in this file, and comment them out or delete them when permanent mappings are defined.
;
; Notes:
; --------------------------------------------------------------------------------------------
; 4/21/09:
; - Created the file and added various hotkeys.
; - Many of the hotkeys simply call functions within the tools.ahk file.
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
#include %A_ScriptDir%\_Include\tools.ahk

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

::_ABC::
   Send Maple
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

::_help_debug::
   strHelp =
(
^!n`tActivates a currently unsaved Notepad instance, or creates a new one.
^!o`tDetects and prints the current OS Type, along with OS and IE versions.
^!t`tLists the title of the currently active window.
!^l`tLaunches DbgView from the default location.
)

   MsgBox %strHelp%
return


; ###################
;   Utility Hotkeys
; ###################

; #A::
; #B::
; #C::     <windows> Launches charms fly out
; #D::     <windows> Shows desktop
; #E::     <windows> Launches My Computer
; #F::     <windows> Launches Explorer Search (scope?)
; #G::
; #H::
; #I::
; #J::
; #K::
; #L::     <windows> Locks the computer
; #M::     <windows> Minimizes all open windows
; #N::     <OneNote> Launches a new side note
; #O::     
; #P::
; #Q::
; #R::     <windows> Run dialog
; #S::     <windows> Launches search
; #T::     <windows> Cycles through apps on the task bar (regardless of if they are open)
; #U::
; #V::
; #W::     
; #X::
; #Y::
; #Z::
; #{F1}::  <windows> Starts Help
; #{Tab}:: <windows> Cycles between open apps


;
; Launches Notepad, or brings an existing instance to the active window.
;
^!n::
   IfWinExist Untitled - Notepad
      WinActivate
   else
      Run Notepad
return


;
; Detects and prints the os and ie versions
;
^!o::
  MsgBox, %A_OSType% 
  MsgBox, %A_OSVersion% 

  RegRead, OutputVar, HKLM, Software\Microsoft\Internet Explorer, Version 
  MsgBox, %OutputVar% 
return


;
; Returns the title of the currently active window.
;
^!t::
  GetActiveWindowTitle()
return


;
; Launches the DbgView app for displaying debug information.
; Assumes that the exe is in the default location.
;
^!l::
   Run %a_scriptdir%\_utils\dbgview\dbgview.exe
return


; #############
;   Functions
; #############
Debug_Startup()
{
   LogFunctionStart(A_ThisFunc)

DEBUG_STARTUP_EXIT:
   LogFunctionEnd()
   return
}