Attribute VB_Name = "Module1"
Option Explicit

Dim g_strHousesSheet As String
Dim g_strTrackingSheet As String
Dim g_strHousesListRange As String
Dim g_strTrackingListRange As String

Public Const cDebug As Boolean = True


Public Type House
'    Tag_No As EXIF_TAG
'    MakerNote As Boolean
'    Data_Format As EXIF_DATA_FORMAT
'    Components As Long
'    Offset_To_Value As Long
'    Value As Variant
    StartLine As Long
    EndLine As Long
    
    Lot As String
    Unit As String
    Address As String
    Status As String
    MLS As String
    County As String
    ListPrice As String
    SoldPrice As String
    Bedrooms As String
    Bathrooms As String
    FirePlaces As String
    HouseSize As String
    LotSizeAc As String
    LotSize As String
    MapLink As String
    PixLink As String
    MainPicLink As String
    MktgRemarks As String
    YearBuilt As String
    Area As String
    Community As String
    Map As String
    Grid As String
    Pool As String
    BusNear As String
    BusRoute As String
    Heat_Cool As String
    Energy As String
    Water As String
    Sewer As String
    Flooring As String
    Appliances As String
    View As String
    Basement As String
    WaterHeater As String
    TaxYear As String
    TaxesAnnual As String
    Directions As String
    InteriorFeatures As String
    SiteFeatures As String
    Latitude As String
    Longitude As String
    City As String
    Zip As String
End Type



Sub InitializeGlobalVariables()
    g_strHousesSheet = "Houses"
    g_strTrackingSheet = "Tracking"
    g_strHousesListRange = "tmpHouseResults"
    g_strTrackingListRange = "tmpTrackingResults"
End Sub


Sub Startup()
    InitializeGlobalVariables
    frmCommands.Show vbModeless
End Sub


Sub ImportMLSRecords()
Attribute ImportMLSRecords.VB_ProcData.VB_Invoke_Func = "m\n14"
    Dim objReader As New NWMLSReader
    Dim txtInfo As String
    Dim strFile As String
    Dim wks As Worksheet
    Dim rngTrackingList As Range
    Dim nNumQueries As Long
    Dim strQuery As String
    Dim strQueryTitle As String
    Dim strDate As String
    Dim rng As Range
    Dim nTrkMLSCol As Long
    Dim nTrkRatingCol As Long
    Dim str As String

    'Application.ScreenUpdating = False
    FilterView -1
    ShowView -1
    
    nNumQueries = 1
 
    ' Set up the global variables we use throughout the system
    InitializeGlobalVariables
    
    strQueryTitle = Range("cfgQueryList").Offset(nNumQueries - 1, 0)
    While (strQueryTitle <> "")
    
        Set wks = GetDataSheet(g_strHousesSheet, True)
        ResetData g_strHousesSheet, 1
        
        strDate = Format(Now, "yyyymmdd")
        strDate = "20071124"
        strFile = Range("cfgFilePath") + "\" + Range("cfgFileSpec") + "_" + strQueryTitle + "_" + strDate + ".txt"
        strQuery = Range("cfgQueryList").Offset(nNumQueries - 1, 1)
        
        Application.StatusBar = "Running query for " + strFile
        'RunCBBQuery strFile, strQuery
        objReader.Load (strFile)
        objReader.DumpToSheet wks, 1, g_strHousesListRange
        
        ' Make sure we have a sheet set up to track results
        On Error Resume Next
            Set rngTrackingList = Range(g_strTrackingListRange)
            If Err.Number > 0 Then
                Debug.Print ("No range")
                Set wks = GetDataSheet(g_strTrackingSheet, True)
                ResetData g_strTrackingSheet, 1
                wks.Cells(1, 1).Name = g_strTrackingListRange
            End If
        On Error GoTo 0
        
        ' Check for column titles in tracking sheet, and copy them if they don't exist
        Set rng = Range(g_strTrackingListRange)
        If (rng.Cells(1, 1).Value = "") Then
            Range(g_strHousesListRange).Rows(1).Copy
            With rng
                .Worksheet.Activate
                .Cells(1, 1).Select
                .Worksheet.Paste
            End With
            
            Selection.Name = g_strTrackingListRange
            Set rng = Range(g_strTrackingListRange)
            
            ' Add columns used for tracking
            rng.Cells(1, rng.Columns.Count + 1) = "Rating"
            rng.Cells(1, rng.Columns.Count + 2) = "Comments"
            rng.Cells(1, rng.Columns.Count + 3) = "List Date"
            rng.Cells(1, rng.Columns.Count + 4) = "Red Fin # Days"
            rng.Cells(1, rng.Columns.Count + 5) = "Days on Market"
            rng.Cells(1, rng.Columns.Count + 6) = "Viewing"
            rng.Resize(1, rng.Columns.Count + 6).Name = (g_strTrackingListRange)
        End If
        
        objReader.CombineSheets g_strHousesListRange, g_strTrackingListRange
        
        nNumQueries = nNumQueries + 1
        strQueryTitle = Range("cfgQueryList").Offset(nNumQueries - 1, 0)
    Wend
    
    ' Add conditional formatting to show which houses have been rated
    nTrkMLSCol = Application.WorksheetFunction.Match("MLS", Range(g_strTrackingListRange).Rows(1), 0)
    nTrkRatingCol = Application.WorksheetFunction.Match("Rating", Range(g_strTrackingListRange).Rows(1), 0)
    
    Set rng = Range(g_strTrackingListRange).Cells(1, nTrkRatingCol)
    
    With Range(g_strTrackingListRange).Columns(1)
        str = "=ISBLANK(" + Range(g_strTrackingListRange).Cells(1, nTrkRatingCol).Address(RowAbsolute:=False) + ")"
        .FormatConditions.Add Type:=xlExpression, Formula1:=str
        .FormatConditions(.FormatConditions.Count).SetFirstPriority
        With .FormatConditions(1)
            With .Interior
                .PatternColorIndex = xlAutomatic
                .Color = 10092543
                .TintAndShade = 0
            End With
            .StopIfTrue = False
        End With
    End With

    
    Application.ScreenUpdating = True
    Application.StatusBar = False

End Sub


Sub RunCBBQuery(strFilename As String, strQuery As String)
    Dim ie As SHDocVw.InternetExplorer
    Dim nFile As Integer


    Set ie = CreateObject("InternetExplorer.Application")

    With ie
        .Visible = False
        .Silent = True
        .Navigate strQuery
        Do Until Not .Busy
            DoEvents
        Loop
        Application.Wait (Now + TimeValue("0:00:20"))
        nFile = FreeFile
        Open strFilename For Output Shared As #nFile
        Print #nFile, .Document.DocumentElement.InnerHTML
        Close #nFile
        .Quit
    End With
    Set ie = Nothing
End Sub


