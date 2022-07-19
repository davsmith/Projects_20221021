Attribute VB_Name = "MediaPlayer_Playlists"
Option Explicit


Sub btnTest()
End Sub


'
' Traverses the playlist collection, looking for those containing
' songs that have been weighted for a particular category (eg. Night time songs,
' children's songs, etc).
'
' The songs in these playlists are then tagged by writing the category name
' and weight to the Mood field in the song.
'
' These playlists are identified by naming them with the category/mood name,
' followed by an _ and a weight of 1 to 5.
'
Sub btnApplyMoodPlaylistsToCollection()
    Dim player As WindowsMediaPlayer
    Dim Playlists As IWMPPlaylistArray
    Dim nNumPlaylists As Integer
    Dim i As Integer
    Dim strPlaylistName As String
    Dim nMoodRating As Long
    Dim colTokens As Collection
    Dim strMood As String
    Dim playlist As IWMPPlaylist
    Dim strDelim As String
    Dim strAttribute As String
    
    strDelim = "#"
    strAttribute = "WM/Mood"
    
    ' Get the Media Player object and playlist collection
    Set player = GetGlobalMediaPlayer()
    Set Playlists = player.playlistCollection.getAll
    nNumPlaylists = Playlists.Count
    
    '
    ' For each playlist, determine if it's a "mood playlist" by
    ' checking for a #, followed by a digit 1 to 5.
    '
    ' If it's a mood playlist, the digit is the weight of the
    ' tracks in the playlist, and the value before the # is
    ' the mood.
    '
    For i = 0 To nNumPlaylists - 1
        strPlaylistName = Playlists.Item(i).Name
        nMoodRating = 0
        Debug.Print ("Playlist #" + CStr(i) + ": " + strPlaylistName)
        Set colTokens = TokenizeToCollection(strPlaylistName, strDelim)
        
        If (IsNumeric(colTokens.Item(colTokens.Count))) Then
            nMoodRating = CLng(colTokens(colTokens.Count))
        End If
        
        Select Case nMoodRating
            Case 1 To 5:
                strMood = Before(strPlaylistName, strDelim + colTokens(colTokens.Count))
                MsgBox "Adding tags for " + strMood + " with a weight of " + CStr(nMoodRating)
                Set playlist = GetSinglePlaylistFromName(strPlaylistName)
                RemoveSubAttributeFromMusicCollection strAttribute, strMood
                ApplySubAttributeValueToPlaylist playlist, strAttribute, strMood, CInt(nMoodRating)
        End Select
    Next
End Sub


'Sub RemoveRatedMoodsFromCollection()
'    Dim nRetVal As Long
'    Dim strAttr As String
'    Dim strMediaType As String
'    Dim player As WindowsMediaPlayer
'    Dim mc As IWMPMediaCollection2
'    Dim qry As IWMPQuery
'    Dim pl As IWMPPlaylist
'    Dim n As Long
'    Dim media As IWMPMedia3
'
'    nRetVal = 0
'
'    strAttr = "WM/Mood"
'    strMediaType = "audio"
'
'    Set player = GetGlobalMediaPlayer()
'    Set mc = player.mediaCollection
'
'    Set qry = mc.createQuery()
'    qry.addCondition strAttr, "NotEquals", ""
'    Set pl = mc.getPlaylistByQuery(qry, strMediaType, strAttr, True)
'    Debug.Print ("Removing rated moods from " + CStr(pl.Count) + " songs.")
'
'    For n = 0 To pl.Count - 1
'        Set media = pl.Item(n)
'        Debug.Print media.Name
'        RemoveMediaSubAttribute media, strAttr, "*", "*", True
'    Next
'
'    Set qry = Nothing
'End Sub


'Sub RemoveEmbeddedPlaylistsFromCollection()
'    Dim player As WindowsMediaPlayer
'    Dim media As IWMPMedia3
'    Dim strAttr As String
'    Dim mc As IWMPMediaCollection2
'    Dim qry As IWMPQuery
'    Dim pl As IWMPPlaylist
'    Dim n As Long
'    Dim strMediaType As String
'
'    strAttr = "WM/Category"
'    strMediaType = "audio"
'
'    Set player = GetGlobalMediaPlayer()
'    Set mc = player.mediaCollection
'
'    Set qry = mc.createQuery()
'    qry.addCondition strAttr, "NotEquals", ""
'    Set pl = mc.getPlaylistByQuery(qry, strMediaType, strAttr, True)
'    Debug.Print ("Removing embedded playlist info from " + CStr(pl.Count) + " files.")
'
'    For n = 0 To pl.Count - 1
'        Set media = pl.Item(n)
'        Debug.Print media.Name
'        RemoveMediaSubAttribute media, strAttr, "*", "*", True
'    Next
'
'    Set qry = Nothing
'End Sub


Sub GeneratePlaylistFromMood()
    Dim nRetVal As Long
    Dim strAttr As String
    Dim strMediaType As String
    Dim strMood As String
    Dim nNumSongs As Long
    Dim strNewPlaylistName As String
    Dim nTarget(4) As Long
    Dim i As Integer
    Dim player As WindowsMediaPlayer
    Dim mc As IWMPMediaCollection2
    Dim pla As IWMPPlaylistArray
    Dim n As Long
    Dim plNew As IWMPPlaylist
    Dim qry As IWMPQuery
    Dim plAvailableTracks(4) As IWMPPlaylist
    Dim iFrom As Long
    Dim iTo As Long
    Dim iDirection As Integer
    Dim j As Integer
    Dim nIndex As Long
    Dim nRollover As Long
    Dim nNumToUse As Long
    Dim media As IWMPMedia3
    
    nRetVal = 0
    
    ' Initialize variables, including reading from config sheet.
    strAttr = "WM/Mood"
    strMediaType = "audio"
    strMood = Range("cfg_NewPlaylistMood")
    nNumSongs = CLng(Range("cfg_NumSongs"))
    strNewPlaylistName = Range("cfg_NewPlaylistName")
    If (strNewPlaylistName = "") Then
        strNewPlaylistName = "Mood"
    End If
    
    ' Initialize the random number generator
    Randomize
    
    ' Calculate the number of songs to be used from each weighting category
    ' This is based on percentages specified on the config sheet.
    For i = 0 To 4
        nTarget(i) = Range("cfg_NewPlaylistWeight").Offset(i, 1) * nNumSongs
    Next
        
    ' Remove any existing instances of the specified playlist name,
    ' then create a new, empty playlist
    Set player = GetGlobalMediaPlayer()
    Set mc = player.mediaCollection
    Set pla = player.playlistCollection.getByName(strNewPlaylistName)
    For n = 0 To pla.Count - 1
        Set plNew = pla.Item(n)
        player.playlistCollection.Remove plNew
    Next
    
    Set plNew = player.playlistCollection.newPlaylist(strNewPlaylistName)
    
    '
    ' For each of the weight categories query the media collection for
    ' songs tagged with the mood and the weighting
    '
    For i = 0 To 4
        Set qry = mc.createQuery()
        qry.addCondition strAttr, "contains", strMood + ":" + CStr(i + 1)
        Set plAvailableTracks(i) = mc.getPlaylistByQuery(qry, strMediaType, strAttr, True)
        Debug.Print ("Found " + CStr(plAvailableTracks(i).Count) + " songs with a mood of " + strMood + " and a weight of " + CStr(i + 1))
    Next
    
    ' Loop through each of the weight values choosing songs randomly with the specified weight
    iFrom = 0
    iTo = 4
    iDirection = 1
    
    '
    ' Loop twice, once counting up and once counting down
    '
    For j = 1 To 2
        For i = iFrom To iTo Step iDirection
            ' Check if we have enough songs in this category to meet the target.  If not,
            ' calculate how many we're short and increase the next target
            nRollover = Application.WorksheetFunction.Max(0, nTarget(i) - plAvailableTracks(i).Count)
            nNumToUse = Application.WorksheetFunction.Min(plAvailableTracks(i).Count, nTarget(i))
        
            For n = 1 To nNumToUse
                nIndex = Int((plAvailableTracks(i).Count * Rnd))
                Set media = plAvailableTracks(i).Item(nIndex)
                plAvailableTracks(i).RemoveItem media
                plNew.appendItem media
            Next
            
            ' Push the rollover up or down depending on the direction we're counting
            Select Case iDirection
                Case 1:
                    If ((i < 4) And (nRollover > 0)) Then
                        nTarget(i + 1) = nTarget(i + 1) + nRollover
                        Debug.Print ("  Not enough songs weighted " + CStr(i + 1) + ".  Rolling over " + CStr(nRollover))
                    End If
                Case -1:
                    If ((i > 0) And (nRollover > 0)) Then
                        nTarget(i - 1) = nTarget(i - 1) + nRollover
                        Debug.Print ("  Not enough songs weighted " + CStr(i + 1) + ".  Rolling over " + CStr(nRollover))
                    End If
            End Select
            nTarget(i) = 0
            
            Set qry = Nothing
        Next
        
        '
        ' If we get to the top of the loop, and don't have enough songs,
        ' count back down to get songs with same mood, but different weight.
        '
        If ((j = 1) And (nRollover > 0)) Then
            nTarget(3) = nRollover
            iFrom = 3
            iTo = 0
            iDirection = -1
        End If
    Next
    
    ' Shuffle the new playlist
    For i = 1 To 10
        For n = 0 To plNew.Count - 1
            plNew.moveItem n, Int((plNew.Count * Rnd))
        Next
    Next
    
End Sub


'
' Iterates through the existing playlists in the playlist collection and embeds
' the name of the playlist in each of the files in the playlist, such that the
' playlist can be rebuilt by extracting the playlist name from each of the files.
'
Sub btnEmbedPlaylistInfo()
    Dim strPlaylist As String
    
    strPlaylist = Range("cfg_Source_Playlist")
    EmbedPlaylistInFile strPlaylist, "WM/Category", True
End Sub

Sub EmbedPlaylistInFile(strPlaylist As String, Optional strAttribute As String = "WM/Category", Optional bPurgeFirst As Boolean = False)
    Dim player As WindowsMediaPlayer
    Dim media As IWMPMedia3
    Dim pl As IWMPPlaylist
    Dim j As Integer
    
    If (bPurgeFirst) Then
        RemoveSubAttributeFromMusicCollection strAttribute, "*"
    End If
    
    ' Get the Media Player object and playlist
    Set player = GetGlobalMediaPlayer()
    Set pl = GetSinglePlaylistFromName(strPlaylist)
    
    For j = 0 To pl.Count - 1
        Set media = pl.Item(j)
        SetMediaSubAttribute media, strAttribute, strPlaylist, CStr(j)
    Next
End Sub


Sub Test1()
    StoreAllPlaylistsInFiles
End Sub

Sub StoreAllPlaylistsInFiles(Optional strAttribute As String = "WM/Category", Optional bPurgeFirst As Boolean = False)
    Dim player As WindowsMediaPlayer
    Dim pl As IWMPPlaylist
    Dim playlist As IWMPPlaylist
    Dim Playlists As IWMPPlaylistArray
    Dim nNumPlaylists As Integer
    Dim i As Integer
    Dim strPlaylistName As String
    Dim strPlaylistType As String
    Dim colTokens As Collection
    Dim bSyncOnly As Boolean
    Dim j As Integer
    Dim media As IWMPMedia3
    
    If (bPurgeFirst) Then
        RemoveSubAttributeFromMusicCollection strAttribute, "*"
    End If
    
    ' Get the Media Player object and playlist
    Set player = GetGlobalMediaPlayer()
    
    Set Playlists = player.playlistCollection.getAll
    nNumPlaylists = Playlists.Count
    
    ' Iterate through the list of playlists.  In some cases the playlist collection may
    ' contain a playlist that doesn't exist, and in some cases the files in the playlist are
    ' read only or missing.  Error handling covers these cases.
    '
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
                    SetMediaSubAttribute media, "WM/Category", strPlaylistName, CStr(j)
                Next
            End If
        End If
    Next

End Sub


Sub ExtractPlaylistsFromFiles()
    Dim player As WindowsMediaPlayer
    Dim mc As IWMPMediaCollection2
    Dim qry As IWMPQuery
    Dim plQry As IWMPPlaylist
    Dim strAttr As String
    Dim n As Long
    Dim o As Long
    Dim media As IWMPMedia3
    Dim strAttribContents As String
    Dim colSubAttribs As Collection
    Dim strName As String
    Dim strValue As String
    Dim colPlaylistCollection As New Collection
    Dim colPlaylist As Collection

    strAttr = "WM/Category"
    
    Set player = GetGlobalMediaPlayer()

    Set mc = player.mediaCollection
    Set qry = mc.createQuery()
    qry.addCondition strAttr, "NotEquals", ""
    Set plQry = mc.getPlaylistByQuery(qry, "audio", strAttr, True)
    Debug.Print ("New playlist contains " + CStr(plQry.Count) + " songs.")

    For n = 0 To plQry.Count - 1
        Set media = plQry.Item(n)
        strAttribContents = GetAttributeContents(strAttr, media)
        Set colSubAttribs = TokenizeToCollection(strAttribContents, ";")

        For o = 1 To colSubAttribs.Count
            If (IsNameValuePair(colSubAttribs.Item(o), ":")) Then
                strName = Before(colSubAttribs.Item(o), ":")
                strValue = After(colSubAttribs.Item(o), ":")
                
                Set colPlaylist = InMemPlaylists_GetPlaylist(colPlaylistCollection, strName)
                If (colPlaylist Is Nothing) Then
                    Set colPlaylist = New Collection
                    colPlaylist.Add strName
                    colPlaylist.Add media
                    colPlaylist.Add CLng(strValue)
                    InMemPlaylists_AddPlaylist colPlaylistCollection, colPlaylist
                Else
                    colPlaylist.Add media
                    colPlaylist.Add CLng(strValue)
                End If
            End If
        Next
    Next
    
    For n = 1 To colPlaylistCollection.Count
        Set colPlaylist = InMemPlaylists_GetPlaylist(colPlaylistCollection, colPlaylistCollection.Item(n).Item(1))
        InMemPlaylists_BuildPlaylist colPlaylist
    Next
End Sub


Function InMemPlaylists_GetPlaylist(colPlaylists As Collection, strName As String) As Collection
    Dim n As Long
    Dim colPlaylist As Collection
    Dim strPlaylistName As String
    Dim colRetVal As Collection
    
    strPlaylistName = ""
    For n = 1 To colPlaylists.Count
        Set colPlaylist = colPlaylists.Item(n)
        If (TypeName(colPlaylist.Item(1)) = "String") Then
            strPlaylistName = colPlaylist.Item(1)
        End If
        If (strPlaylistName = strName) Then
            Set colRetVal = colPlaylist
            n = colPlaylists.Count
        End If
    Next
    
    Set InMemPlaylists_GetPlaylist = colRetVal
End Function

Function InMemPlaylists_AddPlaylist(colPlaylists As Collection, colPlaylist As Collection) As Boolean
    Dim bRetVal As Boolean
    Dim n As Long
    
    bRetVal = True
    n = 2
    
    ' Check the integrity of the collection
    If (colPlaylist.Count < 1) Then
        bRetVal = False
        GoTo FN_EXIT
    End If
    
    If (TypeName(colPlaylist.Item(1)) <> "String") Then
        bRetVal = False
        GoTo FN_EXIT
    End If
    
    While n < colPlaylist.Count - 1
        If (TypeName(colPlaylist.Item(n)) <> "IWMPMedia3") Then
            bRetVal = False
        End If
        
        If (TypeName(colPlaylist.Item(n + 1)) <> "Long") Then
            bRetVal = False
        End If
        n = n + 2
    Wend
    
    If (bRetVal) Then
        colPlaylists.Add colPlaylist
    End If
    
FN_EXIT:
    InMemPlaylists_AddPlaylist = bRetVal
End Function


Function InMemPlaylists_BuildPlaylist(colPlaylist As Collection) As IWMPPlaylist
    
    Dim player As WindowsMediaPlayer
    Dim medialist As IWMPPlaylist
    Dim media As IWMPMedia3
    Dim strItemTitle As String
    Dim strAttr As String
    Dim strValue As String
    Dim mc As IWMPMediaCollection2
    Dim qry As IWMPQuery
    Dim plQry As IWMPPlaylist
    Dim plDest As IWMPPlaylist
    Dim strAttribContents As String
    Dim strWorkingString As String
    Dim n As Long
    Dim nTrackCount As Long
    Dim arnTrackIndex() As Long
    Dim o As Long
    Dim strName As String
    
    Dim colSubAttribs As Collection
    Dim colTrackNames As New Collection
    Dim colTrackOrder As New Collection
    Dim colPlayListNames As New Collection
    Dim colPlaylistCollection As New Collection
    Dim pla As IWMPPlaylistArray
    
    nTrackCount = (colPlaylist.Count - 1) / 2
    ReDim arnTrackIndex(nTrackCount - 1)
    
    For n = 1 To nTrackCount
        arnTrackIndex(n - 1) = CLng(colPlaylist.Item((n * 2) + 1))
    Next
    
    BubbleSort arnTrackIndex
    
    Set player = GetGlobalMediaPlayer()
    strName = "_" + colPlaylist.Item(1)
    Set pla = player.playlistCollection.getByName(strName)
    For n = 1 To pla.Count
        Set plDest = pla.Item(n - 1)
        player.playlistCollection.Remove plDest
    Next
    
    
    Set plDest = player.playlistCollection.newPlaylist(strName)
    
    For n = 0 To nTrackCount - 1
        For o = 1 To nTrackCount
            If ((colPlaylist.Item((o * 2) + 1) = arnTrackIndex(n))) Then
                plDest.insertItem n, colPlaylist.Item(o * 2)
            End If
        Next
    Next
    
End Function


Function InMemPlaylists_SortPlaylist(colPlaylist As Collection) As Collection
    Dim strWorkingString As String
    Dim n As Long
    Dim nTrackCount As Long
    
    nTrackCount = (colPlaylist.Count - 1) / 2
End Function





'Sub RepairPlaylist(strSrcPlaylist As String, Optional strDestPlaylist As String = "")
'    Dim player As WindowsMediaPlayer
'    Dim strWorkSheetDest As String
'    Dim wksDest As Worksheet
'    Dim pla As IWMPPlaylistArray
'    Dim plSrc As IWMPPlaylist
'    Dim plDest As IWMPPlaylist
'    Dim nDeleteOK As Long
'    Dim bDeleteOK As Boolean
'    Dim n As Long
'    Dim nRow As Long
'    Dim media As IWMPMedia3
'
'    strWorkSheetDest = "Temp"
'    Set wksDest = GetDataSheet(strWorkSheetDest, True)
'    ResetData strWorkSheetDest, 1
'
'    Set player = GetGlobalMediaPlayer()
'
'    If (strDestPlaylist = "") Then
'        strDestPlaylist = "_" + strSrcPlaylist
'    End If
'
'    Set pla = player.playlistCollection.getByName(strDestPlaylist)
'    If (pla.Count > 0) Then
'        bDeleteOK = (vbYes = MsgBox("OK to delete destination playlist?", vbYesNo, "Destination playlist exists..."))
'        If (bDeleteOK) Then
'            For n = 0 To pla.Count - 1
'                player.playlistCollection.Remove pla.Item(n)
'            Next
'        Else
'            GoTo FN_EXIT
'        End If
'    End If
'
'    Set plDest = player.playlistCollection.newPlaylist(strDestPlaylist)
'    Set plSrc = GetSinglePlaylistFromName(strSrcPlaylist)
'
'    For n = 0 To plSrc.Count - 1
'        Set media = plSrc.Item(n)
'        wksDest.Cells(n + 1, 1) = media.Name
'        wksDest.Cells(n + 1, 2) = GetAttributeContents("SourceURL", media)
'        wksDest.Cells(n + 1, 3) = GetAttributeContents("Title", media)
'    Next
'
'
'FN_EXIT:
'End Sub



Sub btnExtractPlaylistToSheet()
    Dim strSrcPlaylist As String
    Dim strDestSheet As String
    
    strSrcPlaylist = Range("cfg_Source_Playlist")
    strDestSheet = Range("cfg_Dest_Worksheet")

    ExtractPlaylistToSheet strSrcPlaylist, strDestSheet, 1
End Sub

Sub ExtractPlaylistToSheet(strSrcPlaylist As String, strDestSheet As String, Optional nStartRow As Long = 1)
    Dim wksDest As Worksheet
    Dim n As Long
    Dim nRow As Long
    Dim player As WindowsMediaPlayer
    Dim plSrc As IWMPPlaylist
    Dim media As IWMPMedia3
    Dim strPath As String
    Dim arnWidths As Variant
    Dim strTrackingID As String
        
    ' Argument checking
    If (strDestSheet = "") Then
        strDestSheet = strSrcPlaylist
    End If
    
        
    Set wksDest = GetDataSheet(strDestSheet, True)
    
    If (nStartRow = 1) Then
        arnWidths = Array(44, 76, 12, 40, 10, 20)
    
        ResetData strDestSheet, 1
        wksDest.Cells(1, 1) = "Track Name"
        wksDest.Cells(1, 2) = "File Path"
        wksDest.Cells(1, 3) = "Found"
        wksDest.Cells(1, 4) = "Suggestion"
        wksDest.Cells(1, 5) = "TrackingID"
        wksDest.Cells(1, 6) = "AlbumIDAlbumArtist"
        
        wksDest.Cells(1, 1).Resize(1, UBound(arnWidths) + 1).Font.Bold = True
        For n = 0 To UBound(arnWidths)
            wksDest.Columns(n + 1).ColumnWidth = arnWidths(n)
        Next
        
        nRow = 2
    Else
        nRow = nStartRow
    End If
    
    Set player = GetGlobalMediaPlayer()
    Set plSrc = GetSinglePlaylistFromName(strSrcPlaylist)
    
    For n = 0 To plSrc.Count - 1
        Set media = plSrc.Item(n)
        strPath = GetAttributeContents("SourceURL", media)
        strTrackingID = GetAttributeContents("TrackingID", media)

        wksDest.Cells(nRow, 1) = media.Name
        wksDest.Cells(nRow, 2) = strPath
        If (Dir(strPath, vbNormal) <> "") Then
            wksDest.Cells(nRow, 3) = "Found"
        Else
            wksDest.Cells(nRow, 3) = "Not Found"
            
            
            If (IsNumeric(Trim(Left(media.Name, 3)))) Then
                wksDest.Cells(nRow, 4) = Right(media.Name, Len(media.Name) - 3)
            Else
                wksDest.Cells(nRow, 4) = media.Name
            End If
        End If
        wksDest.Cells(nRow, 5) = strTrackingID
        wksDest.Cells(nRow, 6) = GetAttributeContents("AlbumIDAlbumArtist", media)
        
        nRow = nRow + 1
    Next
End Sub


Sub btnRepairPlaylistInSheet()
    Dim strSheetName As String
    
    strSheetName = Range("cfg_Source_Worksheet")
    RepairPlaylistInSheet strSheetName
End Sub

Sub RepairPlaylistInSheet(strSheetName As String)
    Dim wks As Worksheet
    Dim n As Long
    Dim bContainsAlbumInfo As Boolean
    Dim nTrackNameCol As Long
    Dim nFoundCol As Long
    Dim nPathCol As Long
    Dim nSuggestionCol As Long
    Dim nTrackingIDCol As Long
    Dim nAlbumIDArtistCol As Long
    
    Dim strSuggestion As String
    Dim strAttribute As String
    Dim nRow As Long
    Dim qry As IWMPQuery
    Dim pl As IWMPPlaylist
    Dim mc As IWMPMediaCollection2
    Dim player As WindowsMediaPlayer
    Dim strQueryType As String
    Dim strComment As String
    
    nRow = 2
    
    Set player = GetGlobalMediaPlayer()
    Set mc = player.mediaCollection
    
    Set wks = GetDataSheet(strSheetName, False)
    nTrackNameCol = GetColumnByHeading("Track Name", wks.Rows(1))
    nPathCol = GetColumnByHeading("File Path", wks.Rows(1))
    nFoundCol = GetColumnByHeading("Found", wks.Rows(1))
    nSuggestionCol = GetColumnByHeading("Suggestion", wks.Rows(1))
    nTrackingIDCol = GetColumnByHeading("TrackingID", wks.Rows(1))
    nAlbumIDArtistCol = GetColumnByHeading("AlbumIDAlbumArtist", wks.Rows(1))


    While (wks.Cells(nRow, 1) <> "")
        strSuggestion = wks.Cells(nRow, nSuggestionCol)
        
        If (strSuggestion <> "") Then
            bContainsAlbumInfo = InStr(1, strSuggestion, "*;*")
            
            Set qry = mc.createQuery()
            
            If (bContainsAlbumInfo) Then
                strAttribute = "AlbumIDAlbumArtist"
                qry.addCondition strAttribute, "equals", strSuggestion
            ElseIf (IsGuid(strSuggestion)) Then
                strAttribute = "TrackingID"
                qry.addCondition strAttribute, "equals", strSuggestion
            Else
                strAttribute = "Title"
                qry.addCondition strAttribute, "contains", strSuggestion
            End If
            
            Set pl = mc.getPlaylistByQuery(qry, "audio", "", False)
            
            Debug.Print ("Found " + CStr(pl.Count) + " items matching query " + strAttribute + " contains " + strSuggestion)
            If (pl.Count = 1) Then
                wks.Cells(nRow, nTrackNameCol) = GetAttributeContents("Title", pl.Item(0))
                wks.Cells(nRow, nPathCol) = GetAttributeContents("SourceURL", pl.Item(0))
                wks.Cells(nRow, nFoundCol) = "Found"
                wks.Cells(nRow, nSuggestionCol) = GetAttributeContents("TrackingID", pl.Item(0))
                wks.Cells(nRow, nTrackingIDCol) = GetAttributeContents("TrackingID", pl.Item(0))
                wks.Cells(nRow, nAlbumIDArtistCol) = GetAttributeContents("AlbumIDAlbumArtist", pl.Item(0))
            ElseIf (pl.Count > 0) Then
                strComment = ""
                For n = 0 To pl.Count - 1
                    wks.Cells(nRow, nAlbumIDArtistCol + (2 * (n + 2))) = GetAttributeContents("AlbumIDAlbumArtist", pl.Item(n))
                    wks.Cells(nRow, nAlbumIDArtistCol + (2 * (n + 2)) + 1) = GetAttributeContents("TrackingID", pl.Item(n))
                Next
            End If
            
            Set qry = Nothing
        End If
        
        nRow = nRow + 1
    Wend

End Sub


Sub btnBuildPlaylistFromSheet()
    Dim strSrcWorkSheet As String
    Dim strDestPlaylist As String
    
    strSrcWorkSheet = Range("cfg_Source_Worksheet")
    strDestPlaylist = Range("cfg_Dest_Playlist")
    
    BuildPlaylistFromSheet strSrcWorkSheet, strDestPlaylist, True
End Sub

Sub BuildPlaylistFromSheet(strSheetName As String, strPlaylistName As String, Optional bPurgeExisting As Boolean = False)
    Dim pl As IWMPPlaylist
    Dim wks As Worksheet
    Dim nTrackingIDCol As Long
    Dim player As WindowsMediaPlayer
    Dim plDest As IWMPPlaylist
    Dim qry As IWMPQuery
    Dim nRow As Long
    Dim nTrackNameCol As Long
    Dim strTrackingID As String
    Dim mc As IWMPMediaCollection2
    
    ' Argument checking
    If (strPlaylistName = "") Then
        strPlaylistName = "_" + strSheetName
    End If
    
    Set wks = GetDataSheet(strSheetName, False)
    nTrackingIDCol = GetColumnByHeading("TrackingID", wks.Rows(1))
    nTrackNameCol = GetColumnByHeading("Track Name", wks.Rows(1))
    nRow = 2
    
    Set player = GetGlobalMediaPlayer()
    Set mc = player.mediaCollection
    
    Set plDest = GetSinglePlaylistFromName(strPlaylistName)
    If (plDest Is Nothing) Then
        Set plDest = player.playlistCollection.newPlaylist(strPlaylistName)
    End If
    
    If (bPurgeExisting) Then
        plDest.Clear
    End If
    
    While (wks.Cells(nRow, nTrackNameCol) <> "")
        strTrackingID = wks.Cells(nRow, nTrackingIDCol)
        If (strTrackingID <> "") Then
            Set qry = mc.createQuery()
            qry.addCondition "TrackingID", "equals", strTrackingID
            Set pl = mc.getPlaylistByQuery(qry, "audio", "", False)
            If (pl.Count = 1) Then
                plDest.appendItem pl.Item(0)
            Else
                Debug.Print ("WARNING: There are " + CStr(pl.Count) + " items with ID " + strTrackingID)
            End If
        End If
        
        nRow = nRow + 1
    Wend
    
End Sub


Sub btnListAllPlaylists()
    Dim strDestSheet As String
    
    strDestSheet = Range("cfg_Dest_Worksheet")
    ListAllPlaylists strDestSheet
End Sub

Sub ListAllPlaylists(strDestSheet As String)
    Dim nRow As Long
    Dim n As Long
    Dim o As Long
    Dim wks As Worksheet
    Dim player As WindowsMediaPlayer
    Dim pla As IWMPPlaylistArray
    Dim pl As IWMPPlaylist
    Dim strAttribute As String
    Dim strValue As String
    Dim nAttributeCol As Long
    
    If (strDestSheet = "") Then
        strDestSheet = "Playlists"
    End If
    
    Set wks = GetDataSheet(strDestSheet, True)
    ResetData strDestSheet, 1
    
    Set player = GetGlobalMediaPlayer()
    Set pla = player.playlistCollection.getAll
    
    nRow = 2
    For n = 0 To pla.Count
        On Error Resume Next
        Err.Clear
        Set pl = pla.Item(n)
        If (Err.Number <> 0) Then
            Set pl = Nothing
        End If
        On Error GoTo 0
        
        If (pl Is Nothing) Then
            Debug.Print ("WARNING:  Playlist #" + CStr(n) + " is missing or corrupt.  Error #" + CStr(Err.Number))
        Else
            For o = 0 To pl.attributeCount - 1
                strAttribute = pl.attributeName(o)
                strValue = pl.getItemInfo(strAttribute)
                nAttributeCol = GetColumnByHeading(strAttribute, wks.Rows(1), True)
                wks.Cells(nRow, nAttributeCol) = strValue
            Next
            nRow = nRow + 1
        End If
    Next
End Sub

