#KeyHistory 500

::_r::
   Send ^s
   reload
return

::_kh::
   KeyHistory
return


F1 & a::
   MsgBox FN Key was pressed.
return


;***********************
; Window Management
;***********************

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2


;
; Win-T returns the title of the currently active window.
;
#T::
   WinGetTitle, Title, A
   MsgBox, The active window is "%Title%".
return


;
; Ctrl-Alt-N launches Notepad, or brings an existing instance to the active window.
;
^!n::
   IfWinExist Untitled - Notepad
      WinActivate
   else
      Run Notepad
return


::_WinGet::
   WinGet, nID, ID, Location Sensor
   MsgBox, ID of "Location Sensor" window is %nID%.
return



;
; Launches Notepad, or brings an existing instance to the active window.
;
LaunchNotepad()
{
   IfWinExist Untitled - Notepad
      WinActivate
   else
      Run Notepad
   return
}


;*****************
; Keyboard tools
;*****************
^t::		
   SetKeyDelay 500
   Send +{Tab 2}{Home}  ; Send 2 Shift-Tabs, then home.
return

::_LaunchStartMenu::
 Send ^{Esc}  ; Launch the start menu
return


;*****************
; File tools
;*****************

;
; This example demonstrates checking for a files existence
; as well as how to write text out to a file.
; Note that the parenthesis indicate continuation of a line.
; The use of `r`n vs `n vs nothing seems unpredictable, and you might
; have to futz with them to get the spacing right.
;
!^f::
   OutFile = c:\temp\TestFile.csv
   IfNotExist, %OutFile%
   {
      FileAppend,
       (
        Column1,Column2,Column3`r
       ),%OutFile%
      MsgBox File: %OutFile% didn't exist.  Appended headers.
   }
   
   InputBox strLocName, Location Name, Enter the name of this location
   FileAppend,
    (
      %strLocName%,val1, val2, val3
      %strLocName%2, val2, val3, val4
      End of line?
    ), %OutFile% 


   Run, %a_programfiles%\Windows NT\Accessories\wordpad %OutFile% 
return


;
; Creates or appends a line to a file
;
::_CreatFile_::
;  CreateOrAppendToFile("c:\temp\mubba.csv")
return


;
; Delete a specified file
;
!^d:: 
   OutFile = c:\temp\TestFile.csv
   IfExist, %OutFile%
   {
      FileDelete, %OutFile%
      MsgBox Deleted %OutFile%
   }
   else
   {
      MsgBox %OutFile% did not exist.  No action taken. 
   }
return


;*****************
; Input tools
;*****************
#I::
   InputBox strLocName, Location Name, Enter the name of this location
return


;***********
;   GUI
;***********
#N::
   Gui, Add, Text,vlblFirst,  First name:
   Gui, Add, Text,vlbLast,    Last name:
   Gui, Add, Edit, vebFirstName ym                  ; The ym option starts a new column of controls.
   Gui, Add, Edit, vebLastName                      ; The value of the edit box is assigned to FirstName
   Gui, Add, Button, default gShowNames w100, OK    ; The label ShowNames is run when OK is clicked 
   GuiControl,,ebFirstName, Dave                    ; Set the default contents using the variable name as label
   GuiControl,,ebLastName, Smith
   Gui, Show, w250 , Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

ShowNames:
GuiClose:
ButtonOK:
   Gui, Submit  ; Save the input from the user to each control's associated variable.
   MsgBox First name: %ebFirstName%`nLast name: %ebLastName%
;   GUI, Destroy
return


#G::
   Gui, Font, underline
   Gui, Add, Text, cBlue gLaunchGoogle, Click here to launch Google.
   Gui, Font, norm
   Gui, Show
return

LaunchGoogle:
   Run www.google.com
   Gui, Destroy 
return

#C::
   GuiControlGet, ctrlContents 
   MsgBox, %Firstname%
return 
;-----------------------------------------------------------------------------------


;***************
;  Controls
;***************

::_startshowcontrols::
SetTimer, WatchActiveWindow, 200
return

::_stopshowcontrols::
SetTimer, WatchActiveWindow, Off
Tooltip
return

WatchActiveWindow:
WinGet, ControlList, ControlList, A
ToolTip, %ControlList%
return

::_controlgettext::
   ControlGetText, strTopic, Edit3, AutoHotkey Help
   MsgBox, Topic in Autohotkey Help is: %strTopic%
return

::_cst::
strText = Wubba
ControlSetText, Edit3, %strText%, AutoHotkey Help
if ErrorLevel
    MsgBox There was a problem.
else
    MsgBox Set the text to %strText%.

ControlGetText, strText, Edit3, AutoHotkey Help
MsgBox Got the text as %strText%.

return

::_fnt:: 
   IfWinExist Page Setup
      WinActivate 
   ControlGet, strTopic, Line, 1, Edit1, Font
   MsgBox, Selected font name is: %strTopic%
return

::_tab::
ControlGet, WhichTab, Tab, , SysTabControl321, AutoHotkey Help
if ErrorLevel
    MsgBox There was a problem.
else
    MsgBox Tab #%WhichTab% is active.
return

::_clist::
WinGet, strControls, ControlListHWND, AutoHotkey Help
if ErrorLevel
    MsgBox There was a problem.
else
    MsgBox Control list: %strControls%
return

;
;  Still looking for:
;	- A way to determine the selection of a combo or edit box
;	- Ways to interact with a tree control
;

;
; Sets a timer to show a tool tip containing all of the controls
; in the window containing the mouse pointer.
;
::_startshowcontrols::
   SetTimer, WatchActiveWindow, 200
return

; Turns off the tooltip
::_stopshowcontrols::
   SetTimer, WatchActiveWindow, Off
   Tooltip
return


;
; Gets the contents of an edit box
;
::_controlgettext::
   ControlGetText, strTopic, Edit2, AutoHotkey Help
   MsgBox, Topic in Autohotkey Help is: %strTopic%
return



;
; Sets the contents of an edit box
;
::_cst::
   strText = Wubba
   ControlSetText, Edit2, %strText%, AutoHotkey Help
   if ErrorLevel
      MsgBox There was a problem.
   else
      MsgBox Set the text to %strText%.

   ControlGetText, strText, Edit2, AutoHotkey Help
   MsgBox Got the text as %strText%.
return



;
; Gets the contents of a combo box
;
::_fnt:: 
   ; Launch the format font dialog in Notepad
   SetTitleMatchMode 2
   IfWinExist Notepad
   {
      SetKeyDelay 50
      WinActivate
      Send !OF
      Send !RT
   }
   Sleep 1000  
   
   ;
   ; NOTE: None of the List options (eg. Selected, Count)
   ;       are supported with list boxes, combo boxes, etc.
  ;        You may want to get the corresponding edit box control instead.
 
   ControlGet, strText, List, Gubzer, ComboBox5, Font
   MsgBox, %strText%

    ; Get the Hwnd for a combobox
   ControlGet, nID, HWND, ,ComboBox5, Font
   ControlGetText, strText,,ahk_id %nID%, Font
   MsgBox, %nID%  Text: %strText%
return  



::_showtooltip::
   loop 30
   {
      ControlGetText, strToolTipText,, ahk_class tooltips_class32
      OutputDebug Tooltip: %strToolTipText%  
      sleep 500
   }
return



;
; Determines which tab is active on a tab control
;
::_tab::
   ControlGet, WhichTab, Tab, , SysTabControl321, AutoHotkey Help
   if ErrorLevel
      MsgBox There was a problem.
   else
      MsgBox Tab #%WhichTab% is active.
return


; *************
; Scope tools
; *************

;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;

;***************************************************
#ifwinactive Microsoft

::_ABC::
   Send Maple
return


#ifwinactive 
;***************************************************


; *********
; INI Files
; *********
::write_ini::
   strIniFile = C:\temp\myfile.ini
   strSectionName = FolderShare
   strKeyName = Root
   IniWrite, this is a new value, %strIniFile%, %strSectionName%, %strKeyName%
   MsgBox %errorlevel%
return

::read_ini::
   strIniFile = C:\temp\myfile.ini
   strSectionName = Section
   strKeyName = Key
   IniRead, strValue, %strIniFile%, %strSectionName%, %strKeyName%
   MsgBox, Value = %strValue%
return


; *********
; Registry
; *********

::read_reg::
   RegRead OutputVar,  HKEY_LOCAL_MACHINE, Software\AutohotKey, InstallDir
   MsgBox %OutputVar% 
return


::write_reg::
   RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\AutoHotkey, Script, %a_scriptdir%
   MsgBox %errorlevel%
return



;*************
; Clipboard
;*************
::_ontoclip::
strText = String to place on clipboard
clipboard = %strText%
return

::_showclip::
   MsgBox, %clipboard%
return


;*************************
; Dynamic Function Calls
;*************************
::_DynFunc::
   DynamicFunctionCall()
return

DynamicFunctionCall()
{
   strFunc := "TestFunc"
   Loop,3
   {
      %strFunc%(a_index)
   }

   return
}



TestFunc(strArg1)
{

   MsgBox % "The arg is " . strArg1

goto TESTFUNCT_EXIT
TESTFUNCT_EXIT:

   return
}

