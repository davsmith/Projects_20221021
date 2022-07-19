VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmViewing 
   Caption         =   "Viewing"
   ClientHeight    =   3120
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   4710
   OleObjectBlob   =   "frmViewing.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmViewing"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub btnFilterToViewed_Click()
    frmCommands.ResetCommandFilterButtons
    FilterView 4
End Sub

Private Sub btnFilterToSkip_Click()
    frmCommands.ResetCommandFilterButtons
    FilterView 5
End Sub

Private Sub btnFilterToVisit_Click()
    frmCommands.ResetCommandFilterButtons
    FilterView 6
End Sub



Private Sub btnGoSee_Click()
    SetViewingValue 1
End Sub

Private Sub btnResetViewing_Click()
    SetViewingValue -1
End Sub

Private Sub btnSkipForNow_Click()
    SetViewingValue 2
End Sub

Private Sub btnViewed_Click()
    SetViewingValue 3
End Sub



Private Sub UserForm_Activate()
    Dim nMLS As Long
    
    nMLS = GetMLSFromRange(Selection.Cells(1, 1))
End Sub


Sub ResetFilterButtons()
    btnFilterToViewed.Value = False
    btnFilterToSkip.Value = False
    btnFilterToVisit.Value = False
End Sub

Sub ResetActionButtons()
    btnGoSee.Value = False
    btnSkipForNow.Value = False
    btnViewed.Value = False
    btnResetViewing.Value = False
End Sub

