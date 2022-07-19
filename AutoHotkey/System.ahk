;
; System.ahk
;
; Functions and hotkeys for defining system settings (eg. Folder settings, Favorites, etc).
; These functions will be most useful when first installing the OS
;
;
; Notes:
; ---------------------------------------------------------------------------------------------------------
;
; Functions are broken into the following sections:
;   Power Settings
;   Windows Explorer
;   Display
;   Activation
;   Libraries
;   Windows Explorer Favorites
;   Configuration and Startup
;   





; History:
; ---------------------------------------------------------------------------------------------------------
;
; 4/18/2010:
;   - Updated to match the template
;   - Added functionality for creating shortcuts   
;   - Updated activation keys
;
; ~04/20/09:
;   - Created
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

System_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\debug.ahk

#SingleInstance FORCE




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


; ###################
;   Utility Hotkeys
; ###################

::_System::
   System_Setup()
return

::_SetBackground::
   Display_SetBackground()
return

::_Setup_Display::
   Display_SetResolution(1)
   Display_SetResolution(2)
   Display_SetBackground()
return

::_Setup_FolderOptions::
   Explorer_SetFolderOptions()
return

::_Setup_Shortcuts::
   Fav_CreateShortcutsFromIni()
return

::_Setup_IE_Favorites::
   Explorer_RedirectIEFavorites()
return

::_Setup_Libraries::
   Lib_SetupLibrariesFromIni()
return

::_GetDisplayResolution::
    CoordMode, Mouse, Screen                                    ; Make mouse commands relative to screen (not window)
    SysGet nDisplayCoords, Monitor                              ; Get raw monitor resolution (including systray etc)
    nClickX := nDisplayCoordsRight / 2
    nClicky := nDisplayCoordsBottom / 2
    MsgBox %nDisplayCoordsRight% x %nDisplayCoordsBottom%       ; Display the screen coordinates
    MouseMove %nClickx%, %nClicky%                              ; Move the mouse to the center of the screen
return   


; #############
;   Functions
; #############

::_System_Help::
   ShowHelp()
return

ShowHelp()
{
   strHelpString :=

   strHelpString := strHelpString . "_System`r`n"
   strHelpString := strHelpString . "_SetBackground`r`n"
   strHelpString := strHelpString . "_Setup_Display`r`n"
   strHelpString := strHelpString . "_Setup_FolderOptions`r`n"
   strHelpString := strHelpString . "_Setup_Shortcuts`r`n"
   strHelpString := strHelpString . "_Setup_IE_Favorites`r`n"
   strHelpString := strHelpString . "_Setup_Libraries`r`n"
   strHelpString := strHelpString . "_GetDisplayResolution`r`n"

   MsgBox %strHelpString%
}



; ******************************************
;   Functions to manipulate Power Settings
; ******************************************
;
; Due to the differences in the power settings dialogs between laptops and desktops,
; these functions are still pretty sloppy.
;

::_Power::
   LogFunctionStart(A_ThisFunc)

   if (a_computername = "DAVSMITHLT") OR (a_computername = "DAVSMITHC") OR (a_computername = "DAVSMITHNB")
   {
      nLongDelay = 5000
      crdModifyProfile  = 684, 201
      crdTurnOffDisplay = 515, 240
      crdSleep          = 515, 285
   }
   else if (a_computername = "DAVSMITHA")
   {
      nLongDelay = 2000
      crdModifyProfile = 723, 205
      crdTurnOffDisplay = 393, 168
      crdSleep          = 397, 208
      crdSave           = 586, 342
   }
   else if (a_computername = "DAVSMITHB")
   {
      nLongDelay = 2000
      crdModifyProfile = 723, 205
      crdTurnOffDisplay = 393, 168
      crdSleep          = 397, 208
      crdSave           = 586, 342
   }
   else
   {
      Log("Computer name not recognized")
   }

   SetKeyDelay 50
   Send ^{Esc}                                                               ; Start menu search
   Send Power Options{Enter}                                                 ; Launch power options
   Sleep %nLongDelay%                                                        ;
   Power_ChangePlanSettingValue(crdModifyProfile, crdTurnOffDisplay, 11)
   Sleep %nLongDelay%
   Power_ChangePlanSettingValue(crdModifyProfile, crdSleep, 15)
   WinClose A                                                                ; Close out the window

   LogFunctionEnd()
return
	
	

Power_ChangePlanSettingValue(crdChangeSettingsLink, crdSetting, nNumDown)
{
   LogFunctionStart(A_ThisFunc)

   Click %crdChangeSettingsLink%
   Sleep 5000
   Click %crdSetting%
   Send {Home}
   Send {Down %nNumDown%}
   Send {Enter}

   LogFunctionEnd()
   return
}


 
; ********************************************
;   Functions to manipulate Windows Explorer
; ********************************************

LaunchStartMenu()
{
   LogFunctionStart(A_ThisFunc)

   Send ^{esc}                                             ; Launch the start menu
   WinWait ahk_class DV2ControlHost,,3 
   if (ErrorLevel)  
   {
      LogError("Timed Out waiting for Start Menu.")
      goto LAUNCHSTARTMENU_EXIT
   }

LAUNCHSTARTMENU_EXIT:
   LogFunctionEnd()
   return
}



::_SFO::
   Explorer_SetFolderOptions()
return

Explorer_SetFolderOptions()
{
   LogFunctionStart(A_ThisFunc)
   
   LaunchStartMenu()                                       ; Launch the start menu 
   Send Folder Options{Enter}                              ; Search and click on Folder Options
   WinWaitActive, Folder Options, Browse folders, 5        ; Wait for the window to launch 
   if (ErrorLevel)  
   {
      LogError("Timed Out waiting for 'Folder Options' dialog.")
      goto SETFOLDEROPTIONS_EXIT
   }

   Send +{Tab}{Right}                                      ; Move selection to the tabs, specifically the "View" tab
   Send !D                                                 ; Reset the default settings
   Send {Tab 2}                                            ; Tab down to the Advanced Settings list                                          
   Send {Down 8}{Space}                                    ; Show hidden files and folders
   Send {Down 1}{Space}                                    ; Show emptry drives in the computer folder
   Send {Down 1}{Space}                                    ; Show extensions for known file types
   Send {Down 1}{Space}                                    ; Show system files
   Send !Y                                                 ; Confirm that system files should be shown
   Send {Enter}                                            ; Commit changes.

SETFOLDEROPTIONS_EXIT:
   LogFunctionEnd()
   return
}



; ********************************************
;   Functions to manipulate Display Settings
; ********************************************

; ***
; *** NOTE:  Copy a 126x126 bmp file to C:\Users\Dave\AppData\Local\Temp to set user tile
; ***        Placing a tile in C:\Users\All Users\Microsoft\User Account Pictures\Default Pictures will
; ***        update the choices when choosing an account picture.
; ***
; ***

::_Screen::
   Display_SetResolution(1)
   Display_SetResolution(2)
   Display_SetBackground()
return


Display_SetResolution(nScreen=1)
{
   LogFunctionStart(A_ThisFunc)

   nRetVal = 0

   strIniFile := GetSysIniFile()
   strSection := "Display" . nScreen
   strKey := "Orientation"

   IniRead strOrientation, %strIniFile%, %strSection%, %strKey%

   Log(strSection . " Orientation: " . strOrientation)
   
   if (strOrientation = "Portrait")
   {
      strOrientationKeys := "P"
   }
   else if (strOrientation = "PortraitF")
   {
      strOrientationKeys := "PP"
   }
   else if (strOrientation = "Landscape")
   {
      strOrientationKeys := ""
   }
   else if (strOrientation = "LandscapeF")
   {
      strOrientationKeys := "L"
   }
   else
   {
      LogError("Missing or improper orientation (" . strOrientation . ") specified for " . strSection)
      goto SETRESOLUTION_EXIT
   }

   strKey := "Resolution"
   IniRead nResolution, %strIniFile%, %strSection%, %strKey%

   LaunchStartMenu()                                                   ; Start menu search
   Send Adjust Screen Resolution{Enter}                                ; Launch applet to adjust screen settings
   WinWaitActive, Screen Resolution,, 3
   if (ErrorLevel)
   {
      LogError("Timed Out waiting for display control panel applet")
      nRetVal = 1
      goto SETRESOLUTION_EXIT
   }

   Send %nScreen%                                                      ; Choose the nth display

   Send !O{Home}%strOrientationKeys%                                   ; Set the orientation to Portrait, Landscape
                                                                       ;   Portrait flipped, or Landscape Flipped.
   Log("Specified resolution is " . nResolution . " from max") 
   Send !R{Home}                                                       ; Set to highest resolution
   Send {Down %nResolution%}{Enter}                                    ; Back off max by specified number of clicks
   Send {Tab 7}{Enter}                                                 ; Tab to OK button

   ; Wait for the dialog to accept changes
   WinWait, Display Settings, Keep changes, 3                          ; Wait for the confirmation dialog
   if (ErrorLevel)                                                     ;   that we want to keep these settings                                         
   {
      LogWarning("Timed Out waiting for confirmation dialog.")
      nRetVal = 1
      goto SETRESOLUTION_EXIT
   }

   Send !K                                                             ; Keep the changes
   Send !{F4}

SETRESOLUTION_EXIT:
   LogFunctionEnd()
   return
}



;
; Sets the desktop background to any of a slide show, a theme, or an individual image.
; The background can be specified in the function call, retrieved from an INI file,
; or simply be an image in the _config directory with the same name as the computer.
;
Display_SetBackground(strTarget="")
{
   LogFunctionStart(A_ThisFunc)

   ; If no file/path is specified, try to get it from the INI
   if (strTarget = "")
   {
      strIniFile := GetSysIniFile()
      IniRead strTarget, %strIniFile%, Theme, Background
   }

   ; A JPG in the _Config dir named with the user account trumps all.
   strUserJPG := GetConfigDir() . "\" . a_username . ".jpg"
   Log("User background check for " . strUserJPG)

   if FileExist(strUserJPG)
   {
      Log("Found username JPG..." . strUserJPG)
      strTarget := strUserJPG
   }

   ; Determine the form of the specified background...
   ; If it's a string, it should be a path to a directory (for a slide show),
   ; or a path to a file (for a single background).  A path to a theme
   ; is also accepted.
   strExtension := GetExtension(strTarget)

   Log("File extension: " . strExtension)
   if (strExtension = "THEME")
   {
      Log("It's a theme")

      if (FileExist(strTarget))
      {
         Log("Setting the desktop theme to " . strTarget)
         Run %strTarget%, Max
         WinWaitActive, Personalization,, 5
         if (ErrorLevel)  
         {
            LogError("Timed Out waiting for Personalization CPL applet")
            nRetVal = 1
            goto SETBACKGROUND_EXIT
         }
      }   

      Sleep 1000                              
      WinClose, A                                                            ; Close out the themes window
   }
   else if ((strExtension = "JPG") or (strExtension = "BMP"))
   {
      Log("Setting background to image " . strTarget)
      ExecuteStartMenuContextCommand(strTarget, "B")
   }
   else if InStr(FileExist(strTarget), "D")
   {
      Log("Setting background to slideshow from " . strTarget)

      SetKeyDelay 25
      LaunchStartMenu()                                                      ; Start menu search 
      Send Personalization{Enter} 
      WinWaitActive, Personalization,, 2
      if (ErrorLevel)  
      {
         LogError("Timed Out waiting for Personalization CPL applet")
         nRetVal = 1
         goto SETBACKGROUND_EXIT
      } 
      WinMaximize, A 
      Sleep 1000 
      Send {Tab}{Enter}                                                      ; Click on the Desktop Background
      WinWaitActive, Desktop Background,, 2
      ControlClick Button1, Desktop Background                               ; Click the Browse button
      WinWaitActive, Browse,, 2
      Sleep 500
      ControlSetText Edit1, %strTarget%, Browse                              ; Set the selection to the directory
      Sleep 500 
      ControlClick Button2, Browse,,LEFT,2                                   ; Click the OK button
      WinWaitActive, Desktop Background,, 2
      Sleep 1500
      ControlClick Button6, A,,LEFT,2                                        ; Click Save Changes 
      WinClose, A                                                            ; Close out the themes window
   }
   else
   {
      LogError("Unknown type specified for background.  Please specify a .THEME, .JPG or a folder")
      nRetVal = 1
      goto SETBACKGROUND_EXIT
   }

SETBACKGROUND_EXIT:
   LogFunctionEnd()

   return
}



; *************************************
;   Functions to deal with activation
; *************************************

::_Activate::
;   Explorer_Activate()
return

Explorer_Activate()
{
   LogFunctionStart(A_ThisFunc)

   nWaitTime := 10
   nWaitTimeLong := 120
   LaunchStartMenu()
   Send Activate Windows{Enter}
   WinWaitActive, Windows Activation, You must activate Windows, %nWaitTime%
   if (ErrorLevel)  
   {
      LogError("Timed Out waiting for control panel to launch")
      return
   }

   Send !A

   WinWaitActive, Windows Activation, The product key looks like this, %nWaitTime%
   if (ErrorLevel)  
   {
      LogError("Timed Out waiting for product key page")
      return
   }

   Sleep 1000
   if (a_computername = "DAVSMITHLT") OR (a_computername = "DAVSMITHC")
      Send 6C4WK6QDG4W66J8G7K989MFBG
   if (a_computername = "DAVSMITHA")
      Send D6B97PM6YJTBX3P3D24BXW6M9
   if (a_computername = "DAVSMITHB")
      Send 6DP9D-MBR98-XKK7H-D6RTP-T28TH
   Send !N
   WinWaitActive, Windows Activation, Genuine Logo, %nWaitTimeLong%
   if ErrorLevel  
   {
      LogError("Timed Out waiting for success page")
      return
   }

   MsgBox Done!
Explorer_Activate:
   LogFunctionEnd()
   return
}



::_Fav::
   Explorer_RedirectIEFavorites()
return

Explorer_RedirectIEFavorites(strFavePath="")
{
   LogFunctionStart(A_ThisFunc)

   ; Figure out which directory to point IE Favorites.
   if (strFavePath = "")
   {
      ; Check the configuration INI
      strIniFile := GetSysIniFile()
      strSection := "IE"
      strKey := "Favorites"

      IniRead strFavePath, %strIniFile%, %strSection%, %strKey%
      if (strFavePath = "ERROR")
      {
         strDir := GetFolderShareDir()
         strFavePath = %strDir%Home\Favorites   
      }
   }      

   Log("Setting IE Favorites to " . strFavePath)

   LaunchStartMenu()                           ; Open the start menu
   Send {Right}                                ; Select the right side of the menu
   Send {Down}{Enter}                          ; Choose the User Profile
   WinWaitActive ahk_class CabinetWClass, ,5

   Sleep 100
   Send Favorites                              ; Select the Favorites icon, and open its properties.
   Send {AppsKey}
   Send R

   WinWaitActive, Favorites Properties,, 12    ; Wait for the "Favorites Properties" dialog to be launched
   Send +{Tab 2}                               ; Tab up to the tab controls
   Send {UP}{Tab}                              ; Choose the "Location" tab and tab to the path in the edit box.
   WinGetText, strText, Favorites Properties
   StringSplit strTokens, strText, `r          ; The first element in the dialog's text is the current tab.
   strTab = %strTokens1%
   if (strTab = "Location")                    ; Confirm that we're on the Location tab before making any edits
   {
      clipboard = %strFavePath%
      SetKeyDelay 25
      Send %strFavePath%                       ; Set the favorites path to the Favorites directory under
      Send !A                                  ;   the FolderShare path.

      ; Wait for the "Move Folder" dialog to pop
      WinWaitActive, Move Folder,, 1 
      if (ErrorLevel = 0)  
      {
         ; Dialog popped prompting whether we want to move the contents of the previous folder
         Send !N
      }

      Send {Enter}
   }
   else
   {
      LogError("Couldn't find the Locations tab.  Exiting.")
      goto REDIRECTIEFAVORIES_EXIT 
   }
  
   WinClose, A
REDIRECTIEFAVORIES_EXIT:
   LogFunctionEnd()
   return
}



; *************************************
;   Functions to manipulate Libraries
; *************************************

Lib_CreateLibraryFromPath(strPath, strFriendlyName="")
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 100

   ; Create a custom library for the FolderShare directory
   Run %strPath%
   sleep 1000
   Send {Tab 4}
   Send {Right}{Down}{Up}{Enter}

   if (strFriendlyName <> "")
   {
      StringSplit strTokens, strPath, \
      strName := strTokens%strTokens0%
      Send {Tab}
      Send Libraries
      Log("Name: " strName)
      Sleep 1000 
      Send %strName%
      Send {F2}
      Send %strFriendlyName%{Enter}
   }

   LogFunctionEnd()
   return
}



Lib_AddLocation(strLibraryName, strLocationPath, bMakeDefaultSave=0)
{
   LogFunctionStart(A_ThisFunc)
   nRetVal = 0

   Lib_LaunchLibraryWindow()
   Send {Home}
   Send %strLibraryName%
   Send {AppsKey}r
   WinWait Properties,,3 
   Send !I 
   WinWait Include Folder,,3 
   Send %strLocationPath% 
   Send {Tab}{Enter}

   WinWait Windows Libraries,,.5       ;  Wait to see if we get an error dialog for adding an existing location
   if (errorlevel = 0)
   {
     Send {Enter}
     nRetVal = -1
   }

   WinWait Include Folder,,.5          ;  Wait to see if we get any other error dialog
   if (errorlevel = 0)
   {
     Send {Enter}
     Send {Tab}{Enter}
     nRetVal = 1
   }

   if (nRetVal <= 0) and (bMakeDefaultSave)
   {
      StringSplit strTokens, strLocationPath, \
      Log( "Path:" %strPath% )
      Log( "Tokens0:" %strTokens0% )
      strName := strTokens%strTokens0%
      Send %strName%
      Send !S 
      Log(strName)
   }

   WinWait Properties,,3 
   Send {Enter}

   LogFunctionEnd()
   return %nRetVal%
}



Lib_LaunchLibraryWindow()
{
   LogFunctionStart(A_ThisFunc)

   IfWinExist Libraries ahk_class CabinetWClass
   {
      WinActivate Libraries ahk_class CabinetWClass
   }
   else
   {
      LaunchStartMenu()
      Send Libraries{Enter}
      WinWaitActive Libraries ahk_class CabinetWClass
   }

   LogFunctionEnd()
}



Lib_GetLibraryList()
{
   LogFunctionStart(A_ThisFunc)

   strList =
   strPrevLib =
   Lib_LaunchLibraryWindow()
   Send {Home}" "
   bExit = 0
   loop,10
   {
      Send {F2}^C{Esc}
      strCurLib = %clipboard%
      if (strCurLib = strPrevLib)
      {
         bExit = 1
      }
      else
      {
         strList = %strList%;%strCurLib%
         strPrevLib = %strCurLib%
      }

      Send {down} 

      if (bExit)
      {
         break
      }
   }   

   StringMid strList2, strList, 2
   Log(strList2)
   LogFunctionEnd()
   return strList2
}


					
; ***************************************************
;   Functions to manipulate Favorites, and Pinning
; ***************************************************

Fav_AddRemoveShortcut(strType, strAction, strPath, strFriendlyName="", bCreatePath=0)
{
   LogFunctionStart(A_ThisFunc)

   if (strFriendlyName = "")
   {
      strFriendlyName := GetBaseName(strPath)
      Log( "No friendly name specified.  Using " . strFriendlyName )
   }

   if (bCreatePath)
   {
      Log( "Attempting to create folder " . strPath )
      FileCreateDir %strPath%
   }

   StringUpper strType, strType
   StringUpper strAction, strAction

   Log("Args: Type:" . strType . ", Action: " . strAction . " FN: " . strFriendlyName . " CreatePath: " . bCreatePath)
   Log("      Path: " . strPath)

   bStandardFile := 0

   if (strType = "DESKTOP")
   {
      strDestPath := a_desktop . "\" . strFriendlyName . ".lnk"
      bStandardFile := 1
   }
   else if (strType = "FAVORITES")
   {
      strDestPath := before(a_desktop, "\Desktop") . "\links\" . strFriendlyName . ".lnk"
      bStandardFile := 1
   }
   else if (strType = "TASKBAR")
   {
      ; Added * to path because of strange behavior with pinning where it sometimes adds "- Shortcut" to the filename
      strDestPath := a_appdata . "\Microsoft\Internet Explorer\Quick Launch\User Pinned\Taskbar\" . strFriendlyName . "*.lnk"
      strContextKeys = K
      clipboard := strDestPath

      Log("Taskbar directory: " . strDestPath)
   }
   else if (strType = "STARTMENU")
   {
      ; Added * to path because of strange behavior with pinning where it sometimes adds "- Shortcut" to the filename
      strDestPath := a_appdata . "\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu\" . strFriendlyName . "*.lnk"
      strContextKeys = U
      clipboard := strDestPath

      Log("Start Menu directory: " . strDestPath)
   }

   bAlreadyExists = 0
   Log("Checking for " . strDestPath, 9)
   if (FileExist(strDestPath))
   {
      bAlreadyExists = 1
   }

   ;
   ; If we're adding a standard shortcut (desktop, or favorites) we just create a .lnk file.
   ; If we're adding a special shortcut (start menu or taskbar) we have to do some magic from
   ;    the start menu.
   if (bStandardFile)
   {
      if (strAction = "ADD")
      {
         ; Create the shortcut, using the friendly name if specified.
         Log("Creating shortcut to " . strPath . " in " . strDestPath)
         FileCreateShortcut, %strPath%, %strDestPath%
      }
      else if (strAction = "REMOVE")
      {
         Log("Removing shortcut to " . strPath . " from " . strDestPath)
         FileDelete %strDestPath%
      }
   }
   else
   {
      if (strAction = "ADD")
      {
         if (bAlreadyExists)
         {
            LogWarning("Path " . strPath . " is already pinned.  Ignoring.")
         }
         else
         {
            ; BUGBUG: Sleep was added because the start menu sometimes misfires if launched too quickly.
            Log("Adding special shortcut to " . strPath . " using context keys (" . strContextKeys . ")")
            sleep 250
            ExecuteStartMenuContextCommand(strPath, strContextKeys)
         }
      } 
      else if (strAction = "REMOVE")
      {
         if (not bAlreadyExists)
         {
            LogWarning("Path " . strPath . " isn't pinned.  Ignoring.")
         }
         else
         {
            Log("Removing special shortcut from " . strPath . " using context keys (" . strContextKeys . ")")
            ExecuteStartMenuContextCommand(strDestPath, strContextKeys)
         }
      }
   }

goto ADDREMOVESHORTCUT_EXIT
ADDREMOVESHORTCUT_EXIT:
   LogFunctionEnd()
}


::_CSI::
   Fav_CreateShortcutsFromIni()
;   Fav_AddRemoveShortcut("Favorites","Add","D:\Local\Projects","Local Projects",1)
return

Fav_CreateShortcutsFromIni(strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

   LoopFromIni("Fav_AddRemoveShortcut", "Explorer", "Shortcut", 3)

goto CREATESHORTCUTSFROMINI_EXIT
CREATESHORTCUTSFROMINI_EXIT:
   LogFunctionEnd()
}



;
; Retrieves library names and location names from the ini file.
; For libraries, a new library is created from the specified path.
; For locations, the path is added to the specified library.
;
Lib_SetupLibrariesFromIni(strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

   LoopFromIni("Lib_CreateLibraryFromPath", "Libraries", "Lib", 1)
   LoopFromIni("Lib_AddLocation", "Libraries", "Loc", 2)

goto SETUPLIBRARIESFROMINI_EXIT
SETUPLIBRARIESFROMINI_EXIT:
   LogFunctionEnd()
}


					
; **********************************************
;   Functions for User Accounts
; **********************************************

::_SUA::
   UA_SetUserAccountIcon()
return

UA_SetUserAccountIcon(strFile="")
{
   LogFunctionStart(A_ThisFunc)
   EnvGet strDomain, USERDOMAIN
   Log("Domain: " . strDomain)


goto UA_SETUSERACCOUNTICON_EXIT
UA_SETUSERACCOUNTICON_EXIT:
   LogFunctionEnd()
}



; *****************************
;   Configuration and Startup
; *****************************

System_Startup()
{
   return
}



System_Setup()
{
   LogFunctionStart(A_ThisFunc)

   strSysIni := GetSysIniFile()
   Log("Ini file: " . strSysIni)

   Log("Setting up the displays")
   Display_SetResolution(1)
   Display_SetResolution(2)
   Display_SetBackground()

   ; Configure Explorer folder options
   Log("Setting folder options")
   Explorer_SetFolderOptions()

   Log("Creating shortcuts")
   Fav_CreateShortcutsFromIni()

   ; Configure IE Favorites location
   Log("Redirecting IE Favorites")
   Explorer_RedirectIEFavorites()

   ; Set up libraries
   Log("Setting up libraries")
   Lib_SetupLibrariesFromIni()


   strLibraries := Lib_GetLibraryList()

   Log("Library list: " . strLibraries)

SYSTEM_SETUP_EXIT:
   LogFunctionEnd()
   return
}



; **********************************************
;   Support Functions
; **********************************************

;
; This function looks in the specified ini file (or the SysIniFile) for a specified
; section and key.  The key is expected to be incrmented (key1, key2, key3, ...).
; For each element of the key, the specified function is run with up to 10 specified
; paramenters.
;
LoopFromIni(strFunctionName, strSection, strKeyBase, nMinParams, strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

   ; If no INI file was specified, look for a _config directory, etc.
   if (strIniFile="")
   {
      StrIniFile := GetSysIniFile()
   }

   ;
   ; Look in the specified section for a numerically indexed set of keys (key1, key2, key3, etc...)
   ; Limit the loop to 100 to avoid any infinite loops.
   ;
   loop, 100
   {
      strKey := strKeyBase . A_Index  

      ; Blank out the strTokens
      strBlank := ",,,,,,,,,,,,,,,,,,"
      StringSplit strTokens, strBlank, `,

      ; Get the specified key from the INI file.
      IniRead strFullString, %strIniFile%, %strSection%, %strKey%
      if (strFullString = "ERROR")
      {
         break
      }

      Log(strKeyBase . " #" . A_Index . ": " . strFullString)

      ; Split up the comma separated string value of the key into a set of arguments.
      StringSplit strTokens, strFullString, `,
      Log("The ini entry had " . strTokens0 . " args.", 9)

      ; Check for the proper number of arguments.
      if (strTokens0 < nMinParamas)
      {
         LogWarning(strKeyBase . " #" . A_Index . " has less than " . nMinParams . " parameter(s).  Ignoring.")
         Continue
      }

      ; Call the specified function with the set of arguments from the INI
      Log("Calling " . strFunctionName, 9)
      Loop %strTokens0%
      {
         Log("   Arg #" . a_index . ": " . strTokens%a_index%, 9)
      }

      %strFunctionName%(strTokens1, strTokens2, strTokens3, strTokens4, strTokens5, strTokens6, strTokens7, strTokens8, strTokens9, strTokens10)
   }


goto LOOPFROMINI_EXIT
LOOPFROMINI_EXIT:
   LogFunctionEnd()
}


; D:\FolderShare\Download\Debugging\DebugView\Dbgview.exe

;
; Initiates a Start Menu search for the specified path, opens the context menu, and executes a command.
; This is a helper function to do things like pin/unpin an item to the task bar, as well
; as set a desktop background.
;
ExecuteStartMenuContextCommand(strPath, strCommandString)
{
   LogFunctionStart(A_ThisFunc)
; MsgBox % a_thisfunc
   nRetVal = 0

   Log("Args: Path: " . strPath . ", CommandString:" . strcommandString)

   ; Make sure the specified path exists.
   if (not FileExist(strPath))    
   {
      LogError("Path (" . strPath . ") does not exist.")
      nRetVal = 1
      goto EXECUTESTARTMENUCONTEXTCOMMAND_EXIT
   }

   Log("Performing start menu search for " . strPath)

   SetKeyDelay 25
   LaunchStartMenu()                                                      ; Start menu search 
   Send %strPath%                                                         ; Search for absolute path
   Sleep 1000
   Send {Down}                                                            ; select the item in the start menu 
   Send {AppsKey}
   Send %strCommandString%                                                ; Send the specified key clicks
   Send {Esc 2}                                                           ; Cancel the search and start menu

goto EXECUTESTARTMENUCONTEXTCOMMAND_EXIT
EXECUTESTARTMENUCONTEXTCOMMAND_EXIT:
   LogFunctionEnd()
}