;
; Word.ahk
;
; Set of keyboard macros used within Microsoft Word.
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 4/16/2010:
; - Created and wrote the Setup macro.
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

Word_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\debug.ahk




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
#ifwinactive Microsoft Word
;********************************************************************

;
; Send keboard strokes for the word "Maple" if
; the text underscore ABC is typed while in a window
; with Microsoft in the title.
;
::_ACE::
   LogFunctionStart(A_ThisHotKey)
   Send Maple
return

^!S::
   Word_Setup()
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

; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
Word_Startup()
{
   LogFunctionStart(A_ThisFunc)

WORD_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


Word_Setup()
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 100
   strFSDir := GetFolderShareDir()

   Send !fiS!i
   Send %strFSDir%Home\Word{Enter}

   Send !fia
   Send !f!f!f!f!f!f{Enter}
   Send {down 2}{Enter}
   Sleep 500 
   Send %strFSDir%Home\Word\_Templates
   Send {Tab 2}{Enter 2}{escape}

WORD_SETUP_EXIT:
   LogFunctionEnd()
   return
}


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