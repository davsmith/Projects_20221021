;
; GSAK.ahk
;
; Various macros for use with the geocaching program GSAK (Geocaching Swiss Army Knife).
;
; Notes:
; --------------------------------------------------------------------------------------------
; 5/1/09:
; - Created from the AHK template
;
; 7/26/09:
; Steps done manually (candidates for future automation)
;   Determine which drive holds the SD card, and make sure it matches the GenPOI macro
;   Create folder under $FolderShare/GPS for new location
;   Load "D:\FolderShare\Home\GPS\_Macros\Locations.dat" into Locations

;
; #########################
;   Global Initialization
; #########################

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

GSAK_Startup()

#NoEnv
#include %A_ScriptDir%\Include\Debug.ahk
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\xpath.ahk
#include %A_ScriptDir%\FolderShare.ahk
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
#ifwinactive GSAK 7.

^!S::
   GSAK_Setup()
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

::_GSACT::
   WinActivate ahk_group grpGSAK
   WinGetClass, class, A
   MsgBox, The active window's class is "%class%".
   clipboard := class
return


::_GSAK::
   GSAK_Setup()
return

; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############

::_GLoc::
   GSAK_AddLocationFromGlobals()
return

GSAK_AddLocationFromGlobals()
{
   ; Creates a string formatted to be a GSAK location, and puts it on the clipboard.
   ; The string is then pasted, and the <Name> field selected for typeover.
   ;
   ; Assumes that the coordinates for the location have already been captured from Live maps.
   ; (See GPS_ExtractLatLong)
   ;
   LogFunctionStart("AddLocationFromGlobals")

   global gnLatitude
   global gnLongitude

   clipboard := "<Name>," . gnLatitude . "," . gnLongitude
   Send ^V
   Send {Home}
   Send +{Right 6}

GSAK_ADDLOCATIONFROMGLOBALS_EXIT:
   LogFunctionEnd()
   return
}




GSAK_Startup()
{
   global gGSAKMainHandle

;   MsgBox GSAK Startup.  
   WinGet gGSAKMainHandle, ID, GSAK 7  
   GroupAdd, grpGSAK, ahk_id %gGSAKMainHandle%
   return
}



GSAK_Setup()
{
   LogFunctionStart("GSAK_Setup")

   bActive := SYSTEM_MakeActive("GSAK")            ; Activate the GSAK Window
   if (bActive)
   {
      GSAK_Register()                              ; Enter the registration key
      GSAK_LaunchOptionsDialog()
      sleep 500
      ControlClick, TRadioButton7, Options         ; Set the distance units to "Miles"
      ControlClick, TRadioButton6, Options         ; Set the Owner ID method to "Exact Match"
      ControlSetText TEdit11, Dave_n_Ang, Options  ; Set the username for owner ID to Dave and Ang
      ControlClick, TBitBtn3, Options              ; Click the OK button. 

      ; Define the path and name for txt file which contains Location info
      strDir := FolderShare_GetFolderShareDir()
      strLocPath = %strDir%Home\GPS\_Macros\Locations.dat

      GSAK_SetLocations(strLocPath)                ; Set the info in the Locations tab to our file contents
   }
   else
   {
      msgBox Could not find GSAK
   }

GSAK_SETUP_EXIT:
   LogFunctionEnd()
   return
}



GSAK_LaunchOptionsDialog()
{
   LogFunctionStart("LaunchOptionsDialog")

   bRetVal := 0 

   bActive := SYSTEM_MakeActive("GSAK")
   if (bActive)
   {
      ifWinExist Options
      {
         ControlClick, TBitBtn2, Options   ; If the dialog is already open, cancel it.
      }

      Send !TO                             ; Send menu clicks to open dialog

      WinWaitActive, Options,, 5           ; Wait for the window to launch 
      if (ErrorLevel)  
      {
         MsgBox Timed Out waiting for Options dialog.
         goto GSAK_LAUNCHOPTIONS_EXIT
      }
      else
      {
         bRetVal := 1
      }

      sleep 1000
   }

GSAK_LAUNCHOPTIONS_EXIT:
   LogFunctionEnd()
   return %bRetVal% 
}



::_SL::
   strDir := FolderShare_GetFolderShareDir()
   strLocPath = %strDir%Home\GPS\_Macros\Locations.dat
   MsgBox %strLocPath%
   GSAK_SetLocations(strLocPath)
return

GSAK_SetLocations(strLocFile)
{
   LogFunctionStart("SetLocations")

   bRetVal = 0

   bActive := GSAK_LaunchOptionsDialog()
   if (bActive)
   {
      Log("Calling tab right twice") 
      sleep 1000 
      Control TabRight, 2, TOvcNotebook1, Options   ; Set "Locations" tab

      if (FileExist(strLocFile))
      {
         Log("Reading the file") 
         FileRead, strFull, %strLocFile%
         ControlSetText TMemo1,, Options 

         ;
         ; We can't detect when the control is ready, so we blast blanks into it until it responds.
         ;
         loop, 200
         {
            ControlGetText OutputVar, TMemo1, Options
            if (OutputVar <> "")
            {
               ControlSetText TMemo1,, Options 
            }
            else
            {
               break
            }      
         }

         ; Populate the edit control with the text from the file.
         ControlSetText TMemo1, %strFull%, Options 
         bRetVal := 1
      }
      else
      {
         strLog = Locations file does not exist. (%strLocFile%)
         Log(strLog)
      }

      Sleep 500
      ControlClick, TBitBtn3, Options   ; Click the OK button. 
   }

GSAK_SETLOCATIONS_EXIT:
   LogFunctionEnd()
   return %bRetVal%
}


::_GReg::
   GSAK_Register()
return

GSAK_Register()
{
   LogFunctionStart("GSAK_Register")

   bActive := SYSTEM_MakeActive("GSAK")
   if (bActive)
   {
      Send !HR{Enter}

      WinWaitActive, Enter Name and Serial,, 5        ; Wait for the window to launch 
      if (ErrorLevel)  
      {
         MsgBox Timed Out waiting for registration dialog.
         goto GSAK_REG_EXIT
      }

      Send Dave Smith{Tab}
      Send 183967973{enter}{enter}
   }

GSAK_REG_EXIT:
   LogFunctionEnd()
   return
}



SYSTEM_MakeActive(strTitle, strLaunchString="")
{
   LogFunctionStart("SYSTEM_MakeActive")

   SetTitleMatchMode, 2
   bActivated := 0

   strLog = Checking if window already exists.  Name = %strTitle%
   Log(strLog)
   IfWinExist %strTitle%
   {
      WinActivate %strTitle%
      bActivated := 1
   }
   else
   {
      Log("Window did not exist")
      if (strLaunchString <> "")
      {
         Log("Attempting to launch application")
         Send ^{esc}
         Send %strLaunchString%{Enter}
         WinWaitActive %strTitle%,,5
         if (ErrorLevel)  
         {
            MsgBox Timed Out waiting for %strLaunchString% to launch.
            goto SYSTEM_MakeActive_Exit
         }

         bActivated := 1
      }
   }

SYSTEM_MakeActive_Exit:
   LogFunctionEnd()
   return bActivated
}