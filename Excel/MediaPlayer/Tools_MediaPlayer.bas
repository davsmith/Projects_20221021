Attribute VB_Name = "Tools_MediaPlayer"
Option Explicit

Public Enum enmTokenSearch
    starts_with
    ends_with
    exactly
End Enum


'
' Deletes all files used to store the media library for the
' Windows Media Player.  If the player is open, this routine
' will fail since the files will be in use.
'
Sub KillMediaPlayerLibrary()
    Dim strPath As String
    
    On Error Resume Next
    Err.Clear
    strPath = Environ("LocalAppData")
    Kill (strPath + "\Microsoft\Media Player\LocalMLS_*.wmdb")
    Kill (strPath + "\Microsoft\Media Player\CurrentDatabase_*.wmdb")
    
    If (Err.Number <> 0) Then
        Debug.Print ("Error number " + CStr(Err.Number) + " occurred.")
        Debug.Print ("Description: " + Err.Description)
        Select Case Err.Number
            Case 70:
                MsgBox "The library file could not be deleted.  Please close the Media Player and try again.", , "Error deleting file"
        End Select
    End If
    
    On Error GoTo 0
End Sub


Function GetGlobalMediaPlayer() As WindowsMediaPlayer
    Dim player As WindowsMediaPlayer
    
    On Error Resume Next
    Set player = Sheets("Player").ocxPlayer
    On Error GoTo 0
    
    Set GetGlobalMediaPlayer = player
End Function


Function GetSinglePlaylistFromName(strName As String) As IWMPPlaylist
    Dim pla As IWMPPlaylistArray
    Dim player As WindowsMediaPlayer
    Dim plRetVal As IWMPPlaylist
    
    Set player = GetGlobalMediaPlayer()
    Set pla = player.playlistCollection.getByName(strName)
    
    If (pla.Count = 0) Then
        Debug.Print ("WARNING: There were " + CStr(pla.Count) + " playlists with the name " + strName)
    Else
        Set plRetVal = pla.Item(0)
    End If
    
    Set GetSinglePlaylistFromName = plRetVal
End Function


Function GetAttributeContents(strAttribute As String, media As IWMPMedia3) As String
    Dim strAttrValue As String
    Dim iAttrCount As Integer
    Dim n As Integer
    
    strAttrValue = ""
    iAttrCount = 0
                
    If (Not IsNull(media)) Then
        iAttrCount = media.getAttributeCountByType(strAttribute, "")
        Select Case iAttrCount
            Case 0
            Case 1
                strAttrValue = media.getItemInfo(strAttribute)
            Case Else
                For n = 0 To iAttrCount - 1
                    strAttrValue = strAttrValue + media.getItemInfoByType(strAttribute, "", n) + ";"
                Next
                strAttrValue = Replace(strAttrValue, "; ", ";")
                strAttrValue = Left(strAttrValue, Len(strAttrValue) - 1)
            End Select
    End If
    
    GetAttributeContents = strAttrValue
End Function


Function SetMediaSubAttributeCollection(media As IWMPMedia3, strAttribute As String, colSubAttribs As Collection, colSubAttribValues As Collection) As Boolean
    Dim bRetVal As Boolean
    Dim strWholeString As String
    Dim n As Long
    Dim strSubAttrib As String
    Dim strSubAttribValue As String
    Dim str As String
    Dim strInitialValue As String

    bRetVal = True

    If ((colSubAttribs Is Nothing) Or (colSubAttribValues Is Nothing)) Then
        Debug.Print ("ERROR:  Collections must be specified for sub-attribute names and values")
        bRetVal = False
        GoTo FN_EXIT
    End If

    If (colSubAttribs.Count <> colSubAttribValues.Count) Then
        Debug.Print ("ERROR:  Sub-Attribute names and values are mismatched (different count)")
        bRetVal = False
        GoTo FN_EXIT
    End If

    ' Store the initial value of the attribute so we know if there have been changes
    strInitialValue = GetAttributeContents(strAttribute, media)

    ' Iterate through the provided list of sub-attributes
    For n = 1 To colSubAttribs.Count
        strSubAttrib = colSubAttribs.Item(n)
        strSubAttribValue = colSubAttribValues.Item(n)

        ' Build a running list of the sub-attributes and values
        strWholeString = strWholeString + strSubAttrib
        If (strSubAttribValue <> "_null_") Then
            strWholeString = strWholeString + ":" + strSubAttribValue
        End If
        strWholeString = strWholeString + ";"
    Next

    ' Trim off the leading semicolon
    If (Right(strWholeString, 1) = ";") Then
        strWholeString = Left(strWholeString, Len(strWholeString) - 1)
    End If

    ' If we've made changes to the list, save them to the library and file
    If (strWholeString <> strInitialValue) Then
        On Error Resume Next
        Err.Clear
        media.setItemInfo strAttribute, strWholeString
        If (Err.Number > 0) Then
            Debug.Print ("WARNING: Couldn't set attributes on file " + media.Name)
            Debug.Print ("Error code: " + CStr(Err.Number))
        End If
        On Error GoTo 0
    End If

FN_EXIT:
    SetMediaSubAttributeCollection = bRetVal
End Function


'
' Adds a value to the list of sub-attributes, or replaces a value if the sub-attribute
' already exists
'
' Uses SetMediaSubAttributeCollection routine to convert the collection to a list, and assign
' it to the media file.
'
' BUGBUG:  Seems like performance could be improved by doing the operations on a string collection.
' BUGBUG:     but I haven't built the InMemoryCollection functions yet. (7/10/2012)
'
Function SetMediaSubAttribute(media As IWMPMedia, strAttribute As String, strSubAttribute As String, strValue As String) As Boolean
    Dim strAttribContents As String
    Dim strInitialContents As String
    Dim colSubAttrs As Collection
    Dim strSubAttr As String
    Dim n As Long
    Dim bSubAttributeExists As Boolean
    Dim strSubAttrName As String
    Dim strSubAttrValue As String
    Dim colSubAttrValues As Collection
    Dim colSubAttrNames As Collection
    Dim colTokens As Collection
    Dim strAttributeContents As String
    
    Set colSubAttrNames = GetMediaSubAttributeCollection(media, strAttribute, colSubAttrValues)
    strAttribContents = GetAttributeContents(strAttribute, media)
    strInitialContents = strAttribContents
    
    If (InStr(strAttribContents, strSubAttribute)) Then
        n = GetCollectionValueIndex(colSubAttrNames, strSubAttribute)
        If (n > 0) Then
            ReplaceCollectionElement colSubAttrValues, n, strValue
        End If
    Else
        colSubAttrNames.Add strSubAttribute
        colSubAttrValues.Add strValue
    End If
    
    SetMediaSubAttributeCollection media, strAttribute, colSubAttrNames, colSubAttrValues
End Function


'
' Removes a specified sub attribute from a media item.
'
' media             = the media item on which the subattribute is to be removed
' strAttribute      = the Windows Media attribute which contains the subattribute
' strSubAttribute   = the subattribute to be removed
' strValue          = if specified, only subattributes with this value are removed
' bNVPairsOnly      = if true, only subattributes which are name/value pairs are removed
'
' Notes:
'  - Specify strValue or strSubAttribute = "*" to remove all subattributes/values
'
Function RemoveMediaSubAttribute(media As IWMPMedia, strAttribute As String, strSubAttribute As String, Optional strValue As String = "*", Optional bNVPairsOnly As Boolean = True) As Boolean
    Dim strAttrContents As String
    Dim strInitialAttrContents As String
    Dim n As Long
    Dim colSubAttributes As Collection
    Dim strSubAttr As String
    Dim bFoundToken As Boolean
    Dim strSubAttrName As String
    Dim strSubAttrValue As String
    Dim strNVPDelimiter As String
    Dim bRemoveSubAttribute As Boolean
    Dim nSubAttributes As Long

    Dim strTest As String

    bFoundToken = False

    strNVPDelimiter = ":"

    strAttrContents = GetAttributeContents(strAttribute, media)
    Set colSubAttributes = TokenizeToCollection(strAttrContents, ";")
    strInitialAttrContents = strAttrContents

    nSubAttributes = colSubAttributes.Count
    n = 1
    While n <= nSubAttributes
        strSubAttr = colSubAttributes.Item(n)
        strSubAttrName = Before(strSubAttr, strNVPDelimiter)
        strSubAttrValue = After(strSubAttr, strNVPDelimiter)

        bRemoveSubAttribute = True

        ' Run the gauntlet of conditions that would stop us from removing this
        ' subattribute

        ' Don't remove elements that aren't a name/value pair, if we're not supposed to
        If ((bNVPairsOnly) And (Not IsNameValuePair(strSubAttr, strNVPDelimiter))) Then
            bRemoveSubAttribute = False
        End If

        ' Don't remove sub-attributes with the wrong name
        If ((strSubAttribute <> "*") And (strSubAttrName <> strSubAttribute)) Then
            bRemoveSubAttribute = False
        End If

        ' Don't remove sub-attributes with the wrong balue
        If ((strValue <> "*") And (strValue <> strSubAttrValue)) Then
            bRemoveSubAttribute = False
        End If

        ' If this sub-attribute meets all the criteria, remove it from the collection
        If (bRemoveSubAttribute) Then
            colSubAttributes.Remove n
            n = n - 1
            nSubAttributes = nSubAttributes - 1
        End If

        n = n + 1
    Wend

    ' Rebuild the string we'd store in the library and file
    strAttrContents = CollectionToString(colSubAttributes)

    ' Only write the string back to the library if anything has changed
    If (strInitialAttrContents <> strAttrContents) Then
        media.setItemInfo strAttribute, strAttrContents
    End If

FN_EXIT:
    RemoveMediaSubAttribute = bFoundToken
End Function


Function GetMediaSubAttributeCollection(media As IWMPMedia, strAttribute As String, Optional colValues As Collection) As Collection
    Dim strAttr As String
    Dim n As Long
    Dim m As Long
    Dim strSubAttr As String
    Dim strSubAttrValue As String
    Dim str As String
    Dim strWholeString As String

    Dim colTokens As Collection
    Dim colSubAttrs As New Collection
    Dim colSubAttrValues As New Collection
    Dim strAttrContents As String

    strWholeString = ""

    strAttrContents = GetAttributeContents(strAttribute, media)
    Set colTokens = TokenizeToCollection(strAttrContents, ";")

    For n = 1 To colTokens.Count
        str = colTokens.Item(n)
        If (InStr(1, str, ":") = 0) Then
            strSubAttr = str
            strSubAttrValue = "_null_"
        Else
            strSubAttr = Before(str, ":")
            strSubAttrValue = After(str, ":")
        End If

        colSubAttrs.Add strSubAttr
        colSubAttrValues.Add strSubAttrValue
    Next

    ' BUGBUG: Seems bad to assign this if the argument wasn't passed.  Do we leak?
'    If (Not colValues Is Nothing) Then
        Set colValues = colSubAttrValues
'    End If

    Set GetMediaSubAttributeCollection = colSubAttrs
End Function


'**************
' Sample Code
'**************
'
' Sample code to list the values of each available attribute for
' a specified media file
'
Sub EnnumerateAttributes()
    Dim player As WindowsMediaPlayer
    Dim medialist As IWMPPlaylist
    Dim media As IWMPMedia3
    Dim strItemTitle As String
    Dim strAttr As String
    Dim strValue As String
    Dim mc As IWMPMediaCollection2
    Dim qry As IWMPQuery
    Dim pl As IWMPPlaylist
    Dim strWritable As String
    Dim i As Integer
    Dim j As Integer

    strItemTitle = "Miss Independent"
    Set player = GetGlobalMediaPlayer()
    
    Set medialist = player.mediaCollection.getByName(strItemTitle)
    Set media = medialist.Item(0)

    For i = 0 To media.attributeCount - 1
        strAttr = media.getAttributeName(i)
        strValue = GetAttributeContents(strAttr, media)
        If (media.isReadOnlyItem(strAttr)) Then
            strWritable = "Read-Only"
        Else
            strWritable = "Read-Write"
        End If
        Debug.Print (strAttr + " : " + strValue + " (" + strWritable + ")")
    Next
End Sub


'
' Sample code showing how to create a playlist using the
' query object
'
Sub btnGetPlaylistFromAttribute()
    Dim player As WindowsMediaPlayer
    Dim strAttr As String
    Dim strValue As String
    Dim mc As IWMPMediaCollection2
    Dim qry As IWMPQuery
    Dim medialist As IWMPPlaylist
    Dim media As IWMPMedia3
    Dim pl As IWMPPlaylist

    Set player = GetGlobalMediaPlayer()

    strAttr = "WM/Category"
    strValue = "Night"
    Set mc = player.mediaCollection
    Set qry = mc.createQuery()
    qry.addCondition strAttr, "contains", strValue
    Set pl = mc.getPlaylistByQuery(qry, "audio", strAttr, True)
    Debug.Print ("New playlist contains " + CStr(pl.Count) + " songs.")
End Sub



' *************
'   Playlists
' *************
Sub btnStorePlaylistCollectionInFiles()
    StorePlaylistCollectionInFiles "WM/Category", True
End Sub

Sub StorePlaylistCollectionInFiles(Optional strAttribute As String = "WM/Category", Optional bPurgeFirst As Boolean = False)
    Dim player As WindowsMediaPlayer
    Dim media As IWMPMedia3
    Dim i As Integer
    Dim j As Integer
    Dim nNumPlaylists As Integer
    Dim Playlists As IWMPPlaylistArray
    Dim playlist As IWMPPlaylist
    Dim strPlaylistName As String
    Dim strPlaylistType As String
    Dim colTokens As Collection
    Dim bSyncOnly As Boolean
    
'   Get the Media Player object and list of playlists
    Set player = GetGlobalMediaPlayer()
    Set Playlists = player.playlistCollection.getAll
    nNumPlaylists = Playlists.Count
    
    ' If specified in the argument list, purge all existing values for the attribute
    If (bPurgeFirst) Then
        RemoveSubAttributeFromMusicCollection strAttribute, "*"
    End If
    
'   Iterate through the list of playlists.  In some cases the playlist collection may
'   contain a playlist that doesn't exist, and in some cases the files in the playlist are
'   read only or missing.  Error handling covers these cases.
    
    For i = 0 To nNumPlaylists - 1
        On Error Resume Next
        Err.Clear
        Set playlist = Playlists.Item(i)
        If (Err.Number <> 0) Then
            Debug.Print ("Playlist #" + CStr(i) + " is corrupt or missing.")
        Else
            strPlaylistName = playlist.Name
            Debug.Print ("Playlist #" + CStr(i) + ": " + strPlaylistName)
            Set colTokens = TokenizeToCollection(strPlaylistName, "_")

            Set playlist = GetSinglePlaylistFromName(strPlaylistName)
            strPlaylistType = playlist.getItemInfo("PlaylistType")
            bSyncOnly = CBool(playlist.getItemInfo("SyncOnly"))

            If (strPlaylistType <> "Auto") Then
                MsgBox "Applying playlist info for " + strPlaylistName, vbInformation
                For j = 0 To playlist.Count - 1
                    Set media = playlist.Item(j)
                    SetMediaSubAttribute media, strAttribute, strPlaylistName, CStr(j)
                Next
            End If
        End If
    Next
End Sub


Sub btnStorePlaylistInFiles()
    Dim strPlaylist As String
    
    strPlaylist = Range("cfg_Source_Playlist")
    StorePlaylistInFiles strPlaylist, "WM/Category", True
End Sub

Sub StorePlaylistInFiles(strPlaylist As String, Optional strAttribute As String = "WM/Category", Optional bPurgeFirst As Boolean = True)
    Dim player As WindowsMediaPlayer
    Dim media As IWMPMedia3
    Dim pl As IWMPPlaylist
    Dim j As Integer
    Dim mc As IWMPMediaCollection2
    Dim qry As IWMPQuery
    Dim n As Long
    
    ' Get the Media Player object
    Set player = GetGlobalMediaPlayer()
    
    ' Remove any existing instances of this playlist from files in the library
    If (bPurgeFirst) Then
        Set mc = player.mediaCollection
        Set qry = mc.createQuery
        qry.addCondition strAttribute, "contains", strPlaylist
        Set pl = mc.getPlaylistByQuery(qry, "audio", "", True)
        For n = 1 To pl.Count - 1
            Set media = pl.Item(n)
            RemoveMediaSubAttribute media, strAttribute, strPlaylist, "*", True
        Next
    End If
    
    MsgBox "Applying playlist info for " + strPlaylist, vbInformation
    Set pl = GetSinglePlaylistFromName(strPlaylist)
    For j = 0 To pl.Count - 1
        Set media = pl.Item(j)
        SetMediaSubAttribute media, strAttribute, strPlaylist, CStr(j)
    Next
End Sub


Sub btnRemoveSpecifiedSubAttribute()
    Dim strAttribute As String
    Dim strSubAttribute As String
    
    strAttribute = Range("cfg_Attribute")
    strSubAttribute = Range("cfg_SubAttribute")
    
    RemoveSubAttributeFromMusicCollection strAttribute, strSubAttribute
End Sub


Function ApplySubAttributeValueToPlaylist(playlist As IWMPPlaylist, strAttribute As String, strSubAttribute As String, strValue As String) As Boolean
    Dim bRetVal As Boolean
    Dim strAttribContents As String
    Dim media As IWMPMedia3
    Dim i As Integer
    Dim j As Integer
    Dim strTokens() As String
    Dim bTokenExists As Boolean
    Dim nIndex As Integer
    Dim colTokens As Collection
    Dim strTest As String
    Dim strInitialContents As String

    bRetVal = True

    For i = 0 To playlist.Count - 1
        Set media = playlist.Item(i)
        Debug.Print ("  Applying to " + media.Name)
        SetMediaSubAttribute media, strAttribute, strSubAttribute, strValue
    Next
    
    ApplySubAttributeValueToPlaylist = bRetVal
End Function


' ***************
'   Collections
' ***************
Function RemoveSubAttributeFromMusicCollection(strAttribute As String, strSubAttribute As String) As Long
    Dim nRetVal As Long
    Dim player As WindowsMediaPlayer
    Dim medialist As IWMPPlaylist
    Dim media As IWMPMedia3
    Dim strItemTitle As String
    Dim mc As IWMPMediaCollection2
    Dim qry As IWMPQuery
    Dim pl As IWMPPlaylist
    Dim strWritable As String
    Dim i As Integer
    Dim j As Integer
    Dim n As Long
    Dim strLocalVal As String
    Dim strMediaType As String
    
    nRetVal = 0
    strLocalVal = strSubAttribute
    strMediaType = "audio"

    Set player = GetGlobalMediaPlayer()
    Set mc = player.mediaCollection
    Set qry = mc.createQuery()
    
    If (strSubAttribute = "*") Then
        qry.addCondition strAttribute, "NotEquals", ""
    Else
        qry.addCondition strAttribute, "Contains", strSubAttribute
    End If
    
    Set pl = mc.getPlaylistByQuery(qry, strMediaType, strAttribute, True)
    Debug.Print ("Removing " + strAttribute + ": " + strLocalVal + " from " + CStr(pl.Count) + " songs.")

    For n = 0 To pl.Count - 1
        Set media = pl.Item(n)
        Debug.Print media.Name
        RemoveMediaSubAttribute media, strAttribute, strSubAttribute, "*", True
    Next

    RemoveSubAttributeFromMusicCollection = pl.Count
End Function


' ***********
'   Library
' ***********

Sub btnExtractAllAttributesFromCollection()
    Dim strWksName As String
    Dim wks As Worksheet
    Dim nCol As Long
    Dim nRow As Long
    Dim player As WindowsMediaPlayer
    Dim n As Long
    Dim nAttributeIndex As Long
    Dim media As IWMPMedia3
    Dim mc As IWMPMediaCollection2
    Dim pl As IWMPPlaylist
    Dim nAttributeCount As Long
    Dim strAttributeName As String
    Dim strValue As String
    
    strWksName = Range("cfg_Source_Worksheet")
    Set wks = GetDataSheet(strWksName, True)
    ResetData strWksName, 1
    
    FormatColumnWidths wks, Array(16, 18, 22, 18, 26, 28, 8)
    
    nCol = 1
    nRow = 2
    
    Set player = GetGlobalMediaPlayer()
    Set mc = player.mediaCollection
    Set pl = mc.getAll
    
    For n = 0 To pl.Count - 1
        Set media = pl.Item(n)
        nAttributeCount = media.attributeCount
        Debug.Print ("Extracting media file #" + CStr(n))
        
        For nAttributeIndex = 0 To nAttributeCount - 1
            strAttributeName = media.getAttributeName(nAttributeIndex)
            strValue = GetAttributeContents(strAttributeName, media)
            
            nCol = GetColumnByHeading(strAttributeName, wks.Rows(1), True)
            
            wks.Cells(nRow, nCol) = strValue
        Next
        nRow = nRow + 1
    Next
End Sub



Sub btnExtractAttributes()
    Dim strDestSheetName As String
    Dim strSourceTitle As String
    
    strDestSheetName = Range("cfg_Dest_Worksheet")
    strSourceTitle = Range("cfg_Source_Media_Name")
    
    RetrieveAttributesFromMediaItem strSourceTitle, strDestSheetName
End Sub


'Function SearchForNewAttributes(rngSrc As Range) As Integer
'    Dim attr As Range
'    Dim nFoundCol As Integer
'    Dim rngKnownAttributes As Range
'
'    Dim strAttributesWorksheetName As String
'    Dim wksAttributes As Worksheet
'
'    Dim nAttributeCount As Integer
'    Dim nNewAttributeCount As Integer
'
'    nNewAttributeCount = 0
'    strAttributesWorksheetName = "Database"
'    Set wksAttributes = GetDataSheet(strAttributesWorksheetName, False)
'    nAttributeCount = wksAttributes.Cells(1, 1).End(xlRight).Row
'
'    Set rngKnownAttributes = wksAttributes.Cells(1, 1).Resize(1, nAttributeCount)
'
'    For Each attr In rngSrc.Cells
'        If (attr.Value <> "") Then
'            nFoundCol = FindValueInColumn(rngKnownAttributes, attr.Value, 1)
'            If (nFoundCol = 0) Then
'                nNewAttributeCount = nNewAttributeCount + 1
'                rngKnownAttributes.Cells(nAttributeCount + nNewAttributeCount).Value = attr.Value
'                Debug.Print ("**** Added attribute " + WrapInQuotes(attr.Value) + " to the attribute list.")
'            End If
'        End If
'    Next
'
'    SearchForNewAttributes = nNewAttributeCount
'End Function



Sub RetrieveAttributesFromMediaItem(strItemTitle As String, strDestSheetName As String)
    Dim player As WindowsMediaPlayer
    Dim wksDest As Worksheet
    Dim medialist As IWMPPlaylist
    Dim media As IWMPMedia3
    
    Dim nNumAttributes As Integer
    Dim nDestRow As Integer
    Dim nAttrCol As Integer
    
    Dim strAttr As String
    Dim strValue As String
    
    Dim n As Integer
    Dim i As Integer
    Dim nNumMedia As Integer
    Dim nColumnWidths() As Long
    
    If (strDestSheetName = "") Then
        strDestSheetName = GetBaseName(strItemTitle)
    End If
    
    Set player = GetGlobalMediaPlayer()

    Set wksDest = GetDataSheet(strDestSheetName, True)
    ResetData strDestSheetName, 2
    nDestRow = FindLastRow(wksDest.Cells(1, 1)).Row + 1
    
    If (strItemTitle = "*") Then
        Set medialist = player.mediaCollection.getAll
    Else
        Set medialist = player.mediaCollection.getByName(strItemTitle)
    End If
    
    If (medialist.Count = 0) Then
        Debug.Print ("There are no items in the library called " + Chr(34) + strItemTitle + Chr(34))
        GoTo RETRIEVE_ATTRIBUTES_FROM_MEDIA_ITEM_EXIT
    End If
    
    nNumMedia = medialist.Count
    
    For i = 0 To nNumMedia - 1
        Set media = medialist.Item(i)
        nNumAttributes = media.attributeCount
        For n = 0 To nNumAttributes - 1
            strAttr = media.getAttributeName(n)
            strValue = GetAttributeContents(strAttr, media)
            
            nAttrCol = GetColumnByHeading(strAttr, wksDest.Rows(1), True)
            wksDest.Cells(nDestRow, nAttrCol) = CStr(strValue)
        Next
        nDestRow = nDestRow + 1
    Next
    
    ReDim nColumnWidths(wksDest.Cells(1, 1).End(xlToRight).Column)
    FormatColumnWidths wksDest, nColumnWidths

RETRIEVE_ATTRIBUTES_FROM_MEDIA_ITEM_EXIT:
End Sub


' ************
'   Playback
' ************
Sub btn_TogglePlaybackClick()
    Dim bToggle As Boolean
    Dim player As WindowsMediaPlayer
        
    Set player = GetGlobalMediaPlayer()
    If (player.URL = "") Then
        player.URL = Range("cfg_SourceTitle")
    End If
    
    Select Case player.playState
        Case wmppsPaused
            player.Controls.Play
        Case wmppsPlaying
            player.Controls.pause
    End Select
End Sub



' ********************************


Function GetMediaSubAttribute(media As IWMPMedia, strAttribute As String, strSubAttribute As String) As String

End Function


Function InsertMediaSubAttribute(media As IWMPMedia, strAttribute As String, strSubAttribute As String, nPosition As Long) As Boolean

End Function


Function AppendMediaSubAttribute(media As IWMPMedia, strAttribute As String, strSubAttribute As String) As Boolean

End Function



