;
; XPath_Info.ahk
;
; General research on using XPath in AutoHotkey.
;
; Notes:
; --------------------------------------------------------------------------------------------
; 12/29/09:
; - Added code to extract attributes from GSAK export
;
; 12/27/09:
; - Created
; - Added some links to sample scripts
; 
;
;
; Links:
; http://www.autohotkey.com/forum/topic49643.html&highlight=xpath

;
; #########################
;   Global Initialization
; #########################

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

XPath_Examples_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\xpath.ahk
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
; Send keboard strokes for the word "Maple" if
; the text underscore ABC is typed while in a window
; with Microsoft in the title.
;
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


; #############
;   Functions
; #############
XPath_Examples_Startup()
{
   LogFunctionStart(a_thisfunc)

;   strFile := "E:\FolderShare\Projects\AutoHotkey\Samples\LivePOI.gpx"
;   strFile := "D:\Users\davsmith\Desktop\GSAK_Export.gpx"
   strFile := "E:\FolderShare\Home\GPS\Boston\Geocaches\2894725.gpx"

   bLoaded := XPath_Load(xml, strFile)
   if not bLoaded
   {
      Log( "Could not load file: " . strFile )
      return
   }

   strCreator := XPath(xml, "/gpx/@creator/text()")
   Log( "Creator: " . strCreator )

   strURL := XPath(xml, "/gpx/@xmlns:xsd/text()")
   Log( "URL: " . strURL )
   
   if (strCreator = "Groundspeak Pocket Query" or strCreator = "GSAK") then
   {
      strName := XPath(xml, "/gpx/name/text()")
      nNumWaypoints := XPath(xml, "/gpx/wpt/count()")
      Log( strName . " has " . nNumWaypoints . " caches." ) 

      strNames := XPath(xml, "/gpx/wpt/name/text()")
      Log( "The concatenated list of names is: " . strNames )

      strPOISymbol := XPath(xml, "/gpx/wpt[1]/sym/text()")
      Log( "The first POI is of symbol type " . strPOISymbol )

      strCacheName := XPath(xml, "/gpx/wpt[1]/groundspeak:cache/groundspeak:name/text()")
      Log( "The first cache name is " . strCacheName)

      nCacheID := XPath(xml, "/gpx/wpt[1]/groundspeak:cache/@id/text()")
      Log( "The first cache id is " . nCacheID )
   }



   ; Read the name and lat/long attributes of a particular index
   nNodeNum := 2 
   strOneNode := XPath(xml, "/gpx/wpt[" . nNodeNum . "]/name/text()")
   StringReplace, strOneNode, strOneNode, `&`#44`;,`,, All ; Replace commas
   StringReplace, strOneNode, strOneNode, `&amp`;,`&, All  ; Replace ampersands 
   strLatitude := XPath(xml, "/gpx/wpt[" . nNodeNum . "]/@lat/text()")
   strLongitude := XPath(xml, "/gpx/wpt[" . nNodeNum . "]/@lon/text()")
   MsgBox % strOneNode ": " . strLatitude . "," . strLongitude

   ; Read the name and lat/long attributes of the last node
   strOneNode := XPath(xml, "/gpx/wpt[last()]/name/text()")
   StringReplace, strOneNode, strOneNode, `&`#44`;,`,, All ; Replace commas
   StringReplace, strOneNode, strOneNode, `&amp`;,`&, All  ; Replace ampersands 
   strLatitude := XPath(xml, "/gpx/wpt[last()]/@lat/text()")
   strLongitude := XPath(xml, "/gpx/wpt[last()]/@lon/text()")
   MsgBox % strOneNode ": " . strLatitude . "," . strLongitude

XPATH_EXAMPLES_STARTUP_EXIT:
   LogFunctionEnd()
   return
} 


FunctionCallTemplate(byref strOutVar1, byref strOutVar2)
{
   LogFunctionStart("FunctionCallTemplate")

   strOutVar1 = "Hello"
   strOutVar2 = "There"

FUNCTIONCALLTEMPLATE_EXIT:
   LogFunctionEnd()
   return
}

Sum(nInput1, nInput2)
{
   return nInput1+nInput2
}