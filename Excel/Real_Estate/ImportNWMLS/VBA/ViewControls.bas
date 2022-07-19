Attribute VB_Name = "ViewControls"
Option Explicit

Dim g_strHousesSheet As String
Dim g_strTrackingSheet As String
Dim g_strHousesListRange As String
Dim g_strTrackingListRange As String

Public Function GetMLSFromRange(Target As Range) As Long
    Dim nMLSCol As Long
    Dim nMLS As Long
    Dim rngSrc As Range
    Dim strRange As String
    
    strRange = "tmpTrackingResults"
    
    Set rngSrc = Range(strRange)
    
    nMLS = 0
    
    nMLSCol = Application.WorksheetFunction.Match("MLS", rngSrc.Rows(1), 0)
    
    If IsNumeric(rngSrc.Cells(Target.Row, nMLSCol)) Then
        nMLS = rngSrc.Cells(Target.Row, nMLSCol)
    End If
    
    Debug.Print "MLS: " + CStr(nMLS)
    frmViewing.txtMLSValue = CStr(nMLS)
    
    GetMLSFromRange = nMLS
End Function



'
' Changes the filter based on which button was clicked
'
Public Sub FilterView(nOption As Long)
    Dim rng As Range
    Dim nRatingCol As Long
    Dim nViewCol As Long
    Dim n As Long
    Dim strRange As String
    Dim bUpdate As Boolean
    
    bUpdate = Application.ScreenUpdating
    Application.ScreenUpdating = False

    
    strRange = "tmpTrackingResults"
    
    Set rng = Range(strRange)
    nRatingCol = Application.WorksheetFunction.Match("Rating", rng.Rows(1), 0)
    nViewCol = Application.WorksheetFunction.Match("Viewing", rng.Rows(1), 0)
    
    ' Clear any existing filter
    rng.Worksheet.AutoFilterMode = False
    
    Select Case nOption
        ' Filter by "Rating" value
        Case 1
            rng.AutoFilter Field:=nRatingCol, Criteria1:=Array( _
                "4", "5"), Operator:=xlFilterValues
        Case 2
            rng.AutoFilter Field:=nRatingCol, Criteria1:=Array( _
                "3", "4", "5"), Operator:=xlFilterValues
        Case 3
            rng.AutoFilter Field:=nRatingCol, Criteria1:=Array("="), Operator:=xlFilterValues
        
        ' Filter by "Viewing" value
        Case 4
            rng.AutoFilter Field:=nViewCol, Criteria1:=Array( _
                "Viewed"), Operator:=xlFilterValues
        Case 5
            rng.AutoFilter Field:=nViewCol, Criteria1:=Array( _
                "Skip"), Operator:=xlFilterValues
        Case 6
            rng.AutoFilter Field:=nViewCol, Criteria1:=Array( _
                "Visit"), Operator:=xlFilterValues
        Case Else
            ' Clear any filters
            rng.Worksheet.AutoFilterMode = False
    End Select
    
    Application.ScreenUpdating = bUpdate
End Sub

'
' Changes which columns are displayed/hidden based on which button was clicked
'
Public Sub ShowView(nOption As Long)
    Dim rng As Range
    Dim nCol As Long
    Dim strHeaderArray() As String
    Dim n As Long
    Dim strRange As String
    Dim bUpdate As Boolean
    
    bUpdate = Application.ScreenUpdating
    Application.ScreenUpdating = False

    
    'BUGBUG: Make this global or pass in a range
    strRange = "tmpTrackingResults"
    
    Set rng = Range(strRange)
    rng.Columns.Hidden = True
    
    Select Case nOption
    Case 1
        ReDim strHeaderArray(15)
        strHeaderArray(0) = "MLS"
        strHeaderArray(1) = "Status"
        strHeaderArray(2) = "Community"
        strHeaderArray(3) = "Address"
        strHeaderArray(4) = "ListPrice"
        strHeaderArray(5) = "YearBuilt"
        strHeaderArray(6) = "HouseSize"
        strHeaderArray(7) = "LotSize"
        strHeaderArray(8) = "Bedrooms"
        strHeaderArray(9) = "Bathrooms"
        strHeaderArray(10) = "MapLink"
        strHeaderArray(11) = "PixLink"
        strHeaderArray(12) = "Rating"
        strHeaderArray(13) = "Comments"
        strHeaderArray(14) = "Days on Market"
        strHeaderArray(15) = "Viewing"
    Case 2
        ReDim strHeaderArray(31)
        strHeaderArray(0) = "MLS"
        strHeaderArray(1) = "Status"
        strHeaderArray(2) = "Area"
        strHeaderArray(3) = "Community"
        strHeaderArray(4) = "Address"
        strHeaderArray(5) = "ListPrice"
        strHeaderArray(6) = "YearBuilt"
        strHeaderArray(7) = "HouseSize"
        strHeaderArray(8) = "LotSize"
        strHeaderArray(9) = "Bedrooms"
        strHeaderArray(10) = "Bathrooms"
        strHeaderArray(11) = "FirePlaces"
        strHeaderArray(12) = "MapLink"
        strHeaderArray(13) = "Main Picture"
        strHeaderArray(14) = "PixLink"
        strHeaderArray(15) = "View"
        strHeaderArray(16) = "Heat_Cool"
        strHeaderArray(17) = "Energy"
        strHeaderArray(18) = "Appliances"
        strHeaderArray(19) = "Basement"
        strHeaderArray(20) = "BusNear"
        strHeaderArray(21) = "BusRoute"
        'strHeaderArray(22) = "Pool"
        strHeaderArray(22) = "Water"
        strHeaderArray(23) = "Sewer"
        strHeaderArray(24) = "Flooring"
        strHeaderArray(25) = "WaterHeater"
        strHeaderArray(26) = "InteriorFeatures"
        strHeaderArray(27) = "SiteFeatures"
        strHeaderArray(28) = "Rating"
        strHeaderArray(29) = "Comments"
        strHeaderArray(30) = "Days on Market"
        strHeaderArray(31) = "Viewing"
    Case 3
    Case Else
        ' Show all of the columns
        ReDim strHeaderArray(0)
        rng.Columns.Hidden = False
    End Select
    
    
    n = UBound(strHeaderArray)
    If (n > 0) Then
        For n = 0 To UBound(strHeaderArray)
            nCol = Application.WorksheetFunction.Match(strHeaderArray(n), rng.Rows(1), 0)
            rng.Columns(nCol).Hidden = False
        Next
    End If
    
    rng.Worksheet.Activate
    
    Application.ScreenUpdating = bUpdate

    rng.Cells(1, 1).Select
End Sub

'
' Sorts the range by the specified fields.  Defaults to sort by MLS
'
Public Sub SortView(nOption As Long)
    Dim rng As Range
    Dim nColCommunity As Long
    Dim nColPrice As Long
    Dim nColRating As Long
    Dim nColLotSize As Long
    Dim nColMLS As Long
    Dim strRange As String
    Dim bUpdate As Boolean
    
    bUpdate = Application.ScreenUpdating
    Application.ScreenUpdating = False
        
    strRange = "tmpTrackingResults"
    
    Set rng = Range(strRange)

    nColCommunity = Application.WorksheetFunction.Match("Community", rng.Rows(1), 0)
    nColPrice = Application.WorksheetFunction.Match("ListPrice", rng.Rows(1), 0)
    nColRating = Application.WorksheetFunction.Match("Rating", rng.Rows(1), 0)
    nColLotSize = Application.WorksheetFunction.Match("LotSize", rng.Rows(1), 0)
    nColMLS = Application.WorksheetFunction.Match("MLS", rng.Rows(1), 0)
    
    Set rng = rng.Offset(1).Resize(rng.Rows.Count - 1)
    
    Select Case nOption
        Case 1
            rng.Sort key1:=rng.Cells(1, nColMLS), order1:=xlAscending, _
                        key2:=rng.Cells(1, nColPrice), order2:=xlAscending, _
                        key3:=rng.Cells(1, nColLotSize), order3:=xlDescending
        Case 2
            rng.Sort key1:=rng.Cells(1, nColPrice), order1:=xlAscending, _
                        key2:=rng.Cells(1, nColRating), order2:=xlDescending, _
                        key3:=rng.Cells(1, nColLotSize), order3:=xlDescending
        Case 3
            rng.Sort key1:=rng.Cells(1, nColRating), order1:=xlDescending, _
                        key2:=rng.Cells(1, nColPrice), order2:=xlAscending, _
                        key3:=rng.Cells(1, nColLotSize), order3:=xlDescending
        Case 4
            rng.Sort key1:=rng.Cells(1, nColCommunity), order1:=xlAscending, _
                        key2:=rng.Cells(1, nColPrice), order2:=xlAscending, _
                        key3:=rng.Cells(1, nColRating), order3:=xlDescending
        Case Else
            rng.Sort key1:=rng.Cells(1, nColMLS), order1:=xlAscending, _
                        key2:=rng.Cells(1, nColPrice), order2:=xlAscending, _
                        key3:=rng.Cells(1, nColLotSize), order3:=xlDescending
    End Select
        
    Application.ScreenUpdating = bUpdate

End Sub


Sub SetViewingValue(nOption As Long)
    Dim nViewCol As Long
    Dim rngSrc As Range
    Dim strTrackingListRange As String
    Dim strRange As String
    
    strRange = "tmpTrackingResults"

    Set rngSrc = Range(strRange)
    
    nViewCol = Application.WorksheetFunction.Match("Viewing", rngSrc.Rows(1), 0)
    
    Select Case nOption
        Case 1
            rngSrc.Cells(Selection.Row, nViewCol) = "Visit"
        Case 2
            rngSrc.Cells(Selection.Row, nViewCol) = "Skip"
        Case 3
            rngSrc.Cells(Selection.Row, nViewCol) = "Viewed"
        Case Else
            rngSrc.Cells(Selection.Row, nViewCol).Clear
    End Select
End Sub

