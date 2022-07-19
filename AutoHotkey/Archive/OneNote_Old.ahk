;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2


#NoEnv
#include %A_ScriptDir%\_Include\tools.ahk

OneNote_Startup()

;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;


^r::
;    strName := GetCurrentNotebookDisplayName()
;    MsgBox %strName% 
   strFSDir := FolderShare_GetFolderShareDir()
   strHomeNotebook = %strFSDir%Home\Notebook (Home)

   OutputDebug %strHomeNotebook%
   OpenNotebook(strHomeNotebook)
;   SelectNotebookAtPos(2)
return


;******************************************** Custom **********************************************

;********************************************************************

; *************
; Scoped tools
; *************


;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;


^!d::
   PrintChapter()
return

PrintChapter()
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 100     
   SetControlDelay -1

   Send {Space}
   Send ^p
   Send !u{space}{tab}
   Send ^c
   nFirstPage := clipboard

   ControlClick, Button18, A,,,, NA

   Log("First Page: " . nFirstPage)

   Send {down}{space}
   Send ^p
   Send !u{space}{tab}
   Send ^c
   nLastPage := clipboard - 1

   ControlSetText Edit1, %nFirstPage%-%nLastPage%, A
   ControlClick, Button17, A,,,, NA

   Log("Page Range: " . nFirstPage . "-" . nLastPage)

PRINT_CHAPTER_EXIT:   
   LogFunctionEnd()
   return
}


;********************************************************************
#ifwinactive Microsoft OneNote


^q::
;   nCount := ListNotebooks(strList)
   CloseAllNotebooks()
return


^m::
   SetKeyDelay 100     
   CloseAllNotebooks()
   strFSDir := FolderShare_GetFolderShareDir()
   strHomeNotebook = %strFSDir%Home\Notebook (Home)
   OpenNotebook(strHomeNotebook)
   OutputDebug %strHomeNotebook%
return


CloseAllNotebooks()
{
   nCount := ListNotebooks(strList)

   loop %nCount%
   {
      Send !fl
   }
}

ListNotebooks(ByRef strNameList)
{
   nIndex = 2

   strFirstNotebook := SelectNotebookAtPos(1)
   strNotebookNames = %strFirstNotebook%

   OutputDebug First = %strFirstNotebook%

   if (strFirstNotebook = "")
   {
      strNameList = 
      return 0
   }

   loop,5
   {
      strCurrentNotebook := SelectNotebookAtPos(nIndex)
      OutputDebug Notebook(%nIndex%) = %strCurrentNotebook%

      if (strCurrentNotebook = strFirstNotebook)
      {
         break 
      }
      else
      {
         strNotebookNames = %strNotebookNames%;%strCurrentNotebook%
      }
      nIndex++
   }

   nIndex--
   strNameList := strNotebookNames
   OutputDebug Exit: %strNameList%
   return nIndex
}

SelectNotebookAtPos(nIndex)
{
   WinGetPos, x, y, nWidth, nHeight, A  ; "A" to get the active window's pos.
   nClickX := 30
   nClickY := nHeight - 30
   MouseClick left, %nClickX%, %nClickY%  
   nIterations := nIndex - 1
   loop %nIterations%
   {
      Send {Tab}
   }
   Send {Space}
   Sleep 500 
   strName := GetCurrentNotebookDisplayName()
;   OutputDebug [Infunct] Name: %strName%
   return %strName%
}

CloseCurrentNotebook()
{
   Send !fL
}

GetCurrentNotebookDisplayName()
{
   Send !fi
   ControlGet, OutputVar, Hwnd,, RichEdit20W1, Notebook Properties
   ControlGetText, OutputVar, RichEdit20W1, Notebook Properties
   Send {Escape}
   return %OutputVar%
}


OpenNotebook(strNotebookPath)
{
   Send !E{Left}OK
   Sleep,500
   Send %strNotebookPath%
   Clipboard := strNotebookPath
   Sleep, 100
   Send !O!O
}

^w::
   ;ControlFocus, OneNote::CJotSurfaceWnd1, OneNote
   ;Send {F6}{Up}{Enter}
return


::SetupCategories::
  setkeydelay 10

  Send, !ac{Enter}To Do (DavSmith){Down 3}{Left}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (JEDavis){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (FredNava){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (DonaSa){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (DavLaw){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (SeanHi){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (AAluri){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (GauravK){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}To Do (Someone Else){Down 3}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Discuss with GrantG{Down 10}{Left}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Discuss with D3{Down 10}{Left}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Discuss with JCable{Down 10}{Left}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Discuss with Test Leads{Down 10}{Left}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Question{Down 11}{Right 2}{Down 9}{Right 3}{Down 9}{Right 3}{Down 2}{Right}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Question (Answered){Down 11}{Right 2}{Down 9}{Right 3}{Down 9}{Right 3}{Down 9}{Right 3}{Down 1}{Right 2}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Investigate{Down 5}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Follow Up{Down 11}{Right 2}{Down 9}{Right 3}{Down 8}{Enter}{Tab 3}{Enter}
  Send, !ac{Enter}Follow Up (Complete){Down 11}{Right 2}{Down 9}{Right 3}{Down 8}{Right 2}{Enter}{Tab 3}{Enter}
return


SetCat14()
{
   ; None            = 34,  14
   ; Blue checkbox   = 15,  38
   ; Yellow checkbox = 38,  40
   ; Question        = 292, 61
   ; Follow up       = 270, 59

   setkeydelay 200

   PurgeCat14()                             ; Purges all but last tag -- OneNote doesn't allow an empty tag list
   RenameLastTag("Blibbit")                 ; Rename the last tag to something harmless

   ; Define the tags with symbols
   CreateTag(".DavSmith", 15, 38)
   CreateTag(".SeanO", 15, 38)
   CreateTag(".EricVe", 15, 38)
   CreateTag(".DavidDv", 15, 38)
   CreateTag(".DMilner", 15, 38)
   CreateTag(".TedDw", 15, 38)
   CreateTag(".Antoine", 15, 38)
   CreateTag(".Other", 15, 38)
   CreateTag("Budget", 38, 40)
   CreateTag("CTP", 38, 40)
   CreateTag("DogFood", 38, 40)
   CreateTag("Question", 292, 61)
   CreateTag("Uncategorized", 270, 59)
   Send {Tab 2}{Enter}                      ; Exit the dialog

   PurgeCat14(1)                            ; Delete the last tag

   return
}


CreateTag(strName, x, y)
{
   CoordMode Mouse, Relative

   LaunchNewTagWindow()
;   Send %strName%
   ControlSetText RICHEDIT60W1, %strName%, A
   Send {Tab}
   Send {Down}
   
   Click %x%,%y%

   Send {Tab 3}{Enter}
   return
}




!^g::
   RenameLastTag()
return

RenameLastTag(strName="Blibbit")
{
   LaunchCustomizeTagsWindow()

   Send {end}
   Click 134,432
   ControlSetText RICHEDIT60W1, %strName%, A
   Click 142, 244
   Send {Tab}{Enter}
   
   return
}


PurgeCat14(bPurgeLast=0)
{
   LogFunctionStart(A_ThisFunc)

   SetKeyDelay 100
   
   LaunchCustomizeTagsWindow()
   sleep 500

   if (bPurgeLast)
   {
      Send {End}{Tab 2}{Enter}
      Send {Tab 3}{Enter}                     ; Dismiss the customize dialog
      goto PURGECAT14_EXIT
   }

   send {Tab 2}

   while ((not WinExist("OneNote", "cannot")))
   {
      Log( "Sending Enter")
      Send {Enter}
      Sleep 100

      if (WinExist("New Tag"))
      {
         Send {Enter}
         Send {Tab 2}{Enter}
         goto PURGECAT14_EXIT
      }
   }

   Send {Enter}{Tab 3}{Enter}                     ; Dismiss the customize dialog
   
PURGECAT14_EXIT:
   LogFunctionEnd()
   return
}

^!E::
   SetCat14()
return


^!F::
   PurgeCat14()
return




LaunchCustomizeTagsWindow()
{
   SetKeyDelay 100
   CoordMode Mouse, Relative
 
   IfWinExist Customize Tags
   {
      Log( "Activated Customize Tags" )
      WinActivate
   }  
   else
   {
      Log("Starting from Scratch")
      Send !HTC
   }
}



LaunchNewTagWindow()
{
   IfWinExist New Tag
   {
      Log("Activated Customize Tags")
      WinActivate
   }  
   else
   {
      LaunchCustomizeTagsWindow()
      Click 48, 434
   }
}



::_JDS::
Send ^1
return

::_JD::
Send ^2
return

::_FN::
Send ^3
return

::_DS::
Send ^4
return

::_DL::
Send ^5
return

::_SH::
Send ^6
return

::_AA::
Send ^7
return

::_GK::
Send ^8
return

::_SE::
Send ^9
return

::_GG::
Send !a{Down 11}{Enter}
return

::_D3::
Send !a{Down 12}{Enter}
return

::_JC::
Send !a{Down 13}{Enter}
return

::_TL::
Send !a{Down 14}{Enter}
return

::_Q::
Send !a{Down 15}{Enter}
return

::_A::
Send !a{Down 16}{Enter}
return

::_I::
Send !a{Down 17}{Enter}
return



; *************
; Global tools
; *************


;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************
OneNote_Startup()
{
   global FS_RootDrive
   global FS_RootPath
   global FS_ComputerID

   global FS_NotebookCount
   global FS_NotebookNames

   strIniFile = %A_ScriptDir%\INI\%a_computername%.ini
   strSectionName = FolderShare
   IniRead, FS_RootDrive, %strIniFile%, %strSectionName%, FS_RootDrive
   IniRead, FS_RootPath, %strIniFile%, %strSectionName%, FS_RootPath
   IniRead, FS_ComputerID, %strIniFile%, %strSectionName%, FS_ComputerID
   MsgBox, Value = %FS_ComputerID%

   return
}
