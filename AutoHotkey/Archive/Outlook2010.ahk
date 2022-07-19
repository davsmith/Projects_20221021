;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

Outlook2010_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\Debug.ahk
#include %A_ScriptDir%\FolderShare.ahk


;
; *************
;  Scoped keys
; *************
;
; The hotkeys listed below are only active if the active window contains the text "Inbox" in the title.
; For example, these keys are not active in Notepad, but are active in Outlook.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;
;********************************************************************
#ifwinactive Inbox

^!R::
   LogInit()
   ClearCategories()
   SetupSeattleSmithsRules(true)
return


^!C::
   AssignCategoryToMessage()
return	


^!P::
   AssignPriorityToMessage()
return


;
; *************
;  Global keys
; *************
;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 

^!t::
   SetupSeattleSmithsProfile()
return


^!m::
   SetupMicrosoftProfile()
return


::_OS::
   ClearCategories()
   AddCategories(".Calls;.Errands;.Home;.Office;.Someday")
   SetupSeattleSmithsRules(true)
   LoadSeattleSmithsArchives()
return


^!;::
   _ControlSetText("RichEdit20WPT1", "Hello")
return



;****************
;   Functions 
;****************

Outlook2010_Startup()
{
   LogFunctionStart(A_ThisFunc)

   ; Declare global variables for settings
   global g_strPSTTemplate
   global g_strPSTFile
   global g_strOutlookVersion
   global g_strMSProfile
   global g_strHomeProfile

   ; Read global settings from the INI file
   g_strOutlookVersion := ReadFromSystemIni( "Outlook", "Version" )
   g_strPSTTemplate :=  ReadFromSystemIni( "Outlook", "PST_Template" )
   g_strPSTFile := ReadFromSystemIni( "Outlook", "PST_Destination" )
   g_strMSProfile := ReadFromSystemIni( "Outlook", "MicrosoftProfileName" )
   g_strHomeProfile := ReadFromSystemIni( "Outlook", "HomeProfileName" )

OUTLOOK2010_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


SetupSeattleSmithsProfile(strProfileName="")
{
   LogFunctionStart(A_ThisFunc)

   ; Declare global variables for settings
   global g_strPSTTemplate
   global g_strPSTFile
   global g_strOutlookVersion
   global g_strHomeProfile

   ; Get the profile name.  Give the name in the INI higher priority.
   if (g_strHomeProfile <> "ERROR")
   {
      strProfileName := g_strHomeProfile
   }

   if (strProfileName = "")
   {
      LogError("No profile name was specified.")
   }

   ; Copy over the empty PST template
   FileCopy, %g_strPSTTemplate%, %g_strPSTFile%, 1

   ; Create a profile to which mail accounts will be added later.
   CreateEmptyProfile(strProfileName, true)

   found_it := SelectProfile(strProfileName)
   if (not found_it)
   {
      LogError("Failed to create profile " . strProfileName . ".  Exiting.")
      goto SETUPSEATTLESMITHSPROFILE_EXIT
   }

   ; Add accounts to the profile
   AddAccountToProfile(strProfileName, "Dave",     "POP_GODADDY_PRIMARY", "Dave Smith", "seattlesmiths.com", "", g_strPSTFile)
;   AddAccountToProfile(strProfileName, "Rentals",  "POP_GODADDY_PRIMARY", "Dave Smith", "seattlesmiths.com", "", g_strPSTFile)
;   AddAccountToProfile(strProfileName, "Koolikai", "POP_GODADDY_PRIMARY", "Dave Smith", "seattlesmiths.com", "", g_strPSTFile)
   AddAccountToProfile(strProfileName, "Generic",  "POP_GODADDY_PRIMARY", "Nobody",     "seattlesmiths.com", "", g_strPSTFile)
;   AddAccountToProfile(strProfileName, "9602",     "POP_GODADDY_NOREPLY", "Dave Smith", "seattlesmiths.com", "Dave")
;   AddAccountToProfile(strProfileName, "7231",     "POP_GODADDY_NOREPLY", "Dave Smith", "seattlesmiths.com", "Dave")
;   AddAccountToProfile(strProfileName, "Mortgage", "POP_GODADDY_NOREPLY", "Dave Smith", "seattlesmiths.com", "Dave")
   
SETUPSEATTLESMITHSPROFILE_EXIT:
   LogFunctionEnd()
}


SetupMicrosoftProfile(strProfileName="")
{
   LogFunctionStart(A_ThisFunc)

   ; Declare global variables for settings
   global g_strOutlookVersion
   global g_strMSProfile


   ; Get the profile name.  Give the name in the INI higher priority.
   if (g_strMSProfile <> "ERROR")
   {
      strProfileName := g_strMSProfile
   }

   if (strProfileName = "")
   {
      LogError("No profile name was specified.")
   }

   ; Create a profile to which mail accounts will be added later.
   CreateEmptyProfile(strProfileName, true)
   found_it := SelectProfile(strProfileName)
   if (not found_it)
   {
      LogError("Failed to create profile " . strProfileName . ".  Exiting.")
      goto SETUPMICROSOFTPROFILE_EXIT
   }

   ; Add accounts to the profile
   AddAccountToProfile(strProfileName, "davsmith", "EXCHANGE" )
   
SETUPMICROSOFTPROFILE_EXIT:
   LogFunctionEnd()
}


AddAccountToProfile(strProfileName, strAccount, strType, strDisplayName="", strDomain="", strProxy="", strPSTFile="")
{
   LogFunctionStart(A_ThisFunc)

   global g_strSec1
   global g_strNonSec1
   global g_strMSUser

   Log( "Args: " . strProfileName . ", " . strAccount . ", " . strType . ", " . strDisplayName . ", " . strDomain . ", " . strPSTFile)

   SetKeyDelay 25  
   
   ;
   ; Make sure the profile exists to which we're adding the account
   ;
   found_it := OpenProfile(strProfileName)
   if (not found_it)
   {
      LogError("Could not find profile " . strProfileName . ".  Exiting.")
      goto ADDACCOUNTTOPROFILE_EXIT
   }

   ;
   ; The profile exists, send navigation keys to get us to the new account wizard
   Log( "Opened profile " . strProfileName . ".")

   WaitForWindow("Account Settings", "AcctMgr Tab", 3, true)
   _Send( "!N" ) 

   WaitForWindow("Add New Account", "Add New E-mail Account", 1, true)

   Log("Navigate 'choose the account type (Internet, Exchange, Other...)' page")
   _Send( "!N" )      ; If this is the first e-mail account for the profile, this does nothing.
   _Send( "!M" )
   _Send( "!N" )

   StringUpper, strTypeUpper, strType

   if (strTypeUpper = "EXCHANGE")
   {
      Log("EXCHANGE: Display: " . strDisplayName . " Email:" . strEmailName)
  
      strServer = outlook.wingroup.windeploy.ntdev.microsoft.com
      strProxy  = windows.mail.microsoft.com
      strPrinName = msstd:windows.mail.microsoft.com
      strUser = %strAccount%

      _Send("!M!N")                                                   ; MS Exchange settings page

      WaitForWindow("Add New Account", "Add New E-mail Account", 1, true)

      _ControlSetText( "RichEdit20WPT1", strServer )                  ; Exchange server name
      _ControlSetText( "RichEdit20WPT2", strUser )                    ; MS user account
      _Send( "!M" )                                                         ; Move on to More Settings

      ; BUGBUG: Seems like a hack
;      WinWait Microsoft Office Outlook,The action cannot be completed,3
;      if (ErrorLevel = 0)
;      {
;         Send {Enter 2}
;      }

      _Send( "+{Tab}" )                                               ; Move to the Connection tab
      _Send( "{Right 3}" )
      _Send( "!T" )                                                   ; Set checkbox for HTTTP
 
      _Send( "!E" )                                                   ; Launch proxy settings page
      WaitForWindow("Microsoft Exchange Proxy Settings", 1, true)

      _ControlSetText( "Edit1", strProxy, strTitle )                  ; Proxy server
      _Send( "!P" )                                                   ; Set checkbox for principal name
      _ControlSetText( "Edit2", "msstd:" . strProxy, strTitle )       ; Proxy server
      _Send( "{Enter 2}" )                                            ; Back to server/username page

      ; Store the ID of the window so we can select it again when the e-mail is expanded
      id := WinExist("A")

      ; Validate the e-mail name... note this will generate a password prompt
      _Send( "!K" )  

      ; Wait for the password prompt
      if (g_strSec1 <> "")
      {
         WinWait Connect to,, 30
         if (ErrorLevel <> 0)
         {
            Log("*** Timed out waiting for authentication dialog") 
         }
         else
         {
            strTitle = Connect to
            ControlSetText, Edit2, %g_strMSUser%, %strTitle%
            ControlSetText, Edit3, %g_strSec1%, %strTitle%
            sleep 200
            ControlClick, Button3, %strTitle%
         }
      } 

      ; Loop until the e-mail name is resolved
      Loop, 120
      {
         sleep 1000
         ControlGetText, control_text_current, RichEdit20WPT2, Add New
         if (control_text_current <> control_text_start)
         {
             Log( "Broke out.  Current=" . control_text_current . "  Start=" . control_text_start )
             break
         }
      } 

      ; Activate the window in which the email name has been validated
      WinActivate, ahk_id %id%
      if (ErrorLevel > 0)
      {
         HardMessage("Couldn't activate the 'Add New Account' dialog")
      }

      _Send( "!N" )                                 ; Click the Next button to indicate we're done
       
      ; Wait around for dialog informing us that our delivery location has changed, then click OK.
      WaitForWindow("Mail Delivery Location", 5, true)
      _Send( "{Enter}" )

      _Send( "{Enter}!C!C" )
  } 
  else if (strTypeUpper = "POP_GODADDY_PRIMARY") 
  {
      Log("POP3 Primary: Display:" . strDisplayName . " Email: " . strEmailName)

      WaitForWindow("Add New Account", "", 3, true, "Couldn't find window to add new account")
      _Send( "!I" )
      _Send( "!N" )                                                   ; Internet Email settings page

      WaitForWindow("Add New Account", "E-mail Accounts", 3, true, "Couldn't find window to set account info")
      Log("Found New Account Window")
      ControlSetText RichEdit20WPT1, %strDisplayName%           ; Response name (Friendly)
      ControlSetText RichEdit20WPT2, %strAccount%@%strDomain%   ; Response email
      ControlSend    REComboBox20W1, P                          ; Account type
      ControlSetText RichEdit20WPT3, pop.secureserver.net       ; GoDaddy POP server
      ControlSetText RichEdit20WPT4, smtpout.secureserver.net   ; GoDaddy SMTP server
      ControlSetText RichEdit20WPT6, %strAccount%@%strDomain%   ; User info for logon
      ControlSetText RichEdit20WPT7, %g_strNonSec1%             ; 
      Control Uncheck,, Button4                                 ; Don't try to test the account 
      _Send( "!X" )                                             ; Use an existing PST file
      ControlSetText RichEdit20WPT8, %strPSTFile%               ; Provide the path to the PST copied earlier
      _Send( "!M" )                                             ; Move on to the next page

      WaitForWindow("Internet E-mail Settings", "General", 3, true)
      Click 105,47                          ; Click on the Outgoing Server tab
      Control Check,, Button1, A            ; Set checkbox that SMTP requires authentication
      Click 247, 48                         ; Move to the Advanced tab
      Control Check,, Button3, A            ; Leave messages on the server 
      Control Uncheck,, Button4, A          ; Don't delete after timeframe 
      _Send( "{Enter}" )                    ; Click OK to dismiss the dialog

      WaitForWindow("Add New Account")
      _Send( "!N" )                         ; Click the "Next" button

      WaitForWindow("Add New Account", "Congratulations!", 3, true)
      _Send( "{Enter}" )                    ; Click the "Finish" button

      WaitForWindow("Account Settings")
      _Send( "!C" )                         ; Click the "Close" Button

      WaitForWindow("Mail")
      _Send( "!C" )                         ; Click the "Close" Button
  } 
  else if (strTypeUpper = "POP_GODADDY_NOREPLY") 
  {
      strLogString = POP3 No Reply: Display:%strDisplayName% Email:%strEmailName%
      Log(strLogString)

      _Send( "!I!N" )                                                       ; Internet Email settings page

      WaitForWindow("Add New", "", 3, true )
      ControlSetText RichEdit20WPT1, %strDisplayName%                       ; Response name (Friendly)
      ControlSetText RichEdit20WPT2, %strAccount%@%strDomain%               ; Response email
      ControlSend REComboBox20W1, P, Add New E-mail                         ; Account type
      ControlSetText RichEdit20WPT3, _                                      ; Bogus (outgoing only)
      ControlSetText RichEdit20WPT4, smtpout.secureserver.net               ; GoDaddy SMTP server
      ControlSetText RichEdit20WPT6, %strProxy%@%strDomain%                 ; User info for logon
      ControlSetText RichEdit20WPT7, %g_strNonSec1%                         ; 
      Control Uncheck,, Button4, A                                          ; Don't try to test the account 

      _Send( "!M" )                                                         ; More Settings page

      WaitForWindow("Internet E-mail Settings", "", 3, true )
      ControlSetText RichEdit20WPT1, %strAccount% (Outgoing only)           ; Account friendly name

      _Send( "+{Tab}" )                              ; Move on to the Outgoing Server tab
      _Send( "{Right 1}" )                           ;
      _Send( "!O" )                                  ; Set the checkbox that SMTP requires authentication
      _Send( "{Up}" )                                ; Move to the Advanced tab
      _Send( "{Right 2}" )                           ; 
      _Send( "!O80" )                                ; Set port info
      _Send( "!L" )                                  ; Leave messages on server 
      _Send( "!I+{Tab}" )                            ; Close us back to the profiles dialog
      _Send( "{Enter}!N{Enter}" )
      _Send( "!c!c" )   
  } 
  else
  {
      HardMessage( "Unrecognized account type: " . strTypeUpper ) 
  }

ADDACCOUNTTOPROFILE_EXIT:
  LogFunctionEnd()
}


OpenProfile(strProfileName)
{
   LogFunctionStart(A_ThisFunc)

   ; Open the Mail control panel applet
   win_id := LaunchMailCPLProfiles()
   Log( "Profile dialog window id = " . win_id)

   Log("Looking for profile '" . strProfileName . "'")

   found_it := SelectProfile(strProfileName)

   if (found_it)
   {
      Log("Found the profile")
      SetKeyDelay 100     
      _Send( "!R" )

      WaitForWindow("Mail Setup", "E-mail Accounts", 5, true)
      _Send( "!E" )

      if (not WaitForWindow("Account Settings", "", 5, false))
      {
         found_it := false
         goto OPENPROFILE_EXIT
      }
   }

OPENPROFILE_EXIT:
   LogFunctionEnd()
   return %found_it%
}


;
; Set up rules to redirect mail sent to particular aliases, to specified
; folders under the main Inbox folder.
;
; NOTE:  The calls which specify false, do not create a new subfolder, instead
;        relying on a previous call to create a subfolder.
;
SetupSeattleSmithsRules(bTemp)
{
   LogFunctionStart(A_ThisFunc)

   RedirectAliasToSubFolder("Scans@seattlesmiths.com","Scans", true)
   RedirectAliasToSubFolder("Shop@seattlesmiths.com","Shop", true)
   RedirectAliasToSubFolder("Rentals@seattlesmiths.com","Rentals", true)
   RedirectAliasToSubFolder("Rental@seattlesmiths.com","Rentals", false)
   RedirectAliasToSubFolder("7231@seattlesmiths.com","Rentals", false)
   RedirectAliasToSubFolder("9602@seattlesmiths.com","Rentals", false)
   RedirectAliasToSubFolder("Geocaching@seattlesmiths.com","Geocaching", true)
   RedirectAliasToSubFolder("Newsgroups@seattlesmiths.com","Newsgroups", true)
   RedirectAliasToSubFolder("Newsgroup@seattlesmiths.com","Newsgroups", false)
   RedirectAliasToSubFolder("WebAccounts@seattlesmiths.com","WebAccounts", true)
   RedirectAliasToSubFolder("Camping_Elitist@seattlesmiths.com","WebAccounts", false)
   RedirectAliasToSubFolder("noreply@SourceForge.net","WebAccounts", false)
   RedirectAliasToSubFolder("Mortgage@seattlesmiths.com","Mortgage", true)
   RedirectAliasToSubFolder("Notifications@seattlesmiths.com","Notifications", true)
   RedirectAliasToSubFolder("Services@seattlesmiths.com","Services", true)
   RedirectAliasToSubFolder("Koolikai@seattlesmiths.com","Koolikai", true)
   RedirectAliasToSubFolder("KoolikaiProperties@seattlesmiths.com","Koolikai", false)
   RedirectAliasToSubFolder("Koolikai_Notifications@seattlesmiths.com","Koolikai", false)
   RedirectAliasToSubFolder("Koolikai_Shop@seattlesmiths.com","Koolikai", false)

   LogFunctionEnd()
   return
}

;
;
;
LoadSeattleSmithsArchives()
{
   LogFunctionStart(A_ThisFunc)

   nRetVal   = 1
   nEndYear  = 2011
   nYear     = 2005                                   ; Start looking in 2005

   strFSPath := FolderShare_GetFolderShareDir()

   loop                                               ; Loop through the years looking for archive files
   {
      Log( "Checking year " . nYear ) 

      if (nYear > nEndYear)                           ; Break out if we're beyond the end year
      {
         break
      }

      ; Look for the archive PST in the FolderShare dir
      strPST = %strFSPath%Mail\SeattleSmiths %nYear%.pst  
 
      AddPSTFile(strPST)
      nYear++
   }

   LogFunctionEnd()
   return %nRetVal%
}


AddPSTFile(strPSTFile)
{
   LogFunctionStart(A_ThisFunc)

   strOutlookTitle = Microsoft Outlook

   nRetVal = 1
   IfExist %strPSTFile%                         ; Check if the PST file exists
   {
      Log( "Found file " . strPST ) 

      WinActivate %strOutlookTitle%
      WaitForWindow( %strOutlookTitle%, "", 5 )

      Log("Found Outlook window")
      _Send( "!TA{Right}" )                     ; Launch wizard to add data file to account
      _Send( "!A{Enter}" )                      ; Go to the file chooser

      WaitForWindow( "Create or Open", "", 5 )
      _Send( %strPSTFile% . "{Enter}{Enter}" )  ; Attempt to load the PST file, accepting default naming
      _Send( "!C" )                             ; Close out the dialog
   }
   else
   {
      strLog = *** Did not find file %strPSTFile%
      LogError( "Did not find file " . strPSTFile ) 
   }

 ADDPST_EXIT:
   LogFunctionEnd()
   return
}


;
; Deletes all of the existing categories in the Master Category list.
;
ClearCategories()
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 100

   WinActivate Microsoft Outlook
   WinWaitActive Microsoft Outlook,,5                  ; Get to the Outlook window

   if (ErrorLevel > 0)
   {
      Log("*** Couldn't find the Outlook window")
      nRetVal = 0
      goto CLEARCATEGORIES_EXIT
   }

   Log("Found the Outlook window")
   Send ^+I                                            ; Make sure we're in the Inbox, so Categories light up
   Send !AIC                                           ; Clear categories off the existing item.
   Send !AIA                                           ; Launch the "All Categories" dialog

   WinWaitActive Color Categories,,5
   if (ErrorLevel > 0)
   {
      Log("*** Couldn't get to the categories dialog")
      nRetVal = 0
      goto CLEARCATEGORIES_EXIT
   }

   ; Log the existing list of categories for posterity.
   ControlGet, strCategories, List, , SysListView321, Color Categories 
   Log(strCategories)

   ; Count the number of existing categories, so we know how many to delete
   SendMessage 0x1004, 0, 0, SysListView321, Color Categories
   nNumEntries = %ErrorLevel%
   strLog = Deleting %nNumEntries% categories
   Log(strLog)

   ; Delete the existing categories, one at a time
   Loop %nNumEntries%
   {
      Send !DY
   }

   Log("Done deleting categories")
   Send {Enter}                                       ; Dismiss the categories dialog

CLEARCATEGORIES_EXIT:
   LogFunctionEnd()
   return
}



AddCategories(strCatList)
{
   LogFunctionStart(A_ThisFunc)

   WinActivate Microsoft Outlook
   WinWaitActive Microsoft Outlook,,5
   if (ErrorLevel > 0)
   {
      Log("*** Couldn't find the Outlook window")
      nRetVal = 0
      goto ADDCATEGORIES_EXIT
   }

   Log("Found the Outlook window.")
   Send ^+I                                          ; Make sure we're in the Inbox
   Send !AIA                                         ; Launch the Categories dialog

   WinWaitActive Color Categories,,5                 ; Wait for the categories dialog to launch
   if (ErrorLevel > 0)
   {
      Log("*** Couldn't launch the Categories dialog")
      nRetVal = 0
      goto ADDCATEGORIES_EXIT
   }

   StringSplit, strCategoryArray, strCatList, `;     ; Split the list of categories into an array
   nNumCategories = %strCategoryArray0%              ; Store the number of categories


   strLog = %nNumCategories% categories to add
   Log(strLog) 

   nIndex = 1
   Loop %nNumCategories%
   {
      strCategory := strCategoryArray%nIndex%        ; Get the next category name from the array
      strLog = Adding category %strCategory%
      Log(strLog)
      Send !N                                        ; Create a new category
      Send %strCategory%{Enter}
      nIndex++
   }

   Send {Enter}                                      ; Dismiss the categories dialog
   Send !AIC                                         ; Clear all categories off the selected item

ADDCATEGORIES_EXIT:
   LogFunctionEnd()
   return
}



LaunchMailCPLProfiles()
{
   LogFunctionStart(A_ThisFunc)

   strEmailAccountDialogName = Mail
   strEmailAccountText = E-mail Accounts
   strProfileDialogName = Mail
   strProfileDialogText = Microsoft Outlook Profiles

   wid = 0

   ;
   ; If the profile dialog isn't launched, then launch it.
   ;
   IfWinNotExist %strProfileDialogName%, %strProfileDialogText%
   {
      ; Run the control panel applet for mail configuration.
      ; The path is different for different versions of Office.
      strCPLPath := a_programfiles . "\Microsoft Office\Office14\mlcfg32.cpl"
      if (not FileExist(strCPLPath))
      { 
         strCPLPath := a_programfiles . "\Microsoft Office\Office12\mlcfg32.cpl"
      }

      if (not FileExist(strCPLPath))
      {
         Log("Error: Office not installed.")
         goto LAUNCH_PROFILES_END
      }

      run %strCPLPath%
      WinActivate %strEmailAccountDialogName%, %strEmailAccountDialogText%

      WinWaitActive %strEmailAccountDialogName%, %strEmailAccountDialogText%, 3
      if (ErrorLevel)
      {
         HardMessage("Profile dialog didn't launch.  Terminating.")   
      }

      Send !S           ; Launch the profiles dialog

      WinWaitActive %strProfileDialogName%, %strProfileDialogText%, 3
      if (ErrorLevel)
      {
         HardMessage("Profile dialog didn't launch.  Terminating.")   
      }
   }

   ; If the profile dialog is open, return its HWND
   IfWinExist, %strProfileDialogName%, %strProfileDialogText%
   {
      WinGet wid, ID, %strProfileDialogName%, %strProfileDialogText%
      Log("Found profiles dialog (ID=" . wid . ")", 9)
      goto LAUNCH_PROFILES_END
   }

LAUNCH_PROFILES_END:
   LogFunctionEnd()
   return %wid%
}


;
; Sets the default profile to use when Outlook is launched.
; If the parameter is set to "Choose" then the radio button is set
; to prompt the user for a profile each time.
;
;
SetDefaultProfile(win_id=0, strProfileName="CHOOSE")
{
   LogFunctionStart(A_ThisFunc)

   if (win_id = 0)
     win_id := LaunchMailCPLProfiles()

   StringUpper, strProfileUpper, strProfileName

   if (strProfileUpper = "CHOOSE")
   {
      Send !P
   }
   else
   {
      ControlGet, item_list, FindString, %strProfileName%, ComboBox1, ahk_id %win_id%
      if (ErrorLevel > 0) 
      {
         MsgBox, Could not find the profile %strProfileName%
         retval := 0
      }
      else
      {
         MsgBox, Found the profile %strProfileName%.  It is in row %item_list%.
         Send !U{Tab}%strProfileName%
         retval := 1
      }
   }       
}



SelectProfile(strProfileName)
{
   LogFunctionStart(A_ThisFunc)

   ; Open the mail control panel applet
   id := LaunchMailCPLProfiles()

   if (id = 0)
   {
      Log("Couldn't launch the Mail Profile control panel applet.  Exiting.")
      goto SELECTPROFILE_EXIT      
   }

   ControlGet, item_list, FindString, %strProfileName%, ListBox1, ahk_id %id%
   if (ErrorLevel > 0) 
   {
      Log("*** Could not find the profile " . strProfileName . " ***")
      retval := 0
   }
   else
   {
      Log("Found the profile " . strProfileName . ".  It is in row " . item_list )

      Send !O%strProfileName%
      retval := 1
   }    

SELECTPROFILE_EXIT:
   LogFunctionEnd()
   return %retval%
}


CreateEmptyProfile(strProfileName, bPurgeExisting=false)
{
   LogFunctionStart(A_ThisFunc)

   bRetVal = false

   SetKeyDelay 100 


   ; Open the mail control panel applet
   window_id := LaunchMailCPLProfiles()

   if (window_id = 0)
   {
      Log("Couldn't launch the Mail Profile control panel applet.  Exiting.")
      goto CREATEEMPTYPROFILE_EXIT      
   }

   if (bPurgeExisting)
   {
      found_it := DeleteProfile(window_id, strProfileName)
   }

   Send !d                                          ; Add a profile

   WaitForWindow("New Profile", "", 5)
   ControlSetText RichEdit20WPT1, %strProfileName%  ; Profile name
   Send {Enter}                                     ; Click OK

   ;
   ; NOTE: There appears to be a bug that deleting and recreating a profile
   ; too quickly causes an error.
   ;
   ; If we see this error dialog, we sleep for 30 seconds
   IfWinActive, Microsoft Office Outlook, The profile name
   {
      MsgBox, Profile name error.  Sleeping for 30s
      Sleep, 30000
   }

   WaitForWindow("Add New Account", "", 5, true)
   Send {Enter} ; Click Cancel so we don't have to enter an email account

   WaitForWindow("Microsoft Outlook", "", 5, true)
   Send {Enter} ; Click Cancel so we don't have to enter an email account

CREATEEMPTYPROFILE_EXIT:
   LogFunctionEnd()
   return
}


DeleteProfile(win_id, strProfileName)
{
   LogFunctionStart(A_ThisFunc)

   strLog = Params: %win_id%, %strProfileName% 
   Log(strLog)

   retval = 0
   WinActivate ahk_id %win_id%
   SetKeyDelay 100  
   found_it := SelectProfile(strProfileName)
   if (found_it = true)
   {
      Log("Profile " . strProfileName . " was found.  Deleting it.")
      Send !EY                                 ; Remove the profile
      retval = 1
   }
 
   LogFunctionEnd()
   return %retval%
}


SetupPopAccount(strAlias, strUserName, strPassword, bSendOnly)
{
   LogFunctionStart(A_ThisFunc)

   strPassword = xxxxxxxx
   if %bSendOnly%
   {
      strPOP = _
   }
   else
   {
      strPOP = pop.secureserver.net
   }
 
   SetKeyDelay 50
   Send !TA!N!N!M!N!N
   Send Dave Smith{Tab}
   Send %strAlias%@seattlesmiths.com{Tab 2}
   Send %strPOP%{Tab}
   Send smtpout.secureserver.net{Tab}
   Send %strUserName%@seattlesmiths.com{Tab}
   Send %strPassword%
   Send !M+{Tab}{Right}!O+{Tab}{Right 2}!L!M{Tab}{Enter}!N{Enter}

   return
}


;***********************************************
CreateSubFolder(strUnder, strFolder)
;
; Creates a folder under the specified folder
;
;***********************************************
;
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 50
   retval = 1
   
   Log("Launch the Create New Folder Dialog")
   Send ^+E                           ; Launch the "Create New Folder" dialog  
   WinWaitActive Create New Folder,,5
   if (ErrorLevel > 0)
   {
      Log("*** Couldn't launch Create New Folder dialog")
      nRetVal = 0
      goto CREATE_SUB_FOLDER_EXIT
   }

   Log("Select the folder picker control")
   Send !S                            ; Select the folder picker control 
   Send %strUnder%                    ; Browse to the folder under which we're creating a new folder 
   Send !N                            ; Go back to the edit box to enter the new subfolder name  
   Send %strFolder%{Enter}

   ; If this subfolder name already exists, fail gracefully
   WinWait, Microsoft Office Outlook, A folder with this name already exists, 1
   if (ErrorLevel = 0)
   {
      strLog = *** Sub folder %strFolder% already exists under %strUnder%.
      Log(strLog)

      Pause 
      Send {Enter}{Escape}             ; Dismiss the error dialog and exit the folder picker
      retval = 0
   }

CREATE_SUB_FOLDER_EXIT:
   LogFunctionEnd()
   return %retval%
}



;************************************************************************************
CreateRuleToAlias(strAlias, strSubFolder="", strCategory="", strFolder="Inbox")
;************************************************************************************
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 50   
   Send !TL                            ; Launch the Rules and Alerts dialog
   Send !N                             ; Launch "New Rule" wizard  
   Send C                              ; Check messages when they arrive (start from blank rule)
   Send !N                             ; Advance to the next page (Select Conditions)
   Send {Down 11}                      ; Sent to people or distribution list
   Send {Space}
   Send !D                             ; Activate the control to edit the rule description
   Send {Space}                        ; Edit the "people or distribution list"
   Send {Tab 2}
   Send %strAlias%{Enter}              ; Enter the alias name which we want to redirect
   Send !N                             ; Move on to the "Actions" page
   Send {Space}                        ; Choose to move the message to the specified folder
   Send !D
   Send {Down}                         ; Activate the link for the folder picker
   Send {Space}
   Send {left 4}                       ; Collapse the folder tree to the root (Personal Folders)
   Send {right}                        ; Expand to the first level
   Send %strFolder%                    ; Expand the folder node under which we'll move the msg
   Send {right}
   Send %strSubFolder%{Enter}          ; Select the specified subfolder
   if (strCategory <> "")
   {
      Log("Making category assignment")
      Send !C                          ; Select the control with the actions
      Send {Down}
      Send {Space}   
      Send !D{Down}{Space}             ; Choose the category assignment link
      Send %strCategory%{Space}        ; Assign the category
      Send {Enter}                     ; Dismiss the dialog
   }

   Send !N!N{Enter}{Enter}             ; Finish the wizard

   LogFunctionEnd()
   return
}

;
; Creates a subfolder beneath the "Inbox" folder, then creates a rule
; to redirect to the folder any mail sent to the specified alias
;
RedirectAliasToSubFolder(strAlias, strSubFolder, bCreateSubFolder=true)
{
   LogFunctionStart(A_ThisFunc)

   if (bCreateSubFolder)
   {
      CreateSubFolder("Inbox", strSubFolder)

      strCategory = x%strSubFolder%
      AddCategories(strCategory)
   }

   strCategory = x%strSubFolder%
   CreateRuleToAlias(strAlias, strSubFolder, strCategory)

   LogFunctionEnd()
   return
}


ChangeStorageLocation(strProfileName, strAccount, strType="Folder", strDestination="Bulk")
{
   global g_strSec1
   global g_strNonSec1
   global g_strMSUser

   LogFunctionStart(A_ThisFunc)
   strString = %strProfileName%`,%strAccount%`,%strType%`,%strDestination% 
   Log(strString)
   
   found_it := OpenProfile(strProfileName)                     ; Open the specified profile
   if (not found_it)
   {
      MsgBox, Could not find profile %strProfileName%
      goto CHANGE_STORAGE_EXIT
   }

   Send +{Tab 5}                                               ; Make sure the list of accounts is active
   Send %strAccount%                                           ; Choose the specified account
   Send !f                                                     ; Change the delivery location

   WinWaitActive New E-mail Delivery Location,,5 
   if (ErrorLevel > 0)
   {
      Log("*** Couldn't launch Delivery location dialog")
      nRetVal = 0
      goto CHANGE_STORAGE_EXIT
   }

   Send Personal Folders                                       ; Create the folder at the root (a peer to inbox) 

   Send !F
   WinWaitActive Create Folder,,5                              
   if (ErrorLevel > 0)
   {
      Log("*** Couldn't launch New Folder dialog")
      nRetVal = 0
      goto CHANGE_STORAGE_EXIT
   }

   Send %strDestination%{Enter}           ; Name the folder according to the function arg
   Send {Enter}                           ; Commit the changes

   Send {esc 4}                           ; Dismiss all of the open dialogs

CHANGE_STORAGE_EXIT:
   LogFunctionEnd()
   return
}


;
; Adds a category to the currently selected message
; Use Ctrl-Alt-C, then type the hotkey for the category
; ? Shows the list
;	
AssignCategoryToMessage()
{
   LogFunctionStart(A_ThisFunc)

   Input, strSingleKey, L1
   StringUpper, strTypeUpper, strSingleKey
   strHelp = W:`tWork/Office`rE:`tErrands`rC:`tCalls`rH:`tHome`rC:`tList

   if (strTypeUpper = "?")
     MsgBox %strHelp%
   else if if (strTypeUpper = "W")
   {
     Send !EIA.Office{Space}{Enter} 
   }
   else if (strTypeUpper = "E")
   {
     Send !EIA.Errands{Space}{Enter}
   }
   else if (strTypeUpper = "C")
   {
     Send !EIA.Call{Space}{Enter}
   }
   else if (strTypeUpper = "H")
   {
     Send !EIA.Home{Space}{Enter}
   }
   else if (strTypeUpper = "L")
   {
     Send !EIA.List{Space}{Enter}
   }

   return
}


;
; Sets the priority on the currently selected message
; Use Ctrl-Alt-P, then type the hotkey for the category (H, N, L)
;	
AssignPriorityToMessage()
{
   LogFunctionStart(A_ThisFunc)

   Input, strSingleKey, L1
   StringUpper, strTypeUpper, strSingleKey
  	
   if (strTypeUpper = "H")
   {
     Send {ENTER}!PH!HAV
   }
   else if (strTypeUpper = "N")
   {
     Send {ENTER}!PN!HAV
   }
   else if (strTypeUpper = "L")
   {
     Send {ENTER}!PL!HAV
   }
}
