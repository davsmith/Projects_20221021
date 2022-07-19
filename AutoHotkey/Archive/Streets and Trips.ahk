;
; Streets and Trips.ahk
;
; Set of functions and hotkeys for use with Microsoft Streets & Trips (or MapPoint) software.
;
; Notes:
; --------------------------------------------------------------------------------------------
; 4/21/09:
; Most of these functions are crude, and have not been cleaned up, or formatted yet.
;



;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk

SNT_Startup()


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
;***************************************************
#ifwinactive MapPoint

^!t::
   Send !tgt
return


^!a::
   Send !tga
return

::read_ini::
   strIniFile = C:\temp\new folder\PushPins.ini
   IniRead, ppFlavor, %strIniFile%, main, Flavor
   IniRead, ppListFile, %strIniFile%, main, List
   IniRead, ppIconCount, %strIniFile%, main, Icons
   IniRead, ppShortPause, %strIniFile%, main, ShortPause
   IniRead, ppLongPause, %strIniFile%, main, LongDelay
   IniRead, ppPerk, %strIniFile%, main, Perk

   MsgBox, Flavor = %ppFlavor% `rListFile = %ppListFile%
return


::_f::
   Send ^f+{Tab 2}{Right}+{Tab}{Right}
return



!^l::
   SetKeyDelay 500
   GetLocationSensorCoords(strLatitude, strLongitude)
   CSVFile = c:\temp\MPPoi.csv
   IfNotExist, %CSVFile%
   {
      FileAppend,
      (
Longitude,Latitude,Name,Description`r`n
      ), %CSVFile%
      MsgBox No file.
    }
    InputBox strLocName, Location Name, Enter the name of this location
    FileAppend,
    (
      %strLongitude%,%strLatitude%,%strLocName%,Description`r`n
    ), %CSVFile%
    AddPushPinByCoords(strLatitude, strLongitude)
;   Send !U
;   Send S
;   Send +{Tab 2}{Delete}
return



!^c::
   SetKeyDelay 500
   GetLocationSensorCoords(strLatitude, strLongitude)
   AddPushPinByCoords(strLatitude, strLongitude)
   Send !U
   Send S
;   Send +{Tab 2}{Delete}
return



::_controlgettext::
   ControlGetText strLatitude, Static3, Location Sensor
   ControlGetText strLongitude, Static4, Location Sensor
   MsgBox, Latitude: %strLatitude%, Longitude: %strLongitude%.
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
SNT_Startup()
{
   return
}


GetLocationSensorCoords(byref strLatitude, byref strLongitude)
{
   ControlGetText strFullLatitude, Static3, Location Sensor
   ControlGetText strFullLongitude, Static4, Location Sensor

   strText = %strFullLatitude%`r`n%strFullLongitude%  
   clipboard = %strText%

   StringGetPos, nPosition, strFullLatitude, ° 
   strLatitude := SubStr(strFullLatitude, 1, nPosition)
   IfInString, strFullLatitude, South
   {
      strLatitude = -%strLatitude%
   }

   StringGetPos, nPosition, strFullLongitude, ° 
   strLongitude := SubStr(strFullLongitude, 1, nPosition)
   IfInString, strFullLongitude, West
   {
      strLongitude = -%strLongitude%
   }
   
   return
}



AddPushPinByCoords(strLatitude, strLongitude)
{
   setkeydelay 10

   Send !EF
   Send +{Tab 2}
   Send {Right}
   Send +{Tab}
   Send {Right}

   Send %strLatitude%
   Send {Tab}
   Send %strLongitude%
   Send {Tab 2}
   Send {Enter}
   
   return
}

