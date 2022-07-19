SetTitleMatchMode, 2
; IMPORTANT INFO ABOUT GETTING STARTED: Lines that start with a
; semicolon, such as this one, are comments.  They are not executed.

; This script has a special filename and path because it is automatically
; launched when you run the program directly.  Also, any text file whose
; name ends in .ahk is associated with the program, which means that it
; can be launched simply by double-clicking it.  You can have as many .ahk
; files as you want, located in any folder.  You can also run more than
; one ahk file simultaneously and each will get its own tray icon.

; SAMPLE HOTKEYS: Below are two sample hotkeys.  The first is Win+Z and it
; launches a web site in the default browser.  The second is Control+Alt+N
; and it launches a new Notepad window (or activates an existing one).  To
; try out these hotkeys, run AutoHotkey again, which will load this file.

; #z::Run www.microsoft.com
#z::
WinGetTitle, Title, A
MsgBox, The active window is "%Title%".
return

^!n::
IfWinExist Untitled - Notepad
	WinActivate
else
	Run Notepad
return


;
; Sets up the customized tags for OneNote
;
; To launch, first clear all existing tags from OneNote, then click the Add button, and cancel
;



::SetupON::
setkeydelay 10

Send, !ac{Enter}To Do (DavSmith){Down 3}{Left}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (JEDavis){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (FredNava){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (DonaSa){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (DavLaw){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (SeanHi){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (AAluri){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (GauravK){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}To Do (Someone Else){Down 3}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Discuss with GrantG{Down 10}{Left}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Discuss with D3{Down 10}{Left}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Discuss with JCable{Down 10}{Left}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Discuss with Test Leads{Down 10}{Left}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Question{Down 11}{Right 2}{Down 9}{Right 3}{Down 9}{Right 3}{Down 2}{Right}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Question (Answered){Down 11}{Right 2}{Down 9}{Right 3}{Down 9}{Right 3}{Down 9}{Right 3}{Down 1}{Right 2}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Investigate{Down 5}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Follow Up{Down 11}{Right 2}{Down 9}{Right 3}{Down 8}{Enter}{Tab 3}{Enter}
Send, !ac{Enter}Follow Up (Complete){Down 11}{Right 2}{Down 9}{Right 3}{Down 8}{Right 2}{Enter}{Tab 3}{Enter}
return


::bub::
MsgBox, %A_TitleMatchMode% 
return

#ifwinactive Microsoft
::_ABC::
Send Maple
return

::_t::
WinGetTitle, Title, A
MsgBox, The active window is "%Title%".
return

::_JDS::
Send ^1
return

::_JD::
Send ^2
return

::_FN::
Send ^3
return

::_DS::
Send ^4
return

::_DL::
Send ^5
return

::_SH::
Send ^6
return

::_AA::
Send ^7
return

::_GK::
Send ^8
return

::_SE::
Send ^9
return

::_GG::
Send !a{Down 11}{Enter}
return

::_D3::
Send !a{Down 12}{Enter}
return

::_JC::
Send !a{Down 13}{Enter}
return

::_TL::
Send !a{Down 14}{Enter}
return

::_Q::
Send !a{Down 15}{Enter}
return

::_A::
Send !a{Down 16}{Enter}
return

::_I::
Send !a{Down 17}{Enter}
return


;Send, !ac{Enter}Answered Question{Down}{Down}{Down}{Enter}{Tab}{Tab}{Tab}{Enter}

;WinWait, Modify Tag, 
;IfWinNotActive, Modify Tag, , WinActivate, Modify Tag, 
;WinWaitActive, Modify Tag, 
;Send, {SHIFTDOWN}d{SHIFTUP}iscss{BACKSPACE}{BACKSPACE}uss{SPACE}{SPACE}{SHIFTDOWN}g{SHIFTUP}rang{BACKSPACE}t{SHIFTDOWN}g{SHIFTUP}{TAB}{DOWN}
;WinWait, , 
;IfWinNotActive, , , WinActivate, , 
;WinWaitActive, , 
;Send, {DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{LEFT}{ENTER}
;WinWait, Modify Tag, 
;IfWinNotActive, Modify Tag, , WinActivate, Modify Tag, 
;WinWaitActive, Modify Tag, 
return

