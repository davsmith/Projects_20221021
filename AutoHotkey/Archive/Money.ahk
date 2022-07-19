#NoEnv

;
; Money.ahk
;
; Various functions and hotkeys for use with Microsoft Money and Excel
;
;
; Notes:
; --------------------------------------------------------------------------------------------
; 10/17/09:
; - Added NewTransactionsFromClipboard
; - Did some commenting and cleanup, but it needs much more.
;
;

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode 2


#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\debug.ahk

;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;



;******************************************** Custom **********************************************

;********************************************************************

; *************
; Scoped tools
; *************


;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;


;********************************************************************
#ifwinactive Microsoft Money
;********************************************************************



; Temporary Hotkeys
::_dd::
   Send Dining Out:Dining Out - Dave
return

::_dt::
   Send Dining Out:Dining Out - Together
return

::_da::
   Send Dining Out:Dining Out - Ang 
return

::_atm::
   Send +{Tab 4}^c
   Send Cash
   Send {Tab 4}
   Send ATM - ^V
   Send +{Tab}{Enter}
return


^f::
  SetKeyDelay 25
  Send Vacation:Food{Tab}{Tab}
  Send ^v 
return

^l::
  SetKeyDelay 25
  Send Vacation:Lodging{Tab}{Tab}
  Send ^v 
return

^a::
  SetKeyDelay 25
  Send Vacation:Activities{Tab}{Tab}
  Send ^v
return

^t::
  SetKeyDelay 25
  Send Vacation:Transportation{Tab}{Tab}
  Send ^v
return

^g::
  SetKeyDelay 25
  Send Gasoline{Tab}
return

^r::
  SetKeyDelay 25
  Send Groceries{Tab}
return

^s::
  SetKeyDelay 100
  Send {Delete}Y
return


::M9602::
   SetKeyDelay 10
   Send !I
   Send {Tab 4}
   Send *Rental Expense:Mortgage
   Send {Tab 2}
   Send 9602
return

::M7231::
   SetKeyDelay 100
   Send !I
   Send {Tab 4}
   Send *Rental Expense:Mortgage
   Send {Tab 2}
   Send 7231
return

::MC::
   SetKeyDelay 100
   Send !I
   sleep 500
   Send !N
   sleep 500
   Send !C
   sleep 500
   Send {Enter}
return


::MAng::
   SetKeyDelay 10
   Send !I
   Send !N
   Send !C
   Send {Enter}
   Send {Tab 3}
   Send Angela Smith
   Send {Tab 2}
   Send Bank of America (Angela Checking){Enter}
return


::TDFun::
   SetKeyDelay 100
   Send !I
   Send !N
   Send !C
   Send {Enter}
   Send {Tab 3}
   Send First Tech (Dave Fun Money){Enter}
   Send {Tab 2}
   Send First Tech (Dave Fun Money){Enter}
return


;********************************************************************
#ifwinactive ahk_class ClassSplit
;********************************************************************
^c::
   CopyGridToClipboard()
return

^v::
   PasteClipboardToGrid()
return



^!C::
   SetKeyDelay 25
   Send Loan:Payment
   Send {Tab}
   Send {Home}
   Send {#}Swedes{#}
return



;********************************************************************
#ifwinactive ahk_class MSMoney Frame
;********************************************************************
^!v::
   ; Create transactions from Excel copy to clipboard.
   ; For Charles Schwab Credit Card statement, use 1,4,6,999
   NewTransactionsFromClipboard(1,4,6,999)
return


; *************
; Global tools
; *************


;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************

^!i::
   str1 = This is a test 
   StringReplace str2, str1,%a_Space%, _, All

   WinGetClass strClass, A

      MsgBox %strClass%
return

^!B::
   Input chrVal, L1
   MsgBox %chrVal% 
return




^!c::
   SetKeyDelay 10
   Click 2
   Sleep 100
   Click 2
   Sleep 100
   Send {Tab}
   Send ^c
   Send {Tab 4}
   StringReplace strMemo, clipboard, %a_space%(Interest)
   StringReplace strMemo, strMemo, %a_space%Bank
   Send {#}%strMemo%{#}{Enter}
return



^!o::
   SetKeyDelay 10
   Click 2
   Sleep 100
   Click 2
   Sleep 100
   Send {Tab 5}
   Send {#}Countrywide{#}
return



::_t::
   WinActivate, ahk_class ClassSplit
return

^p::
  SetKeyDelay 20
  Send %clipboard%
return

::_scriptdir::
  MsgBox %a_scriptdir%
return				

^u::
  SetKeyDelay 20
  Send *Rental Expense:Utilities{Tab}
return


^n::
  SetKeyDelay 20
  Send Bills:Natural Gas{Tab}
return

::_7015::
  Send Bills:Natural Gas{Tab}
  Send Late Fee (7015){tab}
return


::_9602::
  Send Bills:Natural Gas{Tab}
  Send Late Fee (9602){tab}
return


::_7231::
  Send Bills:Natural Gas{Tab}
  Send Late Fee (7231){Tab}
return



;
;**************
;  Functions
;**************


;
; Copies the contents of a "split" dialog from MS Money to the clipboard.
;
CopyGridToClipboard()
{
  ifwinexist, ahk_class ClassSplit
  {
     WinActivate

     SetKeyDelay 50
     strOutput =

     Send ^{Home 2}
     ; Do one line of the matrix
     loop, 
     {
        ; Get the category field
        clipboard =
        Send {tab}^c
        szCategory = %clipboard%

        ; Get the Description field
        clipboard = 
        Send {tab}^c
        szComment = %clipboard%

        ; Get the Amount
        clipboard = 
        Send {tab}^c
        szAmount = %clipboard%
        Send {tab}

        ; If we get to a blank category, assume we're at the end.
        if szCategory = 
        {
           break
        }

        ; Append this line onto the other lines we've copied so far
        strOutput = %strOutput%%szCategory%`t%szComment%`t%szAmount%`r
     }

     ; Go back to the beginning of the control
     Send {escape}{home}

     ; Put the contents in the clipboard
     clipboard = %strOutput%
  }

  return
}



;
; Pastes the contents of the clipboard into a grid control (eg. the Split or Paycheck dialogs) in MS Money.
; The paste begins at the currently selected row.
;
; Intended use is to select one or more rows in Excel, copy them, then paste them into the grid control.
; Expects 3 column by n row matrix has been copied.
;
;
PasteClipboardToGrid()
{
  ifwinexist, ahk_class ClassSplit
  {
     WinActivate
     SetKeyDelay 50
     StringTrimRight, clean_line2, clipboard, 2
     StringReplace clean_line, clean_line2,%a_Space%:%a_space%, :, All
     Send %clean_line%
     Send {Enter}
     ifwinactive Microsoft Money ahk_class #32770 
     {
         Send !Y
     } 

     Send {esc 2}
  }

  return
}


;
; Creates new transactions in the current account from rows in the clipboard
;
; Intended use is to select one or more rows in Excel, from a bank or credit card statement,
; then create new transactions in the Money account.
;
; Expects >=4 column by n row matrix has been copied.
;
; Args refer to the column number containing each piece of information
;
NewTransactionsFromClipboard(nPayTo, nDate, nAmount, nMemo)
{
   LogFunctionStart("NewTransactionsFromClipboard")

   SetKeyDelay 50
   StringReplace, clipboard, clipboard, `r`n,``, All         ; Get rid of all of the CR/LFs
   StringSplit, strLines, clipboard, ``                      ; Parse the clipboard into separate lines                  

   nLines := strLines0 - 1
   loop, %nLines%                                            ; Loop through each line
   {
      StringReplace, strLine, strLines%a_index%, #, _        ; Money/AH barfs if you "Send" a pound sign
      StringSplit, strTokens, strLine, %a_tab%               ; Split on tabs
      strPayTo := strTokens%nPayTo%
      strAmount := strTokens%nAmount%                        ; Get Payee, Amount, Date, and memo
      strDate := strTokens%nDate%
      strMemo := strTokens%nMemo%

      Send !w                                                ; Start a new transaction
      Sleep 500                                              ; Wait for the form to display
      Send %strDate%{Tab}
      Send %strPayTo%{Delete}{Tab}
      Send %strAmount%{Tab}                                  ; Send keyclicks to populate new xaction form
      Send Miscellaneous : Dummy (Expense)
      Send {Tab 2}
      Send {Delete}%strMemo%
      Send {Enter}                                           ; Save the transaction
      Sleep 500
   }

NEWTRANSACTIONSFROMCLIPBOARD_EXIT:
   LogFunctionEnd()
   return
}


;
; Count the number of tabs in a line of text.
; Useful for determining the number of columns if the line is being pasted from Excel.
;

::_CountGrid::
{
 str = %clipboard%
 StringSplit, OutputArray, str, `n
 OutputArray0 := OutputArray0 - 1
 MsgBox %OutputArray0%
 
 count := 0
 loop, %OutputArray0%
 {
   count := count + 1
   onesub := OutputArray%count%
   nTabs := CountTabs(onesub)
   MsgBox Line %count% has %nTabs% tabs
 }

 ; nCount := CountTabs(clipboard)
 ; MsgBox %nCount% tabs.
 return
}



;
; This function enters the contents of the clipboard into Microsoft Money.
; Each line creates a separate transaction.
;
; Lines are tab delimited into the following fields: Date, Payee, Amount, Comment, Category (optional)
;
^e::
   ClipboardToTransactions()
return

ClipboardToTransactions()
{
   LogFunctionStart("ClipboardToTransactions")

   ; Divide the clipboard into lines
   str = %clipboard%
   StringSplit, LineArray, str, `n
   LineCount := LineArray0 - 1
   MsgBox # Lines: %LineCount% 

   ; Loop through the lines, adding them to MS Money
   nCounter := 1

   loop
   {
      ; Are we past the last line?
      if (nCounter > LineCount)
      {
         break
      }
   
      ; Divide the line into its columns.  The array was created by the StringSplit above.
      strLine := LineArray%nCounter%
      StringSplit, ColumnArray, strLine, %a_tab%, `n`r
      nNumColumns := ColumnArray0

      ; Depending on the number of columns, assign the values appropriately
      if (nNumColumns < 4)
      {
         MsgBox Date, Payee, Amount, Comment, and Category are required.`rBlank category will leave default.
         return
      }

      strDate := ColumnArray1
      strPayee := ColumnArray2
      strAmount := ColumnArray3
      strComment := ColumnArray4
      strCategory := ColumnArray5

      SetKeyDelay, 50
      Sleep 200

      ; Open the "Withdrawal" form... assumes all transactions are negative
      Send {Esc}
      Send {Alt Down}r{Alt Up}

      Send !W                           ; Open a new transaction
      Send {Tab}                        ; Go to the date field
      Send %strDate%{Tab}               ; Fill in the date, and advance to the Payee field
      Send %StrPayee%
      Send {Tab}                  
      Send %strAmount%                  ; Fill in the Amount
      Send {Tab}
      Send %strCategory%                ; Fill in the category
      Send {Tab 2}
      Send %strComment%                 ; Fill in the comment
      Send {Enter}   

      nCounter := nCounter + 1
    }

   temp_exit:
   LogFunctionEnd()
   return
}



CountTabs(strLine)
{
  nCount := 0
  nSkip := 0

  loop
  {
;     nPosition := InStr(strLine, "`t", 0, nSkip)
;     MsgBox %strLine%  Skip = %nSkip%
     StringGetPos, nPosition, strLine, %A_Tab%,,%nSkip%
;     MsgBox Position = %nPosition%
     if (nPosition > 0)
     {
        nCount := nCount + 1
        nSkip := nPosition + 1
     }
     else
     {
        break
     }
  }

  return nCount
}



;
;***********
;  XL2QIF
;***********
::_genqif::
;   WriteXL2QIFIni()
return

^!t::
   WinMaximize A
   Click 163, 70
   Sleep 1000
   Send ^C
   MsgBox % clipboard
return

WriteXL2QIFIni(strAccount="")
{
   LogFunctionStart(A_ThisFunc)

   strBlank := ""
   strIniPath := a_AppData . "\Microsoft\AddIns\xl2qif.ini"
   strOutputQIF := a_Desktop . "\msmoney2.qif"
   strFields = <Memo>;<Date>;<Don't Care>;<Payee>;<Debit>;<Credit>

   Log(strIniPath)
   clipboard := strIniPath

   strSection = General
   IniDelete %strIniPath%, %strSection%

   IniWrite 1.11, %strIniPath%, %strSection%, Version 
   IniWrite english, %strIniPath%, %strSection%, Language 

   strSection = QIF Settings
   IniDelete %strIniPath%, %strSection%

   IniWrite %strBlank%, %strIniPath%, %strSection%, QIFLoadFile 
   IniWrite %strBlank%, %strIniPath%, %strSection%, QIFLoadDate 
   IniWrite %strOutputQIF%, %strIniPath%, %strSection%, QIFSaveFile 
   IniWrite MM/DD/YYYY, %strIniPath%, %strSection%, QIFSaveDate 
   IniWrite Bank, %strIniPath%, %strSection%, Account
   IniWrite None, %strIniPath%, %strSection%, Processing
   IniWrite -1, %strIniPath%, %strSection%, DebitCredit
   IniWrite 0, %strIniPath%, %strSection%, InvertAmount 
   IniWrite 0, %strIniPath%, %strSection%, KeepCellFormat
   IniWrite -1, %strIniPath%, %strSection%, ImportMoney
   IniWrite %strFields%, %strIniPath%, %strSection%, Fields

goto WRITEXL2QIFINI_EXIT
WRITEXL2QIFINI_EXIT:
   LogFunctionEnd()

   return
}
