;
; Pharmacy.ahk
;
; Scripts for working with CZ Pharmacy Forms
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 12/11/2017: Created from Template.ahk
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

Pharmacy_Startup()

PAGE1_TABS = 6
PAGE2_TABS = 7
PAGE3_TABS = 23


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
::_DLB::
   Send Deleca Reynolds-Barnes
return

::_FIND::
   Send Investigation into the set of duplicate orders indicates that these errors occur when a batch is closed, followed by one or more of the transactions being voided, without the cancellation process being followed correctly.
   Send For example, if an order contains a medication where the NDC has changed, the order must be cancelled in the pharmacy, voided in QS/1, and resubmitted.  In some cases, the order is voided and resubmitted, without the first order being cancelled in the pharmacy in which case both orders ship, resulting in a duplicate order.
   Send {Tab 8}
return

::_MEET::
   Send Details:{Enter}
   Send Patient Impact:{Enter}
   Send Potential Impact:{Enter}
   Send Root Cause:{Enter}
   Send Correction:{Enter}
   Send Follow up:{Enter}
return

::_EXP::
   experiment()
return

::_PG1::
::_PG2::
::_PG3::
::_PG4::
::_PG5::
::_PG6::
    StringRight count, A_THISLABEL, 1
    chromeSkipPage(count)
return

::_m::
    formSelectQuestion("Meeting comments/notes")
return



; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
Pharmacy_Startup()
{
   LogFunctionStart(A_ThisFunc)

   ; This is an ugly check to make sure the function is only run once.
   global Pharmacy_StartupCompleted
   IfEqual Pharmacy_StartupCompleted, true, goto PHARMACY_STARTUP_EXIT
   gPharmacy_StartupCompleted = true

PHARMACY_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


chromeFindButton(ByRef buttonX, ByRef buttonY, label, bkgColor:=0xEEEEEE, highlightColor:=0xFF9632)
{
  WinGetPos x, y, width, height, A
  foundButton := 0
  searchLooped := 0
  buttonX := -1
  buttonY := -1

  Send ^f
  Sleep 200
  Send %label%
  Sleep 200
  
  searchPoints := {}
 
  ; Cycle through all instances of the specified label, looking for a button
  while (not foundButton) and (not searchLooped) {
    PixelSearch pX, pY, 0, 0, %width%, %height%, %highlightColor%, 2, Fast RGB
    if (ErrorLevel = 0) {
      ; Check if the found text is a button or just text
      PixelGetColor color, pX-1, pY-1, RGB
      if (color = bkgColor) {
        buttonX := pX
        buttonY := pY
        foundButton := 1
      } else {
        Send {Enter}
      }

      ; Store the coordinates of the highlighted text, so it doesn't get searched again
      key := pX . "_" . pY
      alreadyChecked := searchPoints[(key)]
      if (alreadyChecked) {
        searchLooped := 1
      } else {
        searchPoints[(key)] := 1
      }
    } else {
      searchLooped := 1
    }
  } ; end while
  Send {Escape}
  return foundButton
}

chromeSkipPage(numToSkip:=1) {
  loop, %numToSkip%
  {
    if (chromeFindButton(x, y, "NEXT")) {
      Click %x%, %y%
    }
    Sleep 750
  }
}

^!p::
    chromeSkipPage(4)
    formSelectQuestion("Meeting comments/notes")
    Send Details:{Enter}
    Send Patient Impact:{Enter}
    Send Potential Impact:{Enter}
    Send Root Cause:{Enter}
    Send Correction:{Enter}
    Send Follow up:{Enter}
    Sleep 500
    if (chromeFindButton(x, y, "SUBMIT", 0x4285F4, 0xFF9632)) {
      Click %x%,%y%
    }
    Sleep 300
    Send ^w
return

formSelectQuestion(label) {
  foundQuestion = false
  if (chromeFindButton(x, y, label, bkgColor:=0xFFFFFF, highlightColor:=0xFF9632)) {
    Click %x%, %y%
    Send {Tab}
    foundQuestion = true
  }
  Sleep 750
  return foundQuestion
}


::_skip::
  chromeSkipPage(2)
return

::_fb::
  if (chromeFindButton(x, y, "NEXT")) {
    MsgBox % "Found the button at " . x . "," . y
  }
  
return



experiment() {
  x = 1
  if (not x) {
    MsgBox "Worked"
  } else {
    MsgBox "Didn't work"
  }



  s .= Format("{1:#x} {2:X} 0x{3:x}`r`n", 3735928559, 195948557, 0)


  x = 12
  y = 15
  array := {ten: 10, twenty: 20, thirty: 30}
  v := array["twenty"]
  name = %x% . "," . %y%
  key := x . "_" . y
  array[(key)] := 111
  v2 := array[(key)] 
  MsgBox % "V2=" . v2

  For key, value in array
    MsgBox %key% = %value%

/*
  MsgBox % "Window width, height: " . width . "," . height
  Send ^f
  Sleep 200
  Send NEXT{ENTER}
  Sleep 200
  PixelSearch pX, pY, 0, 0, %width%, %height%, 0xff9632, 3, Fast RGB
  if (ErrorLevel = 0) {
     MsgBox Found it at %pX%, %pY%, %ErrorLevel%
     PixelGetColor color, pX-1, pY-1, RGB
     MsgBox % "Color at " . pX-1 . "," . pY-1 . " is " . color
  }
*/
;  MouseClick left, %pX%, %pY%
; 0xff9632  1904, 1161
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