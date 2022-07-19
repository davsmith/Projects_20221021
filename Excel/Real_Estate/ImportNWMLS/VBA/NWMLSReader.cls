VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "NWMLSReader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'Private ExifTemp() As Byte
'Private Offset_to_IFD0 As Long
'Private Offset_to_APP1 As Long
'Private Offset_to_TIFF As Long
'Private Length_of_APP1 As Long
'Private Offset_to_Next_IFD As Long
'Private IFDDirectory() As IFD_Data
'Private Offset_to_ExifSubIFD As Long
'Private m_Tag As Long
Private m_file As String
Private m_strFileContents() As String
Private m_nNumLines As Long
Private m_nNumHouses As Long
Private m_nHouseStartLines() As Long
Private IsLoaded As Boolean
Private m_Houses() As House

Const g_szDelimiterString As String = "Residential Client Detail Report"




' Public Property Let picFile(picFile As String)
'     m_file = picFile
' End Property

' Public Property Get MakerNoteTag(Optional ByVal MakerTag As Long) As Variant
'     If IsLoaded = False Then Exit Property
'
'     Dim i As Long
'
'     For i = 1 To UBound(IFDDirectory)
'         If IFDDirectory(i).Tag_No = MakerTag And IFDDirectory(i).MakerNote = True Then
'             MakerNoteTag = IFDDirectory(i).Value
'             Exit For
'         End If
'     Next
'
' End Property

' Public Property Get Tag(Optional ByVal ExifTag As EXIF_TAG) As Variant
'     If IsLoaded = False And m_file <> "" Then
'         Load (m_file)
'     ElseIf IsLoaded = False And m_file = "" Then
'         Exit Property
'     End If
'
'     If ExifTag = 0 Then
'         On Error Resume Next
'         Tag = UBound(IFDDirectory)
'         On Error GoTo 0
'         Exit Property
'     End If
'
'     Dim i As Long
'
'     For i = 1 To UBound(IFDDirectory)
'         If IFDDirectory(i).Tag_No = ExifTag Then
'             Tag = IFDDirectory(i).Value
'             Exit For
'         End If
'     Next
' End Property


Public Property Get HouseCount() As Variant
    HouseCount = m_nNumHouses
End Property



'
' Open the NWMLS HTML file and read in all of the strings
'
Public Sub Load(Optional ByVal strFile As String)
    Dim fso As FileSystemObject
    Dim bRetVal As Boolean
    Dim strm As TextStream
    Dim n As Double

    
    
    m_nNumLines = 0
    m_nNumHouses = 0
    
    
    ' If we don't already have a filename, use the specified filename.
    m_file = strFile
    
    '
    ' Read the file into memory
    '
    
    m_nNumLines = NumberOfLines(m_file)
    
    If (m_nNumLines > 0) Then
        ReDim m_strFileContents(m_nNumLines - 1)
        
        Set fso = CreateObject("Scripting.FileSystemObject")
        Set strm = fso.OpenTextFile(m_file, ForReading)
        
        For n = 0 To m_nNumLines - 1
            m_strFileContents(n) = strm.ReadLine
        Next
        
        strm.Close
        
        CountHouses
        
        If (m_nNumHouses > 0) Then
            ReDim m_Houses(m_nNumHouses - 1)
            ParseHouses
        Else
            Debug.Print ("Error:  No houses in file")
        End If
    End If
End Sub


Public Sub CountHouses()
    Dim n As Long
    Dim nLoc As Long
    
    ReDim m_nHouseStartLines(0)
    m_nNumHouses = 0
    
    For n = 0 To m_nNumLines - 1
        nLoc = InStr(m_strFileContents(n), g_szDelimiterString)
        If nLoc > 0 Then
            m_nNumHouses = m_nNumHouses + 1
            ReDim Preserve m_nHouseStartLines(m_nNumHouses)
            m_nHouseStartLines(m_nNumHouses - 1) = n
        End If
    Next
End Sub

Public Sub ParseHouses()
    Dim i As Long
    Dim nLine As Long
    Dim str As String
    Dim strLead As String
    Dim strTrail As String
    Dim strSpace As String
    Dim strArray() As String
    Dim n As Long
    
    strLead = "<TD nowrap width=" + WrapInQuotes("20%") + "><B>"
    strTrail = "</B></TD>"
    strSpace = "&nbsp;"
    
    For i = 0 To m_nNumHouses - 1
        ' Get the lot, unit # and address, based on hard coded table values
        nLine = m_nHouseStartLines(i)
        str = m_strFileContents(nLine)
        While InStr(str, "Lot:") = 0
            nLine = nLine + 1
            str = m_strFileContents(nLine)
        Wend
        
        ' We found the "Lot" entry, now we store the Lot, the unit and the address
        Debug.Print ("Processing house " + CStr(i))
        If i = 46 Then
 '           Debug.Assert False
        End If
        m_Houses(i).Lot = Replace(Replace(Before(After(m_strFileContents(nLine), strLead + "Lot:"), strTrail), strSpace, " "), "amp;", "")
        m_Houses(i).Unit = Replace(Before(After(m_strFileContents(nLine + 1), strLead + "Unit #:"), strTrail), strSpace, " ")
        
        str = Replace(Before(After(m_strFileContents(nLine + 2), strLead + ""), strTrail), strSpace, " ")
        n = Tokenize(str, " ", strArray)
        
        m_Houses(i).Zip = strArray(n)
        m_Houses(i).City = strArray(n - 1)
        
        str = Trim(Before(str, Trim(m_Houses(i).City + " " + m_Houses(i).Zip)))
        m_Houses(i).Address = str
        
        
        ' Get the map link
        If (InStr(m_strFileContents(nLine + 4), "See Map") > 0) Then
            str = Replace(Before(After(m_strFileContents(nLine + 4), "href=" + Chr(34)), Chr(34)), "amp;", "")
            m_Houses(i).MapLink = str
            str = Before(After(str, "VHW="), ":.25")
            m_Houses(i).Latitude = Before(str, ":")
            m_Houses(i).Longitude = After(str, ":")
        Else
            m_Houses(i).MapLink = "<none>"
        End If
        
        ' Get the link to photos
        
        str = Before(After(m_strFileContents(nLine + 10), "open('"), "'")
        m_Houses(i).MainPicLink = str
       
        ' If there isn't a link to additional pictures, we have to adjust for the missing HTML lines
        If InStr(m_strFileContents(nLine + 12), "/scripts") > 0 Then
            str = "http://locator.nwmls.com" + Before(After(m_strFileContents(nLine + 12), "href=" + Chr(34)), Chr(34))
            str = Replace(str, "amp;", "")
            m_Houses(i).PixLink = str
        Else
            m_Houses(i).PixLink = "<none>"
            nLine = nLine - 2
        End If
        
        ' Get status
        m_Houses(i).Status = Before(After(m_strFileContents(nLine + 26), "<TD>"), "</TD>")
        m_Houses(i).MLS = Trim(Before(After(m_strFileContents(nLine + 29), "<TD>"), "</TD>"))
        m_Houses(i).County = Before(After(m_strFileContents(nLine + 32), "<TD>"), "</TD>")
        m_Houses(i).Bedrooms = Trim(Before(After(m_strFileContents(nLine + 38), "<TD>"), "</TD>"))
        m_Houses(i).Bathrooms = Trim(Before(After(m_strFileContents(nLine + 41), "<TD>"), "</TD>"))
        m_Houses(i).FirePlaces = Trim(Before(After(m_strFileContents(nLine + 44), "<TD>"), "</TD>"))
        m_Houses(i).ListPrice = Trim(Before(After(m_strFileContents(nLine + 50), "<TD align=right>"), "</TD>"))
        m_Houses(i).SoldPrice = Trim(Before(After(m_strFileContents(nLine + 53), "<TD align=right>"), "</TD>"))
        m_Houses(i).YearBuilt = Trim(Before(After(m_strFileContents(nLine + 56), "<TD align=right>"), "</TD>"))
        m_Houses(i).HouseSize = Trim(Before(After(m_strFileContents(nLine + 83), "<TD align=right>"), "</TD>"))
        m_Houses(i).LotSizeAc = Trim(Before(After(m_strFileContents(nLine + 89), "<TD align=right>"), "</TD>"))
        m_Houses(i).LotSize = Trim(Before(After(m_strFileContents(nLine + 92), "<TD align=right>"), "</TD>"))
        m_Houses(i).Area = Before(After(m_strFileContents(nLine + 125), "<TD>"), "</TD>")
        m_Houses(i).Community = Before(After(m_strFileContents(nLine + 128), "<TD>"), "</TD>")
        m_Houses(i).Map = Before(After(m_strFileContents(nLine + 131), "<TD>"), "</TD>")
        m_Houses(i).Grid = Before(After(m_strFileContents(nLine + 134), "<TD>"), "</TD>")
        m_Houses(i).Pool = Before(After(m_strFileContents(nLine + 137), "<TD>"), "</TD>")
        m_Houses(i).Heat_Cool = Trim(Before(After(m_strFileContents(nLine + 243), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).Energy = Trim(Before(After(m_strFileContents(nLine + 246), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).Water = Trim(Before(After(m_strFileContents(nLine + 261), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).Sewer = Trim(Before(After(m_strFileContents(nLine + 264), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).Flooring = Trim(Before(After(m_strFileContents(nLine + 267), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).Appliances = Trim(Before(After(m_strFileContents(nLine + 270), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).View = Trim(Before(After(m_strFileContents(nLine + 276), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).Basement = Trim(Before(After(m_strFileContents(nLine + 279), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).WaterHeater = Trim(Before(After(m_strFileContents(nLine + 285), "<TD colspan=5>"), "</TD>"))
        m_Houses(i).BusNear = Trim(Replace(Before(After(m_strFileContents(nLine + 293), "<TD>"), "</TD>"), strSpace, " "))
        m_Houses(i).BusRoute = Trim(Before(After(m_strFileContents(nLine + 295), "<TD>"), "</TD>"))
        
        ' Some records have extra (useless) info attached such as ERating, and Community Info... we chuck it.
        While (InStr(m_strFileContents(nLine + 299), "Tax Year") = 0)
            nLine = nLine + 1
        Wend
        
        m_Houses(i).TaxYear = Trim(Before(After(m_strFileContents(nLine + 300), "<TD>"), "</TD>"))
        m_Houses(i).TaxesAnnual = Trim(Before(After(m_strFileContents(nLine + 302), "<TD>"), "</TD>"))
        m_Houses(i).Directions = Trim(Before(After(m_strFileContents(nLine + 314), "<TD><B>Directions :&nbsp;</B>"), "</TD>"))
        m_Houses(i).InteriorFeatures = Trim(Before(After(m_strFileContents(nLine + 320), "<TD><B>Interior Features :&nbsp;</B>"), "</TD>"))
        m_Houses(i).SiteFeatures = Trim(Before(After(m_strFileContents(nLine + 324), "<TD><B>Site Features :&nbsp;</B>"), "</TD>"))
        m_Houses(i).MktgRemarks = Trim(Before(After(m_strFileContents(nLine + 330), "<TD><B>Marketing Remarks :&nbsp;</B>"), "</TD>"))
    Next

End Sub


Sub DumpToSheet(wksht As Worksheet, Optional nRow As Long = 1, Optional strRangeName As String = "tmpHouseResults")
    Dim n As Integer
    Dim rngUL As Range
    Dim strFields(44) As String
    Dim str As String
    
    
    strFields(0) = "MLS"
    strFields(1) = "Status"
    strFields(2) = "Area"
    strFields(3) = "Community"
    strFields(4) = "Address"
    strFields(5) = "ListPrice"
    strFields(6) = "YearBuilt"
    strFields(7) = "HouseSize"
    strFields(8) = "LotSize"
    strFields(9) = "Bedrooms"
    strFields(10) = "Bathrooms"
    strFields(11) = "FirePlaces"
    strFields(12) = "MapLink"
    strFields(13) = "Main Picture"
    strFields(14) = "PixLink"
    strFields(15) = "View"
    strFields(16) = "Heat_Cool"
    strFields(17) = "Energy"
    strFields(18) = "Appliances"
    strFields(19) = "Basement"
    strFields(20) = "BusNear"
    strFields(21) = "BusRoute"
    strFields(22) = "Pool"
    strFields(23) = "Water"
    strFields(24) = "Sewer"
    strFields(25) = "Flooring"
    strFields(26) = "WaterHeater"
    strFields(27) = "TaxYear"
    strFields(28) = "TaxesAnnual"
    strFields(29) = "Directions"
    strFields(30) = "InteriorFeatures"
    strFields(31) = "SiteFeatures"
    strFields(32) = "Latitude"
    strFields(33) = "Longitude"
    strFields(34) = "City"
    strFields(35) = "Zip"
    strFields(36) = "County"
    strFields(37) = "Lot"
    strFields(38) = "Unit"
    strFields(39) = "SoldPrice"
    strFields(40) = "LotSizeAc"
    strFields(41) = "MktgRemarks"
    strFields(42) = "Map"
    strFields(43) = "Grid"
    strFields(44) = "HyperLink"
    
    Set rngUL = wksht.Cells(nRow, 1)
    rngUL.Resize(1, UBound(strFields) + 1).Value = strFields
    
    For n = 1 To m_nNumHouses
        Debug.Print ("Entering house:" + CStr(n))
        rngUL.Offset(n, 0).Value = m_Houses(n - 1).MLS
        rngUL.Offset(n, 1).Value = "=hyperlink(" + WrapInQuotes(m_Houses(n - 1).MainPicLink) + "," + WrapInQuotes(m_Houses(n - 1).Status) + ")"
        rngUL.Offset(n, 2).Value = m_Houses(n - 1).Area
        rngUL.Offset(n, 3).Value = m_Houses(n - 1).Community
        rngUL.Offset(n, 4).Value = m_Houses(n - 1).Address
        rngUL.Offset(n, 4).AddComment m_Houses(n - 1).MktgRemarks
        rngUL.Offset(n, 5).Value = m_Houses(n - 1).ListPrice
        rngUL.Offset(n, 6).Value = "_" + m_Houses(n - 1).YearBuilt
        rngUL.Offset(n, 7).Value = m_Houses(n - 1).HouseSize
        rngUL.Offset(n, 8).Value = m_Houses(n - 1).LotSize
        rngUL.Offset(n, 9).Value = m_Houses(n - 1).Bedrooms
        rngUL.Offset(n, 10).Value = m_Houses(n - 1).Bathrooms
        rngUL.Offset(n, 11).Value = m_Houses(n - 1).FirePlaces
        If m_Houses(n - 1).MapLink = "<none>" Then
            rngUL.Offset(n, 12).Value = "No map"
        Else
            rngUL.Offset(n, 12).Value = "=hyperlink(" + WrapInQuotes(m_Houses(n - 1).MapLink) + "," + WrapInQuotes("Map") + ")"
        End If
        
        rngUL.Offset(n, 13).Value = "=hyperlink(" + WrapInQuotes(m_Houses(n - 1).MainPicLink) + "," + WrapInQuotes("Photo") + ")"
        
        If m_Houses(n - 1).PixLink = "<none>" Then
            rngUL.Offset(n, 14).Value = "No photos"
        Else
            rngUL.Offset(n, 14).Value = "=hyperlink(" + WrapInQuotes(m_Houses(n - 1).PixLink) + "," + WrapInQuotes("More") + ")"
        End If
        rngUL.Offset(n, 15).Value = m_Houses(n - 1).View
        rngUL.Offset(n, 16).Value = m_Houses(n - 1).Heat_Cool
        rngUL.Offset(n, 17).Value = m_Houses(n - 1).Energy
        rngUL.Offset(n, 18).Value = m_Houses(n - 1).Appliances
        rngUL.Offset(n, 19).Value = m_Houses(n - 1).Basement
        rngUL.Offset(n, 20).Value = m_Houses(n - 1).BusNear
        rngUL.Offset(n, 21).Value = m_Houses(n - 1).BusRoute
        rngUL.Offset(n, 22).Value = m_Houses(n - 1).Pool
        rngUL.Offset(n, 23).Value = m_Houses(n - 1).Water
        rngUL.Offset(n, 24).Value = m_Houses(n - 1).Sewer
        rngUL.Offset(n, 25).Value = m_Houses(n - 1).Flooring
        rngUL.Offset(n, 26).Value = m_Houses(n - 1).WaterHeater
        rngUL.Offset(n, 27).Value = m_Houses(n - 1).TaxYear
        rngUL.Offset(n, 28).Value = m_Houses(n - 1).TaxesAnnual
        rngUL.Offset(n, 29).Value = m_Houses(n - 1).Directions
        rngUL.Offset(n, 30).Value = m_Houses(n - 1).InteriorFeatures
        rngUL.Offset(n, 31).Value = m_Houses(n - 1).SiteFeatures
        rngUL.Offset(n, 32).Value = m_Houses(n - 1).Latitude
        rngUL.Offset(n, 33).Value = m_Houses(n - 1).Longitude
        rngUL.Offset(n, 34).Value = m_Houses(n - 1).City
        rngUL.Offset(n, 35).Value = m_Houses(n - 1).Zip
        rngUL.Offset(n, 36).Value = m_Houses(n - 1).County
        rngUL.Offset(n, 37).Value = m_Houses(n - 1).Lot
        rngUL.Offset(n, 38).Value = m_Houses(n - 1).Unit
        rngUL.Offset(n, 39).Value = m_Houses(n - 1).SoldPrice
        rngUL.Offset(n, 40).Value = m_Houses(n - 1).LotSizeAc
        rngUL.Offset(n, 41).Value = m_Houses(n - 1).MktgRemarks
        rngUL.Offset(n, 42).Value = m_Houses(n - 1).Map
        rngUL.Offset(n, 43).Value = m_Houses(n - 1).Grid
        rngUL.Offset(n, 44).Value = m_Houses(n - 1).MainPicLink
    Next
    
    rngUL.Resize(n, UBound(strFields) + 1).Name = strRangeName
End Sub

Sub CombineSheets(strSource As String, strDest As String, Optional dSrcDate As Date)
    Dim rng As Range
    Dim rngSource As Range
    Dim rngDest As Range
    Dim nMLSSrcCol As Long
    Dim nMLSDestCol As Long
    Dim nDateAddedCol As Long
    Dim nExistingHouse As Long
    Dim nAddressDestCol As Long
    Dim j As Long
    Dim i As Long
    Dim m As Long
    Dim n As Long
    Dim nMLS As Long
    Dim nDestRow As Long
    Dim str As String
    Dim bHasComment As Boolean
    Dim cmt As Comment
    Dim bFormulaChanged As Boolean
    Dim bValueChanged As Boolean
    Dim strCommentDate As String
    
    
    If (dSrcDate = CDate("12/30/1899")) Then
        dSrcDate = Now()
    End If

    j = 0
    Set rngSource = Range(strSource)
    Set rngDest = Range(strDest)
    nMLSSrcCol = Application.WorksheetFunction.Match("MLS", rngSource.Rows(1), 0)
    nMLSDestCol = Application.WorksheetFunction.Match("MLS", rngDest.Rows(1), 0)
    nDateAddedCol = Application.WorksheetFunction.Match("Date Added", rngDest.Rows(1), 0)
    
    
    ' Set all of the previously updated cells to blue,
    ' to differentiate from cells which were updated on this pass.
    nAddressDestCol = Application.WorksheetFunction.Match("Address", rngDest.Rows(1), 0)
    For i = 1 To rngDest.Worksheet.Comments.Count
        Set cmt = rngDest.Worksheet.Comments(i)
        Set rng = cmt.Parent
        If rng.Column <> nAddressDestCol Then
            With rng.Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent1
                .TintAndShade = 0.599993896298105
                .PatternTintAndShade = 0
            End With
        End If
    Next
    
    For i = 2 To rngSource.Rows.Count
        If (i > 40) Then
            'Debug.Print
        End If
        nMLS = rngSource.Cells(i, nMLSSrcCol)
        If (nMLS = 27202386) Then
            'Debug.Assert False
        End If
            
        
        On Error Resume Next
        nDestRow = 0
        nDestRow = Application.WorksheetFunction.Match(nMLS, rngDest.Columns(nMLSDestCol), 0)
        On Error GoTo 0
        
        If nDestRow = 0 Then
            Debug.Print "Adding row..." + CStr(j) + " MLS:" + CStr(nMLS)
            rngSource.Rows(i).Copy
'            rngDest.Worksheet.Paste rngDest.Rows(rngDest.Rows.Count + j + 1).Resize(1, rngSource.Columns.Count)
            rngDest.Worksheet.Paste rngDest.Cells(rngDest.Rows.Count + j + 1, 1)
            rngDest.Cells(rngDest.Rows.Count + j + 1, nDateAddedCol) = dSrcDate
            j = j + 1
        Else
            ' We already have this record, so compare the values and flag differences
            For m = 1 To rngSource.Columns.Count
                bValueChanged = rngSource.Cells(i, m).Value <> rngDest.Cells(nDestRow, m).Value
                If bValueChanged Then
                    If (m = 1) Then
                        Debug.Assert False
                    End If
                    With rngDest.Cells(nDestRow, m).Interior
                        .Pattern = xlSolid
                        .PatternColorIndex = xlAutomatic
                        .ThemeColor = xlThemeColorAccent6
                        .TintAndShade = 0.599993896298105
                        .PatternTintAndShade = 0
                    End With
                    
                    strCommentDate = Format(dSrcDate, "mm/dd/yyyy")
                    bHasComment = Not rngDest.Cells(nDestRow, m).Comment Is Nothing
                    If Not bHasComment Then
                        str = strCommentDate + Chr(10) + CStr(rngDest.Cells(nDestRow, m).Value) + " --> " + CStr(rngSource.Cells(i, m).Value) + Chr(10)
                        rngDest.Cells(nDestRow, m).AddComment str + Chr(10)
                        'rngDest.Cells(nDestRow, m).Comment.
                        rngDest.Cells(nDestRow, m).Value = rngSource.Cells(i, m).Value
                    Else
                        str = strCommentDate + Chr(10) + CStr(rngDest.Cells(nDestRow, m).Value) + " --> " + CStr(rngSource.Cells(i, m).Value) + Chr(10)
                        str = str + Chr(10) + rngDest.Cells(nDestRow, m).Comment.Text
                        rngDest.Cells(nDestRow, m).Comment.Text Text:=str
                        rngDest.Cells(nDestRow, m).Value = rngSource.Cells(i, m).Value
                    End If
                End If
                
                bFormulaChanged = rngSource.Cells(i, m).HasFormula And (rngSource.Cells(i, m).Formula <> rngDest.Cells(nDestRow, m).Formula)
                If (bFormulaChanged) Then
                    Debug.Print ("Formula changed.")
                    Debug.Print ("From:" + CStr(rngDest.Cells(nDestRow, m).Formula))
                    Debug.Print ("To:" + CStr(rngSource.Cells(i, m).Formula))
                    rngDest.Cells(nDestRow, m).Formula = rngSource.Cells(i, m).Formula
                End If
            Next
        End If
        
    Next
    
    rngDest.Resize(rngDest.Rows.Count + j, rngDest.Columns.Count).Name = strDest
End Sub

