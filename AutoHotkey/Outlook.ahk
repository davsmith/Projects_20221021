;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2


#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\Debug.ahk
#include %A_ScriptDir%\FolderShare.ahk



;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;


;******************************************** Custom **********************************************

;********************************************************************

; *************
; Scoped keys
; *************


;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;
	

;********************************************************************
SetTitleMatchMode, 2
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



; *************
; Global keys
; *************


;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************


::_OS::
   ClearCategories()
   AddCategories(".Calls;.Errands;.Home;.Office;.Someday")
   SetupSeattleSmithsRules(true)
   LoadSeattleSmithsArchives()
return



; 
; Set up Outlook mail profiles for Microsoft and SeattleSmiths mail.
; The Exchange mail profiles also does some hard coded set up to configure the account
; to work with Microsoft's mail server, and HTTP over RPC
;
; See also SetupSeattleSmithsRules function to set up rules to redirect mail to subfolders.
;
^!s::
   LogInit()
   LogFunctionStart("Alt S")
goto SEATTLE_SMITHS 
   ; Open the mail control panel applet
   window_id := LaunchMailCPLProfiles()
   Log("Launched CPL")

   ; If the profiles we're going to add already exist, delete them.
   found_it := DeleteProfile(window_id, "Microsoft")
   found_it := DeleteProfile(window_id, "SeattleSmiths")
   Log("Deleted profiles")

   ; Add empty profiles, and set the radio button to Choose between profiles on starting Outlook
   strProfileName := "Microsoft"
   CreateEmptyProfile(window_id, strProfileName)
   found_it := SelectProfile(window_id, strProfileName)
   if (not found_it)
   {
      LogError("Failed to create profile " . strProfileName . ".  Exiting.")
      goto SETUP_EXIT
   }

   strProfileName := "SeattleSmiths"
   CreateEmptyProfile(window_id, strProfileName)
   found_it := SelectProfile(window_id, strProfileName)
   if (not found_it)
   {
      LogError("Failed to create profile " . strProfileName . ".  Exiting.")
      goto SETUP_EXIT
   }

   SetDefaultProfile(window_id, "CHOOSE")
   Log("Created profiles")

   ; Add the different accounts to the empty profiles
;   AddAccountToProfile("Microsoft","davsmith","EXCHANGE")
SEATTLE_SMITHS:
   AddAccountToProfile("SeattleSmiths","Dave","POP_GODADDY_PRIMARY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","Rentals","POP_GODADDY_PRIMARY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","Koolikai","POP_GODADDY_PRIMARY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","Generic","POP_GODADDY_PRIMARY","Nobody","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","9602","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave")
   AddAccountToProfile("SeattleSmiths","7231","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave")
   AddAccountToProfile("SeattleSmiths","Mortgage","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave")

   ; Close the control panel applet
   Send {Enter}

   ; Change the delivery location for junk mail
   ChangeStorageLocation("SeattleSmiths", "Generic@SeattleSmiths.com", "Folder", "Bulk")

SETUP_EXIT:
   LogFunctionEnd()
return



;****************
;   Functions 
;****************

^!T::
   SetupSeattleSmithsProfile()
return

SetupSeattleSmithsProfile()
{
   LogFunctionStart(A_ThisFunc)

   ; Open the mail control panel applet
   window_id := LaunchMailCPLProfiles()
   found_it := DeleteProfile(window_id, "SeattleSmiths")

   ; Create a profile to which mail accounts will be added later.
   strProfileName := "SeattleSmiths"
   CreateEmptyProfile(window_id, strProfileName)
   found_it := SelectProfile(window_id, strProfileName)
   if (not found_it)
   {
      LogError("Failed to create profile " . strProfileName . ".  Exiting.")
      goto SETUPSEATTLESMITHSPROFILE_EXIT
   }

   ; Add accounts to the profile
   AddAccountToProfile("SeattleSmiths","Dave","POP_GODADDY_PRIMARY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","Rentals","POP_GODADDY_PRIMARY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","Koolikai","POP_GODADDY_PRIMARY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","Generic","POP_GODADDY_PRIMARY","Nobody","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","9602","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave")
   AddAccountToProfile("SeattleSmiths","7231","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave")
   AddAccountToProfile("SeattleSmiths","Mortgage","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave")
   
SETUPSEATTLESMITHSPROFILE_EXIT:
   LogFunctionEnd()
}


SetupMicrosoftProfile()
{
   LogFunctionStart(A_ThisFunc)


SETUPMICROSOFTPROFILE_EXIT:
   LogFunctionEnd()
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
   nEndYear  = 2009
   nYear     = 2015                                   ; Start looking in 2005

   strFSPath := FolderShare_GetFolderShareDir()

   loop                                               ; Loop through the years looking for archive files
   {
      strLog = Checking year %nYear%
      Log(strLog) 

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

   nRetVal = 1
   IfExist %strPSTFile%                    ; Check if the PST file exists
   {
      strLog = Found file %strPST%
      Log(strLog) 

      WinActivate Microsoft Outlook
      WinWaitActive Microsoft Outlook,,5
      if (ErrorLevel > 0)
      {
         Log("*** Could not find Outlook window")
         nRetVal = 0
         goto ADDPST_EXIT
      }
      else
      {
         Log("Found Outlook window")
         Send !TA{Right}                  ; Launch wizard to add data file to account
         Send !A{Enter}                   ; Go to the file chooser
         WinWaitActive Create or Open,,5
         Send %strPSTFile%{Enter}{Enter}  ; Attempt to load the PST file, accepting default naming
         Send !C                          ; Close out the dialog
      }
   }
   else
   {
      strLog = *** Did not find file %strPSTFile%
      Log(strLog) 
      nRetVal = 0
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
   LogFunctionStart("AddCategories")

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


::_t::
   LaunchMailCPLProfiles()
T_EXIT:
return


LaunchMailCPLProfiles()
{
   LogFunctionStart("LaunchMailCPLProfiles")

   wid = 0

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

   ; Check if the config dialog is already launched, if not launch it.
   WinWait Mail,When starting, .25
   if (ErrorLevel > 0)
   {
      WinWait Mail Setup,Setup multiple profiles, 5
      if (ErrorLevel = 0)
      {
         Sleep 500 
         Log("Launching the profiles dialog")
         ControlClick Button3, Mail,,LEFT,2               ; Launch the "profiles" dialog
         Log("Clicked button")
      }
      else
      {
         Log("*** Could not launch the mail control panel applet. ")
         goto LAUNCH_PROFILES_END
      }
   }

   WinWait Mail,use this profile, 5
   if (ErrorLevel > 0)
   {
      Log("*** Timed out waiting for profile dialog")
      goto LAUNCH_PROFILES_END
   }

   WinGet wid, ID, Mail,use this profile        
   if (ErrorLevel > 0)
   {
      wid = 0
      Log("*** Couldn't get the ID for the profile dialog. ")
      goto LAUNCH_PROFILES_END
   }

   strLog = Window ID for profile dialog is: %wid%
   Log(strLog)

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



SelectProfile(win_id, strProfileName)
{
   LogFunctionStart("SelectProfile")

   strLog = params: %win_id%, %strProfileName%
   Log(strLog)

   ControlGet, item_list, FindString, %strProfileName%, ListBox1, ahk_id %win_id%
   if (ErrorLevel > 0) 
   {
      strLog = *** Could not find the profile %strProfileName%
      Log(strLog)
      retval := 0
   }
   else
   {
      strLog = Found the profile %strProfileName%.  It is in row %item_list%.
      Log(strLog)

      Send !O%strProfileName%
      retval := 1
   }    

   LogFunctionEnd()
   return %retval%
}



OpenProfile(strProfileName)
{
   LogFunctionStart("OpenProfile")

   ; Open the Mail control panel applet
   win_id := LaunchMailCPLProfiles()
   strLog = Profile dialog window id = %win_id%
   Log(strLog)

   strLog = Trying to find profile "%strProfileName%"
   Log(strLog)

   found_it := SelectProfile(win_id, strProfileName)

   if (found_it)
   {
      Log("Found the profile")
      SetKeyDelay 100     
      Send !R!E

      WinWait Account Settings,, 5
      if (ErrorLevel > 0)
      {
         Log("*** Timed out waiting for account settings dialog")
         found_it := false
         goto OPENPROFILE_EXIT
      }
   }

OPENPROFILE_EXIT:
   LogFunctionEnd()
   return %found_it%
}


AddAccountToProfile(strProfileName, strAccount, strType, strDisplayName="", strDomain="", strProxy="")
{
   LogFunctionEnd()
   global g_strSec1
   global g_strNonSec1
   global g_strMSUser

   LogFunctionStart(A_ThisFunc)

   Log( "Args: " . strProfileName . ", " . strAccount . ", " . strType . ", " . strDisplayName . ", " . strDomain )

   sleep,2000 
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
   ; The profile exists, send navigation keys to get us to 
   Log( "Opened profile " . strProfileName . ".")



  
   Log("Launching the new account wizard") 
   Send !N 

   WinWait Add New, configure server settings, .5 
   if (ErrorLevel <> 0)
   {
       LogWarning("Not on the Auto Account Setup page. Sending an extra enter should take us there...") 
       Send !N
   }

   Log("Navigate to next page where we'll choose the account type (Internet, Exchange, Other...)")
   Send !M!N

   Log("We should be on the Choose Email Service page")
   StringUpper, strTypeUpper, strType

   if (strTypeUpper = "EXCHANGE")
   {
      Log("EXCHANGE: Display: " . strDisplayName . " Email:" . strEmailName)
  
      strServer = outlook.wingroup.windeploy.ntdev.microsoft.com
      strProxy  = windows.mail.microsoft.com
      strPrinName = msstd:windows.mail.microsoft.com
      strUser = %strAccount%

      Send !M!N                                                       ; MS Exchange settings page
      strTitle = Add New E-mail
      ControlSetText RichEdit20WPT1, %strServer%, %strTitle%          ; Exchange server name
      ControlSetText RichEdit20WPT2, %strUser%, %strTitle%            ; MS user account

      Send !M                                                         ; Move on to More Settings

      ; BUGBUG: Seems like a hack
      WinWait Microsoft Office Outlook,The action cannot be completed,3
      if (ErrorLevel = 0)
      {
         Send {Enter 2}
      }

      Send +{Tab}                                                     ; Move to the Connection tab
      Send {Right 3}
      Send !T                                                         ; Set checkbox for HTTTP
 
      strTitle = Microsoft Exchange Proxy Settings
      Send !E                                                         ; Launch proxy settings page

      ControlSetText Edit1, %strProxy%, %strTitle%                    ; Proxy server
      Send !P                                                         ; Set checkbox for principal name
      ControlSetText Edit2, msstd:%strProxy%, %strTitle%              ; Proxy server
      Send {Enter 2}                                                  ; Back to server/username page

      ; Store the ID of the window so we can select it again when the e-mail is expanded
      id := WinExist("A")

      ; Validate the e-mail name... note this will generate a password prompt
      Send !K  

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
         ControlGetText, control_text_current,RichEdit20WPT2, Add New
         if (control_text_current <> control_text_start)
         {
             strLogText = Broke out.  Current=%control_text_current%  Start=%control_text_start%
             Log(strLogText)
             break
         }
      } 

      ; Activate the window in which the email name has been validated
      WinActivate, ahk_id %id%
      if (ErrorLevel > 0)
      {
         HardMessage("Couldn't activate the dialog")
      }

      Send !N                                 ; Click the Next button to indicate we're done
       
      ;
      ; Wait around for dialog informing us that our delivery location has changed, then click OK.
      ;
      WinGet, snap_id, ID, A
      loop, 5
      {
          WinGet, current_id, ID, A
          if (current_id <> snap_id)
          {
             break
          }
          sleep 500
      } 

      ;
      ; Dismiss the delivery location dialog, and close out the mail cpl applet
      ;
      WinGetTitle title, A
      if (title = "Mail Delivery Location")
      {
         Send {Enter}
      }

      Send {Enter}!C!C
  } 
  else if (strTypeUpper = "POP_GODADDY_PRIMARY") 
  {
      strLogString = POP3 Primary: Display:%strDisplayName% Email:%strEmailName%
      Log("POP3 Primary: Display:" . strDisplayName . " Email: " . strEmailName)

      strTitle = Add New
      Send !I!N                                                             ; Internet Email settings page
      ControlSetText RichEdit20WPT1, %strDisplayName%, %strTitle%           ; Response name (Friendly)
      ControlSetText RichEdit20WPT2, %strAccount%@%strDomain%, %strTitle%   ; Response email
      ControlSend REComboBox20W1, P, Add New E-mail                         ; Account type
      ControlSetText RichEdit20WPT3, pop.secureserver.net, %strTitle%       ; GoDaddy POP server
      ControlSetText RichEdit20WPT4, smtpout.secureserver.net, %strTitle%   ; GoDaddy SMTP server
      ControlSetText RichEdit20WPT6, %strAccount%@%strDomain%, %strTitle%   ; User info for logon
      ControlSetText RichEdit20WPT7, %g_strNonSec1%, %strTitle%             ; 
      Control Uncheck,, Button4, A                                          ; Don't try to test the account 
      Send !M                               ; Move on to the More Settings page
      Click 105,47                          ; Click on the Outgoing Server tab
      Control Check,, Button1, A            ; Set he checkbox that SMTP requires authentication
      Click 247, 48                         ; Move to the Advanced tab
      ControlSetText Edit2, 80, A           ; Set outgoing port to 80
      Control Check,, Button3, A            ; Leave messages on the server 
      Control Uncheck,, Button4, A          ; Don't delete after timeframe 
      ControlClick Button6, A               ; Click OK to dismiss the dialog
      WinWaitActive Add New Account,,3
      if ErrorLevel
      {
         MsgBox, Add New Account dialog did not show.
         goto ADDACCOUNTTOPROFILE_EXIT
      }
      Sleep 500 
      Send !N                                                ; Click the "Next" button

      WinWaitActive Add New Account, Congratulations!,3
      if ErrorLevel
      {
         MsgBox, Success! dialog did not show.
         goto ADDACCOUNTTOPROFILE_EXIT
      }
      Send {Enter}                                           ; Click the "Finish" button

      WinWaitActive Account Settings,,3
      if ErrorLevel
      {
         MsgBox, Account Settings dialog did not show.
         goto ADDACCOUNTTOPROFILE_EXIT
      }
      Sleep 500 
      Send !C                                                ; Click the "Close" Button

      WinWaitActive Mail,,3
      if ErrorLevel
      {
         MsgBox, Mail dialog did not show.
         goto ADDACCOUNTTOPROFILE_EXIT
      }
      Send !C                                                ; Click the "Close" Button
  } 
  else if (strTypeUpper = "POP_GODADDY_NOREPLY") 
  {
      strLogString = POP3 No Reply: Display:%strDisplayName% Email:%strEmailName%
      Log(strLogString)

      strTitle = Add New

      Send !I!N                                                             ; Internet Email settings page
      ControlSetText RichEdit20WPT1, %strDisplayName%, %strTitle%           ; Response name (Friendly)
      ControlSetText RichEdit20WPT2, %strAccount%@%strDomain%, %strTitle%   ; Response email
      ControlSend REComboBox20W1, P, Add New E-mail                         ; Account type
      ControlSetText RichEdit20WPT3, _, %strTitle%                          ; Bogus (outgoing only)
      ControlSetText RichEdit20WPT4, smtpout.secureserver.net, %strTitle%   ; GoDaddy SMTP server
      ControlSetText RichEdit20WPT6, %strProxy%@%strDomain%, %strTitle%     ; User info for logon
      ControlSetText RichEdit20WPT7, %g_strNonSec1%, %strTitle%             ; 
      Control Uncheck,, Button4, A                                          ; Don't try to test the account 

      strTitle = Internet E-mail Settings
      Send !M                                                                   ; More Settings page
      ControlSetText RichEdit20WPT1, %strAccount% (Outgoing only), %strTitle%   ; Account friendly name

      Send +{Tab}                              ; Move on to the Outgoing Server tab
      Send {Right 1}                           ;
      Send !O                                  ; Set the checkbox that SMTP requires authentication
      Send {Up}                                ; Move to the Advanced tab
      Send {Right 2}                           ; 
      Send !O80                                ; Set port info
      Send !L                                  ; Leave messages on server 
      Send !I+{Tab}                            ; Close us back to the profiles dialog
      Send {Enter}!N{Enter}
      Send !c!c   
  } 
  else
  {
      MsgBox, Nothing %strTypeUpper% 
  }

goto ADDACCOUNTTOPROFILE_EXIT
ADDACCOUNTTOPROFILE_EXIT:
  LogFunctionEnd()
}


	
CreateEmptyProfile(win_id, strProfileName)
{
   LogFunctionStart(%a_thisfunc%)
   strLog = Params: %win_id%, %strProfileName% 
   Log("Params: " . win_id . ", " . strProfileName)
   SetKeyDelay 100 
   Send !d                                                               ; Add a profile

   strTitle = New Profile
   ControlSetText RichEdit20WPT1, %strProfileName%, %strTitle%           ; Profile name
   ControlClick Button1, %strTitle%                                      ; Click OK

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
  
   Send {Enter} ; Click Cancel so we don't have to enter an email account
   Send {Enter} ; Click OK at prompt for creating an empty profile
   Sleep 1000

   LogFunctionEnd()
   return
}



DeleteProfile(win_id, strProfileName)
{
   LogFunctionStart("DeleteProfile")
   strLog = Params: %win_id%, %strProfileName% 
   Log(strLog)

   retval = 0
   WinActivate ahk_id %win_id%
   SetKeyDelay 100  
   found_it := SelectProfile(win_id, strProfileName)
   if (found_it = true)
   {
      strLog = "Profile %strProfileNam% was found.  Deleting..."
      Log(strLog)
      Send !EY                                 ; Remove the profile
      retval = 1
   }
 
   LogFunctionEnd()
   return %retval%
}


SetupPopAccount(strAlias, strUserName, strPassword, bSendOnly)
{
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
   LogFunctionStart("RedirectAliasToSubFolder")

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



;****************************************************************
CreateRuleToAlias(strAlias, strSubFolder="", strCategory="", strFolder="Inbox")
;****************************************************************
{
   LogFunctionStart("CreateRuleToAlias")

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
   LogFunctionStart("RedirectAliasToSubFolder")

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


; ### Bookmark ###
ChangeStorageLocation(strProfileName, strAccount, strType="Folder", strDestination="Bulk")
{
   global g_strSec1
   global g_strNonSec1
   global g_strMSUser

   LogFunctionStart("ChangeStorageLocation")
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





^;::
;   SetupSeattleSmithsRules(true)
;   RedirectAliasToSubFolder("DavSmith@seattlesmiths.com", "Dave", true)
;    ChangeStorageLocation("SeattleSmiths", "Generic@SeattleSmiths.com", "Folder", "Goober2")
;   AddAccountToProfile("SeattleSmiths","Gubzer","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com")
   AddAccountToProfile("SeattleSmiths","NoReply2","POP_GODADDY_NOREPLY","Dave Smith","seattlesmiths.com", "Dave") 
return
