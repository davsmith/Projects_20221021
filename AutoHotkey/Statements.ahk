;
; PDF.ahk
;
; Sets the general formatting for an AutoHotKey (AHK) script file.
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 1/31/10:
; - Removed the PDF manipulation functionality (it's in PDFTools.AHK)
; - Updated the functions for downloading Fidelity and Ameritrade statements.
;
;
; 10/28/09:
; - Modifed PDF_Interleave to use CFD and prompt for # pages.
;
; 10/24/09:
; - Added header and formatted per template
; - Added MakeBatch function
; - Modified PDF_CombineFiles to create an INI file, and call MakeBatch
;
;

;
; #########################
;   Global Initialization
; #########################

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

Statements_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\debug.ahk


;
; ###############
;   Scope tools
; ###############
;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;

;********************************************************************
#ifwinactive Online Statements - Windows Internet Explorer
;********************************************************************
;
; ################
;   Global tools
; ################
;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************

; ###################
;   Utility Hotkeys
; ###################


; Edward Jones statement download helpers
!^U::
   SetKeyDelay 150
   Click 358,522
   Send {Down 2}{Enter}
   Click 509,522
   Send {Down 4}{Enter}
   Click 669,522
return

!^V::
   SetKeyDelay 50
   Click 70,142
   Sleep 500
   Clipboard = D:\DaveDocs\PDFs\Edward Jones\Roth\2004.pdf
   Send D:\DaveDocs\PDFs\Edward Jones\Roth\2004.pdf
   Send {Left 4}
return


::_g::
   WinActivate, ahk_class ClassSplit
return

;
; Saves a statement from Capital One by printing to an XPS file
; NOTE: Capital One doesn't support PDF.
;
::Cap1_1::
   SetKeyDelay 100
   Send {Tab 3}
   Send {Enter}
   Sleep 1000
   Send !P
   Sleep 1000
   InputBox strDate, Statement End Date, Enter statement end date (mmdd):
   Send {Home}{Delete}2006%strDate%
   Send !S
   Sleep 1500
   Send {Tab 3}{enter}
return

^!Q::
   SetKeyDelay 100
   Click 66,98
return 



;
; **************
; *  Fidelity  *
; **************
;^!S::
   Save_Fidelity_Statement()
return

Save_Fidelity_Statement()
{
   ; Log in to the Fidelity site and browse to the page
   ; with the list of statements.
   ; The first column should be statement date with the, third column
   ; a link to the PDF.
   ;
   ; Highlight the date (3 clicks), then press ctrl-c to copy the date
   ; then run this function to open the PDF, and save it locally.
   ;
   
   LogFunctionStart("Save_Fidelity_Statement")
   LogFunctionEnd()
   SetKeyDelay 20

   ; Using Window Spy, get x & y window location for
   ; for the date to use in the filename 
   statement_date_x = 477
   statement_date_y = 174
   offset_x = 551
   save_button_x = 71
   save_button_y = 77
   strSavePath = D:\DaveDocs\PDFs\Fidelity (ESPP)
   strCurrentYear = 2006

   MouseGetPos xMousePos, yMousePos
   Click 380, %yMousePos%
   Sleep 6500

   strDate := DateParse(clipboard)
   strDate2 := substr(strDate, 1, 4) . substr(strDate, 7, 2) . substr(strDate, 5, 2)

   ; Maximize the explorer window, and click the save button
   WinMaximize A
   Click %save_button_x%, %save_button_y%
   Sleep 1000
   Send %strSavePath%{Enter}
   Sleep 500
   Send %strDate2%.pdf
   Send {left 4}
   Send {Enter}
   WinClose A 
goto SAVE_FIDELITY_STATEMENT_EXIT
SAVE_FIDELITY_STATEMENT_EXIT:
   return
}


;
; ***************
; *  Ameritrade *
; ***************
;^!s::
;   Save_Ameritrade_Statement()
;return

Save_Ameritrade_Statement()
{
   ; Log in to the Ameritrade site and browse to the page
   ; with the list of statements.
   ; The first column should be statement month linked to a printable page.
   ; The second column should be a date range with the text Statement at the end.
   ;
   ; Highlight the second column (3 clicks), then press ctrl-c to copy the date range
   ; then run this function to open the file, and print to XPS, saving it locally.
   ;
   
   LogFunctionStart("Save_Fidelity_Statement")
   LogFunctionEnd()
   SetKeyDelay 20

   ; Using Window Spy, get x & y window location for
   ; for the date to use in the filename 
   statement_date_x = 477
   statement_date_y = 174
   offset_x = 551
   save_button_x = 70
   save_button_y = 143 
   strSavePath = D:\DaveDocs\PDFs\Ameritrade
   strCurrentYear = 2006

   MouseGetPos xMousePos, yMousePos
   Click 216, %yMousePos%
   Sleep 6500

   strDate := clipboard
   strDate := substr(strDate, 12, 10)
   strDate := DateParse(strDate)
   strDate2 := substr(strDate, 1, 4) . substr(strDate, 7, 2) . substr(strDate, 5, 2)
   WinMaximize, A
   Sleep 1500
   Click %save_button_x% %save_button_y%
   Sleep 500
   Send %strSavePath%\%strDate2%.pdf
goto SAVE_AMERITRADE_STATEMENT_EXIT
   Send !F
   Sleep 1500
   Send p 
   Sleep 1000
   Send Microsoft{Enter}

   Send {Enter}
   Sleep 200 
   Click 24,44
   WinClose A 
SAVE_AMERITRADE_STATEMENT_EXIT:
   return
}


^!C::
   RemoveUnderscoresFromFilename()
return

RemoveUnderscoresFromFilename()
{
   LogFunctionStart("RemoveUnderscoresFromFilename")
   Send {F2}
   Sleep 500
   Send {Home}{Right 4}{Delete}{Right 2}{Delete}{Enter}
   LogFunctionEnd()
}


;************************************************************
::_cp::
  sleep 500
  SetKeyDelay 100
  Send, {LCtrl down}C{LCtrl up}
  MsgBox %clipboard%
return

; AHK_TRICK:  Selection takes a bit of time to catch up before Ctrl-C will get it.
;             so you have to put in a delay between selection and sending the Ctrl-C.
^e::
   Send {Down}
   Send ^{Right 3}
   Send +^{Right 3}
   Sleep 100
   Send ^c
   Sleep 100
   MsgBox %clipboard%
return

::_Chase::
   SetKeyDelay 20
   Click 317, 379
   Send +^{Right 3}
   Click Right, 325, 379
   Send {ESC}
   Sleep, 100
   Click Right
   Send Y
;   MsgBox Clipboard: %clipboard%
   strEndDate = %clipboard%
;   End date = %strEndDate%
   strFmtDate := DateParse(strEndDate) 
;   MsgBox %strFmtDate%
   FormatTime, strFileName, %strFmtDate%, yyyy_MM_dd
;   MsgBox %strFileName%
   Click 65, 105
   Send D:\DaveDocs\PDFs\Chase (Mastercard)\%strFilename%.pdf{Enter}
   Sleep 100
   WinClose, A
return


;::_Countrywide::
   SetKeyDelay 20

   nDateCoordX := 670
   nDateCoordY := 177
;   strPath = D:\DaveDocs\PDFs\Countrywide\Project Savings
   strPath = D:\DaveDocs\PDFs\Countrywide\Cash Holdings
   nSaveButtonX := 66
   nSaveButtonY := 70

   ; Click next to statement date
   Click %nDateCoordX%, %nDateCoordY%

   ; Select the statement date text
   Send +^{Right 3}
   Sleep, 1000

   ; Use right-click to copy since ctrl-c doesn't seem to work
   nBumpX := nDateCoordX + 5
   Click Right, %nBumpX%, %nDateCoordY%
   Send Y

   ; Convert the date string to the filename we'll use
   strEndDate = %clipboard%
;   MsgBox Date variable: %strEndDate%
   strFmtDate := DateParse(strEndDate) 
;   MsgBox Parsed Date: %strFmtDate%
   FormatTime, strFileName, %strFmtDate%, yyyy_MM_dd
;   MsgBox Filename: %strFileName%

   Click %nSaveButtonX%, %nSaveButtonY%
   Send %strPath%\%strFilename%.pdf{Enter}
   Sleep 100
   WinClose, A
return



;::_Schwab::
   SetKeyDelay 20

   nDateCoordX := 98  
   nDateCoordY := 185
   strPath = D:\DaveDocs\pdfs\Schwab\Checking
   nSaveButtonX := 66
   nSaveButtonY := 70

   ; Click next to statement date
   Click %nDateCoordX%, %nDateCoordY%

   ; Select the statement date text
   Send +^{Right 3}
   Sleep, 1000

   ; Use right-click to copy since ctrl-c doesn't seem to work
   nBumpX := nDateCoordX + 5
   Click Right, %nBumpX%, %nDateCoordY%
   Send Y

   ; Convert the date string to the filename we'll use
   strEndDate = %clipboard%
;   MsgBox Date variable: %strEndDate%
;   strFmtDate := DateParse(strEndDate) 
;   MsgBox Parsed Date: %strFmtDate%
;   FormatTime, strFileName, %strFmtDate%, yyyy_MM_dd
;   MsgBox Filename: %strFileName%
   strFilename = %strEndDate%

   Click %nSaveButtonX%, %nSaveButtonY%

   Send %strPath%\%strFilename%.pdf
;   Sleep 100
;   WinClose, A
return



::_user::
   SendUser()
return

SendUser()
{
   global g_strUserName

   Send %g_strUserName%
   return
}


::_hint::
   ShowHint()
return

ShowHint()
{
   global g_strHint

   MsgBox %g_strHint%
   return
}


::_getstatement::
   PutStatementURLOnClipboard()
return

PutStatementURLOnClipboard()
{
   global g_strStatementURL

   LogFunctionStart(a_ThisFunc)
   clipboard := g_strStatementURL
   Run %clipboard%
   LogFunctionEnd()
}


::_Dir::
   PutStatementDirOnClipboard()
return


PutStatementDirOnClipboard()
{
   global g_strStatementDir

   LogFunctionStart(a_ThisFunc)
   clipboard := g_strStatementDir
   Run %clipboard%
   LogFunctionEnd()
}


; Capital One doesn't produce PDF statements, so instead we copy them into OneNote
; Open OneNote and make it full screen to make the coordinates correct.
;
;::_CapitalOne::
^!S::
   Save_CapitalOne_Statement()
return

Save_CapitalOne_Statement()
{
   global g_strStatementRoot
   global g_strStatementDir
   global g_strMainPageURL
   global g_strStatementURL
   global g_strUserName
   global g_strHint

   LogFunctionStart(a_ThisFunc)

   g_strMainPageURL   = https://onlinebanking.capitalone.com/capitalone/
   g_strStatementURL  = https://onlinebanking.capitalone.com/CAPITALONE/Accounts/Statements.aspx
   g_strStatementDir  := g_strStatementRoot . "\Capital One"

   g_strUserName = davsmith22
   g_strHint = Black 0


   WinGetTitle, Title, A
   Log("The active window is " . Title . " and the data dir is " . g_strStatementDir)

goto SAVE_CAPITALONE_STATEMENT_EXIT
   SetKeyDelay 20

   ; Set the area to highlight on the statement, so that we can capture the statement date
   nDateCoordX := 176
   nDateCoordY := 281
   nDateEndX := 228
   nDateEndY := 281

   ; Highlight and copy the statement date
   Click down %nDateCoordX%, %nDateCoordY%
   click up %nDateEndX%, %nDateEndY%
   nBumpX := nDateEndX - 5
   Click right %nBumpX% %nDateEndY%
   Send C
   strDate = %clipboard%

   ; Shift-Tab up to the link for printing the statement, and launch the printing dialog
   Send +{Tab 2}{Space}{Enter}
   Sleep 1000
   ; Tell the printing dialog to "Send to OneNote 2007"
   Send Send
   Send {Enter}

   ; Wait for OneNote to launch
   Sleep 2000

   ; Click in the title area of the page, and enter the statement date
   Click 237, 156
   Send %strDate%

   ; Go back to the IE page with the list of statements
   Sleep 100
   Send !{Tab 2}

SAVE_CAPITALONE_STATEMENT_EXIT:
   LogFunctionEnd()
   return 
}

::_FirstUSA::
;   SetKeyDelay 20
   Click 399, 501
;   Send +^{Right 3}
;   Sleep 1500
;   Send ^C
   Send +^{Right 3}
   Sleep 100
   Send ^c
   strEndDate = %clipboard%
   strFmtDate := DateParse(strEndDate) 
;   MsgBox %strFmtDate%
   FormatTime, strFileName, %strFmtDate%, yyyy_MM_dd
;   MsgBox %strFileName%
   Click 65, 105
   Send D:\DaveDocs\PDFs\Chase (Mastercard)\%strFilename%.pdf{Enter}
   Sleep 100
;   WinClose, A
return


::_Discover::
   SetKeyDelay 20
   Send !S
   Sleep 1000
   Send ^C
   StringTrimRight, strRawDate1, clipboard, 4
   StringTrimLeft, strRawDate, strRawDate1,19
   strMonth := SubStr(strRawDate, 1, 2)
   strDay := SubStr(strRawDate, 3, 2)
   strYear := SubStr(strRawDate, 5, 4)
   strFilename = %strYear%_%strMonth%_%strDay%
   Send \\davsmith00\davedocs$\PDFs\Discover\%strFilename%.pdf{Enter}
   Sleep 1000
   Send {Enter}
return


::_PSE::
   SetKeyDelay 20
   Click 257, 390
   Send +^{Right 3}
   Send ^C
   Click Right, 260, 395
   Send {ESC}
   Sleep, 100
   Click Right
   Send Y
   MsgBox Clipboard: %clipboard%
   strEndDate = %clipboard%
   MsgBox %strFmtDate%
;   FormatTime, strFileName, %strFmtDate%, yyyy_MM_dd
;   MsgBox %strFileName%
;    Click 85, 243
;   Click 65, 105
;   Send D:\DaveDocs\PDFs\Chase (Mastercard)\%strFilename%.pdf{Enter}
;   Sleep 100
;   WinClose, A
return


^w::
   MouseGetPos, nMouseX, nMouseY
   x2 := nMouseX + 5
   Click
   Send +{End}
   Sleep 200
   clipboard = 
   Click Right %x2% %nMouseY%
   Send Y   
   Send, ^C
   ClipWait, 2
   if ErrorLevel
   {
      MsgBox, The attempt to copy text onto the clipboard failed.
      return
   }
;   MsgBox, clipboard = %clipboard%
   strLine = %clipboard%
   strDate1 := SubStr(strLine, 1, 5)
   strDate = %strDate1%/2008
   strPayee1 := Substr(strLine, 30)
   StringTrimRight, strPayee, strPayee1, 6
   strLength := StrLen(strLine)
   nPos := strLength - 4
   strAmount := Substr(strLine, nPos)
;   clipboard = %strPayee% Amount: %strAmount%
return

^q::
  Send %strDate%{Tab}
  Send %strPayee%{Tab}
  Send %strAmount%{Tab}
return


;
; Move the mouse cursor to the UR part of the highlighted text.
; This seems pretty fragile, but works for now.
;
::_d::
   WinGetPos, X, Y, Width, Height, A
   MsgBox Doing pixel search on %width% by %height%
   PixelSearch, nFndX, nFndY, 0, 0, %width%, %Height%, 0xDAC199
   MsgBox %nFndX% %nFndY%
   MouseMove %nFndX%, %nFndY%
return


^p::
  SetKeyDelay 20
  Send %clipboard%
return


^d::
  SetKeyDelay 50
  strOutput =
  ; Do one line of the matrix
  loop, 
  {
     clipboard =
     Send {tab}^c
     szCategory = %clipboard%

     clipboard = 
     Send {tab}^c
     szComment = %clipboard%

     clipboard = 
     Send {tab}^c
     szAmount = %clipboard%
     Send {tab}

     if szCategory = 
     {
        break
     }

     strOutput = %strOutput%%szCategory%`t%szComment%`t%szAmount%`r
  }

  Send {escape}{home}
  clipboard = %strOutput%
return

^u::
  SetKeyDelay 20
  Send *Rental Expense:Utilities{Tab}
return



; #############
;   Functions
; #############

Statements_Startup()
{
   global g_fsdir
   global g_strStatementRoot
   global g_strStatementDir
   global g_strMainPageURL
   global g_strStatementURL
   global g_strUserName
   global g_strHint

   LogFunctionStart(a_ThisFunc)

   g_fsdir := GetFolderShareDir()
   strBinDir := g_fsdir . "Projects\_bin"

   if (a_computername = "DAVSMITHA") 
   {
      g_strStatementRoot := "D:\DaveDocs\PDFs"
   }
   else
   {
      g_strStatementRoot := g_fsdir . "Scans\Shoebox"
   }

STATEMENTS_STARTUP_EXIT:
   LogFunctionEnd()
}

^!`::
{
   SearchForText("Quick")
}

SearchForText(strSearchText)
{
   LogFunctionStart("SearchForText")

   brgHighLight = 0xDAC199
   nShades = 0

   Send ^f
   Send %strSearchText%{Enter}
   Sleep 100

   PixelSearch, Px, Py, 50, 89, 990, 913, 0xDAC199, 0, Fast
   if ErrorLevel
      Log("*** That color was not found in the specified region.")
   else
   {
      strLog = A color within %nShades% shades of variation was found at X:%Px%, Y:%Py%
      Log(strLog)
      Px += 5
      Py += 5
      Click right %Px% %Py%
      Sleep 200
      Send e
      Click %Px% %Py%
   }

   LogFunctionEnd()
   return
}


::_genini::
   Statements_GenerateIni()
return

Statements_GenerateIni()
{
   global g_strStatementRoot

   LogFunctionStart(%a_thisfunc%)

   strBankName       = CapitalOne
   strMainPageURL    = https://onlinebanking.capitalone.com/capitalone/
   strStatementURL   = https://onlinebanking.capitalone.com/CAPITALONE/Accounts/Statements.aspx
   strStatementDir  := g_strStatementRoot . "\Capital One"
   strUserName       = davsmith22
   strHint           = Black 0

   WriteIni("Statements.ini", strBankName, "StatementRoot", g_strStatementRoot )
   WriteIni("Statements.ini", strBankName, "StatementDir",  strStatementDir )
   WriteIni("Statements.ini", strBankName, "MainPageURL",   strMainPageURL )
   WriteIni("Statements.ini", strBankName, "StatementURL",  strStatementURL )
   WriteIni("Statements.ini", strBankName, "UserName",      strUserName )
   WriteIni("Statements.ini", strBankName, "Hint",          strHint )

   WriteIni("Statements.ini", "First Tech", "BinDir", "Gubzer")


goto STATEMENTS_GENERATEINI_EXIT
STATEMENTS_GENERATEINI_EXIT:
   LogFunctionEnd()
   return
}