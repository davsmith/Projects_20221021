;
; FolderShare.ahk
;
; Scripts for configuring and using Windows Live Sync (formerly FolderShare).
;
; Notes:
; ---------------------------------------------------------------------------------------------------------
; This functionality relies heavily on settings within Autohokey.ini in a directory called
; _Config on any hard drive.
;
; AutoHotkey.ini should have the following keys under the FolderShare section:
;   LibList:      A comma separated list of active libraries.  Initially this list may
;                   include all libraries, but be reduced if some actions are only desired
;                   on a subset of libraries.
;
;   Root:         The absolute path to the foldershare directory, including a trailing \.
;                   GetFolderShareDir can be used to access this info.
;
;   ID:           The unique ID used by FolderShare to identify this computer. It can be
;                   retrieved manually by mousing over the computer name on the Live Sync
;                   web site.  GetComputerID can also be used to set and retrieve this info.
;
;   TrayX, TrayY: The absolute coordinates on the screen of the FolderShare icon in the
;                   system tray.  The GetCoords function sets and retrieves this info.
;                   It can also be determined manually using Window Spy.
;
;   
;   Lib_X ... :   The list of library names and their associated IDs.  This information
;                   must be set manually by mousing over each of the Personal and Shared
;                   folders on the sync web site.  This value is the number after LID in
;                   the URL for the library, and is unique per account, but common across
;                   all logins. X is the library friendly name which shows up on the sync
;                   web site.  The value can be a comma separated list composed of
;                   the library ID, followed by an optional absolute path to the local
;                   folder to which this library is linked.
;
; Primary functions are:
;   Setup              _fssetup        This function is the main function which calls the support
;                                        functions to create the directory structure and connect the
;                                        libraries to the sync site.
;
;   CreateTree         _fscreatetree   Creates the directory structure from the keys in the INI file.
;
; Other functions are:
;   Startup                            Currently empty
;   GetCoords          _gcoord         Retrieves/Sets the coordinates of the Sync icon in the systray
;   GetFolderShareDir                  Retrieves/Sets the root directory of the FolderShare path
;                                        If this value isn't found in the INI file, it's divined
;                                        from the path of the current script.
;   GetComputerID      _gcid           Retrieves/Sets the unique ID for the current computer.
;                                        This value is stored in the INI file, but can be divined
;                                        from the the number after DID in the url for the device
;                                        on the Sync website.
;   GetLibrary                         Retrieves the library ID from the INI file, along with
;                                        the optional absolute path for the specified library name.
;   SetupFSLibrary                     Connects a FolderShare library with a local directory.
;                                        The function requires the local path to the library,
;                                        the computer ID, the library name, the library ID, and the
;                                        coordinates of the FolderShare icon in the systray.
;   SetupAllLibraries                  Reads the library list from the INI file, and calls SetupFSLibrary
;                                        for each library.
;   RemoveOldMachines  _rom            Can be run from the Live Sync root page to remove machines which
;                                        are no longer active.  This function must be passed 2 integers
;                                        the first is the number of machines to skip, the second is
;                                        the number of machines to delete.
; 
;
; History:
; ---------------------------------------------------------------------------------------------------------
;
; 04/21/10:
; - Added optional argument to Setup (strIniFile)
; - Added function GetCoords
; - Modified RemoveOldMachines to take # good machines, # old machines as parameters
; - Removed the global g_strFSDir.  Use FolderShare_GetFolderShareDir instead
; - Modified logging to use a_thisfunc
; - Modified FS_CreateTree to take a list of libraries and an Ini file as params
;
; 04/16/10:
; - Changed the docs.
; - Added default logging.
;

;
; #######################
;  Global Initialization
; #######################

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

FolderShare_Startup()
#NoEnv
;#include %A_ScriptDir%\Include\tools.ahk
;#include %A_ScriptDir%\Include\debug.ahk
#include %A_ScriptDir%\IE.ahk


;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

; #############
;  Scope tools
; #############

;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode
; setting specified at the top of the script.
;

;********************************************************************
#ifwinactive Windows Live Sync
;********************************************************************

::_FSD::
   strDir := FolderShare_GetFolderShareDir()
   MsgBox %strDir%
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

::_FSSetup::
   FolderShare_Setup()
return

::_FSCreateTree::
   strIniFile := GetSysIniFile() 
;   FolderShare_CreateTree("Download,Favorites,Home,Scans,Work,Public,DVDInfoCache")
   FolderShare_CreateTree(strIniFile)
return

::_FSID::
   nID := FolderShare_GetComputerID()
   MsgBox %nID% 
return

::_ROM::
   FolderShare_RemoveOldMachines(0,0)
return


::_TS9::
   WinGet hWnd, ID, Windows Live Sync
   WinActivate ahk_id %hWnd%
   MsgBox %hWnd%

   Send ^f
   Send Personal Folders
   Send {esc}
   Sleep 200
   Send {tab}
   Send ^f
   Send HomeGroup
   Send {esc}
   Sleep 200
   Send {Enter}
   pwb := IE_GetWebBrowser()
   WaitForReady(pwb)
   MsgBox Done!
return



;*************
; Functions
;*************
FolderShare_Startup(strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

FOLDERSHARE_STARTUP_EXIT:
   LogFunctionEnd()
   return
}



FolderShare_Setup()
{
   LogFunctionStart(A_ThisFunc)

   strIniFile := GetSysIniFile()
   FolderShare_CreateTree(strIniFile)
   FolderShare_SetupAllLibraries(strIniFile)

FOLDERSHARE_SETUP_EXIT:
   LogFunctionEnd()
}



::gc::
   FolderShare_GetCoords(x, y, GetSysIniFile())
   Log( "Tray: " . x . "," . y )
return

FolderShare_GetCoords(ByRef xTray, ByRef yTray, strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

   xTray := "ERROR"

   ; Try to read the coordinates from the specified INI file
   if (strIniFile <> "")
   {
      Log( "Attempting to read tray coords from " . strIniFile)
      IniRead, xTray, %strIniFile%, FolderShare, TrayX
      IniRead, yTray, %strIniFile%, FolderShare, TrayY
      Log( "Tray coords read from Ini (" . xTray . "," . yTray . ")" )
   }

   ; If that didn't work, ask the user to show us the location of the tray icon.
   if (xTray = "ERROR")
   {
      Log( "Didn't find coords in INI file.  Prompting user." )
      CoordMode Mouse, Screen
      MsgBox, Place the mouse over the Sync systray icon, and press <Enter>
      MouseGetPos, xTray, yTray 
   }

   ; If an INI file was specified, write the coordiates back to it.
   if (strIniFile <> "")
   {
      Log( "Writing Tray coordinates (" . xTray . "," . yTray . ") to " . strIniFile )
      IniWrite %xTray%, %strIniFile%, FolderShare, TrayX
      IniWrite %yTray%, %strIniFile%, FolderShare, TrayY
      Log("Return value: " . ErrorLevel)
   }
   else
   {
      Log( "No INI file was passed, coords not persisted" )
   }

GETCOORDS_EXIT:
   LogFunctionEnd()
   return
}



FolderShare_CreateTree(strIniFile)
{
   LogFunctionStart(A_ThisFunc)

   if (FileExist(strIniFile))
   { 
      strFSRoot := FolderShare_GetFolderShareDir(strIniFile)

      IniRead, strLibList, %strIniFile%, FolderShare, LibList
      if (strLibList = "ERROR")
      {
         Log("ERROR: Please add the key FolderShare\LibList to " . strIniFile)
         goto CREATETREE_EXIT
      }
      
      Loop, PARSE, strLibList, `,
      {   
         strLibName := a_LoopField     
         FolderShare_GetLibrary( strIniFile, strLibName, nLibID, strLibPath)
         if (nLibID = 0)
         {
            Log("ERROR: Library " . strLibName . " does not exist in " . strIniFile)
         }
         else
         {
            strDir := strFSRoot . strLibName
            Log( "Creating directory " . strDir )
            FileCreateDir %strDir%
         }
      }
   }
   else
   {
      Log( "ERROR: No INI file was specified." )
   }

CREATETREE_EXIT:
   LogFunctionEnd()
   return
}



;
; In this function an INI file is checked for the path to the root of
; the FolderShare directory.  If no INI file is specified, assume that
; the script path is in the foldershare directory, and just trim off the parts
; we don't need
;
FolderShare_GetFolderShareDir(strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

   ; Attempt to get the ID from an INI file
   IniRead, strFSPath, %strIniFile%, FolderShare, Root
   Log( "Attempt to retrieve FSPath from " . strIniFile . " yielded: " . strFSPath )

   ; If that doesn't work, retrieve it from the path to the script directory
   if (strFSPath = "ERROR")
   {
      strFSPath = 
      strEntry = FolderShare
      nLen1 := Instr(A_ScriptFullPath, strEntry)
      if nLen1 > 0 then
      {
         strFSPath := SubStr(a_ScriptFullPath, 1, nLen1+StrLen(strEntry))
      }

      Log( "Defined foldershare path from script dir (" . strFSPath . ")")
   }

   If (strIniFile <> "")
   {
      Log( "Writing path to " . strIniFile )
      IniWrite %strFSPath%, %strIniFile%, FolderShare, Root
   }

FOLDERSHARE_GETFOLDERSHAREDIR_EXIT:
   LogFunctionEnd()
   return strFSPath
}



FolderShare_GetComputerID(strIniFile="")
{
   LogFunctionStart(A_ThisFunc)

   Log("Ini file:" . strIniFile)

   strWindowTitle = Windows Live Sync

   ; Attempt to get the ID from an INI file
   IniRead, strFSMachineID, %strIniFile%, FolderShare, ID

   ; If that doesn't work, scrape the ID from a FolderShare page
   if (strFSMachineID = "ERROR")
   {
      Log( "Didn't find Computer ID in INI. Launching FolderShare." )
      FolderShare_GetCoords(x, y, strIniFile)
      Log("Coords returned from GetCoords: " . x . "," . y )

      nKD = %a_KeyDelay%
      SetKeyDelay 200
      CoordMode Mouse, Screen
      Click %x%, %y%                                    ; Click the systray icon for sync
      Send {up 4}{enter}				; Launch the sync website


      WinWaitActive, %strWindowTitle%, ,5               ; Wait for the web page to be launched
      StatusBarWait Done, 10, , %strWindowTitle%        ; Wait for the web page to finish loading
      Send ^f%a_computername%{Tab 2}+{Tab}              ; Search for the computer in the remote access list
      Sleep 1000
      StatusBarGetText, strStatus,, %strWindowTitle%    ; Capture the computer id from the hyperlink
      StringSplit strArr, strStatus, =
      nRetVal := strArr2

      SetKeyDelay %nKD%
      WinClose, %strWindowTitle%

      IniWrite %nRetVal%, %strIniFile%, FolderShare, ID
      Log( "Writing ID #" . nRetVal . " to " . strIniFile . " (exit code " . errorlevel . ")" )
   }
   else
   {
      Log( "Retrieved ID from INI" )
      nRetVal := strFSMachineID
   }

GETCOMPUTERID_EXIT:
   LogFunctionEnd()
   return %nRetVal%
}



FolderShare_GetLibrary(strIniFile, strLibName, ByRef nLibID, ByRef strLibPath)
{
   LogFunctionStart(A_ThisFunc)

   nRetVal = 0
   strKey := "Lib_" . strLibName

   IniRead, strFullLine, %strIniFile%, FolderShare, %strKey%, %a_space%
   Log( "Full entry for Library " . strLibName . " = " . strFullLine )

   if (strFullLine = "")
   {
      Log( "Error: Library " . strLibName . " did not exist." )
      nRetVal = 1
      nLibID = 0
      strLibPath = 
      goto GETLIBRARY_EXIT
   }

   StringSplit, strArray, strFullLine, `,
   if (strArray0 = 2)
   {
      strLibPath := strArray2
   }
   else
   {
      strLibPath := FolderShare_GetFolderShareDir() . strLibName
   }

   nLibID := strArray1

   Log( "Library Name: " . strLibName )
   Log( "Library ID: " . nLibID )
   Log( "Library Path: " . strLibPath )

GETLIBRARY_EXIT:
   LogFunctionEnd()
   return %nRetVal%
}



FolderShare_SetupAllLibraries(strIniFile)
{
   LogFunctionStart(A_ThisFunc)

   nLibCount=0
   nCompID := FolderShare_GetComputerID(strIniFile) 
   FolderShare_GetCoords(x, y, strIniFile)

   if (FileExist(strIniFile))
   { 
      strFSRoot := FolderShare_GetFolderShareDir(strIniFile)

      IniRead, strLibList, %strIniFile%, FolderShare, LibList

      ; If that doesn't work, retrieve it from the path to the script directory
      if (strLibList = "ERROR")
      {
         Log("ERROR: Please add the key FolderShare\LibList to " . strIniFile)
         goto SETUPALLLIBRARIES_EXIT
      }

      Loop, PARSE, strLibList, `,
      {   
         strLibName := a_LoopField     
         FolderShare_GetLibrary( strIniFile, strLibName, nLibID, strLibPath)
         if (nLibID = 0)
         {
            Log("ERROR: Library " . strLibName . " does not exist in " . strIniFile)
         }
         else
         {
            Log( "Activating library from Ini (" . strLibName . ") with an ID of " . nLibID)
            SetupFSLibrary( strLibPath, nCompID, strLibName, nLibID, x, y )
         }
      }
   }
   else
   {
      Log( "ERROR: No INI file was specified." )
   }

SETUPALLLIBRARIES_EXIT:
   LogFunctionEnd()
   return
}



SetupFSLibrary(strPath, nCompID, strLibFolder, nLibID, nSysTray_x, nSysTray_y)
{
   LogFunctionStart(A_ThisFunc)

   CoordMode Mouse, Screen
   StringSplit strArray, strPath, :
   root_drive = %strArray1%:
   StringSplit strArray, strPath, \
   root_path = \%strArray2%\

   Log("Path: " . strPath)
;  MsgBox Param path: %strParamPath%   Root path: %root_path%
;  HardMessage("Stop")

   ;MsgBox %root_drive%  %root_path% %nCompID%
   strFolderName = %strLibFolder%
   StringReplace strParamDrive, root_drive, :, `%3a
   StringReplace strParamPath, root_path, \, `%2f, All

   strFull = https://sync.live.com/browseselect.aspx?did=%nCompID%&bpath=`%2f%strParamDrive%&blabel=Fritz&rpath=%strParamPath%%strLibFolder%&mode=2&lid=%nLibID%
   Click %nSysTray_x%, %nSysTray_y%
   Send {UP 4}{Enter}
   Sleep 2000 
   clipboard = %strFull%
   Send {TAB}%strFull%
   Send {Enter} 
   Sleep 3000
   SetKeyDelay 50
   Send {Tab 28}{Enter}
   Sleep 3000
   Send {Enter}
   Sleep 3000
   Send !{F4}

SETUPFSLIBRARY_EXIT:
   LogFunctionEnd()
   return
}



FolderShare_RemoveOldMachines(nNumGoodMachines, nNumOldMachines)
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 100

   loop, %nNumOldMachines%
   {
      Send ^fDevices{Tab 2}
      Send {Tab %nNumGoodMachines%} 
      Send {Enter}
      Sleep 2000
      Send ^fRemove this computer
      Send {Esc}
      Send {Enter 2}
      Sleep 2000 
   }

REMOVEOLDMACHINES_EXIT:
   LogFunctionEnd()
   return
}