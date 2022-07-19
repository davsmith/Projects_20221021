;
; Tools.ahk
;
; A set of utility functions and hotkeys used in writing, defining,
; and running AutoHotkey macros
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 5/24/2015:
; - Replaced FolderShare functions with OneDrive
;
; 5/1/2011:
; - Added WriteToSystemIni and ReadFromSystemIni
; - Fixed up some of the function logging
; - Modified LogError to use HardMessage.
; - Added code to LogError to check the system ini file for the DebugErrorAction value.
;
; 4/24/2011:
; - Added some documentation about setting the debug level.
; - Added WaitForWindow function
;
; 4/24/10:
; - Added GetConfigDir function
; - Added MakeSelectionUppercase function, added ^u hotkey
; - Changed logging to use A_ThisFunc
; - Changed scope on ^f and _r to Notepad
;
; 10/30/09:
; - Added GetPath, GetEntry, and GetBaseName functions
;
; 10/24/09:
; - Moved many of the "sample" functions to Tricks.ahk
; - Moved the scope tools to the top
; - Added String section
; - Added Before and After functions
;
;
#NoEnv
SetTitleMatchMode, 2

;****************
;  Scoped tools
;****************

;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;

;***************************************************
#ifwinactive Microsoft
   ;***************************************************

   ;***************************************************
   #ifwinactive - Notepad
      ;***************************************************
      ^!f::
         BuildFunctionTemplate()
      return

      ^u::
         MakeSelectionUppercase()
      return

      ::_r::
         SaveAndReloadCurrentScript()
      return

      ;
      ; ################
      ;   Global tools
      ; ################
      ;
      ; The hotkeys listed below are always active
      ;

      ;***************************************************
      #ifwinactive 
         ;***************************************************

         Tools_Startup()
         {
            global g_DebugErrorAction
            global g_LogKeyStrokes
            global gnTabSpaces = 2

            LogInit()
            LogFunctionStart(a_ThisFunc)

            g_DebugErrorAction := ReadFromSystemIni( "AutoHotkey", "DebugErrorAction" ) 
            StringUpper g_DebugErrorAction, g_DebugErrorAction

            g_LogKeyStrokes := ReadFromSystemIni( "AutoHotkey", "LogKeyStrokes" )
            StringUpper g_LogKeyStrokes, g_LogKeystrokes
            g_LogKeyStrokes := (g_LogKeyStrokes = "TRUE")
            LogFunctionEnd()
         }

      ::_help_tools::
         LogFunctionStart(A_ThisHotkey)
         strHelp =
         (
         #!f`tAdds logging and labels to a function that has a name, (), and {}.
         ^u`tMakes selection upper case
         _r`tSave and reload current script
         ^space`tInserts a number of spaces set by ^!1 - ^!4 (defaults to 4)
         )

         MsgBox %strHelp%
         LogFunctionEnd()
      return

      ;***********************
      ; Hotkeys & HotStrings
      ;***********************

      ; Open the folder containing the Autohotkey scripts
      #H::
         strDir := GetOneDriveDir()
         Run %strDir%\Projects\AutoHotkey 
      return

      ;
      ; Typing _AHHelpID followed by a space, quotes, etc. will locate a window with Notepad
      ; in the title, and display the window ID for the window.
      ;
      ::_AHHelpID::

         ; Search for the text anywhere in the title, not just exact match
         SetTitleMatchMode, 2 

         strText = Notepad
         nID := GetWindowID(strText)
         if (nID = "")
         {
            MsgBox No window exists with "%strText%" in the title.
            return
         }
         else
         {
            MsgBox Window %nID% has "%strText%" in the title.
         }
      return

      ;
      ; Indents the current text by 3 spaces
      ; of whatever is defined in gnTabSpaces.
      ;
      ; Note, the hotkeys below to change the
      ; number of spaces.
      ;
      ^space::
         if (gnTabSpaces = "")
            gnTabSpaces = 4

         Send {Space %gnTabSpaces%}
      return

      ^!1::
         gnTabSpaces = 1
      return

      ^!2::
         gnTabSpaces = 2
      return

      ^!3::
         gnTabSpaces = 3
      return

      ^!4::
         gnTabSpaces = 4
      return

      ;*********************
      ;  Window Management
      ;*********************

      GetActiveWindowTitle()
      {
         WinGetTitle, Title, A
         MsgBox, The active window is "%Title%".
      return
   }

   ;
   ; Return the ID of any window with the specified text in the title
   ; NOTE:  Use SetTitleMatchMode to determine if the title must be an exact match,
   ;        or only partial match.
   ;
   GetWindowID(strTitle)
   {
      WinGet, nID, ID, %strTitle%
      return %nID%
   }

   WaitForWindow(strTitle, strText="", nSeconds=3, bHardBreakOnFail=true, strErrorMsg="")
   {
      LogFunctionStart(A_ThisFunc)

      Log( "Looking for window: " . strTitle )

      bRetVal = 0
      if (strErrorMsg = "")
         strErrorMsg = Could not find window "%strTitle%".

      WinWaitActive, %strTitle%, , %nSeconds%
      if ErrorLevel
      {
         if (bHardBreakOnFail)
         {
            HardMessage( strErrorMsg ) 
         }
         else
         {
            Log( strErrorMsg )
         }
      }
      else
      {
         Log( "Found " . strTitle . " window." )
         bRetVal = 1
      }

      WAITFORWINDOW_EXIT:
         LogFunctionEnd()
      return %bRetVal%
   }

   ;
   ; Query and display the current title match mode
   ;
   ::?TitleMatch::
      SetTitleMatchMode, 1

      if (A_TitleMatchMode = 1)
         strMsg = Title must START with the specified text.
      else if (A_TitleMatchMode = 2)
         strMsg = Title must CONTAIN the specified text.
      else if (A_TitleMatchMode = 3)
         strMsg = Title must EXACTLY match the specified text.

      MsgBox, %strMsg% 
   return

   ;*****************
   ;  Macro Editing 
   ;*****************

   ;
   ; Saves and reloads the current script
   ; NOTE: You could do the same thing with the "Reload" command
   ;
   SaveAndReloadCurrentScript()
   {
      LogFunctionStart(A_ThisFunc)
      Send ^s
      Reload

   SAVEANDRELOADCURRENTSCRIPT_EXIT:
      LogFunctionEnd()
   return
}

;
; Adds logging and goto functionality to a new function
;
; Function requires a name, arg parenthesis, and open and closing braces.
; Put the cursor on the line with the function name and type the
; hot string.
;
BuildFunctionTemplate()
{
   LogFunctionStart(A_ThisFunc)
   Send {Home}+{End}^c
   strFunctionName := clipboard
   strFunc := Before(strFunctionName, "(")
   StringUpper strExit, strFunc
   strExit := strExit . "_EXIT" 
   Send ^f
   Send {{} 
   Send !f{esc}
   Send {Home}{Down}{Enter}{Up}
   Send {Space 3}LogFunctionStart(A_ThisFunc)
   Send {Enter}
   Send goto %strExit%{Enter} 
   Send %strExit%:{Enter} 
      Send {Space 3}LogFunctionEnd()

   BUILDFUNCTIONTEMPLATE_EXIT:
      LogFunctionEnd()
   }

   ;
   ; Replaces the current selection with all uppercase letters
   ;
   MakeSelectionUppercase()
   {
      LogFunctionStart(A_ThisFunc)

      Send ^c
      StringUpper strUpper, clipboard
      Log("Original: " . clipboard . " Upper: " . strUpper)
      Send %strUpper%

   MAKESELECTIONUPPERCASE_EXIT:
      LogFunctionEnd()
   return
}

;*******************
;  Debugging tools
;*******************

;
; Emulates a breakpoint in code by listing all variables, then pausing.
;
BreakPoint(nDelay=0, bShowVars=false)
{
   if (bShowVars)
   {
      ListVars
   }

   if (nDelay = 0)
   {
      Pause
   }
   else
   {
      Sleep, %nDelay%
   }
}

;
; Shows a MessageBox and exits
;
HardMessage(strMessage)
{
   MsgBox %strMessage%
   exit
   return
}

;******************
; Path tools
;******************

;
; Returns the directory containing config files for use with AutoHotkey.
; The config directory is called _Config.  If multiple _Config directories
; exist, the first found is used.
;
GetConfigDir()
{
   LogFunctionStart(A_ThisFunc)

   DriveGet strList, List
   Loop, PARSE, strList
   {
      strDirectory := a_LoopField . ":\_config"
      if InStr(FileExist(strDirectory), "D") 
      {
         break
      }
      else
      {
         strDirectory :=
      }
   } 

   if (strDirectory <> "")
      Log("Found config directory at " . strDirectory, 9)
   else
      Log("Didn't find a config directory.", 9) 

   GETCONFIGDIR_END:
      LogFunctionEnd()
   return %strDirectory%
}

;
; Returns the INI file tailored for this system.
; Gives priority to an INI file with the same name as the computer,
; then falls back to AUTOHOTKEY.INI
;
GetSysIniFile()
{
   LogFunctionStart(A_ThisFunc)

   strIniFile := 
   nRetVal := 0

   strConfigDir := GetConfigDir()
   if (strConfigDir <> "")
   {
      ; First check if there is an Ini file specific for this computer name.
      strIniFile := strConfigDir . "\" . a_computername . ".ini"
      Log("Looking for " . strIniFile, 9)
      if (FileExist(strIniFile))
      {
         nRetVal := 1
      }
      else
      {
         strIniFile := strConfigDir . "\autohotkey.ini"
         Log("Looking for " . strIniFile, 9)
         if (FileExist(strIniFile))
         {
            nRetVal := 1
         }
      } 
   }

   if (nRetVal = 0)
   {
      Log("Found no system INI file", 9)
      strIniFile :=
   }

   goto GETSYSINIFILE_EXIT
   GETSYSINIFILE_EXIT:
      LogFunctionEnd()
   return %strIniFile%
}

;
; Returns the path portion of an absolute path
; (eg. c:\temp\)
;
GetPath(strFilename)
{
   LogFunctionStart(A_ThisFunc)

   StringSplit strPathTokens, strFilename, \
   strPathTokens0--
   loop %strPathTokens0%
   {
      strPath := strPath . "\" . strPathTokens%a_index%
   }

   if ( strlen(strPath) > 0 ) then
   {
      strPath := Substr(strPath, 2) . "\"
   }

   Log( "Path: " . strPath )

   GETPATH_EXIT:
      LogFunctionEnd()
   return %strPath% 
}

;
; Returns the filename portion of an absolute path
; (eg. Temp.TXT)
;
GetEntryName(strFilename)
{
   LogFunctionStart(A_ThisFunc)

   StringSplit strPathTokens, strFilename, \
   strEntry := strPathTokens%strPathTokens0%
   Log( "Entry: " . strEntry )

   GETENTRY_EXIT:
      LogFunctionEnd()
   return %strEntry% 
}

;
; Returns the filename portion of an absolute path, without extension
; (eg. Temp)
;
GetBaseName(strFilename)
{
   LogFunctionStart(A_ThisFunc)

   strEntry := GetEntryName(strFilename)
   Log( "Entry: " . strEntry )

   strBase := before(strEntry, ".")

   GETBASENAME_EXIT:
      LogFunctionEnd()
   return %strBase% 
}

;
; Returns the extension portion of an absolute path or filename
; (eg. TXT)
;
GetExtension(strFilename)
{
   LogFunctionStart(A_ThisFunc)

   strEntry := GetEntryName(strFilename)
   Log( "Entry: " . strEntry )

   strExtension := after(strEntry, ".")
   StringUpper strExtension, strExtension

   GETEXTENSION_EXIT:
      LogFunctionEnd()
   return %strExtension% 
}

;******************
;  Keyboard tools
;******************
_Send(strKeyStrokes)
{
   global g_LogKeyStrokes

   if (g_LogKeyStrokes)
   {
      Log( "Keystrokes: " . strKeyStrokes )
   }

   Send %strKeyStrokes%
}

;**************
;  File tools
;**************

;***************
;  Input tools
;***************

;******************
;  Date Functions
;******************

/*
	Title: Date Parser
	Function: DateParse
	Converts almost any date format to a YYYYMMDDHH24MISS value.
        NOTE:  Dave tweaked the d := string to get it to work with the FormatTime command
	
	Parameters:
		str - a date/time stamp as a string
	
	Returns:
		A valid YYYYMMDDHH24MISS value which can be used by FormatTime,
		EnvAdd and other time commands.
	
	About: Example
		- time := DateParse("2:35 PM, 27 November, 2007")
	
	About: License
		- Version 1.04 by Titan <http://www.autohotkey.net/~Titan/#dateparse>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.

*/
/*
Commented out because Autohotkey 1.1 is gacking on the '.' (5/23/15)

DateParse_old(str)
{
	static e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
	str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
		. "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
		. "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
		d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
		RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?(?:\s*([ap]m))?", t)
			, RegExMatch(str, e2, d)
	f = %A_FormatFloat%
	SetFormat, Float, 02.0

	d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
		. ((d1 := d1 + 0 ? d1 : (InStr(e2, SubStr(d1, 1, 3)) - 40) // 4 + 1.0) > 0
			? d1 + 0.0 : A_MM). ((d2 += 0.0) ? d2 : A_DD) . t1
			+ (t1 = 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "am" ? 0.0 : 12.0) . t2 + 0.0 . t3 + 0.0

	SetFormat, Float, %f%
	Return, d
}
*/

/*
	Title: Date Parser
	Function: DateParse v1.04
	Converts almost any date format to a YYYYMMDDHH24MISS value.
	Parameters:
		str - a date/time stamp as a string
	Returns:
		A valid YYYYDDMMHH24MISS value which can be used by FormatTime,
		EnvAdd and other time commands.
	About: Example
		- time := DateParse("2:35 PM, 27 November, 2007")
	About: License
		- Version 1.04 by Titan <http://www.autohotkey.net/~Titan/#dateparse>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.
*/

/*
Commenting out because Autohotkey 1.1 is gacking on the '.'

DateParse(str) {
	static e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
	str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
		. "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
		. "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
		d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
		RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?(?:\s*([ap]m))?", t)
			, RegExMatch(str, e2, d)
	f = %A_FormatFloat%
	SetFormat, Float, 02.0
	d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
		. ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0
			? d2 + 0.0 : A_MM). ((d1 += 0.0) ? d1 : A_DD) . t1
			+ (t1 = 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "am" ? 0.0 : 12.0) . t2 + 0.0 . t3 + 0.0
	SetFormat, Float, %f%
	Return, d
}
*/

;************
;  Controls
;************
;
; Generates a list of controls for the specified window
;
ShowControlList(strTitle)
{
   LogFunctionStart(A_ThisFunc)

   WinGet, strControls, ControlList, %strTitle%
   if ErrorLevel
      MsgBox There was a problem.
   else
      MsgBox Control list for %strTitle%: `n%strControls%

   LogFunctionEnd()
   return
}

_ControlSetText( ctrl, strText, strTitle="A", strWinText="", strExcludeTitle="", strExcludeText="")
{
   global g_LogKeyStrokes

   if (g_LogKeyStrokes)
   {
      Log( "Setting text for control: " . ctrl . " to " . chr(34) . strText . chr(34) )
   }

   ControlSetText %ctrl%, %strText%, %strTitle%, %strWinText%, %strExcludeTitle%, %strExcludeText%
}

;***********
;  Logging
;***********
;
; This section defines the functions used for outputting debug information
; to a debugger such as DebugView.
;
; The workflow is similar to:
;   - Call LogInit to define global variables, and set level of verbosity.
;   - Set the g_LogDebugLevel = to the lowest value of information to display (1=Errors, 5=Warnings, 7=Info)
;   - **** Documentation in progress ****
;

;
; Sets the level of debug output which is logged to
; the debug window.
;
; It defaults to 9, but can be set by creating a
; a DebugLevel key in autohotkey.ini in the _config directory
;
; The value can also be set manually in any script by setting
; the global variable g_LogDebugLevel
;
LogInit()
{
   global g_LogFunctionList
   global g_LogDebugLevel

   g_LogFunctionList =
   g_LogDebugLevel = 9

   strIniFile := GetSysIniFile()

   ; Attempt to get the ID from an INI file
   IniRead, g_LogDebugLevel, %strIniFile%, AutoHotkey, DebugLevel
   OutputDebug Debug level: %g_LogDebugLevel% 
}

LogFunctionStart(strFunctionName)
{
   global g_LogFunctionList

   if (g_LogFunctionList = "")
   {
      g_LogFunctionList = %strFunctionName%
   }
   else
   {
      g_LogFunctionList = %g_LogFunctionList%`;%strFunctionName%
   }

   OutputDebug [%strFunctionName%] #### Function started ####
   return
}

LogFunctionEnd()
{
   global g_LogFunctionList

   StringSplit strFunctionList, g_LogFunctionList, `;
   strFunctionName := strFunctionList%strFunctionList0%
   StringGetPos nPos, g_LogFunctionList, `;, R
   StringLeft g_LogFunctionList, g_LogFunctionList, %nPos% 
   OutputDebug [%strFunctionName%] #### Function exited ####
   return
}

Log(strMessage,nLevel=9)
{
   global g_LogFunctionList
   global g_LogDebugLevel

   if (nLevel <= g_LogDebugLevel)
   {
      StringSplit strFunctionList, g_LogFunctionList, `;
      strFunctionName := strFunctionList%strFunctionList0%
      OutputDebug [%strFunctionName%][%nLevel%] %strMessage%
   }

   return
}

LogError(strMessage)
{
   global g_LogFunctionList
   global g_DebugErrorAction

   StringSplit strFunctionList, g_LogFunctionList, `;
   strFunctionName := strFunctionList%strFunctionList0%

   strLogString = [%strFunctionName%] ERROR: *** %strMessage% ***

   if (g_DebugErrorAction = "STOP")
   {
      HardMessage( strLogString )
   }

   Log( strLogString, 1) 

   if (g_DebugErrorAction = "PAUSE")
   {
      BreakPoint()
   }

   return
}

LogWarning(strMessage)
{
   global g_LogFunctionList
   StringSplit strFunctionList, g_LogFunctionList, `;
   strFunctionName := strFunctionList%strFunctionList0%
   Log( "[" . strFunctionName . "] WARNING: *** " . strMessage . " ***", 5 )
   return
}

LogInfo(strMessage)
{
   global g_LogFunctionList
   StringSplit strFunctionList, g_LogFunctionList, `;
   strFunctionName := strFunctionList%strFunctionList0%
   Log( "[" . strFunctionName . "] INFO: *** " . strMessage . " ***", 7 )
   return
}

;*************
;  Strings
;*************

;
; Takes as input a string and a substring.  If the substring is found in
; the string, the function returns the string before the first character of the substring.
; If the string is not found, the function returns szString.
;

Before(strString, strSubStr)
{
   LogFunctionStart(A_ThisFunc)

   nIndex := InStr(strString, strSubStr)
   Log( "Index:" . nIndex ) 
   If (nIndex = -1)
   {
      strReturnVal := strString
   }
   Else
   {
      Log("String:" . strString)
      nIndex-- 
      strReturnVal := SubStr(strString, 1, nIndex) 
      Log("Return:" . strReturnVal)
   }

   LogFunctionEnd()
   return %strReturnVal%
}

After(strString, strSubStr)
{
   LogFunctionStart(A_ThisFunc)

   Log("String: " . strString . ", SubString: " . strSubStr)

   nIndex := InStr(strString, strSubStr)
   Log( "Index:" . nIndex ) 
   If (nIndex = -1)
   {
      strReturnVal := 
   }
   Else
   {
      Log("String:" . strString)
      nIndex += StrLen(strSubStr)
      strReturnVal := SubStr(strString, nIndex) 
      Log("Return:" . strReturnVal)
   }

   LogFunctionEnd()
   return %strReturnVal%
}

StringReverse(strString)
{
   LogFunctionStart(A_ThisFunc)

   strNewString :=
   nLen := StrLen(strString)
   loop %nLen%
   {
      nIndex := nLen - a_Index + 1
      strNewString := strNewString . Substr(strString, nIndex, 1)
   }

   STRINGREVERSE_EXIT:
      LogFunctionEnd()
   return %strNewString%
}

;****************
;  OneDrive
;****************

;
;
; In this function an INI file is checked for the path to the root of
; the FolderShare directory.  If no INI file is specified, assume that
; the script path is in the OneDrive directory, and just trim off the parts
; we don't need
;
; This function was moved to Tools.ahk, from OneDrive.ahk
; due to its frequent use in many scripts.  By moving it to
; tools.ahk, in most cases it eliminates the need to include
; OneDrive.ahk.
;
GetOneDriveDir()
{
   LogFunctionStart(A_ThisFunc)

   bWriteBack := 0
   strIniFile := GetSysIniFile()
   Log( "System INI file is: " . strODPath )

   RegRead, strODPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\OneDrive\Accounts\Personal, UserFolder
   Log( "Windows 10 OneDrive check returned: " . strODPath)

   if (strODPath = "")
   {
      RegRead, strODPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\SkyDrive, UserFolder
      Log( "Windows 8.x OneDrive check returned: " . strODPath)
   }

   ; Attempt to get the ID from an INI file
   if (strODPath = "")
   {
      IniRead, strODPath, %strIniFile%, OneDrive, Root
      Log( "Attempt to retrieve ODPath from INI yielded: " . strODPath )
   }

   ; Finally, if that doesn't work, retrieve it from the path to the script directory
   if ((strODPath = "ERROR") or (strODPath = ""))
   {
      bWriteBack := 1
      strODPath = 
      strEntry = OneDrive
      nLen1 := Instr(A_ScriptFullPath, strEntry)
      if nLen1 > 0 then
      {
         strODPath := SubStr(a_ScriptFullPath, 1, nLen1+StrLen(strEntry))
      }

      Log( "Defined OneDrive path from script dir (" . strODPath . ")")
   }

   LogFunctionEnd()
   return strODPath
}

;*************
;  INI Files
;*************
WriteIni(strFile, strSection, strKey, strValue)
{
   LogFunctionStart(A_ThisFunc)

   StringSplit strPath, strFile, \
   if (strPath0 = 1)
   {
      strOneDriveDir := GetOneDriveDir()
      strFile := strOneDriveDir . "projects\_Ini\" . strFile
      Log( "Updated path: " . strFile ) 
   }

   IniWrite %strValue%, %strFile%, %strSection%, %strKey%

   LogFunctionEnd()
   return %strFile%
}

ReadIni(strFile, strSection, strKey)
{
   LogFunctionStart(A_ThisFunc)

   StringSplit strPath, strFile, \
   if (strPath0 = 1)
   {
      strOneDriveDir := GetOneDriveDir()
      strFile := strOneDriveDir . "projects\_Ini\" . strFile
      Log( "Updated path: " . strFile ) 
   }

   Log("File:" . strFile . " Section:" . strSection . " Key:" . strKey) 
   IniRead, strValue, %strFile%, %strSection%, %strKey%
   Log("KeyValue=" . strValue) 
   LogFunctionEnd()
   return strValue
}

WriteToSystemIni(strSection, strKey, strValue)
{
   LogFunctionStart(A_ThisFunc)

   strSysIniFile := GetSysIniFile()
   strRetVal := strSysIniFile
   if (strSysIniFile = "")
   {
      strRetVal := ERROR
      goto WRITETOSYSTEMINI_EXIT
   }

   IniWrite %strValue%, %strSysIniFile%, %strSection%, %strKey%

   WRITETOSYSTEMINI_EXIT:
      LogFunctionEnd()
   return %strRetVal%
}

ReadFromSystemIni(strSection, strKey)
{
   LogFunctionStart(A_ThisFunc)

   strSysIniFile := GetSysIniFile()
   if (strSysIniFile = "")
   {
      strRetVal := ERROR
      goto READFROMSYSTEMINI_EXIT
   }

   Log("File:" . strSysIniFile . " Section:" . strSection . " Key:" . strKey) 
   IniRead, strRetVal, %strSysIniFile%, %strSection%, %strKey%
   Log("KeyValue=" . strRetVal) 

   READFROMSYSTEMINI_EXIT:
      LogFunctionEnd()
   return %strRetVal%
}

;*************
;  Web Tools
;*************
FindImageAndClick(imageName, offsetX, offsetY, numRetries, increment, numClicks:=1)
{
   CoordMode Pixel Window ; Interprets the coordinates below as relative to the screen rather than the active window.
   CoordMode Mouse Window ; Interprets the coordinates below as relative to the screen rather than the active window.

   foundIt := false
   tries := numRetries + 1

   while (tries > 0)
   {
      WinGetPos winX, winY, winWidth, winHeight, A
      ImageSearch FoundX, FoundY, 0, 0, winWidth, winHeight, %imageName%
      ; MsgBox Searching (%winX%, %winY%, %winWidth%, %winHeight%).

      if ErrorLevel = 2
      {
         MsgBox Could not conduct the search (%winWidth%, %winHeight%).
      }
      else if ErrorLevel = 1
      {
         sleep increment * 1000 ; If the image wasn't found, pause the specified time before trying again.
      }
      else
      {
         foundIt := true
         ; MsgBox The icon was found at %FoundX%x%FoundY%.
         adjX := FoundX + offsetX
         adjY := FoundY + offsetY
         while (numClicks > 0)
         {
            Click %adjX%, %adjY%
            numClicks--
         }
         goto FIND_IMAGE_AND_CLICK_EXIT
      }

      tries := tries - 1
   }

   FIND_IMAGE_AND_CLICK_EXIT:
   return %foundIt%
}