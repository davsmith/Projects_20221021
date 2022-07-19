SetTitleMatchMode, 2


;
; Win-Z returns the title of the currently active window.
;
#z::
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

;
; Saves and reloads the current script
; NOTE: You could do the same thing with the "Reload" command
;
::_R::
   Send ^s
   #SingleInstance force
   WinGetActiveTitle, strWindow
   StringReplace, strScript, strWindow, - Notepad, 
   Run, %A_ScriptDir%\%strScript%
return



::_Title::
   WinGetTitle, Title, A
   MsgBox, The active window is "%Title%".
return


::_WinGet::
   WinGet, nID, ID, Location Sensor
   MsgBox, ID of "Location Sensor" window is %nID%.
return

::_TitleMatchMode::
   MsgBox, %A_TitleMatchMode% 
return





::_f::
   Send ^f+{Tab 2}{Right}+{Tab}{Right}
return


;
; The hotkeys listed below are only active if the active window contains the specified text in the title.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;

;***************************************************
#ifwinactive Microsoft Visual Studio
^d::
   SetKeyDelay 1
   Send {Delete 30}{Down}
return

^p::
   SetKeyDelay 10
   Send {Home}+^{right}^c
   Send {Home}{Tab 4}newRow["^v"] = house.m_{end}{down}   
return

#ifwinactive 
;***************************************************

;***************************************************
#ifwinactive Notepad
^d::
   SetKeyDelay 10	
   Send {Delete 30}
return

^!S::
   SetKeyDelay 10
   Send {Home}^f;!f{esc}
   Send ^+{left}
   Send ^c
   strField = %clipboard%
   Send {left}{right}^+{left}
   Send ^c
   strClip = %clipboard%
   strCSField = %strClip%

  if (strCSField = "int")
  {
      strSQLType = "int"
  }
  else if (strCSField = "bool")
  {
      strSQLType = "bit"
  }
  else if (strCSField = "long")
  {
      strSQLType = "bigint"
  }
  else if (strCSField = "double")
  {
      strSQLType = "float"
  }
  else if (strCSField = "float")
  {
      strSQLType = "real"
  }
  else if (strCSField = "short")
  {
      strSQLType = "smallint"
  }
  else if (strCSField = "byte")
  {
      strSQLType = "tinyint"
  }
  else if (strCSField = "decimal")
  {
      strSQLType = "decimal"
  }
  else if (strCSField = "string")
  {
      strSQLType = "varchar"
  }
  else if (strCSField = "DateTime")
  {
      strSQLType = "datetime"
  }
  else
  {
      strSQLType = "???"
  }

   
   WinGetActiveTitle, strCurWindow
   WinActivate, SQL Server Management Studio
   Send %strField%{Tab}%strSQLType%{Tab 2}
   WinActivate, %strCurWindow%
   Send {Down}{Home}
return

;***************************************************
#ifwinactive .ahk
^d::
   SetKeyDelay 10
   Send {Delete 9}{Down}
return

;^!S::
;   
;   MsgBox, %strField%.
;return
  

#ifwinactive 
;***************************************************
