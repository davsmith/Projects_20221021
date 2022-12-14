Attribute VB_Name = "Budget"
'****************************************
'* MSMoney/Excel Budget Tools
'*
'*   D:\FolderShare\Work\Excel\VBA\Budget.bas
'*
'* 1/24/2010:
'*   - Modified YearFrac calculation to be no greater than a year.
'*
'* 10/18/2009:
'*   - Changed MakePivot to be a function instead of a sub
'*   - Added Vacation pivot
'*   - Removed type=Projects from monthly expenses
'*
'* 09/05/09:
'*   - Added documentation
'*   - Added FLAG macro
'*   - Added flexibility to specify the year in the strBudgetYear variable
'*   - Much of the Main macro uses "ActiveSheet"... should this be converted to wksData?
'*   - Still trying to track down Excel crash when some of the pivot macros are run...
'*      The crash doesn't seem to occur if SKIPAHEAD is placed before FormatPivotTable
'*      on the monthly expenditures pivot.
'*
'* 12/15/08:
'*   - Created base set of macros to:
'*      - Generate data table from MS Money export generated by Ultrasoft MoneyLink
'*      - Parse MSMoney comments field for macro and subcategory tags
'*      - Run the sub-macros indicated in the MS Money comments field
'*      - Generate pivot tables for different budget workflows
'*
'*
'* Setup notes when starting from scratch:
'*   - Install Ultrasoft MoneyLink Add In
'*   - Add the MoneyLink Add In (Excel Options|Add Ins|Microsoft MoneyLink|Go)
'*   - Copy the Config sheet to the new Workbook
'*      - Alternatively, create a new worksheet with the following columns:
'*         Category    Type    Discretionary   Business    Tax Status   Budget
'*      - Populate the Category column with the list of Category|Subcategory entries from MS Money
'*      - Fill in values for each of the Category mappings
'*         Type: Largely equates to frequency (Monthly, Irregular, Unplanned, Annual, Net Income)
'*         Discretionary: A rating from 0-5 on how much choice you have in making the spend (0=No choice)
'*         Business: Yes or No value indicating whether this category is business related
'*         Tax Status: Indicates how to treat this category wrt to taxes (Taxable, Deductible, Partial, None)
'*         Budget:  The monthly amount alloted to this category
'*   - Define a named table (TBL_Categories) around the table of categories (including the row header)
'*   - Copy the row headers to the Data sheet
'*      Number  Date    Account Payee   Cleared Amount  Category    Subcategory Memo    SubCat1 SubCat2 SubCat3 Month   Year    Type    Discretionary   Business    ConCat  Tax Status
'*         Number - Memo are generated by the MSMoney plugin
'*         SubCat1 - SubCat3 are wildcard subcategories generated from the MS Money comments field (#Cat1|Cat2|Cat3#)
'*         Month, Year are text versions of the date field
'*         Other fields are lookup related fields mapped to the TBL_Categories table
'*   - Set <ctrl-M> to run the Main macro
'*
'* To run the macros:
'*   - Refresh (or import) the MS Money data using the plugin, set to all transactions, all accounts, all dates (optional)
'*   - Run the Main macro (ctrl-M)
'*
Option Explicit


Sub Main()
Attribute Main.VB_ProcData.VB_Invoke_Func = "m\n14"
'
'
'
    Dim nSettingsIndex As Long
    
    Dim nDateCol As Integer
    Dim nConcatCol As Integer
    Dim nCategoryCol As Integer
    Dim nSubCategoryCol As Integer
    Dim nFrequencyCol As Integer
    Dim nDiscretionaryCol As Integer
    Dim nBusinessCol As Integer
    Dim nTaxStatusCol As Integer
    Dim nMonthCol As Integer
    Dim nYearCol As Integer
    Dim nMemoCol As Integer
    Dim nDateRow As Integer
    
    Dim i As Integer
    Dim j As Integer
    
    Dim strDataTable As String
    Dim strDataSheet As String
    Dim wksData As Worksheet
    Dim rngData As Range
    
    Dim strConfigSheet As String
    Dim wksConfig As Worksheet
    Dim strBudgetTable As String
    
    Dim strPivotSheet As String
    Dim wksPivot As Worksheet
    Dim strPivotName As String
    Dim rngPivotDest As Range
    Dim colRowFields As New Collection
    Dim colColFields As New Collection
    Dim colFilterFields As New Collection
    Dim colSumFields As New Collection
    Dim colFilterValues As New Collection
    
    Dim rng As Range
    Dim nRows As Integer
    Dim nCols As Integer
    Dim strFormula As String
    Dim strBudgetYear As String
    
    Dim pvt As PivotTable
    
    ' Config
    strConfigSheet = "Config"
    strDataSheet = Range("CFG_DataSheetName")
    strDataTable = "TBL_Data"
    strPivotSheet = "Monthly"
    strPivotName = "PVT_Monthly"
    strBudgetTable = "TBL_Categories"
    
    strBudgetYear = CStr(Range("CFG_BudgetYear"))

   
   Dim dStartDate As Date
   Dim dEndDate As Date
   Dim fYearFrac As Double
   
   dStartDate = CDate("1/1/" + strBudgetYear)
   dEndDate = Now
   fYearFrac = WorksheetFunction.Min(1, Application.WorksheetFunction.YearFrac(dStartDate, dEndDate))

    'nSettingsIndex = PersistSettings(dsSave)
'    Application.ScreenUpdating = False
    
    ' Get a reference to each of our sheets.
    ' The worksheets Data and Config are required.
    ' The pivot sheet can be created from scratch.
    Set wksData = GetDataSheet(strDataSheet, False)
    Set wksConfig = GetDataSheet(strConfigSheet, False)
    Set wksPivot = GetDataSheet(strPivotSheet, True)
    
    ' Figure how which column is which within the sheet containing the raw data.
    ' The "Number" through "Memo" columns come from the Ultrasoft plugin.
    ' The other columns headers must be copied from the "Config" sheet.
    wksData.Activate
    nMonthCol = GetColumnByHeading("Month")
    nYearCol = GetColumnByHeading("Year")
    nFrequencyCol = GetColumnByHeading("Type")
    nDiscretionaryCol = GetColumnByHeading("Discretionary")
    nBusinessCol = GetColumnByHeading("Business")
    nTaxStatusCol = GetColumnByHeading("Tax Status")
    nDateCol = GetColumnByHeading("Date")
    nCategoryCol = GetColumnByHeading("Category")
    nSubCategoryCol = GetColumnByHeading("Subcategory")
    nConcatCol = GetColumnByHeading("Concat")
    nMemoCol = GetColumnByHeading("Memo")
    
    '
    ' Define a named range for all of our data
    ' (assumes the column names have been copied from the config sheet)
    '
    
    ' Figure out how many columns are in the data table
    Set rng = ActiveSheet.Cells(1, 1).End(xlToRight)
    nCols = rng.Column
    
    ' Figure out how many rows are in the data table.
    Set rng = ActiveSheet.Cells(1, nDateCol).End(xlDown)
    nRows = rng.Row
    
    ' Define the table
    Set rng = ActiveSheet.Cells(1, 1).Resize(nRows, nCols)
    rng.Name = strDataTable
    
    ' Clear all of the post-processed data (anything after the memo field)
    rng.Cells(2, nMemoCol + 1).Resize(nRows - 1, nCols - nMemoCol).Clear
    
    ' Run the macro to clean up the transaction dates based on comments field
    RunMoneyMacros "FD", "FixDate"
    RunMoneyMacros "DIV", "DivideIntoMonthly"
    RunMoneyMacros "FLAG", "FlagForFollowup"
    RunMoneyMacros "BAL", "LastBalanced", "TBL_Balanced"
    
    ' Pull subcategories from comments field
    SubCategorize
    
    ' Sort on the updated date field
    SortOnColumnName "Date", Range(strDataTable)
    
    ' Since the dates have been fixed up, purge anything we don't need
    PurgeDatesOutOfRange "Date", Range(strDataTable), "1/1/" + strBudgetYear, "12/31/" + strBudgetYear
    
    Set rngData = Range(strDataTable)
    
    ' Fill in the month column
    Set rng = rngData.Cells(2, nMonthCol).Resize(rngData.Rows.Count - 1)
    
    strFormula = "=text(" + ActiveSheet.Cells(2, nDateCol).Address(rowabsolute:=False) + "," + WrapInQuotes("MMM") + ")"
    rng.Value = strFormula

    ' Fill in the year column
    Set rng = rngData.Cells(2, nYearCol).Resize(rngData.Rows.Count - 1)
    
    strFormula = "=Year(" + ActiveSheet.Cells(2, nDateCol).Address(rowabsolute:=False) + ")"
    rng.Value = strFormula
    
    ' Add in the budget data
    AddBudgetEntriesToData strDataTable, strBudgetTable
    Set rngData = Range(strDataTable)
    
    ' Create a column concatenating category and subcategory for lookup
    Set rng = rngData.Cells(2, nConcatCol).Resize(rngData.Rows.Count - 1)
    strFormula = "=concatenate(" + ActiveSheet.Cells(2, nCategoryCol).Address(rowabsolute:=False) + "," + _
                    WrapInQuotes("|") + "," + ActiveSheet.Cells(2, nSubCategoryCol).Address(rowabsolute:=False) + ")"
    rng.Value = strFormula

    ' Add a column for Frequency
    Set rng = rngData.Cells(2, nFrequencyCol).Resize(rngData.Rows.Count - 1)
    strFormula = "=VLOOKUP(" + ActiveSheet.Cells(2, nConcatCol).Address(rowabsolute:=False) + ",TBL_Categories,2,FALSE)"
    rng.Value = strFormula

    ' Add a column for Discretionary rating
    Set rng = rngData.Cells(2, nDiscretionaryCol).Resize(rngData.Rows.Count - 1)
    strFormula = "=VLOOKUP(" + ActiveSheet.Cells(2, nConcatCol).Address(rowabsolute:=False) + ",TBL_Categories,3,FALSE)"
    rng.Value = strFormula

    ' Add a column for Business
    Set rng = rngData.Cells(2, nBusinessCol).Resize(rngData.Rows.Count - 1)
    strFormula = "=VLOOKUP(" + ActiveSheet.Cells(2, nConcatCol).Address(rowabsolute:=False) + ",TBL_Categories,4,FALSE)"
    rng.Value = strFormula

    ' Add a column for Tax Status
    Set rng = rngData.Cells(2, nTaxStatusCol).Resize(rngData.Rows.Count - 1)
    strFormula = "=VLOOKUP(" + ActiveSheet.Cells(2, nConcatCol).Address(rowabsolute:=False) + ",TBL_Categories,5,FALSE)"
    rng.Value = strFormula

    '******************** Generate the Monthly Expenditures Pivot ********************
    If (Not Range("CFG_GeneratePivots")) Then
        GoTo EXIT_Main
    End If
        
    ResetData strPivotSheet, 1
    
    colRowFields.Add ("Category")
    colRowFields.Add "SubCategory"
    
    colColFields.Add "Year"
    colColFields.Add "Month"
    
    colFilterFields.Add "Type"
    colFilterFields.Add "Discretionary"
    colFilterFields.Add "Business"
    
    colSumFields.Add "Amount"
    
    Set pvt = MakePivot(Range(strDataTable), wksPivot.Cells(5, 1), strPivotName, colColFields, colRowFields, colFilterFields, colSumFields)
    FormatPivotTable strPivotName, wksPivot
    
    

    '******************** Generate the Vacation and Project Pivots ********************
    GenerateVacationPivot "Vacation", strDataTable
    GenerateProjectsPivot "Projects", strDataTable

    '******************** Generate the Last Balanced Pivot ********************
    FormatLastBalancedTable "Balanced", "TBL_Balanced"

GoTo EXIT_Main
    
    GenerateIncomePivot "Income", strDataTable
    GenerateTaxesPivot "Taxes", strDataTable
    
    ' Restore selections and settings to their initial values
    'PersistSettings dsRestore, nSettingsIndex
EXIT_Main:
    
 End Sub


Sub GenerateTaxesPivot(strPivotSheet As String, strDataRange As String)
    Dim strPivotName As String
    Dim colRowFields As New Collection
    Dim colColFields As New Collection
    Dim colFilterFields As New Collection
    Dim colFilterValues As New Collection
    Dim colSumFields As New Collection
    Dim wks As Worksheet
    Dim dateLastReconciled As Date
    Dim colReconciled As New Collection
    Dim colAccountNames As New Collection
    Dim rngAccountList As Range
    Dim pvt As PivotTable
    Dim nDateRow As Long
    Dim nDateCol As Long
    Dim i As Long
    Dim rng As Range
    Dim nSettingsIndex As Long
    
'    nSettingsIndex = PersistSettings(dsSave)
    
    Application.ScreenUpdating = False
    strPivotName = "PVT_Taxes"
    
    Set wks = GetDataSheet(strPivotSheet, True)
    ResetData strPivotSheet, 1
    
    ' Generate the pivot table listing income categories and sources
    colRowFields.Add ("SubCat1")
    colColFields.Add "Year"
    colColFields.Add "Month"
    colFilterFields.Add "Tax Status"
    colSumFields.Add "Amount"
    Set pvt = MakePivot(Range(strDataRange), wks.Cells(5, 1), strPivotName, colColFields, colRowFields, colFilterFields, colSumFields)
    
    ' Only show categories which generate income
'    colFilterValues.Add "Net Income"
'    SetPivotFilterValues strPivotName, "Type", wks, colFilterValues, dsOnExclusive
    
    pvt.PivotFields("Sum of Amount").NumberFormat = "+#,##0.00;#,##0.00;##0.00"

    'pvt.PivotFields("Year").Subtotals = Array(False, False, False, False, False, False, False, False, False, False, False, False)
    'pvt.ColumnGrand = False
    'pvt.RowGrand = False

'    PersistSettings dsRestore, nSettingsIndex
End Sub

Sub GenerateIncomePivot(strPivotSheet As String, strDataRange As String)
    Dim strPivotName As String
    Dim colRowFields As New Collection
    Dim colColFields As New Collection
    Dim colFilterFields As New Collection
    Dim colFilterValues As New Collection
    Dim colSumFields As New Collection
    Dim wks As Worksheet
    Dim dateLastReconciled As Date
    Dim colReconciled As New Collection
    Dim colAccountNames As New Collection
    Dim rngAccountList As Range
    Dim pvt As PivotTable
    Dim nDateRow As Long
    Dim nDateCol As Long
    Dim i As Long
    Dim rng As Range
    Dim nSettingsIndex As Long
    
'    nSettingsIndex = PersistSettings(dsSave)
    
    Application.ScreenUpdating = False
    strPivotName = "PVT_Income"
    
    Set wks = GetDataSheet(strPivotSheet, True)
    ResetData strPivotSheet, 1
    
    ' Generate the pivot table listing income categories and sources
    colRowFields.Add ("SubCat1")
    colColFields.Add "Year"
    colColFields.Add "Month"
    colFilterFields.Add "Type"
    colSumFields.Add "Amount"
    Set pvt = MakePivot(Range(strDataRange), wks.Cells(5, 1), strPivotName, colColFields, colRowFields, colFilterFields, colSumFields)
    
    ' Only show categories which generate income
    colFilterValues.Add "Net Income"
    SetPivotFilterValues strPivotName, "Type", wks, colFilterValues, dsOnExclusive
    
    pvt.PivotFields("Sum of Amount").NumberFormat = "+#,##0.00;#,##0.00;##0.00"

    'pvt.PivotFields("Year").Subtotals = Array(False, False, False, False, False, False, False, False, False, False, False, False)
    'pvt.ColumnGrand = False
    'pvt.RowGrand = False

'    PersistSettings dsRestore, nSettingsIndex
End Sub


Sub GenerateVacationPivot(strPivotSheet As String, strDataRange As String)
    Dim strPivotName As String
    Dim colRowFields As New Collection
    Dim colColFields As New Collection
    Dim colFilterFields As New Collection
    Dim colFilterValues As New Collection
    Dim colSumFields As New Collection
    Dim wks As Worksheet
    Dim dateLastReconciled As Date
    Dim colReconciled As New Collection
    Dim colAccountNames As New Collection
    Dim rngAccountList As Range
    Dim pvt As PivotTable
    Dim nDateRow As Long
    Dim nDateCol As Long
    Dim i As Long
    Dim rng As Range
    Dim nSettingsIndex As Long
    
'    nSettingsIndex = PersistSettings(dsSave)
    
    Application.ScreenUpdating = False
    strPivotName = "PVT_Vacation"
    
    Set wks = GetDataSheet(strPivotSheet, True)
    ResetData strPivotSheet, 1
    
    ' Generate the pivot table listing vacation categories
    colRowFields.Add ("SubCat1")
'    colColFields.Add "Subcategory"
    colFilterFields.Add "Category"
    colSumFields.Add "Amount"
    Set pvt = MakePivot(Range(strDataRange), wks.Cells(5, 1), strPivotName, colColFields, colRowFields, colFilterFields, colSumFields)
    
    ' Only show vacation categories
    colFilterValues.Add "Vacation"
    SetPivotFilterValues strPivotName, "Category", wks, colFilterValues, dsOnExclusive
    
    pvt.PivotFields("Sum of Amount").NumberFormat = "+#,##0.00;#,##0.00;##0.00"

    'pvt.PivotFields("Year").Subtotals = Array(False, False, False, False, False, False, False, False, False, False, False, False)
    'pvt.ColumnGrand = False
    'pvt.RowGrand = False

'    PersistSettings dsRestore, nSettingsIndex
End Sub


Sub GenerateProjectsPivot(strPivotSheet As String, strDataRange As String)
    Dim strPivotName As String
    Dim colRowFields As New Collection
    Dim colColFields As New Collection
    Dim colFilterFields As New Collection
    Dim colFilterValues As New Collection
    Dim colSumFields As New Collection
    Dim wks As Worksheet
    Dim dateLastReconciled As Date
    Dim colReconciled As New Collection
    Dim colAccountNames As New Collection
    Dim rngAccountList As Range
    Dim pvt As PivotTable
    Dim nDateRow As Long
    Dim nDateCol As Long
    Dim i As Long
    Dim rng As Range
    Dim nSettingsIndex As Long
    
'    nSettingsIndex = PersistSettings(dsSave)
    
    Application.ScreenUpdating = False
    strPivotName = "PVT_Projects"
    
    Set wks = GetDataSheet(strPivotSheet, True)
    ResetData strPivotSheet, 1
    
    ' Generate the pivot table listing vacation categories
    colRowFields.Add ("Subcategory")
    colFilterFields.Add "Category"
    colSumFields.Add "Amount"
    Set pvt = MakePivot(Range(strDataRange), wks.Cells(5, 1), strPivotName, colColFields, colRowFields, colFilterFields, colSumFields)
    
    ' Only show project categories
    colFilterValues.Add "Projects"
    SetPivotFilterValues strPivotName, "Category", wks, colFilterValues, dsOnExclusive
    
    pvt.PivotFields("Sum of Amount").NumberFormat = "+#,##0.00;#,##0.00;##0.00"

'    PersistSettings dsRestore, nSettingsIndex
End Sub


Sub FormatLastBalancedTable(strTableSheet As String, strTableName As String)
   Dim rngBalTable As Range
   
   Set rngBalTable = Range(strTableName)
   rngBalTable.Rows(1).Font.Bold = True
   rngBalTable.Columns(1).AutoFit
   rngBalTable.Columns(2).AutoFit
   rngBalTable.Columns(3).AutoFit
   
   rngBalTable.Sort Key1:=rngBalTable.Cells(1, 2), Order1:=xlDescending, Header:=xlYes
   rngBalTable.Columns(3).Style = "Currency"
End Sub



Sub FormatPivotTable(strPivotName As String, Optional wksPivot As Worksheet)
    Dim pvtBudget As PivotTable
    Dim pvtField As PivotField
    Dim pvtValuesRange As Range
    Dim nBudgetRow As Long
    Dim nBudgetCol As Long
    Dim rng As Range
    Dim rngSubTotals As Range
    Dim colFilterSettings As New Collection
    
    If wksPivot Is Nothing Then
        Set wksPivot = ActiveSheet
    End If
    
    wksPivot.Activate
    Set pvtBudget = wksPivot.PivotTables(strPivotName)
    
    pvtBudget.PivotFields("Sum of Amount").NumberFormat = "+#,##0.00;#,##0.00;##0.00"

    ' Turn off the grand totals
    'pvtBudget.PivotFields("Year").Subtotals = Array(False, False, False, False, False, False, False, False, False, False, False, False)
    pvtBudget.ColumnGrand = False
    pvtBudget.RowGrand = False
    
    pvtBudget.PivotSelect "'Budget Total'", xlDataAndLabel, True
    Selection.EntireColumn.Hidden = True
    
    ' Set the pivot table filters to exclude categories we don't need to see
    colFilterSettings.Add "Annual"
    colFilterSettings.Add "Irregular"
    colFilterSettings.Add "Monthly"
'    colFilterSettings.Add "Project"
    colFilterSettings.Add "Unplanned"
    SetPivotFilterValues strPivotName, "Type", wksPivot, colFilterSettings, dsOnExclusive

GoTo exit_format_pivot
    
    '
    ' Add a conditional format to the monthly values to
    ' turn red if they exceed the monthly budgeted amount by a threshhold
    '
    
    ' Get the range of cells to format
    Set pvtValuesRange = pvtBudget.PivotFields("Year").VisibleItems("2008").DataRange
    
    ' Determine the location of the monthly budget info
    Set pvtField = pvtBudget.PivotFields("Month")
    nBudgetRow = pvtField.VisibleItems("Monthly").DataRange.Row
    nBudgetCol = pvtField.VisibleItems("Monthly").DataRange.Column
    Set rng = pvtField.VisibleItems("Monthly").DataRange
    
    Dim strFormula As String
    
    strFormula = "=" + wksPivot.Cells(nBudgetRow, nBudgetCol).Address(False, True) + "*1.1"
    pvtValuesRange.FormatConditions.Add Type:=xlCellValue, Operator:=xlLess, Formula1:=strFormula
    pvtValuesRange.FormatConditions(pvtValuesRange.FormatConditions.Count).SetFirstPriority
    With pvtValuesRange.FormatConditions(1).Font
        .Color = -16383844
        .TintAndShade = 0
    End With
    With pvtValuesRange.FormatConditions(1).Interior
        .PatternColorIndex = xlAutomatic
        .Color = 13551615
        .TintAndShade = 0
    End With
    pvtValuesRange.FormatConditions(1).StopIfTrue = False
'    pvtValuesRange.FormatConditions(1).ScopeType = xlDataFieldScope
    
    
    ' Select the data range for the year
'    ActiveSheet.PivotTables("PVT_Monthly").PivotSelect "'2008'", xlDataAndLabel, _
'        True
    
    ' Hide the subtotal column for budget
    'Dim rngSubTotals As Range
    Dim n As Long
    Dim nColumnNum As Long

    pvtBudget.PivotSelect "Year[All;Total]", xlDataAndLabel, True
    Set rngSubTotals = Selection
    For n = 1 To rngSubTotals.Areas.Count
        If (rngSubTotals.Areas(n).Cells(1, 1)) = "Budget Total" Then
            nColumnNum = rngSubTotals.Areas(n).Cells(1, 1).Column
            Columns(nColumnNum).EntireColumn.Hidden = True
        End If
    Next

    ' Split the window to always show the category column
    ActiveWindow.SplitColumn = 1
exit_format_pivot:

End Sub


Sub PurgeDatesOutOfRange(strDateCol As String, rng As Range, Optional strDateBefore As String = "", Optional strDateAfter As String = "")
    Dim nDateCol As Integer
    Dim dThreshhold As Date
    Dim dCurrentRow As Date
    Dim nRowFirst As Integer
    Dim nRowLast As Integer
    Dim nCount As Integer


    nDateCol = GetColumnByHeading(strDateCol, rng)
    
    If (strDateBefore <> "") Then
        dThreshhold = CDate(strDateBefore)
        nRowFirst = 2
        nRowLast = 1
        
        SortOnColumnName strDateCol, rng, xlAscending
        
        dCurrentRow = CDate(rng.Cells(nRowFirst, nDateCol))
        While (dCurrentRow < dThreshhold)
            nRowLast = nRowLast + 1
            dCurrentRow = CDate(rng.Cells(nRowLast, nDateCol))
        Wend
        
        If (nRowLast >= nRowFirst) Then
            nCount = nRowLast - nRowFirst
            rng.Cells(nRowFirst, 1).Resize(nCount, rng.Columns.Count).Delete
        End If
    End If
    
    If (strDateAfter <> "") Then
        dThreshhold = CDate(strDateAfter)
        nRowFirst = 2
        nRowLast = 1
        
        SortOnColumnName strDateCol, rng, xlDescending
        
        dCurrentRow = CDate(rng.Cells(nRowFirst, nDateCol))
        While (dCurrentRow > dThreshhold)
            nRowLast = nRowLast + 1
            dCurrentRow = CDate(rng.Cells(nRowLast, nDateCol))
        Wend
        
        If (nRowLast >= nRowFirst) Then
            nCount = nRowLast - nRowFirst
            rng.Cells(nRowFirst, 1).Resize(nCount, rng.Columns.Count).Delete
        End If
    End If
    
End Sub


Sub SubCategorize()
    Dim nCommentCol As Long
    Dim nRow As Long
    Dim nNextRow As Long
    Dim strValue As String
    Dim nPrevFindRow As Long
    Dim strParam As String
    Dim strNewValue As String
    Dim bRemoveSubCats As Boolean
    Dim strDelim As String
    Dim n As Long
    Dim o As Long
    Dim rng As Range
    
    strDelim = "#"
    bRemoveSubCats = True
    
    nCommentCol = GetColumnByHeading("Memo")
    nRow = FindValueInColumn(ActiveSheet.Cells, strDelim, nCommentCol)
    
    nPrevFindRow = 0
    While (nRow > nPrevFindRow)
        nPrevFindRow = nRow
        strValue = ActiveSheet.Cells(nRow, nCommentCol).Value
        strParam = Between(ActiveSheet.Cells(nRow, nCommentCol).Value, strDelim, strDelim)
        
        ' If the parameter isn't wrapped by delimiters, ignore it.
        If InStr(strValue, strDelim + strParam + strDelim) Then
            DivideSubCategories strParam, nRow
        
            If (bRemoveSubCats) Then
                strNewValue = Trim(Replace(strValue, strDelim + strParam + strDelim, ""))
                ActiveSheet.Cells(nRow, nCommentCol) = strNewValue
            End If
        End If
        
        nNextRow = -1
        On Error Resume Next
        nNextRow = ActiveSheet.Columns(nCommentCol).FindNext(ActiveSheet.Cells(nRow, nCommentCol)).Row
        On Error GoTo 0
        If nNextRow > 0 Then
            nRow = nNextRow
        End If
    
    
    Wend
End Sub


Sub DivideSubCategories(strParam As String, nRow As Long)
    Dim nOffset As Integer
    Dim strDelim As String
    Dim nCount As Long
    Dim strSubCategories() As String
    Dim nSubCatCol As Integer
    
    strDelim = "|"
    
    nCount = Tokenize(strParam, strDelim, strSubCategories)
    For nOffset = 1 To nCount
        nSubCatCol = GetColumnByHeading("SubCat" + CStr(nOffset))
        ActiveSheet.Cells(nRow, nSubCatCol) = strSubCategories(nOffset)
    Next
End Sub





Sub AddBudgetEntriesToData(strDataTable As String, strBudgetTable As String)
    Dim rngData As Range
    Dim rngBudget As Range
    
    Dim nBudgetCatCol As Integer
    Dim nBudgetAccountCol As Integer
    Dim nBudgetAmtCol As Integer
    Dim nDataMonthCol As Integer
    Dim nDataYearCol As Integer
    Dim nDataCatCol As Integer
    Dim nDataSubCatCol As Integer
    Dim nDataSubCat1Col As Integer
    Dim nDataDateCol As Integer
    Dim nDataAmtCol As Integer
    Dim nDataAccountCol As Integer
    Dim nDestRow As Integer
    Dim lAmount As Long
    Dim rng As Range
    Dim n As Integer
    Dim c As Range
    Dim nBudgetRow As Integer
    Dim strConcat As String
    Dim strTokens() As String
    
    Set rngBudget = Range(strBudgetTable)
    Set rngData = Range(strDataTable)
    
    nBudgetCatCol = GetColumnByHeading("Category", rngBudget)
    nBudgetAmtCol = GetColumnByHeading("Budget", rngBudget)
    nDataDateCol = GetColumnByHeading("Date", rngData)
    nDataMonthCol = GetColumnByHeading("Month", rngData)
    nDataYearCol = GetColumnByHeading("Year", rngData)
    nDataCatCol = GetColumnByHeading("Category", rngData)
    nDataSubCatCol = GetColumnByHeading("SubCategory", rngData)
    nDataSubCat1Col = GetColumnByHeading("SubCat1", rngData)
    nDataAmtCol = GetColumnByHeading("Amount", rngData)
    nDataAccountCol = GetColumnByHeading("Account", rngData)
    
    nDestRow = rngData.Rows.Count + 1
    
    Set rngBudget = rngBudget.Cells(2, 1).Resize(rngBudget.Rows.Count - 1, rngBudget.Columns.Count)
    For Each c In rngBudget.Columns(1).Cells
        lAmount = c.Offset(0, nBudgetAmtCol - 1)
        If (lAmount > 0) Then
            rngData.Cells(nDestRow, nDataAccountCol).Resize(2, 1) = "Budget"
            rngData.Cells(nDestRow, nDataDateCol).Resize(2, 1) = "=Today()"
            strConcat = c.Offset(0, nBudgetCatCol - 1)
            Tokenize strConcat, "|", strTokens
            rngData.Cells(nDestRow, nDataCatCol).Resize(2, 1) = strTokens(1)
            If UBound(strTokens) > 1 Then
                rngData.Cells(nDestRow, nDataSubCatCol).Resize(2, 1) = strTokens(2)
            End If
            
            rngData.Cells(nDestRow, nDataYearCol).Resize(2, 1) = "Budget"
            rngData.Cells(nDestRow, nDataSubCat1Col).Resize(2, 1) = "Budget"
            
            rngData.Cells(nDestRow, nDataMonthCol) = "Monthly"
            rngData.Cells(nDestRow, nDataAmtCol) = lAmount * -1
            
            rngData.Cells(nDestRow + 1, nDataMonthCol) = "Annual"
            rngData.Cells(nDestRow + 1, nDataAmtCol) = lAmount * -1 * 12
            
            nDestRow = nDestRow + 2
        End If
    Next
    
    Range(strDataTable).Resize(nDestRow - 1, rngData.Columns.Count).Name = strDataTable

End Sub


Sub btnWipeMoneyData()
Attribute btnWipeMoneyData.VB_ProcData.VB_Invoke_Func = "w\n14"
   Dim wks As Worksheet
   Dim strDefaultSheets(5) As String
   Dim strDeleteSheets() As String
   Dim varWorksheet
   Dim nNumSheets As Integer
   Dim nmName As Name
   
   nNumSheets = 0
   strDefaultSheets(0) = "Monthly"
   strDefaultSheets(1) = "Income"
   strDefaultSheets(2) = "Balanced"
   strDefaultSheets(3) = "Taxes"
   strDefaultSheets(4) = "Vacation"
   strDefaultSheets(5) = "Projects"
   
   ' Generate the list of existing macro created sheets
   On Error Resume Next
      For Each varWorksheet In strDefaultSheets
         Err.Clear
         Set wks = Sheets(varWorksheet)
         If (Err.Number = 0) Then
            ReDim Preserve strDeleteSheets(nNumSheets)
            strDeleteSheets(nNumSheets) = varWorksheet
            nNumSheets = nNumSheets + 1
         End If
      Next
   
      ' Delete any names that are no longer valid
      For Each nmName In Names
         If (Left(nmName.Name, 3) = "tmp") Then
            nmName.Delete
         End If
      Next
      
      Names("TBL_Balanced").Delete
   On Error GoTo 0
   
   ' Add all sheets called Sheet### (generated by clicking pivot items)
   For Each wks In Sheets
      If (LCase(Left(wks.Name, 5)) = "sheet") Then
         If (IsNumeric(Mid(wks.Name, 6))) Then
            ReDim Preserve strDeleteSheets(nNumSheets)
            strDeleteSheets(nNumSheets) = wks.Name
            nNumSheets = nNumSheets + 1
         End If
      End If
   Next

   ' Delete the sheets we don't want (we'll get prompted)
   If (nNumSheets > 0) Then
      Sheets(strDeleteSheets).Delete
   End If
   
   ' Clear out the Money data for a refresh
   ResetData "Data", 2
   
   
   ' Set Data to the active sheet
   Sheets("Data").Activate
   Cells(1, 1).Select
End Sub


'
' Money macros
'
' These macros are executed via the Run command in the Main macro.
' They are triggered by wrapping a keyword between @.
' Use a comma separated list within the memo field to designate per record arguments
' Use a comma separated list with the RunMoneyMacros function to designate per macro arguments
'
Sub RunMoneyMacros(strCode As String, strMacroName As String, Optional strMacroArgList As String = "", Optional strDataSheet As String = "")
    Dim nCommentCol As Long
    Dim nRow As Long
    Dim nNextRow As Long
    Dim strValue As String
    Dim nPrevFindRow As Long
    Dim strMemoArgList As String
    Dim strNewValue As String
    Dim bRemoveMacros As Boolean
    Dim strFullMacroName As String
    Dim strDelim As String
    Dim wksDataSheet As Worksheet
    
    If (strDataSheet <> "") Then
        Set wksDataSheet = GetDataSheet(strDataSheet, False)
    Else
        Set wksDataSheet = ActiveSheet
    End If
    
    '
    ' strCode can be any pattern in the MS Money memo field, prepended with the delimeter,
    ' and ended with a :.
    '
    bRemoveMacros = True
    strDelim = "@"
    
    ' Define the string for which we'll search in the memo field.
    strFullMacroName = strDelim + strCode + ":"
    
    nCommentCol = FindColumn(wksDataSheet, "Memo")
    nRow = FindValueInColumn(wksDataSheet.Cells, strFullMacroName, nCommentCol)
    
    nPrevFindRow = 0
    While (nRow > nPrevFindRow)
        nPrevFindRow = nRow
        
        strValue = wksDataSheet.Cells(nRow, nCommentCol).Value
        strMemoArgList = Between(wksDataSheet.Cells(nRow, nCommentCol).Value, strFullMacroName, strDelim)
        
        If (bRemoveMacros) Then
            strNewValue = Trim(Replace(strValue, strFullMacroName + strMemoArgList + strDelim, ""))
            wksDataSheet.Cells(nRow, nCommentCol) = strNewValue
        End If
        
        Run strMacroName, nRow, strMemoArgList, strMacroArgList
        
        nNextRow = -1
        On Error Resume Next
        nNextRow = FindValueInColumn(wksDataSheet.Cells, strFullMacroName, nCommentCol, nRow)
        On Error GoTo 0
        If nNextRow > 0 Then
            nRow = nNextRow
        End If
    Wend
    
End Sub


Sub FixDate(nRow As Integer, strMemoArgList As String, strMacroArgList As String)
    Dim nDateCol As Integer
    
    nDateCol = GetColumnByHeading("Date")
    ActiveSheet.Cells(nRow, nDateCol) = strMemoArgList
End Sub

'
' Divides the transaction into n equal monthly charges.  This is useful for bills
' which come bimonthly, quarterly, yearly, etc.
'
' Specifying a ,F after the number of months (eg. @DIV:12,F@) tells the macro to project the charges
' forward.  Default is backward.
'
Sub DivideIntoMonthly(nRow As Integer, strMemoArgList As String, strMacroArgList As String)
    Dim nDateCol As Integer
    Dim nAmountCol As Integer
    Dim nMemoCol As Integer
    Dim nNumMonths As Integer
    Dim fAmtPerMonth As Single
    Dim dEndDate As Date
    Dim nNewDay As Integer
    Dim dNewDate As Date
    Dim i As Integer
    Dim strArgs() As String
    Dim nDirection As Integer
    Dim strMemo As String
    
    nDirection = -1
    
    Tokenize strMemoArgList, ",", strArgs
    nNumMonths = CInt(strArgs(1))
    If (UBound(strArgs) > 1) Then
        If (strArgs(2) = "F") Then
            nDirection = 1
        End If
    End If
    
    nDateCol = GetColumnByHeading("Date")
    nAmountCol = GetColumnByHeading("Amount")
    nMemoCol = GetColumnByHeading("Memo")
    fAmtPerMonth = Round(ActiveSheet.Cells(nRow, nAmountCol) / nNumMonths, 2)
    dEndDate = CDate(ActiveSheet.Cells(nRow, nDateCol))
    
    For i = 1 To nNumMonths - 1
        dNewDate = DateAdd("m", nDirection * i, dEndDate)
        ActiveSheet.Rows(nRow).Copy
        ActiveSheet.Rows(nRow + 1).Insert Shift:=xlDown
    
        strMemo = ActiveSheet.Cells(nRow, nMemoCol)
        ActiveSheet.Cells(nRow + 1, nDateCol) = dNewDate
        ActiveSheet.Cells(nRow + 1, nAmountCol) = fAmtPerMonth
        ActiveSheet.Cells(nRow + 1, nMemoCol) = strMemo + "(" + CStr(i) + " of " + CStr(nNumMonths) + ")"
    Next
    
    ActiveSheet.Cells(nRow, nAmountCol) = fAmtPerMonth
End Sub


Sub FlagForFollowup(nRow As Integer, strMemoArgList As String, strMacroArgList As String)
    Dim nDateCol As Integer
    Dim nAmountCol As Integer
    Dim nMemoCol As Integer
    Dim nNumMonths As Integer
    Dim fAmtPerMonth As Single
    Dim dEndDate As Date
    Dim nNewDay As Integer
    Dim dNewDate As Date
    Dim i As Integer
    Dim strArgs() As String
    Dim nDirection As Integer
    Dim strMemo As String
    Dim rngMemoCell As Range
    
    nDirection = -1
    
    nMemoCol = GetColumnByHeading("Memo")
    
    Set rngMemoCell = ActiveSheet.Cells(nRow, nMemoCol)
    
    With rngMemoCell.Interior
        .Pattern = xlSolid
        .PatternColorIndex = xlAutomatic
        .ThemeColor = xlThemeColorAccent2
        .TintAndShade = 0.799981688894314
        .PatternTintAndShade = 0
    End With
    rngMemoCell.AddComment
    rngMemoCell.Comment.Visible = False
    rngMemoCell.Comment.Text Text:=strMemoArgList
End Sub


Sub LastBalanced(nRow As Integer, strMemoArgList As String, strMacroArgList As String)
' Under construction
   ' Creates and populates a table of all accounts and when
   ' they were last balanced.  The balanced date and amount are
   ' manually stored in the Money memo field.
   '
   ' MemoArgList is passed in the the Money memo field
   ' MacroArgList is passed in with the call to RunMoneyMacro
   '
   Dim strMacroArgs() As String
   Dim strMemoArgs() As String
   Dim nDateCol As Integer
   Dim nAccountCol As Integer
   Dim nAmountCol As Integer
   Dim nMemoCol As Integer
   Dim fBalancedVal As Single
   Dim dBalancedDate As Date
   Dim strMemo As String
   Dim strAccount As String
   Dim str As String
   Dim bRangeExists As Boolean
   Dim cellRngUL As Range
   Dim wks As Worksheet
   Dim rngBalTable As Range
   Dim wksDataSheet As Worksheet
   Dim nFoundRow As Integer
   
   Dim nColumn As Long
   Dim vRetVal As Variant
   Dim rngNewRow As Range
   
   Set wksDataSheet = ActiveSheet
   
   Tokenize strMemoArgList, ",", strMemoArgs
   Tokenize strMacroArgList, ",", strMacroArgs
    
   nDateCol = GetColumnByHeading("Date")
   nAccountCol = GetColumnByHeading("Account")
   dBalancedDate = CDate(ActiveSheet.Cells(nRow, nDateCol))
   fBalancedVal = CCur(strMemoArgs(1))
   strAccount = ActiveSheet.Cells(nRow, nAccountCol)
   
   On Error Resume Next
   str = Names(strMacroArgs(1))
   bRangeExists = (Err.Number = 0)
   On Error GoTo 0
   If Not bRangeExists Then
      Set wks = GetDataSheet("Balanced", True)
      Set rngBalTable = wks.Cells(1, 1).Resize(1, 3)
      rngBalTable = Array("Account", "Last Balanced", "Last Amount")
      rngBalTable.Resize(2, 3).Name = strMacroArgs(1)
   Else
      Set rngBalTable = Range(strMacroArgs(1))
   End If
     
   nFoundRow = FindValueInColumn(rngBalTable, strAccount, 1)
   If (nFoundRow = 0) Then
      Debug.Print ("Inserting new row.  Account: " + strAccount + " Date: " + CStr(dBalancedDate) + " Amount: " + CStr(fBalancedVal))
      rngBalTable.Cells(2, 1).Resize(1, 3).Insert
      Set rngNewRow = rngBalTable.Cells(2, 1).Resize(1, 3)
      rngNewRow = Array(strAccount, dBalancedDate, fBalancedVal)
   Else
      Set rngNewRow = rngBalTable.Cells(nFoundRow, 1).Resize(1, 3)
      rngNewRow = Array(strAccount, dBalancedDate, fBalancedVal)
      Debug.Print ("Updating row.  Account: " + strAccount + " Date: " + CStr(dBalancedDate) + " Amount: " + CStr(fBalancedVal))
   End If
   
'   wksDataSheet.Activate
End Sub

