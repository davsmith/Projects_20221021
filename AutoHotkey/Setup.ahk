;
; Setup.ahk
;
; Sets configurations for newly installed programs.
;
; Notes:
; --------------------------------------------------------------------------------------------
; 03/02/10:
; - Created file using PDFTools.ahk as template
; - Added Word setup
;
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

Setup_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\debug.ahk


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
::_setup::
   Configure_Templates()
   Configure_Save_Location()
return

;********************************************************************
#ifwinactive GSAK 7.7
;********************************************************************
::_GSAK::
  Send Dave Smith
return


!^S::
   Configure_GSAK()
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


::_ONSetup::
   CoordMode Mouse, Screen
   MsgBox, Place the mouse over the OneNote systray icon, and press <Enter>
   MouseGetPos, xpos, ypos 
   nOneNoteTray_x := xpos
   nOneNoteTray_y := ypos
   OneNote_SetupScreenClipping()
return

OneNote_SetupScreenClipping()
{
   Click right, %nOneNoteTray_x%, %nOneNoteTray_y%
   Send {UP 2}{Right}{Down}{Right}{Enter}
   return
}



; #############
;   Functions
; #############

Setup_Startup()
{
   global g_strFSDir
   global g_strIniDir

   LogFunctionStart("Setup_Startup")

   g_strFSDir := GetFolderShareDir()
   g_strIniDir := g_strFSDir . "Projects\_ini"

   goto SETUP_STARTUP_EXIT
SETUP_STARTUP_EXIT:
   LogFunctionEnd()
}


Configure_GSAK()
{
   global g_strFSDir
   global g_strIniDir

   LogFunctionStart("Configure_GSAK")

   strIniFile := g_strIniDir . "\GSAK.ini"

   ; Info on output files is stored in a section per output file
   ; Loop through the INI and store name and page ranges of each output file
   nIndex := 1
   loop, 200
   {
      strSection = Locations 
      strKey = Loc%nIndex%
      strLocation%nIndex% := ReadIni(strIniFile, strSection, strKey)
 
      if (strLocation%nIndex% = "ERROR")
      {
         break 
      } 

      nIndex++
   }

   Send !TO
   Sleep 1000
   Send {Right 2}{Tab}
   Send ^+{End}{Delete}

   Loop, %nIndex%
   {
      strLocation := strLocation%a_Index%

      if (strLocation = "ERROR")
      {
         break 
      } 

      Send %strLocation%{Enter}
   }

   Send {Tab}{Enter}

   Send !TO
   Sleep 2000
   ControlClick, TRadioButton7, Options,,,2          ; Set the distance units to "Miles"
   ControlClick, TRadioButton6, Options,,,2          ; Set the Owner ID method to "Exact Match"
   ControlSetText TEdit13, Dave_n_Ang, Options  ; Set the username for owner ID to Dave and Ang
   ControlClick, TComboBox9, Options,,,1          ; Set the Owner ID method to "Exact Match"
   Sleep 100
   Send A{Enter}
   ControlClick, TComboBox8, Options,,,1          ; Set the Owner ID method to "Exact Match"
   Sleep 100
   Send L{Enter}
   ControlClick, TComboBox10, Options,,,1          ; Set the Owner ID method to "Exact Match"
   Sleep 100
   Send Y{Enter}
   ControlClick, TBitBtn3, Options              ; Click the OK button. 

   LogFunctionEnd()
}


Configure_Templates()
{
   LogFunctionStart("Configure_Templates")
   Click 32,32                                             ; Click the Office perl
   Send IA                                                 ; Go the user advanced tab
   Send !{f 6}{Enter}
   Send {Down 2}{Enter}
   Sleep 1000
   Send D:\DaveDocs\Word Documents\Templates{Enter}
   Send {Esc 4}
   goto CONFIGURE_TEMPLATES_EXIT
CONFIGURE_TEMPLATES_EXIT:
   LogFunctionEnd()
   return
}


Configure_Save_Location()
{
   LogFunctionStart("Configure_Save_Location")
   Click 32,32                                             ; Click the Office perl
   Send IS                                                 ; Go the user advanced tab
   Send !i
   Sleep 1000
   Send D:\DaveDocs\Word Documents{Enter}
   Send {Esc}
   goto CONFIGURE_SAVE_LOCATION_EXIT
CONFIGURE_SAVE_LOCATION_EXIT:
   LogFunctionEnd()
   return
}