;
; DVD.ahk
;
; Keyboard scripts for working with DVDs
;
; Notes:
; --------------------------------------------------------------------------------------------
; 6/3/09:
; - Created the from the template file
;
SettitleMatchMode RegEx

DVD_Startup()

;
; #########################
;   Global Initialization
; #########################
;
; Set the title matching to match if the string is found
; anywhere in the title.
;
;SetTitleMatchMode, 2

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
#ifwinactive [0-9a-f]{8}            ; Check if the current window is a DVDID file (starts with 8 hex chars)

^!I::
   ControlGetText strContents, Edit1, A
   DVD_MakeDVDIDFile(strContents)
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


; #############
;   Functions
; #############
DVD_Startup()
{
   LogFunctionStart("DVD_Startup")
   global g_strDVDInfoPath

   str := A_Appdata . "\Microsoft\eHome\DVDInfoCache"
   clipboard := str
   g_strDVDInfoPath := str

   LogFunctionEnd()
   return
}



::_DVDIDPath::
   DVD_LaunchDVDInfo()
return


DVD_LaunchDVDInfo()
{
   global g_strDVDInfoPath

   LogFunctionStart("DVD_LaunchDVDInfo")
   run %g_strDVDInfoPath%   

   LogFunctionEnd()
   return
}   


::_Mk::
   ControlGetText strContents, Edit1, A
   DVD_MakeDVDIDFile(strContents)
return


DVD_MakeDVDIDFile(strXMLSrc)
{
   LogFunctionStart("DVD_MakeDVDIDFile")

   Sleep 200
   XML_FindTag(strXMLSrc, "DVDTitle", strTag, strDVDTitle, strFullTagText)
   XML_FindTag(strXMLSrc, "DVDID", strTag, strDVDID, strFullTagText)

   strNew = <?xml version="1.0" encoding="utf-8"?>`r`n
   strNew = %strNew%<Disc>`r`n
   strNew = %strNew%      <Name>%strDVDTitle%</Name>`r`n
   strNew = %strNew%      <ID>%strDVDID%</ID>`r`n
   strNew = %strNew%</Disc>`r`n

   ControlSetText Edit1, %strNew%, A

   if (strDVDTitle <> "")
   {
      strFilename := "_" . RegExReplace(strDVDTitle, "[\s]", "_", strTagContents)
   }
   else
   {
      strFilename := "_" . RegExReplace(strDVDID, "[\|]", "", strTagContents)
   }



   Send !FA
   Sleep 1000
   Send %strFilename%.dvdid.xml

   goto DVD_MAKEDVDIDFILE_EXIT

DVD_MAKEDVDIDFILE_EXIT:
   LogFunctionEnd()
   return
}


::_FT::
{
   ControlGetText strContents, Edit1, A
   XML_FindTag(strContents, "trkpt", strTagText, strTagContents, strFullString)
   return
}

XML_FindTag(strText, strTag, byref strTagText="", byref strTagContents="", byref strFullString = "")
{
   LogFunctionStart("XML_FindTag")

   strExpr = is)<%strTag%[^>]*>
   FoundPos := RegExMatch(strText, strExpr, strTagText)

   strExpr = is)%strTagText%[^>].*?</%strTag%>
   FoundPos := RegExMatch(strText, strExpr, strTagContents)
   strFullString := strTagContents

   strTagContents := Substr(strTagContents, StrLen(strTagText)+1, StrLen(strTagContents) - StrLen(strTagText) - StrLen(strTag) - 3)

   LogFunctionEnd()
   return
}


^!x::
   Fixup_CoverArt_Path()
return

Fixup_CoverArt_Path()
{
   LogFunctionStart("Fixup_CoverArt_Path")
   Send {AppsKey}E
   Sleep 1500
   Send ^h
   Send D:\SharedDocs\Video\DVDs\{Tab}
   Send \\davsmitha\shareddocs\video\dvds\!A
   Send {esc}
   Send ^s
   Send !FX 
   LogFunctionEnd()
   return
}

