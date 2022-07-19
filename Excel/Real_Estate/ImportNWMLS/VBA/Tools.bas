Attribute VB_Name = "Tools"
'****************************************
'* Excel Macro Tools
'*
'* Updated 11/22/07
'*  - Added Tokenize
'*  - Added Clipboard functions
'*
'* Updated 11/18/07
'*  - Combined standard and Pictures.xls Tools modules
'*
'* Updated 12/4/05
'*
Option Explicit
Option Base 1

Public Enum etQuoteType
    enDoubleQuote = 0
    enSingleQuote = 1
End Enum

Type utNameValue
    szName As String
    varValue As Variant
End Type

' *****************************
'       Workbook Tools
' *****************************


'
' Clears out the range within the specified sheet, starting at the specified row
' The formatting is preserved.
'
Sub ResetData(strDataSheetName As String, StartRow As Integer)
    Dim datasheet As Worksheet
    Dim currentSheet As Worksheet
    Dim LastRow As Integer
    Dim currentScreenSetting As Boolean
    
    On Error Resume Next
    
    ' Turn off screen updates
    currentScreenSetting = Application.ScreenUpdating
    Application.ScreenUpdating = False
    
    ' Retrieve the data sheet
    Set datasheet = Sheets(strDataSheetName)
    Set currentSheet = ActiveSheet
    
    On Error GoTo 0
    
    If IsEmpty(datasheet) Then
        MsgBox "No " & strDataSheetName & " sheet"
        Exit Sub
    End If
    
    datasheet.Select
    LastRow = FindRow(datasheet, "*")
    
    If LastRow > StartRow Then
        Range(StartRow & ":" & LastRow).Delete
        Range(StartRow & ":" & LastRow).ClearContents
    Else
        Range(StartRow & ":" & StartRow).Delete
        Range(StartRow & ":" & StartRow).ClearContents
    End If
    
    currentSheet.Select
    Application.ScreenUpdating = currentScreenSetting
End Sub



'
' Protects the active worksheet
'
Sub ProtectMe()
    ActiveSheet.Protect Password:="Test"
    Range("A1:IV65536").Locked = True
End Sub



'
' Returns the worksheet with the specified name
'
' [in]  strSheetName    The name of the worksheet to retrieve
' [in]  bCreate         Create the worksheet if it doesn't exist
'
'
Function GetDataSheet(strSheetName As String, Optional bCreate As Boolean = False)
    Dim aSheet As Worksheet
    Dim bScreenUpdating As Boolean
    Dim shtCurrentWorksheet As Worksheet
    
    On Error Resume Next
    Set aSheet = Sheets(strSheetName)
    On Error GoTo 0
    
    If (aSheet Is Nothing) And bCreate Then
        Set shtCurrentWorksheet = ActiveSheet
        bScreenUpdating = Application.ScreenUpdating
        
        Set aSheet = Sheets.Add
        aSheet.Name = strSheetName
        
        shtCurrentWorksheet.Select
        Application.ScreenUpdating = bScreenUpdating
    End If
    
    Set GetDataSheet = aSheet
End Function

'
'
'
Sub AddNewRow()
    Dim SelectedCol As Integer
    Dim RowToCopy As Integer
    Dim NewRow As Integer
        
    Application.EnableEvents = False
    
    ' Find the last row
    RowToCopy = FindRow(ActiveSheet, "*")
    Rows(RowToCopy & ":" & RowToCopy).Copy '.Select
    'Selection.Insert Shift:=xlDown
    
    ' select first cell in dest row and paste
    Range("A" & (RowToCopy + 1)).Select
    ActiveSheet.Paste
    
    Application.EnableEvents = True
End Sub

'
' Returns the row number in the specified worksheet of the specified string.
' If * is specified as the string to find, the function returns the next open row.
'
' [in]  sh              The worksheet to search
' [in]  strToFind       The string to search for
'
'
Function FindRow(sh As Worksheet, strToFind As Variant)
    On Error Resume Next
    FindRow = sh.Cells.Find(What:=strToFind, _
                            After:=sh.Range("A1"), _
                            LookAt:=xlPart, _
                            LookIn:=xlFormulas, _
                            SearchOrder:=xlByRows, _
                            SearchDirection:=xlPrevious, _
                            MatchCase:=False).Row
    On Error GoTo 0
End Function


'
' Returns the column number in the specified worksheet of the specified string.
' If * is specified as the string to find, the function returns the next open column.
'
' [in]  sh              The worksheet to search
' [in]  strToFind       The string to search for
'
'
Function FindColumn(sh As Worksheet, strToFind As Variant)
    Dim rngCell As Range
    
    On Error Resume Next
    Set rngCell = sh.Cells.Find(What:=strToFind, _
                            After:=sh.Range("A1"), _
                            LookAt:=xlPart, _
                            LookIn:=xlFormulas, _
                            SearchOrder:=xlByColumns, _
                            SearchDirection:=xlPrevious, _
                            MatchCase:=False)
    FindColumn = rngCell.Column
    On Error GoTo 0
End Function

'
' Finds the last populated cell in the specified column
'
' [in]  rStartCell  A cell in the column which is to be searched
'
'
Function FindLast(rStartCell As Range) As Range
    Set FindLast = Cells(65536, rStartCell.Column).End(xlUp)
End Function

'
' Finds the specified string in the specified column number.  If found the function
' returns the row number where the search string was found.  If not found the function
' returns 0.
'
' [in]  szString    The string for which to search
' [in]  nColIndex   The column number in which to search for the string
'
Function FindValueInColumn(szStringToFind As String, nColIndex As Integer) As Integer
Dim nRetVal As Integer
Dim rCell As Range

    nRetVal = 0
    Set rCell = Columns(nColIndex).Find(What:=szStringToFind, LookIn:=xlFormulas _
        , LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext, _
        MatchCase:=False, SearchFormat:=False)
        
        If (Not IsNothing(rCell)) Then
            nRetVal = rCell.Row
        End If
    
    FindValueInColumn = nRetVal
End Function


'
' Returns the column number which contains the specified heading
'
' [in]  ColHeading  The heading we're looking for
'
'   - Expects the column headings to be in the first row
'
Function ColumnFromHeading(ColHeading As Variant)
    Dim rgHeader As Range
    Dim i As Integer
    
    ColumnFromHeading = -1
    
    Set rgHeader = Range("1:1")
    For i = 1 To ActiveSheet.UsedRange.Columns.Count
        If rgHeader.Cells(1, i).Value = ColHeading Then
            ColumnFromHeading = i
            Exit For
        End If
    Next i

End Function



'
' Returns the heading of the specified column in the specified worksheet
'
' [in]  aSheet  The worksheet in which we are to look for the heading
' [in]  Col     The column number of which to return the heading
'
'   - Expects the column headings to be in the first row
'
Function HeadingFromColumn(aSheet As Worksheet, Col As Integer)
    HeadingFromColumn = aSheet.Range("1:1").Cells(1, Col)
End Function


'
' Searches the specified row for the "heading" string, and returns the column number in
' which it finds it.  Returns 0 if the string is not in the row.
'
Function GetColumnByHeading(szHeading As String, Optional wksht As Worksheet = Nothing, Optional nHeadingRow As Long = 1) As Integer
    Dim c As Range
    Dim colval As Integer
    
    If wksht Is Nothing Then
        Set wksht = ActiveSheet
    End If
        
    colval = 0
    Set c = wksht.Rows(nHeadingRow).Find(What:=szHeading, LookIn:=xlFormulas, LookAt _
        :=xlWhole, SearchOrder:=xlByRows, SearchDirection:=xlNext, MatchCase:= _
        False, SearchFormat:=False)
    
    If Not c Is Nothing Then
        colval = c.Column
    End If

    GetColumnByHeading = colval
End Function


Function IsNothing(Obj) As Boolean
Dim t As Variant

    On Error Resume Next
    
    Err.Clear
    t = Obj.Value
    If (Err <> 0) Then
        IsNothing = True
        Err.Clear
    Else
        IsNothing = False
    End If
End Function


'
' Replaces blank cells with 0 for all cells in the specified range.
'
' [in]  rngFillRange    The range in which to replace blanks with zeros.
'
Sub FillZeros(rngFillRange As Range)
    Dim rCell As Range
    
    For Each rCell In rngFillRange
        If (IsEmpty(rCell)) Then
            rCell.Value = 0
        End If
    Next
End Sub



' ****************
'   Date Tools
' ****************

'
' Adjusts the dates in a range, by the specified number of hours.
' This function is mostly for adjusting Product Studio resolved and closed dates which
' are reported in GMT.
'
' [in]  rngRange            The range in which all cells containing dates will be adjusted
' [in]  fHours              The # of hours by which to adjust dates (negative is backward in time).
Sub AdjustDates(rngRange As Range, fHours As Double)
    Dim cell As Range
    Dim i, j As Integer
    
    For i = 1 To rngRange.Rows.Count
        For j = 1 To rngRange.Columns.Count
            Set cell = rngRange.Cells(i, j)
            If IsDate(cell) Then
                cell.Value = cell.Value + (fHours / 24)
            End If
        Next
    Next
End Sub


'
' Truncates the hours and minutes from a date in a range, by the specified number of hours.
' This function is mostly for adjusting Product Studio resolved and closed dates which
' include hours, minutes and seconds in the date.
'
' [in]  rngRange            The range in which all cells containing dates will be adjusted
Sub TruncateDates(rngRange As Range)
    Dim cell As Range
    Dim i, j As Integer
    
    For i = 1 To rngRange.Rows.Count
        For j = 1 To rngRange.Columns.Count
            Set cell = rngRange.Cells(i, j)
            If IsDate(cell) Then
                cell.Value = Int(cell.Value)
            End If
        Next
    Next
End Sub

'
' ***************
' File Tools
' ***************
'
' These functions require the Microsoft Scripting Runtime.
' To add it, select Tools|References|Microsoft Scripting Runtime
'

' For more documentation on using the FileSystemObject, see http://msdn2.microsoft.com/en-us/library/6kxy1a51.aspx
'


'
' Replaces the source path with a destination path and returns the new absolute filename
'
Function ReplacePath(strFullName As String, strSrcPath As String, strNewPath As String) As String
    Dim strRetval As String
    
    strRetval = Replace(strFullName, strSrcPath, strNewPath, 1, 1, vbTextCompare)
    ReplacePath = strRetval
End Function


'
' Counts the number of lines in a text file
'
Function NumberOfLines(sFile As String) As Double
'  = = = = = = = = = = = = = = = = = = = = = = = =
'// By: Dana DeLouis
'// Returns the number of lines in a text file
'// Use:  Answer = NumberOfRecords("C:\Test.txt")
'  = = = = = = = = = = = = = = = = = = = = = = = =
   Dim f As Object
   With CreateObject("Scripting.FileSystemObject")
   On Error Resume Next
      Set f = .OpenTextFile(sFile, 8) ' 8 -> Appending
      If Err.Number > 0 Then
         NumberOfLines = 0
      Else
         NumberOfLines = f.Line - 1
         f.Close
         Set f = Nothing
      End If
   End With
End Function



' Creates the specified folder path, one node at a time.
' The fso.CreateFolder command fails if most of the path does not already exist.
'
' Returns:
'   True if the folder path was created or already existed.
'   False if the folder path could not be created.
'
Function CreateFolderPathEx(strPath As String) As Boolean
    Dim nDepth As Integer
    Dim i As Integer
    Dim strNode As String
    Dim strParent As String
    Dim fso As FileSystemObject
    Dim bRetVal As Boolean
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    strNode = strPath
    strParent = fso.GetParentFolderName(strNode)
    
    If (Not (fso.FolderExists(strParent))) Then
        bRetVal = CreateFolderPathEx(strParent)
    End If
    
    If (Not (fso.FolderExists(strNode))) Then
        fso.CreateFolder (strNode)
    End If
    
    CreateFolderPathEx = True
End Function

'
' Deletes the list of files in the specified range.
' If bDelDirs is false, directories are skipped from deletion
' If bRemoveEmpty is true, empty directories are deleted.
'
Sub DeleteFileList(rngFileList As Range, Optional bDelDirs As Boolean = False)
    Dim cell As Range
    Dim fso As FileSystemObject
    Dim strFile As String
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    For Each cell In rngFileList
        strFile = cell.Value
        If fso.FolderExists(strFile) Then
            If bDelDirs Then
                Debug.Print ("Deleting folder " + strFile)
                fso.DeleteFolder strFile
            Else
                Debug.Print ("Not deleting folder " + strFile)
            End If
        End If
        
        If fso.FileExists(strFile) Then
            Debug.Print ("Deleting " + strFile)
            fso.DeleteFile strFile
        End If
    Next
End Sub



Sub DeleteEmptyFolders(strSubFolder As String)
    Dim oFiles As FoundFiles
    Dim f As File
    Dim fso As FileSystemObject
    Dim cell As Range
    Dim i As Long
    Dim folderRoot As Folder
    Dim folderNext As Folder
        
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set folderRoot = fso.GetFolder(strSubFolder)
    
    'Debug.Print (strSubFolder + ":" + CStr(folderRoot.Files.Count))
    
    For Each folderNext In folderRoot.SubFolders
        DeleteEmptyFolders (folderNext.Path)
    Next
    
    If ((folderRoot.SubFolders.Count = 0) And (folderRoot.Files.Count = 0)) Then
        Debug.Print ("Deleting " + folderRoot)
        fso.DeleteFolder folderRoot, True
    Else
        Debug.Print ("Don't delete " + folderRoot)
    End If
        
End Sub




Function GetFileList(strPath As String, strFileSpec As String, _
                    Optional bSubFolders As Boolean = True, _
                    Optional rngDestRange As Range) As FoundFiles
    Dim fs As FileSearch
    Dim i As Long
    
    Set fs = Application.FileSearch
    
    fs.NewSearch
    fs.LookIn = strPath
    fs.SearchSubFolders = bSubFolders
    fs.Filename = strFileSpec
    fs.Execute
    
    msoFileTypeExcelWorkbooks
    
    Set GetFileList = fs.FoundFiles
    
    If Not rngDestRange Is Nothing Then
        For i = 1 To fs.FoundFiles.Count
            rngDestRange.Cells(i, 1) = fs.FoundFiles(i)
        Next
    End If
End Function

Function GetDirectoryList(strPath As String, strNameSpec As String, _
                    Optional bSubFolders As Boolean = True, _
                    Optional rngDestRange As Range) As FoundFiles
    Dim fs As FileSearch
    Dim i As Long
    
    Set fs = Application.FileSearch
    
    fs.NewSearch
    fs.LookIn = strPath
    fs.Filename = strFileSpec
    fs.Execute
    
    Set GetFileList = fs.FoundFiles
    
    If Not IsEmpty(rngDestRange) Then
        For i = 1 To fs.FoundFiles.Count
            rngDestRange.Cells(i, 1) = fs.FoundFiles(i)
        Next
    End If
End Function


' ***************
'   Set Tools
' ***************

'
' Returns TRUE if the specified item is in the specified set (range)
'
Function IsInSet(varElement As Variant, rngSet As Range) As Boolean
    Dim rngCell As Range
    
    Set rngCell = rngSet.Find(What:=varElement, MatchCase:=False, LookAt:=xlWhole)
    
    If rngCell Is Nothing Then
        IsInSet = False
    Else
        IsInSet = True
    End If
End Function

'
' Returns an array of strings which are unique from a range
'
Sub GetUniqueItems(szUnique() As String, rngToSearch As Range, _
                    Optional strDelimiter As String = "_:_")
    Dim cell        As Range
    Dim dic         As Scripting.Dictionary 'Dictionary Object
    Dim dicItem     As Variant              'Items within dictionary object
    Dim strUnique() As String
    Dim nNumItems   As Long
    Dim strSearchVal As String
    Dim i, j As Long
    Dim nNumColumns As Long
    Dim nNumRows As Long

    If rngToSearch Is Nothing Then Set rngToSearch = ActiveCell

    'Create dictionay object
    Set dic = New Scripting.Dictionary

    ' Populate dictionary object with unique items
    nNumColumns = rngToSearch.Columns.Count
    nNumRows = rngToSearch.Rows.Count
    strSearchVal = ""
    
    For i = 1 To nNumRows
        Set cell = rngToSearch.Cells(i, 1)
        
        strSearchVal = ""
        For j = 1 To nNumColumns
            If Not IsEmpty(cell) Then
                strSearchVal = strSearchVal + strDelimiter + CStr(cell.Offset(0, j - 1).Value)
            End If
        Next
    
        ' Trim off the leading delimiter
        strSearchVal = After(strSearchVal, strDelimiter)
    
        If (Not dic.Exists(strSearchVal)) Then
            dic.Add strSearchVal, CVar(strSearchVal)
        End If
    Next

    ' Pass back the list of unique values
    If Not dic Is Nothing Then
        ReDim szUnique(dic.Count)
        For i = 1 To dic.Count
            szUnique(i) = dic.Items(i - 1)
        Next i
        
        'Clean up objects
        Set dic = Nothing
    End If


End Sub

' ****************
'   Math Tools
' ****************
Function Interpolate(rngData As Range, nInterval As Integer) As Double
    Dim nIncrement As Double
    Dim nRangesize As Integer
    Dim nRetVal As Double
    
    
    If ((rngData.Rows.Count > 1) And (rngData.Columns.Count > 1)) Then
        nRetVal = 0#
    Else
        nRangesize = Application.WorksheetFunction.Max(rngData.Rows.Count, rngData.Columns.Count)
        nIncrement = (rngData(rngData.Rows.Count, rngData.Columns.Count).Value - rngData(1, 1)) / nRangesize
        nRetVal = rngData(1, 1) + (nInterval * nIncrement)
    End If
    
    Interpolate = nRetVal
    
End Function


Sub InterpolateSelectedColumn()
'
'
'
    Dim nCurrentRow As Integer
    Dim nCurrentCol As Integer
    Dim rngCell As Range
    Dim nStartRow, nEndRow As Integer
    Dim nStartCol, nEndCol As Integer
    
    Dim i, j As Integer
    Dim rng As Range
    Dim nNumRows As Integer
    Dim nFirstVal, nLastVal As Integer
    Dim fIncrement As Double
    
    Set rng = Selection
    
    nStartRow = rng.Cells(1, 1).Row
    nEndRow = rng.Cells(rng.Rows.Count).Row
    
    ' Calculate the increment
    nNumRows = nEndRow - nStartRow
    
    nFirstVal = rng.Cells(1, 1).Value
    nLastVal = rng.Cells(rng.Rows.Count, 1).Value
    fIncrement = (nLastVal - nFirstVal) / (nNumRows)
    
    Set rngCell = rng.Cells(1, 1).Offset(1, 0)
    While rngCell.Row < nEndRow
        rngCell.Value = rngCell.Offset(-1, 0) + fIncrement
        Set rngCell = rngCell.Offset(1, 0)
    Wend
End Sub



' *******************
'   Clipboard Tools
' *******************
'
' NOTE:  These require that you add a reference to the Microsoft Forms 2.0 object library
'

Public Sub PutOnClipboard(Obj As Variant)
    Dim MyDataObj As New DataObject
    MyDataObj.SetText Format(Obj)
    MyDataObj.PutInClipboard
End Sub


Public Function GetOffClipboard() As Variant
    Dim MyDataObj As New DataObject
    MyDataObj.GetFromClipboard
    GetOffClipboard = MyDataObj.GetText()
End Function


Public Sub ClearClipboard()
    Dim MyDataObj As New DataObject
    MyDataObj.SetText ""
    MyDataObj.PutInClipboard
End Sub


' ****************
'   String Tools
' ****************

' Returns the input string with quotation marks added at the beginning and end
Function WrapInQuotes(strString As String) As String
    WrapInQuotes = Chr(34) + CStr(strString) + Chr(34)
End Function

' Returns the input string with all blanks removed
Function RemoveWhiteSpace(strString As String) As String
    Dim i As Integer
    Dim strReduced As String
    Dim strOneChar As String
    
    i = 1
    While i <= Len(strString)
        If (Mid(strString, i, 1) <> " ") Then
            strReduced = strReduced + Mid(strString, i, 1)
        End If
        i = i + 1
    Wend
    
    RemoveWhiteSpace = strReduced
End Function

'
' Takes as input a string and a substring.  If the substring is found in
' the string, the function returns the remainder of the string after the substring.
' If the string is not found, the function returns szString.
'
Function After(szString As String, szSubStr As String) As String
Dim nIndex As Integer
Dim szReturnVal As String

nIndex = InStr(1, szString, szSubStr, vbTextCompare)
szReturnVal = Mid(szString, nIndex + Len(szSubStr))

After = szReturnVal
End Function

'
' Takes as input a string and a substring.  If the substring is found in
' the string, the function returns the string before the first character of the substring.
' If the string is not found, the function returns szString.
'

Function Before(szString As String, szSubStr As String) As String
Dim nIndex As Integer
Dim szReturnVal As String

nIndex = InStr(1, szString, szSubStr, vbTextCompare)
If (nIndex = 0) Then
    szReturnVal = szString
Else
    szReturnVal = Left(szString, nIndex - 1)
End If

Before = szReturnVal
End Function

' Accepts a string and a token delimiter.  The function searches for
' the first instance of the token in the string, and returns the value of the string
' before the token.  The argument string is modified to contain the value after the
' token, so the argument string can be passed in multiple times to parse values.
'
Function StrTok(ByRef szString As String, szToken As String) As String
Dim szRetVal As String

szRetVal = Before(szString, szToken)

szString = After(szString, szToken)
StrTok = szRetVal
End Function

Function Tokenize(szString As String, szDelim As String, ByRef szStrTokens() As String) As Long
    Dim nCount As Long
    Dim szCopy As String
    
    
    ReDim szStrTokens(1)
    
    nCount = 1
    szCopy = szString
    
    szStrTokens(nCount) = StrTok(szCopy, szDelim)
    While (szStrTokens(nCount) <> szCopy)
        nCount = nCount + 1
        ReDim Preserve szStrTokens(nCount)
        szStrTokens(nCount) = StrTok(szCopy, szDelim)
    Wend
    
    Tokenize = nCount
End Function

'
' Adds single or double quotes to the beginning and end of the specified string
'
' [in] szString     The string to be wrapped
' [in] nQuoteType   ucSingle or ucDouble [default]
'
Function QuoteString(szString As String, Optional lQuoteType As etQuoteType = enDoubleQuote) As String
    If lQuoteType = enDoubleQuote Then
        QuoteString = Chr(34) + szString + Chr(34)
    Else
        QuoteString = Chr(39) + szString + Chr(39)
    End If
End Function

'
' Accepts an array and sorts it in place
'
Sub BubbleSort(TempArray As Variant)
    Dim Temp As Variant
    Dim i As Integer
    Dim NoExchanges As Integer

    ' Loop until no more "exchanges" are made.
    Do
        NoExchanges = True

        ' Loop through each element in the array.
        For i = 1 To UBound(TempArray) - 1

            ' If the element is greater than the element
            ' following it, exchange the two elements.
            If TempArray(i) > TempArray(i + 1) Then
                NoExchanges = False
                Temp = TempArray(i)
                TempArray(i) = TempArray(i + 1)
                TempArray(i + 1) = Temp
            End If
        Next i
    Loop While Not (NoExchanges)
End Sub






'
' Tips
'
' R1C1 References:
' - Use the .Address property of a cell to convert between R1C1 and $A$1
' - Use RefersTo to define a name as $A$1, use RefersToR1C1 to define a name as r1c1
' - Setting a formula using R1C1:      ActiveCell.FormulaR1C1 = "=AVERAGE(RC[-7]:RC[-3])"

'
' Dialog Tips
'
' - Set radio buttons to a height of 16
' - Set spacing between to 12



