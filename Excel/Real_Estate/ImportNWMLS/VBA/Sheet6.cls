VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet6"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    Dim nMLS As Long
    
    nMLS = GetMLSFromRange(Target)
    Debug.Print "MLS: " + CStr(nMLS)
    frmViewing.txtMLSValue = CStr(nMLS)
    frmViewing.ResetActionButtons
End Sub
