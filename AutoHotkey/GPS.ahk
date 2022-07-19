;
; GPS.ahk
;
; Various functions and hotkeys for use with different programs associated with
; GPS devices, and or Geocaching.
;
; Functionality is combined for GSAK, Geocaching.COM, Microsoft Streets & Trips,
; and Bing Maps 
;
; Notes:
; --------------------------------------------------------------------------------------------
; 12/27/09:
; - Added XPath functionality for parsing Bing XML files.
;   - GPS_LoadFromBingXML (poiload)
;   - POI_Next (poi +)
;   - POI_Prev (poi -)
;   - POI (hotstring)
;   - POI_Extract
; - Added hot strings:
;    - _POI
;    - _POILoad
;    - _POIName
;    - _POIFull
;    - To complement _Lat, _Lon, and _LatLon
;
; 
; 9/25/09:
; - Cleaned up existing GPS.AHK
; - Added ExtractLatLongFromStreetsAndTrips
; - Converted to use window groups for Streets and Trips
; - Added functionality to load and format pushpin info from
;   the GSAK macro PushPin
;
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

GPS_Startup()

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
;;
;********************************************************************
#ifwinactive Geocaching - Pocket Queries
;********************************************************************

;
; Ctrl-Alt-P
;
; From the GeoCaching.com Pocket Query page, parse the lat/long from
; mapping software such as Bing Maps, or Streets & Trips,
; and put it into the Pocket Query coordinates field.
;
^!P::
   GEOCACHING_PopulatePocketQueryTemplate()
return



;;
;********************************************************************
#ifwinactive Bing Maps
;********************************************************************

;
; Ctrl-Alt-C
; Puts the lat/long link for the current "location" into the clipboard
; Assumes the location has been selected, and the "Share" link has been clicked
;
^!c::
   GPS_ExtractLatLongFromBing()
   MsgBox Latitude: %gnLatitude%,  Longitude: %gnLongitude%
return



;;
;********************************************************************
#ifwinactive ahk_group SNT
;********************************************************************

;
; Ctrl-Alt-C
; Puts the lat/long link for the current "location" into the clipboard
; Assumes the location has been selected, and the "Share Your Map" link has been clicked
;
^!c::
   GPS_ExtractLatLongFromStreetsAndTrips()
   MsgBox Latitude: %gnLatitude%,  Longitude: %gnLongitude%
return

^!G:: 
   LogFunctionStart("PushpinsToClipboard")
   SetKeyDelay 100
   ControlClick SysTreeView322, Microsoft Streets & Trips  ; Choose the nav pane which shows the data series
   Sleep 200 
   Send {Home}                                             ; Start at the top of the data series
   Send {Down 1}                                           ; Choose the nth data series (change the number appropriately).
   Send !DD                                                ; Open the property page for the data set
   Send +{Tab}{Right}{Tab}                                 ; Select the tab and list box containing the list of data points.
   Send {AppsKey}C                                         ; Copy the first data point to the clipboard.
   StringReplace, clipboard, clipboard, `r`n, __ , All
   ControlGetText, strPinLatLong, Static10, A
   Log("Latlong: " . strPinLatLong) 
   StringReplace, strPinLatLong, strPinLatLong, `,,%a_tab%, All
   StrPrev :=                                              ; Clear the comparator
   strCurrent := clipboard                                 ; Use this variable to store the value of one entry.
   strFull :=                                              ; Use this variable to store the whole list as it is built.
   loop
   {
      if (strCurrent = strPrev)                            ; If the current entry is the same as the last, we're done with the list.
      {
         break
      }
      else 
      {
         Log("Adding " . strCurrent . "to the list.")
         strFull = %strFull%`r`n%strCurrent%`t%strPinLatLong% ; Add it to the end of the list
         strPrev := strCurrent                              ; Store the current entry
         Send {Down}                                        ; Advance to the next entry
         Send {AppsKey}C                                    ; Put the contents in the clipboard
         StringReplace, clipboard, clipboard, `r`n, __ , All
         ControlGetText, strPinLatLong, Static10, A
         Log("Latlong: " . strPinLatLong) 
         StringReplace, strPinLatLong, strPinLatLong, `,,%a_tab%, All
         strCurrent := clipboard                            ; Retrieve the next value from the clipboard
      }
   }

   clipboard := Substr(strFull, 3)

PUSHPINSTOCLIPBOARD_EXIT:
   LogFunctionEnd()
return



;
; Ctrl-Alt-P
; From Microsoft Streets & Trips, places a pushpin at the current location,
; populates the notes field with the latitude and longitude (from the location sensor)
; and sets the focus to pushpin name field for user input.
;
^!P::
   SetKeyDelay 25

   GPS_ExtractLatLongFromStreetsAndTrips()
   ControlClick X68 Y755, Microsoft Streets & Trips      ; Click on the pushpin button in the Draw toolbar
   Click                                                 ; Click at the current location to set a pushpin
   Sleep 500
   ControlClick X68 Y755, Microsoft Streets & Trips      ; Turn off the pushpin control

   MsgBox, Move the mouse over the edit area for the pushpin, then press <Enter>
   MouseGetPos, xPinEditArea, yPinEditArea               ; Store the location of the "Notes" part of the new pushpin
   Click %xPinEditArea%, %yPinEditArea%                  ; Activate the edit box for the pushpin
   Send %gnLatitude%, %gnLongitude%                      ; Populate the Notes field with the latitude/longitude
   Send +{Tab}                                           ; Set input to the title part of the pushpin for user input
return


^!L::
   GPS_LoadPushPinsFromCSV()
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

; *******************
;   Utility Hotkeys
; *******************


^!B::
   
   if (ConfirmActiveWin( "Notepad", 5 ))
      MsgBox Affirmative.
   else
      MsgBox Negative.

return


; Windows-Space launches Bing Maps
#space::run http://maps.bing.com

; Windows-G launches Geocaching pocket queries
#P::run http://www.geocaching.com/pocket/

#Q::
   Log("Activating Streets & Trips Window") 
   GroupActivate SNT
return

; Load a GPX file (usually from Bing Maps) into memory for further POI operations
;$$$$
::_poiload::
   GPS_LoadFromBingXML()
return

; Send keystrokes for previously extracted latitude
::_lat::
   Send %gnLatitude%
return

; Send keystrokes for previously extracted longitude
::_lon::
   Send %gnLongitude%
return

; Send keystrokes for previously extracted latitude, and longitude
::_latlon::
   Send %gnLatitude%, %gnLongitude%
return

; Send keystrokes for the name of the POI
::_poiname::
   Send %gstrPOIName%
return

; Send keystrokes for the name, latitude and longitude of the POI
::_poifull::
   Send %gstrPOIName%,%gnLatitude%,%gnLongitude%
return

::_fixup::
   GPS_FixupGPXForPOILoader()
return

GPS_FixupGPXForPOILoader()
{
   ; The Garmin POI Loader rejects the GPX files generated by exporting a Live Maps collection.
   ; This function replaces the header string of the GPX file with a header which POI Loader will accept.
   ;
   ; The function assumes that it is called with Notepad active, and the GPX file
   ; has been loaded into Notepad.
   ;
   ; 5/16/2009
   ;
   LogFunctionStart("GPS_FixupGPXForPOILoader")
   Send ^{Home}
   Send {Down}
   Send +{Down}
   Send {Delete}{Enter}{Up}
   clipboard = <gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.0" creator="Groundspeak, Inc. All Rights Reserved. http://www.groundspeak.com" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0 http://www.groundspeak.com/cache/1/0/cache.xsd" xmlns="http://www.topografix.com/GPX/1/0">
   Send ^V
   loop,2
   {
      Send ^fMetadata{Enter}{esc}
      Send {Home}
      Send +{Down}{Delete}
   }

   LogFunctionEnd()
   return
}


^!w::
   Geocaching_Translate_GPX_For_GSAK()
return

Geocaching_Translate_GPX_For_GSAK()
{
/*
   This function converts a GPX file (eg. A collection file from Live maps) into a GPX
   file which can be successfully imported into GSAK.

   To run the function, open a GPX file in Notepad, then press Ctrl-Alt-W.

   Save the file to a new name, and import into GSAK.

   5/16/2009

*/
   LogFunctionStart("Geocaching_Translate_GPX_For_GSAK()")

   ControlGetText strFile, Edit1, A                             ; Get all of the text from the active Notepad window

   nWPTIndex := 0
   nLetterIndex := 65                                           ; ASCII for A

   loop,
   {
      nWPTStart   := InStr(strFile, "<wpt")                     ; Look for the start of the next waypoint
      if (nWPTStart = 0)                                        ; If there aren't anymore, exit the function
      {
         Log("Breaking out at index " . nWPTIndex)
         break
      }

      strWPTStart := SubStr(strFile, nWPTStart)                 ; Create a string to hold only this waypoint

      nWPTEnd     := Instr(strWPTStart, "</wpt>") + StrLen("</wpt>")   ; Find the end of the waypoint
      strWPT      := SubStr(strWPTStart, 1, nWPTEnd)                   ; Isolate this waypoint
      strOrigWPT  := strWPT                                            ; Store the original info
      nDataStart  := Instr(strWPT, "<name>")

      ; Replace the name and description fields, and tack on some groundspeak specific tags
      StringReplace, strWPT, strWPT, <name>, %A_SPACE%%A_SPACE%%A_SPACE%%A_SPACE%%A_SPACE%%A_SPACE%<groundspeak:name>
      StringReplace, strWPT, strWPT, </name>, </groundspeak:name>
      StringReplace, strWPT, strWPT, <desc>, %A_SPACE%%A_SPACE%%A_SPACE%<groundspeak:long_description html="True">
      StringReplace, strWPT, strWPT, </desc>, </groundspeak:long_description>
      StringReplace, strWPT, strWPT, </wpt>, %A_SPACE%%A_SPACE%</groundspeak:cache>`r`n%A_SPACE%%A_SPACE%</wpt>

      nDataStart--

      ; Isolate the string we've been editing (leave the wpt tag info alone)
      strBeginning := SubStr(strWPT, 1, nDataStart)
      strEnding    := SubStr(strWPT, nDataStart)

      ;   
      ; Build a complete string containing all of the info for this one waypoint
      ; The Name field is used as the waypoint code in GSAK, and is sorted alphabetically.
      ;  each waypoint is given an alphabetic character, and a number 0-9 so that the points
      ;  can be sorted correctly.
      ;
      strWPTNew := strBeginning . "<name>" . chr(nLetterIndex) . Mod(nWPTIndex,10) . "</name>`r`n"  
      strWPTNew := strWPTNew . "    <sym>POI</sym>`r`n"
      strWPTNew := strWPTNew . "    <type>Geocache|Locationless (Reverse) Cache</type>`r`n"
      strWPTNew := strWPTNew . "    <groundspeak:cache id=" . chr(34) . "99999" . chr(34) . " available=" . chr(34) . "True" . chr(34) . " archived="  . chr(34) . "False"  . chr(34) . " xmlns:groundspeak=" . chr(34) . "http://www.groundspeak.com/cache/1/0" . chr(34) . ">`r`n"
      strWPTNew := strWPTNew . strEnding 

      ; Store pointers to the beginning and end of the old waypoint data, so we can replace
      ; the string with the new waypoint info.
      nReplaceStart  := Instr(strFile, strOrigWPT)
      nReplaceEnd := nReplaceStart + StrLen(strOrigWPT)

      ; Replace the original waypoint with the new one.
      strFile := SubStr(strFile, 1, nReplaceStart-1) . strWPTNew . SubStr(strFile, nReplaceEnd) 

      ; Rename the wpt tag to indicate we've already processed it.
      StringReplace, strFile, strFile, <wpt, <wpxt

      ; Increment the name index
      nWPTIndex++
   
      ; If the index is above 9, increment the letter, so the
      ;  waypoints can be sorted correctly in GSAK
      if (mod(nWPTIndex,10) = 0)
         nLetterIndex++
   }   
   
   ; Fixup the wpt tags which we renamed as they were processed.
   StringReplace, strFile, strFile, <wpxt, <wpt, All

   ; Replace the text in the open instance of Notepad
   ControlSetText Edit1, %strFile%, A 

ADJUST_WAYPOINTS_EXIT:
   LogFunctionEnd()
   return
}



GPS_ExtractLatLongFromBing()
{
   ;
   ; Extracts the latitude and longitude from a Bing Maps URL.
   ; Assumes that the URL is already on the clipboard.  The easiest way to do this is
   ; to browse to the location in Live Maps, and click the "Share" link.
   ;
   ; The lat/long are stored as global variables, in decimal degrees.
   ; Other functions, such as PopulatePocketQueryCoordinates can be used to convert the
   ; coordinates to different units.
   ;

   LogFunctionStart("GPS_ExtractLatLongFromBing")
   global gnLatitude
   global gnLongitude

   com := chr(44)
   length := strlen(Clipboard)
   StringGetPos pos, Clipboard, cp=            ; Get the starting position of lat/long in the string
   StringMid temp1, clipboard, pos+4           ; Trim off the beginning of the string
   StringGetPos pos, temp1, &                  ; Get the end position of lat/long in the string
   StringMid temp2, temp1, 1, pos              ; Extract the lat/long string
   StringGetPos pos, temp2, ~                  ; Live maps uses a tilde to separate lat and long
   StringMid lat, temp2, 1, pos                ; Extract the latitude
   StringMid lon, temp2, pos+2                 ; Extract the longitude (scrape off the negative)

   gnLatitude := lat 
   gnLongitude := lon
   Log("Latitude: " . gnLatitude . ", Longitude: " . gnLongitude)

   LogFunctionEnd()
   return
}



GPS_ExtractLatLongFromStreetsAndTrips()
{
   ;
   ; Extracts the latitude and longitude from Microsoft Streets & Trips.
   ; The coordinates are extracted from the Location Sensor dialog.  If this dialog
   ; is not currently showing, it is displayed via the menu (sending key clicks)
   ;
   ; The lat/long are stored as global variables, in decimal degrees.
   ; Other functions, such as PopulatePocketQueryCoordinates can be used to convert the
   ; coordinates to different units.
   ;

   LogFunctionStart("GPS_ExtractLatLongFromStreetsAndTrips")
   global gnLatitude
   global gnLongitude


   IfWinNotExist Location Sensor
   {
      Send !TL
      Sleep 1000
   }

   ControlGetText winLat, Static3, Location Sensor
   ControlGetText winLon, Static4, Location Sensor
 
   StringRight strDirLat, winLat, 1
   StringLeft strCoordLat, winLat, strlen(winlat)-2

   StringRight strDirLon, winLon, 1
   StringLeft strCoordLon, winLon, strlen(winlon)-2

   if (strDirLat = "S")
   {
      strCoordLat := strCoordLat * -1
   }

   if (strDirLon = "W")
   {
      strCoordLon := strCoordLon * -1
   }
   
   gnLatitude := strCoordLat 
   gnLongitude := strCoordLon
   Log("Latitude: " . gnLatitude . ", Longitude: " . gnLongitude)

   LogFunctionEnd()
   return
}



GEOCACHING_PopulatePocketQueryTemplate()
{
   ;
   ; This function navigates the Geocaching.com Pocket Query definition page,
   ; setting the coordinate type, and populating the latitude and longitude
   ; fields from global variables previously populated from Bing Maps, or
   ; Streets & Trips.  The changes are then submitted.
   ;
   ; Notes:
   ;   - Run from the Geocaching.Com Pocket Query definition page.
   ;   - Use ExtractLatLongFromXXXX functions to populate
   ;     global lat/long variables.
   ;

   LogFunctionStart("GEOCACHING_PopulatePocketQueryTemplate")
   global gnLatitude
   global gnLongitude
   global gstrPOIName

   Log("POI Name: " . gstrPOIName . "Latitude: " . gnLatitude . ", Longitude: " . gnLongitude)
   SetKeyDelay, 200
   Log("Sending Control-F")
   Send ^f    
   Sleep 200     
   Send ^f                                       ; Unclear why, but opening Find dialog is flaky w/o 3 ctrl-Fs
 

;   Send ^f                                       ; Take the shortcut (using IE's Find) to the fields we want to edit.
;   Sleep 1000                                    ; Let the Find control wake up
;   Send Query Name                               ; Scroll to the correct part of the page
;   Send {ESC}                                    ; Ditch the find dialog
;   Send {Tab}                                    ; Tab to the next control after the find (Unit combo box)
;   Send ^C 
;Log( "Sending query name" . gstrPOIName )
;   Send %gstrPOIName%                            ; Fill in the name from the GPX file
;goto POPULATE_POCKET_QUERY_TEMPLATE_EXIT
;
   Send ^f                                       ; Take the shortcut to the By Coordinates control by using "Find"
   Sleep 1000                                    ; Let the Find control wake up
   Send By Coordinates                           ; Scroll to the correct part of the page
   Send {ESC}                                    ; Ditch the find dialog
   Send {Tab}                                    ; Tab to the next control after the find (Unit combo box)
   GEOCACHING_PopulatePocketQueryCoordinates()   ; Fill in the coordinates we extracted from "Live Maps"

   Send ^f                                       ; We can't find the "Submit" button directly
   Sleep 100                                     ;  so we find the text right above it, then tab to it.
   Send Compress
   Send {ESC}
   Send {Tab}                                    ; Tab to the Submit button
   Send {Enter}                                  ; Commit the edits by clicking "Submit"

POPULATE_POCKET_QUERY_TEMPLATE_EXIT:
   clipboard = New,%gnLatitude%,%gnLongitude%    ; Put the coordinates on the clipboard for a Location in GSAK
   LogFunctionEnd()
}



GEOCACHING_PopulatePocketQueryCoordinates()
{
   ; Assumes that global variables have already been populated from Live Maps

   LogFunctionStart("PopulatePocketQueryByCoordinates")

   global gnLatitude
   global gnLongitude

   ; Split the latitude and longitude numbers into the integer and fractional values
   MATH_SplitFloat(gnLatitude, nLatWhole, fLatFrac)
   MATH_SplitFloat(gnLongitude, nLonWhole, fLonFrac)

   ; Scrape the negative of the whole numbers as we'll just be using N,S,E,W
   nAbsLatWhole := Abs(nLatWhole)
   nAbsLonWhole := Abs(nLonWhole)

   ; Convert the fractional degrees to minutes for use with pocket queries
   fLatMinutes := fLatFrac * 60
   fLonMinutes := fLonFrac * 60

   ; Log our calculations
   strLog = Latitude: %nLatWhole%%fLatFrac%   (%nLatWhole%d %fLatMinutes%')
   Log(strLog)
   strLog = Longitude: %nLonWhole%%fLonFrac%  (%nLonWhole%d %fLonMinutes%')
   Log(strLog)

   ; Tab to the directional value for latitude, and populate it
   sleep 500
   Send {Tab}
   if (nLatWhole < 0)
   {
      Log("South")
      Send S
   }
   else
   {
      Log("North")
      Send N
   }

   ; Tab to and populate the whole value for latitude
   Send {Tab}
   Log(nAbsLatWhole)
   Send %nAbsLatWhole%

   ; Tab to and populate the minutes value for latitude
   Send {Tab}
   Log(fLatMinutes)
   Send %fLatMinutes%

   ; Tab to the directional value for longitude, and populate it
   Send {Tab}

   if (nLonWhole < 0)
   {
      Log("West")
      Send W
   }
   else
   {
      Log("East")
      Send E
   }

   ; Tab to and populate the whole value for longitude
   Send {Tab}
   Send %nAbsLonWhole%

   ; Tab to and populate the minutes value for longitude
   Send {Tab}
   Send %fLonMinutes%{Tab}
      
   LogFunctionEnd()
   return
}


	
GPS_LoadPushPinsFromCSV()
{
   LogFunctionStart("LoadPushPinsFromCSV")

   SetKeyDelay 25 

   ;
   ; Load some variables from an INI file generated by 
   ; a GSAK Setup macro.
   ;
   strIniFile = %a_workingdir%\INI\PushPins.ini
   IniRead, strAppName, %strIniFile%, Main, Flavor
   IniRead, strFileList, %strIniFile%, Main, List

   ;
   ; Read into an array the list of cache data files (CSV),
   ; as well as their corresponding icons (BMP).
   ; The list file is generated by the GSAK macro
   ; PushPins.txt
   ;
   nValidLines := 0                                                ; Reset the count of data files.
   Loop, read, %strFileList%                                       ; Loop through the file containing the list of data files.
   {
      nLineNum := a_index
      strFirstChar := SubStr( A_LoopReadLine, 1, 1 )               ; Ignore comment lines (they start with #)
      if (strFirstChar <> "#")                                     
      {
         nValidLines += 1                                          ; Increment the count of data files
         nNumFields := 0
         Loop, parse, A_LoopReadLine, `;                           ; File list is ; separated into the CSV, the BMP, and the list
         {                                                         ; of check boxes to turn on in the SnT info field.
            nNumFields += 1                                    
            Array%nValidLines%_%nNumFields% := A_LoopField
         }
      }
   }

   Sleep 500                                                       ; For some reason the File menu is highlighted in SnT after we
   Send {Escape}                                                   ; read the file list, so we escape out of it.

   Loop, %nValidLines%                                             ; Loop through the list of data sets we intend to load.
   {
      strCSVFile := Array%a_index%_1
      strIconFile := Array%a_index%_2
      strDisplay := Array%a_index%_3

      Send ^i                                                      ; Launch the Import Data Wizard
      if (not ConfirmActiveWin( "Import Data Wizard", 5 ))
         goto LOADPUSHPINSFROMCSV_EXIT 
      
      Send %strCSVFile%{Enter}                                     ; Give the wizard the name of the CSV file to load
      Send !N!F
      Sleep 2000                                                   ; Wait for CSV file to load

      
      ControlClick SysTreeView322, Microsoft Streets & Trips,,,,Y326  ; Put focus on the new data set, and open its properties
      Send !DD
      if (not ConfirmActiveWin( "Properties", 5 ))
         goto LOADPUSHPINSFROMCSV_EXIT 

      Send !S                                                      ; Launch the Pushpin Symbols dialog
      Send {Down}
      if (not ConfirmActiveWin( "Pushpin Symbols", 5 ))
         goto LOADPUSHPINSFROMCSV_EXIT 

      nNumRetries := 3
      Loop, %nNumRetries%                                          ; Click the "Import Custom Symbol" button to load the
      {                                                            ; icon for this cache type.
         ControlClick Button1, A,,,1                               ; Occasionally the dialog does not launch when the button
                                                                   ; is clicked, so there is retry code as well.
         if (ConfirmActiveWin( "Open", 2 ))
         {
            nRetVal = 1
            break
         }
         else
         {
            Log("*** Open dialog did not launch!  Retrying.")
            nRetVal = 0
         }
      }

      if (nRetval = 0)
      {
         Log("Could not launch the open dialog after " . nNumRetries . " attempts.  Exiting the function.")
         goto LOADPUSHPINSFROMCSV_EXIT 
      }

      Send %strIconFile%{Enter}                                    ; Give the filename of the icon to load
      Send {Down}                                                  ; Move selection to the custom icons

      nCustomIconRows := A_Index // 9                              ; If there are a lot of custom icons,
      loop, %nCustomIconRows%                                      ; they are displayed in multiple rows.
      {                                                            ; We need to account for the number of rows
         Send {Down}                                               ; when selecting the custom icon.
      }

      Send {Right 9}                                               ; Cruise to the end of the row of icons
      Send {Enter}                                                 ; Close the custom icon dialog
      Send +{Tab 2}{End}{Tab}
      Send {Space}{Down}{Space}{Home}
      nNumBoxes := strlen(strDisplay)
      loop, %nNumBoxes%
      {
         if(SubStr(strDisplay,a_index,1) = "Y")
         {
            Send {Space}
         }
       
         Send {Down} 
      }

      Send {Enter}

      Sleep 1000                                                   ; Wait a sec before moving on to the next data set.
   } 

LOADPUSHPINSFROMCSV_EXIT:
   MsgBox Completed loading pushpins.
   LogFunctionEnd()
   return
}



MATH_SplitFloat(fNumber, ByRef nWhole=-1, ByRef nFrac=-1)
{
   LogFunctionStart("SplitFloat")

   nPos := Instr(fNumber, ".")
   nWhole := SubStr(fNumber, 1, nPos-1)
   nFrac := SubStr(fNumber, nPos)

   LogFunctionEnd()
   return
}


::_GPX::
   GPS_SplitGPXFile("E:\FolderShare\Home\GPS\Seattle\GeoCaches\", "2930169", ".gpx")
return

GPS_SplitGPXFile(strPath, strBasename, strExtension)
{
   LogFunctionStart("SplitGPXFile")

   strFilename = %strPath%%strBasename%%strExtension%
   strNewFile1 = %strPath%%strBasename%_1%strExtension%
   strNewFile2 = %strPath%%strBasename%_2%strExtension%
   strNewFile3 = %strPath%%strBasename%_3%strExtension%
   Log(strNewFile1)

   if (FileExist(strFilename))
   { 
      Log("Reading the file") 
      FileRead, strFull, %strFilename%
      nFirstWPT := Instr(strFull, "<wpt")
      strFileHeader := Substr(strFull,1,nFirstWPT-1)      
      ControlSetText Edit1, %strFileHeader%, Untitled - Notepad

      nMidWPT := Instr(strFull, "<wpt", false, 980000)
      strLog = Mid waypoint starts at %nMidWPT%
      Log(strLog) 

      FileDelete %strNewFile1%      
      FileDelete %strNewFile2%      
      FileDelete %strNewFile3%      


      strFirstFileText := SubStr(strFull, 1, nMidWPT-1)
      FileAppend %strFirstFileText%, %strNewFile1%
      FileAppend </gpx>, %strNewFile1%
      clipboard = %strNewFile1%


      strSecondFileText := SubStr(strFull, nMidWPT)
      FileAppend %strFileHeader%, %strNewFile2%
      FileAppend %strSecondFileText%, %strNewFile2%

      strLog = First waypoint starts at %nFirstWPT%
      Log(strLog) 
      bRetVal := 1
   }
   else
   {
      strLog = GPX file does not exist. (%strFilename%)
      Log(strLog)
   }

   LogFunctionEnd()
   return
}


;######
GPS_LoadFromBingXML(strFile="")
{
   ;
   ; Uses XPath functionality from XPath.ahk to load a GPX file into memory, storing
   ; the contents in a global variable for future use by POI functions.
   ;
   ; If an absolute path is not specified for the GPX file, the macro looks on the
   ; the desktop for the default file exported from Live Maps called List+of+places.gpx.
   ;

   global gnNodeCount
   global gnCursor
   global gXML

   LogFunctionStart("GPS_LoadFromBingXML")
   
   gnNodeCount := 0
   gnCursor := 0

   if (strFile = "")
   {
      strFile := A_Desktop . "\List+of+places.gpx"
   }

   strExists := FileExist(strFile)
   if (strExists = "")
   {
      Log( strFile . " could not be found.  Exiting." )
      return
   }

   bLoaded := XPath_Load(gXML, strFile)
   if not bLoaded
   {
      Log( "Could not load file: " . strFile )
      return
   }

   strGPXName := XPath(gXML, "/gpx/metadata/name/text()")
   Log( "GPX name: " . strGPXName )

   gnNodeCount := XPath(gXML, "/gpx/wpt/count()")
   Log( "There are " . gnNodeCount . " waypoints in this file." )
   gnCursor := 1

   POI_Extract()

LOADFROMBINGXML_EXIT:
   LogFunctionEnd()
}



POI_Next()
{
   global gnNodeCount
   global gnCursor
   global gXML

   LogFunctionStart("POI_Next")

   if (gnCursor < gnNodeCount)
   {
      gnCursor++
   }

   POI_Extract()

   LogFunctionEnd()
}



POI_Prev()
{
   global gnNodeCount
   global gnCursor
   global gXML

   LogFunctionStart("POI_Prev")

   if (gnCursor > 1)
   {
      gnCursor--
   }

   POI_Extract()

   LogFunctionEnd()
}



POI_Extract()
{
   LogFunctionStart("POI_Extract")
   global gnLatitude
   global gnLongitude
   global gnNodeCount
   global gnCursor
   global gXML
   global gstrPOIName

   gstrPOIName := XPath(gXML, "/gpx/wpt[" . gnCursor . "]/name/text()")
   StringReplace, gstrPOIName, gstrPOIName, `&`#44`;,`,, All ; Replace commas
   StringReplace, gstrPOIName, gstrPOIName, `&amp`;,`&, All  ; Replace ampersands 
   gnLatitude := XPath(gXML, "/gpx/wpt[" . gnCursor . "]/@lat/text()")
   gnLongitude := XPath(gXML, "/gpx/wpt[" . gnCursor . "]/@lon/text()")
   Log( gstrPOIName ": " . gnLatitude . "," . gnLongitude )

   LogFunctionEnd()
}


::_poi::
   Input strKeyStrokes, , {Enter}.{Esc}%a_space% 
   if ( strKeyStrokes = "+" )
   {
      POI_Next()
   }
   else if (strKeyStrokes = "-" )
   {
      POI_Prev()
   }
   else
   {
      gnCursor := strKeyStrokes
      MsgBox % "Cursor set to " . gnCursor
      POI_Extract()
   }

return

GPS_Startup()
{
   global gnLatitude
   global gnLongitude
   global gnNodeCount
   global gnCursor
   global gXML
   global gstrPOIName

   ; Group the Streets & Trips Windows for use in variant hotkeys
   GroupAdd, SNT, Location Sensor
   GroupAdd, SNT, Microsoft Streets
   GroupAdd, SNT, GPS Sensor

   return
}


/*
*
* XPath Demo
*
*/
::_xs::
; Converts xml to a form usable with xpath(). In this case, xml
; is empty, to it is essentially creating a new xml document.
xpath_load(xml)
MsgBox % xpath_save(xml)

; Create elements with a +/-1 predicate.
xpath(xml, "/root[+1]/node[+1]/text()", "initial value")

; If filename is omitted, xpath_save returns the XML.
MsgBox % xpath_save(xml)

; Modify an element.
xpath(xml, "/root/node/text()", "modified value")

; Add or modify an attribute.
xpath(xml, "/root/node/@attr/text()", "attribute value")

MsgBox % xpath_save(xml) ; (not necessary if you don't want to display the XML)

; Add another element, before the existing <node>.
xpath(xml, "/root/node[-1]/text()", "second node")

MsgBox % xpath_save(xml)

; Delete an element.
xpath(xml, "/root/node[@attr=attribute value]/remove()")

MsgBox % xpath_save(xml)
xpath_save(xml, "e:\temp\test.xml") 
return


; Loads an XML file for use with XPath parsing
::_xpl::
   LogFunctionStart("XPL")

;   strInFile = E:\FolderShare\Home\GPS\Seattle\GeoCaches\2930169.gpx
   strInFile = E:\temp\MyCache.gpx
   strOutFile = "E:\FolderShare\Home\GPS\Seattle\GeoCaches\Found.gpx"

   if (not xpath_load(objFeed, strInFile))
   {
      Log("Couldnt load the file.")
   }
   else
   {
      MsgBox % xpath_save(objFeed)
      xpath_save(objFeed, "e:\temp\test.xml") 
/*
      Log("Successfully loaded the file.")
      nWayPts := xpath(objFeed, "/gpx/wpt/count()")   
      nFoundPts := xpath(objFeed, "/gpx/wpt[sym=Geocache Found]/count()")   
      objFound := xpath(objFeed, "/gpx/wpt[sym=Geocache Found]/name/text()", "New Content") 
        
      strLog = File contains %nWayPts% entities.
      Log(strLog) 
      strLog = You've found %nFoundPts%.
      Log(strLog) 
      bSaved := xpath_save( objFound )
      MsgBox Saved: %bSaved% 
;      MsgBox %objFound% 
*/
   }

   LogFunctionEnd()
return


; Loads an XML file for use with XPath parsing
::_xp2::
   LogFunctionStart("XPL")

   strInFile = E:\FolderShare\Home\GPS\Seattle\GeoCaches\2930169.gpx
;   strInFile = E:\temp\MyCache.gpx
   strOutFile = "E:\FolderShare\Home\GPS\Seattle\GeoCaches\Found.gpx"

   if (not xpath_load(objFeed, strInFile))
   {
      Log("Couldnt load the file.")
   }
   else
   {
      Log("Successfully loaded the file.")
      nWayPts := xpath(objFeed, "/gpx/wpt/count()")   
;      nFoundPts := xpath(objFeed, "/gpx/wpt[sym=Geocache Found]/count()")   
      nFoundPts := xpath(objFeed, "/gpx/wpt/[difficulty=1]/count()")
      objFound := xpath(objFeed, "/gpx/wpt[sym=Geocache Found]/name/text()", "New Content")       
      MsgBox Of %nWayPts% points, you selected %nFoundPts% 
   }

   LogFunctionEnd()
return


; RegEx experiment
::_re::
   RegExExperiment()
return

RegExExperiment()
{
; Experimenting with regular expression (regex) searches
; There are 11 characters which need to be escaped (using \): [\^$.|?*+()
;
; - Use [] to enclose a character class which will match a single character (eg. [a-zA-Z0-9] returns any alphanumeric character.
; - Use ^ to negate the following value (eg [^a-z] returns a character which is not in a-z)
;
   LogFunctionStart("RegExExperiment")
   SetKeyDelay 20

   FileRead strFile, E:\FolderShare\Home\GPS\Seattle\GeoCaches\MyFinds.gpx
;   strFile = This is a <EM>first</EM> test
;   strExpr = wp[r-u] 

;   strFile = This is a <EM>first</EM> test            ; Greedy search... keeps going until it has to stop to meet the rest of the requirements
;   strExpr = <.+>

;   strFile = This is a <EM>first</EM> test            ; Lazy search... stops when it has met the requirements
;   strExpr = <.+?>

   strExpr = s)<wpt.+?>.+?</wpt>                       ; The leading s) includes newlines in the . specifier
   FoundPos := RegExMatch(strFile, strExpr, strMatch)
   MsgBox %FoundPos% 
   MsgBox %strMatch%

   strExpr = s)<groundspeak:name>.+?</groundspeak:name>
   FoundPos := RegExMatch(strMatch, strExpr, strMatch)
   MsgBox %FoundPos% 
   MsgBox %strMatch%


   LogFunctionEnd()
   return
}


ConfirmActiveWin( strTitle, nWait=5 )
{
   WinWaitActive %strTitle%,,%nWait%                          ; Wait for the window to show
   if (ErrorLevel > 0)
   {
      Log("Window: " . strTitle . " was not found.")
      bRetVal = 0
   }
   else
   {
      Log("Window: " . strTitle . " was found.")
      bRetVal = 1
   }   

   return bRetVal
}
