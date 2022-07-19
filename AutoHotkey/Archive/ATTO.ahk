;
; ATTO.ahk
;
; Scripts for use with the ATTO Disk benchmark.
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 12/5/2010:
;   - Use control-B to copy the results from the ATTO Disk Benchmark to the clipboard (tab separated)
;   - Assumes Transfer size range of 4.0 kb to 1024.0 kb
;   - Also used Total Length of 256Mb, with Queue Depth of 4, Overlapped I/O and Direct I/O
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

Template_Startup()

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

; ###################
;   Utility Hotkeys
; ###################
^b::
  SetTitleMatchMode, 2

  WinGetTitle strTitle, A
;  MsgBox % "Retrieving values for " . strTitle

  strWriteVals :=
  strReadVals :=

  nIndex := 23
  loop, 9
  {
     ControlGetText strWrite%nIndex%, Static%nIndex%, A
     strWriteVals := strWriteVals . a_tab . strWrite%nIndex% / 1000
     nIndex := nIndex + 1
  }

  nIndex := 35
  loop, 9
  {
     ControlGetText strRead%nIndex%, Static%nIndex%, A
     strReadVals := strReadVals . a_tab . strRead%nIndex% / 1000
     nIndex := nIndex + 1
  }

  clipboard := Substr(strWriteVals,2) . a_tab . SubStr(strReadVals,2)
  MsgBox ATTO Disk Benchmark values have been copied to the clipboard.
return


; #############
;   Functions
; #############
Template_Startup()
{
   LogFunctionStart(A_ThisFunc)


   strFunc := "TestFunc"
   Loop,3
   {
      Log("Calling " . strFunc)
      %strFunc%("Hello")
   }
   

TEMPLATE_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


TestFunc(strArg1)
{
   LogFunctionStart(A_ThisFunc)

   Log("The argument is " . strArg1)
goto TESTFUNCT_EXIT
TESTFUNCT_EXIT:
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