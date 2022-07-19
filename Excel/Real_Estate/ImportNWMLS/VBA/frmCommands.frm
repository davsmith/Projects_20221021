VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmCommands 
   Caption         =   "Commands"
   ClientHeight    =   3615
   ClientLeft      =   45
   ClientTop       =   345
   ClientWidth     =   4050
   OleObjectBlob   =   "frmCommands.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmCommands"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Dim g_strHousesSheet As String
Dim g_strTrackingSheet As String
Dim g_strHousesListRange As String
Dim g_strTrackingListRange As String

'
' Detail view buttons
'
Private Sub btnDetailHigh_Click()
    ShowView 4
End Sub

Private Sub btnDetailLow_Click()
    ShowView 1
End Sub

Private Sub btnDetailMed_Click()
    ShowView 2
End Sub

'
' Filter view buttons
'
Private Sub btnFilterClearFilter_Click()
    frmViewing.ResetFilterButtons
    FilterView -1
End Sub

Private Sub btnFilterHighRating_Click()
    frmViewing.ResetFilterButtons
    FilterView 1
End Sub

Private Sub btnFilterUnrated_Click()
    frmViewing.ResetFilterButtons
    FilterView 3
End Sub

Private Sub btnFilterMediumRating_Click()
    frmViewing.ResetFilterButtons
    FilterView 2
End Sub



Private Sub btnImport_Click()
 ImportMLSRecords
End Sub




Private Sub btnSortCommunity_Click()
    SortView 4
End Sub

Private Sub btnSortMLS_Click()
    SortView 1
End Sub

Private Sub btnSortPrice_Click()
    SortView 2
End Sub

Private Sub btnSortRating_Click()
    SortView 3
End Sub


Private Sub chkShowRecordDialog_Click()
    If (chkShowRecordDialog.Value) Then
        frmViewing.Show vbModeless
        frmViewing.Top = Me.Top
        frmViewing.Left = Me.Left + Me.Width
    Else
        frmViewing.Hide
    End If
End Sub

Private Sub UserForm_Initialize()
    Dim strRange As String
    
    strRange = "tmpTrackingResults"

    ' Navigate to the "Tracking" sheet
    Range(strRange).Worksheet.Activate
End Sub

Private Sub UserForm_Terminate()
    frmViewing.Hide
End Sub

Public Sub ResetCommandFilterButtons()
    btnFilterClearFilter = False
    btnFilterHighRating = False
    btnFilterUnrated = False
    btnFilterMediumRating = False
End Sub
