;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Vista
; Author:         Dave Smith
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

;
; Set up the global environment
;
#singleinstance force        ; Automatically reload if the script is executed more than once
#NoEnv                       ; Recommended for performance and compatibility with future AutoHotkey releases.
;SendMode Input              ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; Windows-Space launches Live Maps
#space::run http://maps.live.com

; Windows-G launches Geocaching pocket queries
#G::run http://www.geocaching.com/pocket/

;
; Ctrl-Alt-C
; Puts the lat/long link for the current "location" into the clipboard
; Assumes "Search Maps" is the active control
;

^!C::
  SetKeyDelay, 200

  ; Tab to the "Share" menu
  loop,9
  {  
     Send {tab}
  }

  ; Expand the menu  
  Send {Space}

  ; Copy to the clipboard
  SetKeyDelay, 400
  Send {tab}{tab}{enter}
return


; Ctrl-Alt-G
; Parses the Windows Live URL from the clipboard and returns the lat/long
^!G::
  com := chr(44)
  length := strlen(Clipboard)
  StringGetPos pos, Clipboard, cp=
  StringMid temp1, clipboard, pos+4
  StringGetPos pos, temp1, &
  StringMid temp2, temp1, 1, pos
  StringReplace temp3,temp2,~,%com%
;  Run Notepad
;  WinWait Untitled - Notepad
;  WinActivate
;  SetKeyDelay, 100
;  SetWinDelay, 2000
;  Send %temp3%
  clipboard = %temp3%
  MsgBox %temp3%
return

; Ctrl-Alt-P
; From the GeoCaching.com Pocket Query page, parse the lat/long from Live Maps
; and put it into the Pocket Query coordinates field
;
^!P::
  SetKeyDelay, 50
  Send ^f
  Sleep 100
  Send By Coordinates
  Send !n
  Send {ESC}
  Send {Tab}
  SetKeyDelay, 25
  Send {Down}
  Send {Down}
  Sleep 1000
  SetKeyDelay, 100
  Send ^f
  Sleep 100
  Send !n
  Send {ESC}
  Send {Tab}{Tab}{Tab}

  com := chr(44)
  length := strlen(Clipboard)
  StringGetPos pos, Clipboard, cp=
  StringMid temp1, clipboard, pos+4
  StringGetPos pos, temp1, &
  StringMid temp2, temp1, 1, pos
  StringGetPos pos, temp2, ~
  StringMid lat, temp2, 1, pos
  StringMid lon, temp2, pos+3 ; Scrape off the negative on the longitude

  Send %lat%
  Send {tab}{tab}
  Send %lon%

  Send ^f
  Sleep 100
  Send Compress
  Send !n
  Send {ESC}
  Send {Tab}
  Send {Enter}

  clipboard = New,%lat%,%lon%
  Msgbox %lat% and %lon%

return

;
; Ctrl-R
; Save and reload the current macro
;
^R::
  Send !f!s
  run "\\davsmith00\davedocs$\Autohotkey\geocaching.ahk"
return


::lat::
  com := chr(44)
  length := strlen(Clipboard)
  StringGetPos pos, Clipboard, cp=
  StringMid temp1, clipboard, pos+4
  StringGetPos pos, temp1, &
  StringMid temp2, temp1, 1, pos
  StringGetPos pos, temp2, ~
  StringMid lat, temp2, 1, pos
  StringMid lon, temp2, pos+3 ; Scrape off the negative on the longitude

;  Msgbox Latitude: %lat%
  Send %lat%
return

::lon::
  com := chr(44)
  length := strlen(Clipboard)
  StringGetPos pos, Clipboard, cp=
  StringMid temp1, clipboard, pos+4
  StringGetPos pos, temp1, &
  StringMid temp2, temp1, 1, pos
  StringGetPos pos, temp2, ~
  StringMid lat, temp2, 1, pos
  StringMid lon, temp2, pos+3 ; Scrape off the negative on the longitude

;  Msgbox Latitude: %lat%
  Send %lon%
return