Attribute VB_Name = "Product_Studio_Tools"
Option Explicit

' ************************************
'       Product Studio Tools
' ************************************
'* Updated 6/8/2010
'*  - Documented and grouped functions.
'*
'* Updated 6/22/08
'*  - Exported from ScenarioUtils6.xlsm
'*

' *****************
'    Connection
' *****************

'----------------------------------------------------------------------------
' ConnectToDatastore
'
' This function connects to the specified Product Studio database on
' the specified domain.
'
' The function returns a Datastore object which can be passed to other
' functions in the tool set.
'
' Example:
'    ConnectToDatastore("redmond.corp.microsoft.com", "WEX COSD Find and Organize")
'----------------------------------------------------------------------------

Function ConnectToDatastore(strDomain As String, strProduct As String) As ProductStudio.Datastore
    Dim oDirectory As ProductStudio.Directory
    Dim oProduct As ProductStudio.Product
    
    If (strDomain = "") Then
        strDomain = "redmond.corp.microsoft.com"
    End If
    
    Set oDirectory = CreateObject("ProductStudio.Directory")
    oDirectory.Connect strDomain

    Set oProduct = oDirectory.GetProductByName(strProduct)
    Set ConnectToDatastore = oProduct.Connect
End Function



' *****************
'    Queries
' *****************

'
' Executes the query in a PSQ file, and populates a specified worksheet with the results.
'
' [in]  strPSQFile          The PSQ file to execute
' [in]  strWorkSheet        The text name of the worksheet where the results are placed.
' [in]  nFirstRow           The first row which will be populated with query results.
' [in]  nFirstCol           The first column which will be populated with query results
' [in]  strRangeName        Define a name in the workbook for the range of results
'
' - Assumes the redmond domain if none is specified
' - Displays the fields specified in the PSQ file
'
Function QueryUsingPSQ(strPSQFile As String, _
                    strWorkSheet As String, _
                    Optional nFirstRow As Integer = 1, _
                    Optional nFirstCol As Integer = 1, _
                    Optional strRangeName As String = "", _
                    Optional strDomain As String) As Integer
    
    Dim strQuery As String
    Dim strDatabase As String
    Dim strMode As String
    Dim recordlist As DatastoreItemList
    Dim objQueryDisplayInfo As psqResultList
    Dim strDisplayFields() As String

'    On Error GoTo PSFailed

    ' If no domain is specified, use Redmond
    If (strDomain = "") Then
        strDomain = "redmond.corp.microsoft.com"
    End If
    
    ' Get the query info from the PSQ file
    Set objQueryDisplayInfo = GetQueryFromPSQ(strPSQFile, strQuery, strDatabase, strDisplayFields, strMode)
        
    ' Execute the query using the display fields from the PSQ file to determine which fields to retrieve
    Set recordlist = RunQuery(strDomain, strQuery, strDatabase, strDisplayFields, objQueryDisplayInfo, strMode)
    
    PutPSResultsInWorksheet recordlist, strWorkSheet, strDisplayFields, nFirstRow, nFirstCol, strRangeName
    
    QueryUsingPSQ = recordlist.DatastoreItems.Count
    GoTo EndQueryUsingPSQ
    
PSFailed:
    MsgBox ("Error in loading Product Studio data")
    Err.Clear
    GoTo EndQueryUsingPSQ

EndQueryUsingPSQ:
End Function ' QueryUsingPSQ



'
' Executes the query text from Product Studio, and populates a specified worksheet with the results.
'
' [in]  strQuery            The query in XML text
' [in]  strWorkSheet        The text name of the worksheet where the results are placed.
' [in]  nFirstRow           The first row which will be populated with query results.
' [in]  nFirstCol           The first column which will be populated with query results
'
' - Assumes the redmond domain if none is specified
' - Assumes the fields to display are listed in the first row of the destination spreadsheet.
' - Query text can be placed in the clipboard from PS by holding ctrl and pressing the ! (execute button).
'
Sub QueryUsingText(strQuery As String, strDatabase As String, _
                    strWorkSheet As String, _
                    Optional nFirstRow As Integer = 1, _
                    Optional nFirstCol As Integer = 1, _
                    Optional strDoman As String)
    
    Dim strDomain As String
    Dim recordlist As DatastoreItemList
    Dim objQueryDisplayInfo As psqResultList
    Dim strDisplayFields() As String
    Dim numCols As Integer
    Dim strColHeading As String
    Dim datasheet As Worksheet
    Dim j As Integer
    
'    On Error GoTo PSFailed

    ' Use the column headings to determine which fields to fetch from PS
    numCols = 0
    Set datasheet = GetDataSheet(strWorkSheet)
    strColHeading = HeadingFromColumn(datasheet, numCols + 1)
    While Not (strColHeading = "")
        numCols = numCols + 1
        strColHeading = HeadingFromColumn(datasheet, numCols + 1)
    Wend
    
    ReDim strDisplayFields(numCols - 1) As String
    
    For j = 1 To numCols
        strColHeading = HeadingFromColumn(datasheet, j)
        strDisplayFields(j - 1) = strColHeading
    Next
    
    ' If no domain was specified, use Redmond
    If (strDomain = "") Then
        strDomain = "redmond.corp.microsoft.com"
    End If
    
    ' Execute the query using the display fields we found in the worksheet
    Set recordlist = RunQuery(strDomain, strQuery, strDatabase, strDisplayFields)
    
    ' Put the query results into the specified spreadsheet
    PutPSResultsInWorksheet recordlist, strWorkSheet, strDisplayFields, nFirstRow, nFirstCol
    
    GoTo EndQueryUsingText
    
PSFailed:
    MsgBox ("Error in loading Product Studio data")
    Err.Clear
    GoTo EndQueryUsingText

EndQueryUsingText:
End Sub ' QueryUsingPSQ



'
' Takes the results from a PS Query and places them in the specified worksheet.
'
' [in]  objResultList       The result list from a query executed against Product Studio
' [in]  strWorkSheet        The text name of the worksheet where the results are placed.
' [in]  nFirstRow           The first row which will be populated with query results.
' [in]  nFirstCol           The first column which will be populated with query results.
' [in]  strDisplayFields    A string array of column headings
'
'
Sub PutPSResultsInWorksheet(objResultList As DatastoreItemList, strWorkSheetName As String, strDisplayFields() As String, _
                                Optional nFirstRow = 1, Optional nFirstCol = 1, _
                                Optional strRangeName As String = "", Optional strSortField As String)
    Dim objItem As ProductStudio.DatastoreItem
    Dim objItems
    Dim nNumRows As Integer
    Dim vRange As Range
    Dim vArray() As Variant
    Dim datasheet As Worksheet
    Dim nNumCols As Integer
    Dim nCurRow, nCurCol As Integer
    Dim nPrimarySortCol As Integer

    ' Retrieve the data sheet
    Set datasheet = GetDataSheet(strWorkSheetName, True)
        
    ' Figure out the dimensions of the result matrix
    Set objItems = objResultList.DatastoreItems
    nNumRows = objItems.Count
    nNumCols = UBound(strDisplayFields)
    
    ' Put the column headings in the worksheet
    Set vRange = datasheet.Range(datasheet.Cells(nFirstRow, nFirstCol), datasheet.Cells(nFirstRow, nNumCols + nFirstCol - 1))
    vRange.Value = strDisplayFields
        
    ' Populate an array with the results
    Set vRange = datasheet.Range(datasheet.Cells(nFirstRow + 1, nFirstCol), datasheet.Cells(nNumRows + nFirstRow + 1, nNumCols + nFirstCol - 1))
    
    vArray = vRange.Value
    
    nCurRow = 1
    For Each objItem In objItems
        ' BUGBUG:  For some fields in PS you have to open the item for editing, but it's very expensive for performance.
        ' BUGBUG:  It would be good to do an error check and open for edit only when this fails.
'        objItem.Edit psDatastoreItemEditActionReadOnly
        For nCurCol = 1 To nNumCols
            vArray(nCurRow, nCurCol) = objItem.Fields(strDisplayFields(nCurCol - 1))
        Next
        
        nCurRow = nCurRow + 1
    Next
    
    ' Populate the worksheet with the array data
    vRange.Value = vArray
    
    ' Adjust the range to include the headings
    Set vRange = vRange.Offset(-1, 0)
    
    ' If specified, define a name in the worksheet for the range
    If (strRangeName <> "") Then
        Debug.Print ("  Name: " + strRangeName + "   Address:" + vRange.Address)
        vRange.Worksheet.Activate
        vRange.Select
        vRange.Name = strRangeName
    End If

    ' If a sort field is specified, sort by the field, ascending
    If (strSortField <> "") Then
        nPrimarySortCol = Application.WorksheetFunction.match(strSortField, vRange.Rows(1), 0)
        Set vRange = vRange.Offset(1).Resize(vRange.Rows.Count - 1)
        vRange.Sort Key1:=vRange.Cells(1, nPrimarySortCol), order1:=xlAscending
    End If
End Sub



'
' Returns the text query string, and display fields from a specified PSQ file.
'
' [in]  strPSQFile          The PSQ file to parse for query strings and display fields
' [out] strQuery            The query in XML text form
' [out] strDisplayFields    A string array with the list of fields displayed in the query
' [out] strProductName      The name of the PS database used in this query
' [out] strMode             The mode of the query.  This is almost always "Bugs"
Function GetQueryFromPSQ(strPSQFile As String, strQuery As String, strProductName As String, _
                            strDisplayFields() As String, strMode As String) As psqResultList
'    On Error GoTo GetQueryFromPSQ_ERROR:
    Dim objPSQ As ProductStudio.PSQFile            'ProductStudio.PSQFile
    Dim objProdQueries As Object    'ProductStudio.PSQProductQueries
    Dim objDisplayFields As Object  'ProductStudio.ResultList
    Dim i As Integer
     
    ' Open the specified file
    Set objPSQ = CreateObject("ProductStudio.PSQFile")
    objPSQ.Load strPSQFile
    strMode = objPSQ.currentmode
    Set objProdQueries = objPSQ.Modes(strMode).Handler.GenerateProductQueries()
    Set objDisplayFields = objPSQ.Modes(strMode).Handler.Format.resultlist
    
    ' Assume there is only 1 query in the file.  If there are more, take the first
    strQuery = objProdQueries(0).SelectionCriteria
    strProductName = objPSQ.PrimaryProductName
    
    ' Populate the list of display fields
    ReDim strDisplayFields(objDisplayFields.DisplayColumns.Count - 1) As String
    
    For i = 0 To objDisplayFields.DisplayColumns.Count - 1
        strDisplayFields(i) = objDisplayFields.DisplayColumns(i).Name
    Next
    
    Set GetQueryFromPSQ = objDisplayFields
    
    Exit Function
GetQueryFromPSQ_ERROR:
    If Err.Number = 429 Then
        MsgBox "Fatal Error: Product Studio is not installed."
        End
    End If
End Function



' Runs a Product studio query against the specified database and returns the results
'
' [in]  strDomain           The domain string for the connection
' [in]  strQuery            The XML text for the query to be executed
' [in]  strProductName      The PS database name against which the query is executed.
' [in]  strDisplayFields    An array of strings specifying the fields to show in the results
' [in]  strMode             The mode for the query.  This is usually "Bugs"
Function RunQuery(strDomain As String, strQuery As String, strProductName As String, strDisplayFields() As String, _
                    Optional objQueryDisplayInfo As ProductStudio.psqResultList, Optional strMode As String = "Bugs") As DatastoreItemList
'    On Error GoTo RunQuery_ERROR
    Dim objDirectory As ProductStudio.Directory
    Dim objProduct As ProductStudio.Product
    Dim objDataStore As ProductStudio.Datastore
    Dim objQuery As ProductStudio.Query
    Dim psDatastoreItemType As ProductStudio.PsDatastoreItemTypeEnum
    'Dim objItems
    Dim objFields As ProductStudio.FieldDefinitions
    Dim objList As ProductStudio.DatastoreItemList
    Dim objItemList As ProductStudio.DatastoreItemList
    Dim nSortType As Integer
    
    Dim i As Integer
        
    ' Specify the product database we'll use and
    ' the domain in which the database is located.
    psDatastoreItemType = Switch(strMode = "Bugs", psDatastoreItemTypeBugs, _
                                    strMode = "TestCase", psDatastoreItemTypeTestCase, _
                                    strMode = "TestResult", psDatastoreItemTypeResult)
    
    ' BUGBUG:  Could use a global constant for the redmond domain string.
    If (strDomain = "") Then
        strDomain = "redmond.corp.microsoft.com"
    End If
    
    ' Connect to Active Directory to get the product reference
    ' BUGBUG:  Could use ConnectToDatastore
    Set objDirectory = CreateObject("ProductStudio.Directory")
    objDirectory.Connect strDomain
    
    Set objProduct = objDirectory.GetProductByName(strProductName)
    Set objDataStore = objProduct.Connect
    
    ' Build the query from the passed in query text, and the item type (usually "Bugs")
    Set objQuery = CreateObject("ProductStudio.Query")
    objQuery.CountOnly = False
    objQuery.DatastoreItemType = psDatastoreItemType
    
    ' Create the ItemList
    Set objItemList = CreateObject("ProductStudio.DataStoreItemList")
    Set objItemList.Query = objQuery
    Set objItemList.Datastore = objDataStore
    
    ' Set the selection criteria for the query.
    objQuery.SelectionCriteria = strQuery
    
    ' Get the field definitions so we can specify them in the
    ' result and sort list.
    Set objFields = objDataStore.FieldDefinitions
    
    ' Specify the fields to be returned
    objQuery.QueryFields.Clear
    
    For i = 0 To UBound(strDisplayFields)
        objQuery.QueryFields.Add objFields(strDisplayFields(i))
    Next
    
    ' Specify the sort order
    If Not objQueryDisplayInfo Is Nothing Then
        For i = 0 To objQueryDisplayInfo.SortColumns.Count - 1
            If (objQueryDisplayInfo.SortColumns(i).Ascending) Then
                nSortType = psSortTypeAscending
            Else
                nSortType = psSortTypeDescending
            End If
            
            objQuery.QuerySortFields.Add objFields(objQueryDisplayInfo.SortColumns(i).Name), nSortType
        Next
    End If
    
    ' Execute the query
    objItemList.Execute
    
    Set RunQuery = objItemList
    Exit Function

RunQuery_ERROR:
    MsgBox "Error: RunQuery()"
    End
End Function



Function CountRecordsInQuery(strQuery As String, strDatabase As String, _
                                Optional strDomain As String = "redmond.corp.microsoft.com") As Integer
    Dim recordlist
    Dim strDisplayFields(0) As String
    
    strDisplayFields(0) = "ID"
    
    ' Execute the query using the display fields from the PSQ file to determine which ields to retrieve
    Set recordlist = RunQuery(strDomain, strQuery, strDatabase, strDisplayFields)
    
    CountRecordsInQuery = recordlist.DatastoreItems.Count
    
End Function



Function BuildQueryFromIDList(rngBugList As Range, strPSQFileName As String)
    Dim strDatabase As String
    Dim strQueryString As String
    Dim fs As Object
    Dim a
    Dim nIDColumn As Integer
    Dim nFirstBugRow As Integer
    Dim nNumRows As Integer
    Dim i As Integer
    Dim strClause As String
    
    
    nNumRows = rngBugList.Rows.Count
    nIDColumn = FindColumnInRange(rngBugList, "ID")
    
    '<Data Application="Product Studio" Type="Query" Version="2.1"><Query Product="Windows OS Bugs" CurrentMode="Bugs" CurrentTree="1"><Mode Type="Bugs" ModeFormat="QueryBuilder"><QueryBuilder><Expression AttachWith="" Field="Product" Operator="Equals" Value="Windows OS Bugs"/><Expression AttachWith="And" Field="ID" Operator="Equals" Value="1095735"/><Expression AttachWith="Or" Field="ID" Operator="Equals" Value="1102234"/><Expression AttachWith="Or" Field="ID" Operator="Equals" Value="1111111"/></QueryBuilder><ResultList><DisplayColumns><Column Name="ID" Width="140"/><Column Name="Title" Width="917"/></DisplayColumns><SortColumns><Column Name="ID" Ascending="-1"/></SortColumns></ResultList></Mode><Mode Type="Contacts"><Browse Product="Windows OS Bugs" BrowseBy="Path" BrowsePath="\"/></Mode></Query></Data>

    strQueryString = "<Data Application=" + WrapInQuotes("Product Studio") + _
                            " Type=" + WrapInQuotes("Query") + _
                            " Version=" + WrapInQuotes("2.1") + ">" + _
                        "<Query Product=" + WrapInQuotes("Windows OS Bugs") + _
                            " CurrentMode=" + WrapInQuotes("Bugs") + _
                            " CurrentTree=" + WrapInQuotes("1") + ">" + _
                        "<Mode Type=" + WrapInQuotes("Bugs") + _
                            " ModeFormat=" + WrapInQuotes("QueryBuilder") + ">" + _
                        "<QueryBuilder> " + _
                        "<Expression AttachWith=" + WrapInQuotes("") + _
                            " Field=" + WrapInQuotes("Product") + _
                            " Operator=" + WrapInQuotes("Equals") + _
                            " Value=" + WrapInQuotes("Windows OS Bugs") + "/>"
                            
                            
    ' Use the AND operator for the first bug in the list, then use OR for the rest.
    strClause = "<Expression AttachWith=" + WrapInQuotes("And") + " Field=" + WrapInQuotes("ID") + _
                            " Operator=" + WrapInQuotes("Equals") + _
                            " Value=" + WrapInQuotes(CStr(rngBugList.Cells(2, nIDColumn))) + "/>"
    strQueryString = strQueryString + strClause
                        
    For i = 3 To nNumRows
        strClause = "<Expression AttachWith=" + WrapInQuotes("Or") + _
                            " Field=" + WrapInQuotes("ID") + _
                            " Operator=" + WrapInQuotes("Equals") + _
                            " Value=" + WrapInQuotes(CStr(rngBugList.Cells(i, nIDColumn))) + "/>"
        strQueryString = strQueryString + strClause
    Next

    strQueryString = strQueryString + "</QueryBuilder>" + _
                        "<ResultList>" + _
                        "<DisplayColumns>" + _
                            "<Column Name=" + WrapInQuotes("ID") + " Width=" + WrapInQuotes("70") + "/>" + _
                            "<Column Name=" + WrapInQuotes("Title") + " Width=" + WrapInQuotes("400") + "/>" + _
                            "<Column Name=" + WrapInQuotes("Assigned To") + " Width=" + WrapInQuotes("80") + "/>" + _
                            "<Column Name=" + WrapInQuotes("Opened Date") + " Width=" + WrapInQuotes("70") + "/>" + _
                            "<Column Name=" + WrapInQuotes("Opened By") + " Width=" + WrapInQuotes("70") + "/>" + _
                            "<Column Name=" + WrapInQuotes("Resolved By") + " Width=" + WrapInQuotes("70") + "/>" + _
                            "<Column Name=" + WrapInQuotes("Resolution") + " Width=" + WrapInQuotes("70") + "/>" + _
                        "</DisplayColumns>" + _
                        "<SortColumns>" + _
                        "<Column Name=" + WrapInQuotes("ID") + " Ascending=" + WrapInQuotes("-1") + "/>" + _
                        "</SortColumns>" + _
                        "</ResultList></Mode><Mode Type=" + WrapInQuotes("Contacts") + "><Browse Product=" + WrapInQuotes("Windows OS Bugs") + " BrowseBy=" + WrapInQuotes("Path") + " BrowsePath=" + WrapInQuotes("\") + "/></Mode></Query></Data>"
    Debug.Print (strQueryString)

    ' Dump the field list to a file
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set a = fs.CreateTextFile(strPSQFileName, True)
    a.writeline ("<?xml version=" + WrapInQuotes("1.0") + " encoding=" + WrapInQuotes("UTF-8") + "?>")
    a.writeline (strQueryString)
    a.Close
End Function



'*********
'  Dates
'*********
'
' Rounds a column of dates to the nearest week
'
Sub RoundDateToWeekColumn(rngDate As Range, rngWeek As Range)
    Dim nDateColumn As Long
    Dim nWeekColumn As Long
    Dim strFormula As String
    
    nDateColumn = rngDate.Cells(1, 1).Column
    nWeekColumn = rngWeek.Cells(1, 1).Column
    strFormula = "=RC[" + CStr(nDateColumn - nWeekColumn) + "]-mod(RC[" + CStr(nDateColumn - nWeekColumn) + "],7)"

    rngWeek.Formula = strFormula

End Sub



'***********
'  History
'***********

Sub GetHistory(strPSQuery As String, strWorkSheet As String, Optional strDomain As String, Optional strProductName As String)
    Dim bugs As DatastoreItemList
    Dim strDisplayList() As String
    Dim psqResults As psqResultList
    Dim strXMLQuery As String
    Dim psHistory As DatastoreItemHistory
    Dim bugSingle As Bug
    Dim wksDest As Worksheet
    Dim i As Integer
    Dim j As Integer
    Dim strNewValue As String
    Dim strOriginalValue As String
    
    
    Set wksDest = GetDataSheet(strWorkSheet, True)
    ResetData strWorkSheet, 1
    
    If strDomain = "" Then
        strDomain = "redmond.corp.microsoft.com"
    End If
    
    If strProductName = "" Then
        strProductName = "Windows OS Bugs"
    End If
    
    Set psqResults = GetQueryFromPSQ(strPSQuery, strXMLQuery, strProductName, strDisplayList, "Bugs")
    Set bugs = RunQuery(strDomain, strXMLQuery, strProductName, strDisplayList, psqResults)
    Set bugSingle = bugs.DatastoreItems.Item(1)
    bugSingle.Edit psDatastoreItemEditActionEdit
    Set psHistory = bugSingle.History
    
    For i = 0 To bugSingle.History.Count - 1
        Debug.Print (psHistory.Item(i).TagLine)
        For j = 0 To psHistory.Item(i).Fields.Count - 1
            strNewValue = ""
            strOriginalValue = ""
            On Error Resume Next
            strNewValue = CStr(psHistory.Item(i).Fields(j).Value)
            strOriginalValue = CStr(psHistory.Item(i).Fields(j).OriginalValue)
            On Error GoTo 0
'            If (strNewValue <> "") Or (strOriginalValue <> "") Then
                Debug.Print (CStr(j) + "   " + psHistory.Item(i).Fields(j).Name + " " + psHistory.Item(i).Fields(j).FieldDefinition.Name + " = " + strNewValue + "   Original:" + strOriginalValue)
'            End If
        Next
    Next
    
    bugSingle.Reset True
End Sub



'**********************
'  Tree Functionality
'**********************

' This function takes a hierarchy path and returns the
' Tree ID value that represents the final node on the path.

Function TreeIDFromPath(objNode As ProductStudio.node, strPath As String) As Integer
    Dim nodeCurrent As ProductStudio.node
    
    Set nodeCurrent = GetNodeInTreeFromNode(objNode, strPath)
    
    If (nodeCurrent Is Nothing) Then
        TreeIDFromPath = 0
    Else
        TreeIDFromPath = nodeCurrent.ID
    End If
End Function


Sub Test()
    Dim node As ProductStudio.node
    Dim ds As ProductStudio.Datastore
    
    Set ds = ConnectToDatastore("", "Windows 8 Scenario Tracking")
    Set node = ds.RootNodeEx(psCoreTreeTypeTCM)
    
    Set node = CreatePath(node, "\Test\SecondLevel\ThirdLevel")
End Sub


Sub UnTest()
    DeleteNodeHierarchy "Windows 8 Scenario Tracking", Range("cfgPSPath")
End Sub


Function CreatePath(objNode As ProductStudio.node, strPath As String) As ProductStudio.node
    Dim ds As ProductStudio.Datastore
    Dim nodeRoot As ProductStudio.node
    Dim nodeCurrent As ProductStudio.node
    Dim strPathElements() As String
    Dim i As Integer
    
    Const errNotFound = -2147352565
    
    strPathElements = Split(strPath, "\")
    Set nodeCurrent = objNode
    
    For i = 0 To UBound(strPathElements)
        If ((strPathElements(i) <> "") And (strPathElements(i) <> objNode.Name)) Then
            If (Not nodeCurrent Is Nothing) Then
                On Error Resume Next
                Err.Clear
                Set nodeCurrent = nodeCurrent.Nodes(strPathElements(i))
                If (Err.Number = errNotFound) Then
                    Set nodeCurrent = AddSubNode(nodeCurrent, strPathElements(i))
                End If
                On Error GoTo 0
            End If
        End If
    Next
    
    Set CreatePath = nodeCurrent
End Function



Function AddSubNode(objNode As ProductStudio.node, strSubNodeName As String) As ProductStudio.node
    Dim objDirectory As ProductStudio.Directory
    Dim objProduct As ProductStudio.Product
    Dim objDataStore As ProductStudio.Datastore
    Dim objRootNode As ProductStudio.node
    Dim objSubNodes As ProductStudio.Nodes
    Dim objNewSubNode As ProductStudio.node
    Dim objSubNode As ProductStudio.node
    Dim objCurrentNode As ProductStudio.node
    
    Dim n As Long
    
    
    ' Constants
    ' psUserRightsAdmin from the PsUserRightsMask enum
    ' indicates permission to administer an item.
'    Const psUserRightsAdmin = 4
    
    ' psDatastoreItemTypeTree from PsDatastoreItemTypeEnum
    ' indicates a tree node.
'    Const psDatastoreItemTypeTree = -102
    
    ' psCoreFieldsTreeNodeTypeSubProduct from PsCoreFieldsEnum
    ' indicates the SubProduct level of the hierarchy.
'    Const psCoreFieldsTreeNodeTypeSubProduct = -42
    
   
    Dim IsDuplicateName
    IsDuplicateName = 0
    
    ' Check that you have permission to modify the root node before
    ' you add the child node.
    If (objNode.UserRights(psDatastoreItemTypeTree, False) And psUserRightsAdmin) = psUserRightsAdmin Then
        ' Retrieve the collection of child nodes for the root node, then add
        ' a new child node.
        Set objSubNodes = objNode.Nodes
        Set objNewSubNode = objSubNodes.Add
    
        ' Set the name on the newly created node
        objNewSubNode.Name = strSubNodeName
    
        On Error Resume Next
        Err.Clear
        objNewSubNode.Save
        If (Err.Number <> 0) Then
            Debug.Print ("Error number " + CStr(Err.Number) + " occurred.")
        End If
        On Error GoTo 0
    
        ' If the root node already contains a child node with this name,
        ' display an error message.
    
        ' If the root node does not contain any child nodes with this name,
        ' continue.
'        If IsDuplicateName <> 1 Then
    
        ' You must set the type of the new child node before you save it.
    
        ' Save the new child node.
    
        ' If an error occurred when saving the node, print the
        ' description of the error. Otherwise, print a message that
        ' confirms that you successfully added the child node.
    
        If Err Then
          Debug.Print Err.Description
        Else
          Debug.Print objNewSubNode.Name & " was added."
        End If
    Else
        ' Print a message if you do not have permission to modify the root
        ' node.
        Debug.Print "Permissions insufficient to add a child node to " & _
            "the root node for the specified database."
    End If
    
    Set AddSubNode = objNewSubNode
End Function


Sub Test3()
    DeleteNodeHierarchy "Windows 8 Scenario Tracking", "TestMe"
End Sub



Sub DeleteNodeHierarchy(strDB As String, strPath As String)
    Dim node As ProductStudio.node
    Dim bDeleted As Boolean
    
    Set node = GetNodeInTreeFromDB(strDB, strPath)
    DeleteChildren node
    node.Parent.Nodes.Remove (node.Name)
End Sub



Sub DeleteChildren(node As ProductStudio.node)
    Dim objChild As ProductStudio.node
    Dim bDeleted As Boolean
    
    For Each objChild In node.Nodes()
        If (IsBottomOfTree(objChild)) Then
            node.Nodes.Remove (objChild.Name)
        Else
            DeleteChildren objChild
        End If
    Next
End Sub



Function IsBottomOfTree(objNode As ProductStudio.node) As Boolean
    IsBottomOfTree = (objNode.Nodes.Count = 0)
End Function



Function GetNodeInTreeFromDB(strDatabase As String, strPath As String, Optional strDomain As String = "") As ProductStudio.node
    Dim bFoundIt As Boolean
    Dim ds As ProductStudio.Datastore
    Dim nodeCurrent As ProductStudio.node
    
    If (strDomain = "") Then
        strDomain = "redmond.corp.microsoft.com"
    End If

    Set ds = ConnectToDatastore(strDomain, strDatabase)
    Set nodeCurrent = ds.RootNodeEx(psCoreTreeTypeTCM)
    
    Set nodeCurrent = GetNodeInTreeFromNode(nodeCurrent, strPath)
    
    Set GetNodeInTreeFromDB = nodeCurrent
End Function


Function GetNodeInTreeFromNode(node As ProductStudio.node, strPath As String) As ProductStudio.node
    Dim bFoundIt As Boolean
    Const errNotFound = -2147352565
    Dim strPathElements() As String
    Dim nodeCurrent As ProductStudio.node
    Dim i As Integer
    
    strPathElements = Split(strPath, "\")
    Set nodeCurrent = node
    
    bFoundIt = True
    For i = 0 To UBound(strPathElements)
        If (strPathElements(i) <> "") And (strPathElements(i) <> nodeCurrent.Name) Then
                On Error Resume Next
                Set nodeCurrent = nodeCurrent.Nodes(strPathElements(i))
                If (Err.Number = errNotFound) Then
                    bFoundIt = False
                End If
                On Error GoTo 0
        End If
    Next

    If (Not bFoundIt) Then
        Set nodeCurrent = Nothing
    End If

    Set GetNodeInTreeFromNode = nodeCurrent
End Function



Function GetAbsolutePath(node As ProductStudio.node) As String
    Dim nodeCurrent As ProductStudio.node
    Dim node2
    Dim str As String
    
    Set nodeCurrent = node
    str = nodeCurrent.Name
    
    While Not nodeCurrent.IsRoot
        Set node2 = nodeCurrent.Parent  ' BUGBUG:  Sometimes nodeCurrent.Parent is invalid.  Why?
        Set nodeCurrent = nodeCurrent.Parent
        str = nodeCurrent.Name + "\" + str
    Wend
    
    GetAbsolutePath = str

End Function

'******************
' Case Management
'******************

Sub NewCase()
    Dim objDirectory As ProductStudio.Directory
    Dim objProduct As ProductStudio.Product
    Dim objDataStore As ProductStudio.Datastore
    Dim objItemList As ProductStudio.DatastoreItemList
    Dim objItem As ProductStudio.DatastoreItem
    Dim objFields As ProductStudio.Fields
    Dim objField As ProductStudio.field
    
    ' Specify the product database we'll use and
    ' the domain in which the database is located.
    
    Dim strProductName As String
    Dim strDomain As String
    Dim nFeaturePathID As Integer
    Dim nTestNodeID As Integer
    
    ' -----------------
    Dim ds As ProductStudio.Datastore
    'blahblah
    strProductName = "Windows 8 Scenario Tracking"
'    strProductName = "Product Studio 2.0 SDK Samples"
    
    Set ds = ConnectToDatastore("", strProductName)
    
    
    
    ' Create the ItemList
    nFeaturePathID = TreeIDFromPath(ds.RootNodeEx(psCoreTreeTypeProduct), "WSC-Web Services and Content")
    nTestNodeID = TreeIDFromPath(ds.RootNodeEx(psCoreTreeTypeTCM), "Test\WOL:Engage and Acquire Customers Through Rich Content\")
    
    ' Create a new test case
    Dim oTestCase As ProductStudio.DatastoreItem
    Set oTestCase = CreateTestCase(ds)
    oTestCase.Fields("TreeID") = nFeaturePathID
    
    Dim oTCMTrees As ProductStudio.SubobjectField
    Dim oCurrentTree
    Dim oNewTree As ProductStudio.Subobject
    
    Set oTCMTrees = oTestCase.SubobjectFields("TCMTrees")
    
    For Each oCurrentTree In oTCMTrees
        Debug.Print oCurrentTree.Name
    Next
    
    Set oNewTree = oTCMTrees.Add
    oNewTree.Fields("TCMTreeID") = nTestNodeID
    
    If ValidateFields(oTestCase) Then
        oTestCase.Save False
    Else
        Debug.Print "Error: Invalid Field(s) were found."
    End If
End Sub



'----------------------------------------------------------------------------
' CreateTestCase
'
' The function creates a test case and sets its fields to valid values, so
' the test case can be saved.
'----------------------------------------------------------------------------

Private Function CreateTestCase(oDs) As ProductStudio.DatastoreItem
    Dim oCase As ProductStudio.DatastoreItem
    Dim oField As ProductStudio.field
        
    Set oCase = oDs.GetDatastoreItem(psDatastoreItemTypeTestCase, 0)
    
    For Each oField In oCase.Fields
        Debug.Print oField.Name
    Next
    
    ' Fill all required fields which have no defaults with valid values
    With oCase
    
    
'    .Fields("TreeID") = lFieldID
        .Fields("Opened by") = "davsmith"
        .Fields("Type") = "ScenarioItemDetail"
        .Fields("PM Leader") = "cynthiat"
        .Fields("Test Leader") = "seano"
        .Fields("OSFeatureOwner") = "davlaw"
        .Fields("Test Leader") = "davlaw"
'        .Fields("Tree Path") = "\WSC-Web Services and Content\APPS-App Store and Metadata Services"
        .Fields("Assigned To") = "malamus"
        .Fields("Description") = "Sample test case"
        .Fields("Title") = "Sample test case"
        .Fields("TreeID") = -200
'        .Fields("TCMTreeID") = -200
    End With
    
    Set CreateTestCase = oCase
End Function



'----------------------------------------------------------------------------
' ValidateFields
'
' The function checks all the test case's fields to ensure everything that
' needs a valid value has one. Since the required fields and values can be
' modified by the admin at any time this helps isolate any problems before
' attempting to save the test case.
'----------------------------------------------------------------------------
Function ValidateFields(oDataStoreItem As ProductStudio.DatastoreItem)
    Dim objField As ProductStudio.field
    Dim isValid As Boolean

    isValid = True
    For Each objField In oDataStoreItem.Fields
        If objField.Validity <> psFieldStatusValid Then
            isValid = False
            Debug.Print "Invalid Field " & objField.Name & " : " & objField.Validity & vbCrLf & _
                        "Current Value: " & objField.Value & vbCrLf
        End If
    Next

    ValidateFields = isValid
End Function

Function GetStepsFromFullText(strStepFullText As String, strSteps() As String, bStripNum As Boolean) As Long
    Dim strLines() As String
    Dim nNumLines As Long
    Dim nNumSteps As Long
    Dim n As Long
    Dim nRetVal As Long
    Dim str As String
    
    nNumSteps = 0
    
    ' Break the full text into lines
    nNumLines = StringToLines(strStepFullText, strLines)
    
    For n = 1 To nNumLines
    
        ' If the line starts with a number, followed by a period, it's a step
        str = Trim(Before(strLines(n), "."))
        nRetVal = -1
        On Error Resume Next
            nRetVal = CLng(str)
        On Error GoTo 0
        
        If (nRetVal > 0) Then
            nNumSteps = nNumSteps + 1
            
            If (bStripNum) Then
                str = After(strLines(n), ".")
            Else
                str = strLines(n)
            End If
            
            ReDim Preserve strSteps(nNumSteps - 1)
            strSteps(nNumSteps - 1) = str
        End If
    Next
    
    GetStepsFromFullText = nNumSteps
End Function


Function IsNumbered(strLine As String, Optional bStripNum As Boolean = False) As Boolean
    Dim nStepNum As Long
    Dim str As String
    Dim bRetVal As Boolean
    
    bRetVal = False
    
    ' If the line starts with a number, followed by a period, it's numbered
    str = Trim(Before(strLine, "."))
    nStepNum = -1
    On Error Resume Next
        nStepNum = CLng(str)
    On Error GoTo 0
    
    If (nStepNum > 0) Then
        bRetVal = True
        
        If (bStripNum) Then
            strLine = Trim(After(strLine, "."))
        End If
    End If
    
    IsNumbered = bRetVal
End Function

Function GetResultText(strResultLetter As String) As String
    GetResultText = Choose(InStr("PFNB", strResultLetter), "Pass", "Fail", "N/A", "Blocked")
End Function


Sub AddFilesToRecord(recItem As ProductStudio.DatastoreItem, strFilePaths() As String, Optional bClearFirst As Boolean = False)
    Dim strDocument As String
    Dim n As Integer
    
    Dim i As Integer
    Dim oFileList As ProductStudio.SubobjectField
    Dim oFile As ProductStudio.Subobject
    Dim bOpened As Boolean
    Dim bAlreadyLinked As Boolean
    
    bOpened = False
    
    If (Not recItem.IsOpenForEdit) Then
        recItem.Edit psDatastoreItemEditActionEdit
        bOpened = True
    End If
    
    If (bClearFirst) Then
        recItem.Files.Clear
        recItem.Save
        recItem.Edit psDatastoreItemEditActionEdit
    End If
    
    For n = 0 To UBound(strFilePaths)
        strDocument = strFilePaths(n)
        Debug.Print (strDocument)
        
        bAlreadyLinked = False
        For i = 0 To recItem.Files.Count - 1
            If (recItem.Files(i).Filename = strDocument) Then
                bAlreadyLinked = True
            End If
        Next
        
        If (Not bAlreadyLinked) Then
            recItem.Files.Add strDocument, True
        End If
    Next
    
    If bOpened Then
        recItem.Save
    End If
End Sub
