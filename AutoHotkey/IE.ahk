;
; IE.ahk
;
; Scripts for driving the IE Document Object Model (DOM)
;
; Notes:
; --------------------------------------------------------------------------------------------
; 5/8/09:
; - Created based on the following forum topics:
;      http://www.autohotkey.com/forum/viewtopic.php?t=34972
;      http://www.autohotkey.com/forum/viewtopic.php?t=30599
;      
;      pwb = InternetExplorer Object (http://msdn.microsoft.com/en-us/library/aa752084(VS.85).aspx#)
;      oDoc = Document object (http://msdn.microsoft.com/en-us/library/ms531073(VS.85).aspx)
;
;      Click method: http://msdn.microsoft.com/en-us/library/ms536363(VS.85).aspx
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

#NoEnv
IE_Startup()

#include %A_ScriptDir%\_Include\Tools.ahk
#include %A_ScriptDir%\_Include\COM.ahk
#include %A_ScriptDir%\_Include\debug.ahk

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

::_ABC::
   Send Maple
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

::_TS4::
   pwb := IE_GetWebBrowser("Windows Live Sync", "https://sync.live.com/home.aspx?wa=wsignin1.0" )
   MsgBox %pwb%
return



; #############
;   Functions
; #############

IE_Startup()
{
   global gstrStatementRoot

   LogFunctionStart("IE_Startup")
   COM_Init()

   strFolderShareRoot := GetFolderShareDir()
   gstrStatementRoot = %strFolderShareRoot%Home\Statements    

   LogFunctionEnd()
   return
}



::_exp::
   pwb := IE_GetWebBrowser("second nuclear","cnn.com")
   MsgBox %pwb%
return

IE_GetWebBrowser(strTitleString="A", strURL="" )
{
   ;
   ; Check for an instance of IE with the specified keyword in the title.
   ; If not found, launch IE with the specified URL, or return an empty string.
   ;

   LogFunctionStart("IE_GetWebBrowser")

   pwb := ""

   ; Search for an instance of IE with the keyword in the title.
   if (strTitleString = "A")
   {
      Log("Retrieving IWebBrowser for active window")
      ControlGet, hIESvr, hWnd, , Internet Explorer_Server1, A
   }
   else
   {
      Log("Retrieving IWebBrowser for window with " . %strTitleString% . " in title.")
      ControlGet, hIESvr, hWnd, , Internet Explorer_Server1, %strTitleString% ahk_class IEFrame
   }

   If Not   hIESvr
   {
      Log("Did not find an existing instance of IE")
   }
   else
   {
      ; If IE was found, get its IWebBrowserApp interface
      DllCall("SendMessageTimeout", "Uint", hIESvr, "Uint", DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT"), "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lResult)
      DllCall("oleacc\ObjectFromLresult", "Uint", lResult, "Uint", COM_GUID4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}"), "int", 0, "UintP", pdoc)
      IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
      pwb := COM_QueryService(pdoc,IID_IWebBrowserApp,IID_IWebBrowserApp)
   }

   if ( (pwb = "") AND (strURL <> "") )
   {
      pwb := IE_LaunchIE(strURL)
   }
 
GETWEBBROWSER_EXIT:
   COM_Release(pdoc)
   LogFunctionEnd()
   Return   pwb
}



WaitForReady(pwb)
{
   ;
   ; Loops until the specified IE object is ready
   ; That is, blocks until previously specified activity is complete.
   ;
   LogFunctionStart("IE_WaitForReady")

   Loop
   {
      if rdy:=COM_Invoke(pwb,"readyState") = 4
      {
         goto WFR_EXIT
      }
      else
      {
         sleep 200
         Log( "Ready State: " . rdy )
      }
   }

WFR_EXIT:
   LogFunctionEnd()
}




::_L2::
  IE_LaunchIE("http://www.microsoft.com")
  IE_LaunchIE("http://www.msn.com")
  IE_LaunchIE("http://www.geocaching.com")
return

IE_LaunchIE(strURL="", strVisible="TRUE")
{
   ;
   ; Creates a new instance of IE and navigates to the specified page.
   ; The function is asynchronous, waiting for the page to load before returning.
   ;
   ; With recent builds ~7134, sleep functions have been required between creating the object
   ; and navigating to the page.
   ;
   
   LogFunctionStart("IE_LaunchIE")

   pwb := COM_CreateObject("InternetExplorer.Application")               ; Create the IE object
   Log("Finished creating the IE object")
   Sleep 250                                                             ; Snooze a bit for the object to initialize
   COM_Invoke(pwb , "Visible=", strVisible)                              ; Make the instance of IE visible
   Log("Finished making the object visible")
;   Sleep 3000
   Log("Navigating to " . strURL )
   COM_Invoke(pwb, "Navigate", strURL GETdata)                           ; Navigate to the specified URL

;   Sleep 3000
   Log("Waiting for Ready")
   WaitForReady(pwb)                                                     ; Wait for the page to complete loading

   LogFunctionEnd()
   return %pwb% 
}



IE_GetItem(pwb, strItemName)
{
   LogFunctionStart("IE_GetItem")
   oDoc   :=COM_Invoke(pwb,"Document")                                  ; Get the document object
   if (oDoc = 0)
   {
      Log("*** Could not retrieve the document object.")
      goto GETITEM_EXIT
   }

   Log("Doc: "oDoc)

   colAll :=COM_Invoke(oDoc,"All")                                      ; Get the "all" collection            
   if (colAll = 0)
   {
      Log("*** Could not retrieve the All collection.")
      goto GETITEM_EXIT
   }

   Log("colAll: "colAll)

   oItem :=COM_Invoke(colAll, "Item", strItemName  )                    ; Get the item with the specified ID
   if (colAll = 0)
   {
      Log("*** Could not retrieve the item "oItem)
      goto GETITEM_EXIT
   }


GETITEM_EXIT:
   ReleaseAll(oDoc, colAll)                                             ; Release the interim items

   LogFunctionEnd()
   return %oItem%
}



IE_GetItemValue(oItem)
{
   LogFunctionStart("IE_GetItemValue")

   strValue := COM_Invoke(oItem, "value")
   Log("Value:"strValue)

   LogFunctionEnd()
   return %strValue%
}



IE_SetItemValue(oItem, strValue)
{
   LogFunctionStart("IE_SetItemValue")

   COM_Invoke(oItem, "value", strValue)

   LogFunctionEnd()
}



IE_ClickButton(pwb, strButtonName)
{
   LogFunctionStart("IE_ClickButton")

   oButton := IE_GetItem(pwb, strButtonName)
   COM_Invoke(oButton,"Click")

   ReleaseAll(oButton)

   LogFunctionEnd()
   return
}



IE_CountDocElements(pwb)
{
   LogFunctionStart("IE_CountDocElements")

   doc         := COM_Invoke(pwb,"Document")
   all         := COM_Invoke(doc,"All")
   nElements   := COM_Invoke(all,"Length")


   Log("Element count: "nElements)
   LogFunctionEnd()
   return %nElements%
}



ReleaseAll(p1=0,p2=0,p3=0,p4=0,p5=0,p6=0,p7=0,p8=0,p9=0,p10=0)
{
   ;
   ; Releases a group of interfaces up to 10 at a time.
   ;

   LogFunctionStart("ReleaseAll")

   nIndex = 0

   loop, 10
   {
      nIndex++
      if (p%nIndex% > 0)
      {
;        Log("Releasing p"nIndex)
         COM_Release(p%nIndex%)
      } 
   }

   LogFunctionEnd()
   return
}



IE_ExitApp:
   if A_ExitReason not in Logoff,Shutdown  ; Avoid spaces around the comma in this line.
   {
      MsgBox, 4, , Are you sure you want to exit?
       IfMsgBox, No
          return
   }
   ExitApp  ; The only way for an OnExit script to terminate itself is to use ExitApp in the OnExit subroutine.
return


;******************************************************************************************************************8

::_Live::
   IE_LiveMapsLogin()
return

IE_LiveMapsLogin()
{
   LogFunctionStart("IE_LiveMapsLogin")

   strURL   := "http://maps.live.com"
   strUser  := "dave_n_ang"
   strPass  := "xxxxx"

   pwb := IE_LaunchIE(strURL)

/*
   nElements := IE_CountDocElements(pwb)
   Log("Length: "nElements)

   nIndex = 0

   loop %nElements%
   { 
      nIndex++ 
      oElement := IE_GetItem(pwb, nIndex)
      str := COM_Invoke(oElement, "value")
      Log("String Value: "str)
      str := COM_Invoke(oElement, "id")
      Log("String Value (ID): "str)


;      str := COM_Invoke(oElement, "attributes")
;      strID := COM_Invoke(oElement, "id")
;      Log("Index: "nIndex)
;      Log("ID: "strID)
   }
*/
   
   oSearchBox := IE_GetItem(pwb, "qf")
   COM_Invoke(oSearchBox, "value", "Jamaica Plains, MA")   

   oSearchBox2 := IE_GetItem(pwb, "sb_form_q")
   COM_Invoke(oSearchBox2, "value", "7015 1st Ave NW, Seattle, WA")   

   IE_ClickButton(pwb, "sb_form_go")
   WaitForReady(pwb)
;   IE_ClickButton(pwb, "taskBar_collectionsAnchor")
   Sleep 2000 
   IE_ClickButton(pwb, "taskBar_shareLink")
   WaitForReady(pwb)
   Send ^c
   Send +{Tab}{Enter}

   WaitForReady(pwb)
   IE_ClickButton(pwb, "sb_form_q")
   WaitForReady(pwb)

   Sleep 10000
   IE_ClickButton(pwb, "sb_form_q")

pause


   strID := COM_Invoke(oElement, "id")
   Log("ID: "strID)

   strValue := COM_Invoke(oElement, "value")
   Log("Value: "strValue)

;   oAttributes := COM_Invoke(oElement, "attributes")
;   strName := COM_Invoke(oAttributes, "length")


   ;oPasswd := IE_GetItem(pwb, "ctl00$MiniProfile$loginPassword")
   ;oRemem  := IE_GetItem(pwb, "ctl00_MiniProfile_loginRemember")

   IE_SetItemValue(obj, "lolly")

 ;  IE_SetItemValue(oPasswd, strPass)
 ;  IE_ClickButton(pwb, "ctl00$MiniProfile$LoginBtn")
   IE_ClickButton(pwb, "scopingBar_Collections")
;   strTest := IE_GetItemValue(oRemem)
;   Log("Checkval: "strTest)
   sleep 500
   WaitForReady(pwb)

   ReleaseAll(oEmail, oPasswd, pwb)
   COM_Term()
}



::_Chase::
   IE_ChaseCreditCardStatements()
return

IE_ChaseCreditCardStatements()
{
   global gstrStatementRoot

   LogFunctionStart("IE_ChaseCreditCardStatements")
   strStatementPath = %gstrStatementRoot%\Chase
   Log("Statement root: "strStatementPath)

   pwb := IE_LaunchIE("https://stmts.chase.com/StmtList.aspx")


   Send ^f
   Send 2005
   Send {Escape}
   Send {Enter}


   LogFunctionEnd()
   return
}



::_GC::
   IE_GeocachingLogin()
return

IE_GeocachingLogin()
{
   LogFunctionStart("IE_GeocachingLogin")

   strURL   := "http://www.geocaching.com"
   strUser  := "dave_n_ang"
   strPass  := "xxxxx"

   pwb := IE_LaunchIE(strURL)

   Log("PWB1: "pwb) 
   oEmail  := IE_GetItem(pwb, "ctl00_MiniProfile_loginUsername")
   oPasswd := IE_GetItem(pwb, "ctl00$MiniProfile$loginPassword")
   oRemem  := IE_GetItem(pwb, "ctl00_MiniProfile_loginRemember")
   IE_SetItemValue(oEmail, strUser)
   IE_SetItemValue(oPasswd, strPass)
   IE_ClickButton(pwb, "ctl00$MiniProfile$LoginBtn")
 ;  IE_ClickButton(pwb, "ctl00_MiniProfile_loginRemember")
   sleep 500
   WaitForReady(pwb)

   ReleaseAll(oEmail, oPasswd, pwb)

   COM_Term()
}



::_Script::
   IE_Script()
return
IE_Script()
{
   LogFunctionStart("IE_Script")

   pwb := IE_LaunchIE("http://www.live.com")

; Bookmark
   oDoc   :=COM_Invoke(pwb,"Document")                ; Get the document object
   if (oDoc = 0)
   {
      Log("*** Could not retrieve the document object.")
      goto SCRIPT_EXIT
   }

   Log("Doc: "oDoc)

   colAll :=COM_Invoke(oDoc,"All")                    ; Get the "all" collection            
   if (colAll = 0)
   {
      Log("*** Could not retrieve the All collection.")
      goto SCRIPT_EXIT
   }
   Log("All Collection: "colAll) 
   nElementCount := COM_Invoke(colAll,"Length")
   Log("Num elements: "nElement)

pause 


   COM_Invoke(item62:=COM_Invoke(all2:=COM_Invoke(document:=COM_Invoke(pwb,"Document"),"All"),"Item",62),"click")
   sleep 500
   WaitForReady(pwb)
   msgbox % results:=COM_Invoke(item79:=COM_Invoke(all3:=COM_Invoke(document,"All"),"Item",78),"innerHTML")

SCRIPT_EXIT:
   ReleaseAll(oDoc, colAll)                           ; Release the interim items

   ReleaseAll(itemq, item62, item79, itemq, all1, all2, all3, document, pwb)

   COM_Term()
}



::_GMail::
   IE_GMailLogin()
return

IE_GMailLogin()
{
   LogFunctionStart("IE_GMailLogin")

   url:="https://www.google.com/accounts/Login?continue=http://www.google.com/&hl=en"
   pwb := IE_LaunchIE(url)

   gUser:="myName"
   gPass:="myPass"

   WaitForReady(pwb)

   doc    :=COM_Invoke(pwb,"Document")
   all    :=COM_Invoke(doc,"All")

   Email  :=COM_Invoke(all,"Item","Email")
   Passwd :=COM_Invoke(all,"Item","Passwd")


   nElements := IE_CountDocElements(pwb)
   Log("Length: "nElements)
; Bookmark
pause
   
   COM_Invoke(Email, "value", gUser)
   COM_Invoke(Passwd,"value", gPass)
/*
   COM_Invoke(signIn:=COM_Invoke(all,"Item","signIn"),"Click")
   sleep 500
   WaitForReady(pwb)
   COM_Invoke(pwb, "Navigate", "http://mail.google.com/")
*/
   COM_Release(signIn),COM_Release(Passwd),COM_Release(Email),COM_Release(all),COM_Release(doc),COM_Release(pwb)
   COM_Term()

   LogFunctionEnd()
   return
}
