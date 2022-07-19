;
; VisualStudio.ahk
;
; Macros and setup for Visual Studio 2010.
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 05/15/10:
; - Created the file and macros for initial VS setup
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

VisualStudio_Startup()

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
; ################
;   Global tools
; ################
;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************


^!T::
   Click Right 
   Sleep 500
   Send {Down 4}
   Sleep 200
   Send {Enter}
   Sleep 200
   Send {Enter}
return


; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
VisualStudio_Startup()
{
   LogFunctionStart(A_ThisFunc)

VISUALSTUDIO_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


::_vs::
   VisualStudio_Setup()
return

VisualStudio_Setup()
{
   LogFunctionStart(A_ThisFunc)

   nRetVal = 0

   strIniFile := GetSysIniFile()
   strSection := "VisualStudio" . nScreen

   strKey := "ProjectDirectory"
   IniRead strProjectDirectory, %strIniFile%, %strSection%, %strKey%

   strKey := "ProjectTemplateDir"
   IniRead strProjectTemplateDir, %strIniFile%, %strSection%, %strKey%

   strKey := "ItemTemplateDir" 
   IniRead strItemTemplateDir, %strIniFile%, %strSection%, %strKey%

   Log("Setting up Visual Studio with the following settings:")
   Log("  Project Directory: " . strProjectDirectory)
   Log("  Project Template Directory: " . strProjectTemplateDir)
   Log("  Item Template Directory: " . strItemTemplateDir)

   Send !TO
   Sleep 1000
   Control, Uncheck, , Button10, Options                     ; Reset the tree control so we know where we are
   Sleep 1000
   Control, Check, , Button10, Options
   ControlGet bIsChecked, Checked, , Button10, Options
   Log("Checkbox value is: " . bIsChecked)
   Send +{Tab}
   Send Projects 

   Send !P
   Send %strProjectDirectory%

   Send !R
   Send %strProjectTemplateDir%

   Send !M
   Send %strItemTemplateDir%

   Send {Enter}

   ; Set up the "Get Public Key" tool
   strStrongNameTool := a_programfiles . "\Microsoft SDKs\Windows\v7.0A\Bin\sn.exe"
   if (not FileExist(strStrongNameTool))
   {
      strStrongNameTool := "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\sn.exe"
      if (not FileExist(strStrongNameTool))
      {
         strStrongNameTool := ""
      }
   }   

   if (strStrongNameTool <> "")
   {
      MsgBox Please open the "External Tools" dialog and click OK.
      WinWait External Tools,, 30000
      if (ErrorLevel)
      {
         LogError("Timed out waiting for Options dialog")
         goto VISUALSTUDIO_SETUP_EXIT
      }
      
      Send !T
      Send Get Public Key{Tab}
      Send %strStrongNameTool%
      Send {Tab 2}
      Send -Tp "$(TargetPath)"
      ControlGet hWnd, HWND, , Button11, External Tools
      Control, Uncheck, , Button11, External Tools
      Control, Uncheck, , Button10, External Tools
      Control, Uncheck, , Button9, External Tools
      Control, Check, , Button8, External Tools
      Send {enter}
   } 

VISUALSTUDIO_SETUP_EXIT:
   LogFunctionEnd()
}


#ifwinactive Visual
^!Z::
   MsgBox In it.
return

^!F::
   ; Add function logging at beginning and end of function
   Send {Tab}{Enter}
   Send CLogger.TraceFunctionStart();{Enter}
   Send {Up 2}
   Send ^]
   Send {Up}{End}{Enter 2}
   Send CLogger.TraceFunctionEnd();
return