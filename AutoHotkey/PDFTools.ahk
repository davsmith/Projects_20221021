;
; PDFTools.ahk
;
; Sets the general formatting for an AutoHotKey (AHK) script file.
;
; Notes:
; --------------------------------------------------------------------------------------------
; 01/30/10:
; - Changed the hard coded number of sections in the split macro from 3 to 1.
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

PDF_Startup()

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

::_Combine::
   PDF_CombineFiles()
return

::_Split::
   PDF_SplitFile()
return

::_IntScanner:: 
   PDF_Interleave_Scanner()
return

::_Int:: 
   PDF_Interleave()
return

::_R90::
   PDF_Rotate(90)
return

::_R180::
   PDF_Rotate(180)
return

::_R270::
   PDF_Rotate(270)
return

::_evenodd::
   PDF_Extract_Even_Odd()
return


::_GB::
   strBase := GetBaseName("E:\FolderShare\Scans\Shoebox\Combined.pdf")
return

^R::
   Click 408, 154
   sleep 1000
   Click 560, 411 
   MouseClickDrag, left, 492, 430, 492, 297  
   MouseClickDrag, left, 207, 59, 207, 172    
   Click 566, 320  
return


; #############
;   Functions
; #############

PDF_Startup()
{
   global g_fsdir

   LogFunctionStart("PDF_Startup")

   g_fsdir := GetFolderShareDir()
   strWorkingDir := g_fsdir . "Scans\Shoebox"
   strBinDir := g_fsdir . "Projects\_bin"
   strArchiveDir := strWorkingDir . "\Archive"

   WriteIni("PDFTools.ini", "Common", "WorkingDir", strWorkingDir )
   WriteIni("PDFTools.ini", "Common", "BinDir", strBinDir )

   goto PDF_STARTUP_EXIT
PDF_STARTUP_EXIT:
   LogFunctionEnd()
}


::_pc::
   nCount := PDF_GetPageCount("E:\FolderShare\Scans\Shoebox\Combined.pdf")
   MsgBox %nCount% 
return

PDF_GetPageCount(strInFile)
{
   LogFunctionStart("PDF_GetPageCount")
   Log(A_WorkingDir)
   Log(A_ScriptDir)

   ; Get the paths from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 
   strBinDir := ReadIni("PDFTools.ini", "Common", "BinDir")
   strBatchFile := strWorkingDir . "\CountPages.cmd"
   strPageCountDataFile := strWorkingDir . "\PageCount.txt"
   strInvisScript := strBinDir . "\invis.vbs"

   ; If the specified file doesn't have an absolute path
   ; append the working directory from the INI file.
   strPath := GetPath(strInFile)
   if (strPath = "")
   {
      strInFile := strWorkingDir . "\" . strInFile
   }

   FileDelete %strBatchFile%
   FileDelete %strPageCountDataFile%
   strCmd := strBinDir . "\PDFTK " . strInFile . " dump_data > " . strPageCountDataFile
   Log(strCmd)
   FileAppend %strCmd%, %strBatchFile%   

   RunWait wscript.exe %strInvisScript% %strBatchFile% 
   Sleep 500 

   FileRead strData, %strPageCountDataFile%
   StringReplace, strData, strData, `r`n, , All
   nNumPages := After(strData, "NumberOfPages: ")

   Log("FullString: " . strData) 
   Log("ReadLine: " . nNumPages) 

GETPAGECOUNT_EXIT:
   LogFunctionEnd()
   return %nNumPages%
}


;
; Rotates user specified files in 90 degree increments.
;
PDF_Rotate(nDegrees)
{
   LogFunctionStart("PDF_Rotate")

   ; Get the paths from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 
   strBinDir := ReadIni("PDFTools.ini", "Common", "BinDir")
   strInvisScript := strBinDir . "\invis.vbs"

   ; Remove any previously specified input and output files from the INI
   PDF_ResetIni("PDFTools.ini")

   ; Show the CFD allowing the user to choose multiple files to combine.
   FileSelectFile strFileList, M, %strWorkingDir%, Please choose the PDF files to merge, *.pdf

   if nDegrees = 90
      strRotation = R
   else if nDegrees = 180
      strRotation = D
   else if nDegrees = 270
      strRotation = L
   else
      strRotation = N

   ;
   ; Write the list of input files to an INI file which can be used with PDF_MakeBatch.
   ; Note that selected files are always returned in alphabetical order.
   ;
   nLoop := 1
   Loop, parse, strFileList, `n
   {
      nIndex := nLoop - 1 
      if a_index > 1
      { 
         strKey  := "InFile" . nIndex 
         strValue := a_loopfield
         Log("Writing Ini: " . strKey . "," . strValue)
         WriteIni("PDFTools.ini", "Common", strKey, strValue)
      }
      else 
      {
         ; The first entry in the file list is the directory
         ; containing the selected files.
         strDocPath = %a_loopfield%
         WriteIni("PDFTools.ini", "Common", "WorkingDir", strDocPath)
      }

      ;
      ; Create section in the INI file for the output file
      ; Relevant keys are the output filename, and page ranges
      ; with reference to the alphabetical file handles (see PDFTK docs)
      ;
      strDocFile := strDocPath . "\R_" . a_loopfield
      WriteIni("PDFTools.ini", "OutFile1", "Filename", strDocFile)
      strKey := "Sec1"  
      strValue := "A1-end" . strRotation
      WriteIni("PDFTools.ini", "OutFile1", strKey, strValue)

      ;
      ; Generate and run the batch file, 
      ; then display the output document and open the containing folder.
      ;
      strCMDFile := PDF_MakeBatch("PDFTools.cmd")
      RunWait wscript.exe %strInvisScript% %strCMDFile% 
      Sleep 500 

      RunWait %strDataFile%  

      nLoop++ 
   }
   nNumFiles := nLoop - 1
   RunWait %strDocPath%

PDFROTATE_EXIT:
   LogFunctionEnd()
} 



::_Burst::
   PDF_Burst()
return


;
; Splits user specified file into one page per file.
;
PDF_Burst()
{
   LogFunctionStart("PDF_Burst")

   ; Get the paths from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 
   strBinDir := ReadIni("PDFTools.ini", "Common", "BinDir")
   strInvisScript := strBinDir . "\invis.vbs"
   strBatchFile := AppendWorkingDir(strBatchFile, strWorkingDir)

   ; Show the CFD allowing the user to choose multiple files to combine.
   FileSelectFile strFileList, M, %strWorkingDir%, Please choose the PDF files to merge, *.pdf

   ;
   ;
   nLoop := 1
   Loop, parse, strFileList, `n
   {
      nIndex := nLoop - 1 
      if a_index > 1
      { 
         strOutFile := GetBaseName(a_loopfield) . "_`%`%03d.pdf"
         strCmd := strBinDir . "\PDFTK"
         strCmd := strCmd . " " . strDocPath . "\" . a_loopfield . " burst " . "output " . strOutFile . " dont_ask"

         strCMDFile := strDocPath . "\pdftools.cmd"
         FileDelete %strCMDFile%  
         FileAppend %strCmd%, %strCMDFile%
         RunWait wscript.exe %strInvisScript% %strCMDFile% 
         Sleep 500 
         nIndex++
      }
      else 
      {
         ; The first entry in the file list is the directory
         ; containing the selected files.
         strDocPath = %a_loopfield%
         WriteIni("PDFTools.ini", "Common", "WorkingDir", strDocPath)
         SetWorkingDir %strDocPath% 
      }
   }

   RunWait %strDocPath%

PDFBURST_EXIT:
   strJunkFile := strDocPath . "\doc_data.txt"
   FileDelete %strJunkFile%
   LogFunctionEnd()
} 


;
; Combines multiple user specified PDF files into a single file.
;
PDF_CombineFiles()
{
   LogFunctionStart("PDF_CombineFiles")

   ; Get the working directory from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 

   ; Remove any previously specified input and output files from the INI
   PDF_ResetIni("PDFTools.ini")

   ; Show the CFD allowing the user to choose multiple files to combine.
   FileSelectFile strFileList, M, %strWorkingDir%, Please choose the PDF files to merge, *.pdf

   ;
   ; Write the list of input files to an INI file which can be used with PDF_MakeBatch.
   ; Note that selected files are always returned in alphabetical order.
   ;
   nLoop := 1
   Loop, parse, strFileList, `n
   {
      nIndex := nLoop - 1 
      if a_index > 1
      { 
         strKey  := "InFile" . nIndex 
         strValue := a_loopfield
         Log("Writing Ini: " . strKey . "," . strValue)
         WriteIni("PDFTools.ini", "Common", strKey, strValue)
      }
      else 
      {
         ; The first entry in the file list is the directory
         ; containing the selected files.
         strDocPath = %a_loopfield%
         WriteIni("PDFTools.ini", "Common", "WorkingDir", strDocPath)
      }

      nLoop++ 
   }
   nNumInputFiles := nIndex

   ;
   ; Create section in the INI file for the output file
   ; Relevant keys are the output filename, and page ranges
   ; with reference to the alphabetical file handles (see PDFTK docs)
   ;
   strDocFile := "Combined.pdf"
   WriteIni("PDFTools.ini", "OutFile1", "Filename", strDocFile)
   loop, %nNumInputfiles%
   {
      strKey := "Sec" . a_index  
      nASCII := 64 + a_index

      strValue := chr(nASCII)
      WriteIni("PDFTools.ini", "OutFile1", strKey, strValue)
   }

   strDataFile := strDocPath . "\" . strDocFile

   ;
   ; Generate and run the batch file, 
   ; then display the output document and open the containing folder.
   ;
   strCMDFile := PDF_MakeBatch("PDFTools.cmd")
   RunWait %strCMDFile% 
   RunWait %strDataFile%  
   RunWait %strDocPath%
PDFCOMBINEFILES_EXIT:
   LogFunctionEnd()
} 


;
; Splits user specified PDF file into multiple files.
;
PDF_SplitFile()
{
   LogFunctionStart("PDF_SplitFile")

   ; Get the working directory from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 

   ; Remove any previously specified input and output files from the INI
   PDF_ResetIni("PDFTools.ini")

   ; Show the CFD allowing the user to choose a single file.
   FileSelectFile strPDFFile, , %strWorkingDir%, Please choose the PDF file to split, *.pdf
   strWorkingDir := GetPath(strPDFFile)

   ;
   ; Write the input file to an INI file which can be used with PDF_MakeBatch.
   ;
   strKey  := "InFile1" 
   strValue := strPDFFile
   Log("Writing Ini: " . strKey . "," . strValue)
   strIniFile := WriteIni("PDFTools.ini", "Common", strKey, strValue)

   ; Open the PDF file and snap it to the left of the screen so the user
   ; can determine where to split it.
   Run %strPDFFile% 
   Sleep 500
   Send #{Left}
  
   ; Prompt the user for the number of files into which the PDF will be split
   ; This info is used to determine how many sections to write to the configuration INI
   InputBox nNumOutput, Output Files, Into how many files will this PDF be split?

   ;
   ; Create a section in the configuration INI for each file we intend to create
   ;
   strOutputBaseName := GetBaseName(strPDFFile)
   nIndex := 1
   loop, %nNumOutput%
   {
      strDocFile := strWorkingDir . strOutputBaseName . "_" . nIndex . ".pdf"
      strSection := "OutFile" . nIndex
      WriteIni("PDFTools.ini", strSection, "Filename", strDocFile)

      nSecIndex := 1
      
      ; Hard code the number of sections per output file.
      loop, 1
      {
         strKey := "Sec" . nSecIndex  
         strValue := "A1-5"
         WriteIni("PDFTools.ini", strSection, strKey, strValue)
         nSecIndex++
      }

      nIndex++
   }

   ; Open the configuration INI file and snap it to the right side of the screen
   ; so the user can manually edit it.
   Run %strIniFile%
   Sleep 500
   Send #{Right} 

   ; Wait for the user to get done editing the INI file.
   bINIClosed := 0
   Loop
   {
      Loop, 600
      {
         Log("Waiting for PDFTools.INI to be closed. Iteration " . a_index)
         if not WinExist("PDFTools.ini")
         {
            bINIClosed := 1
            break
         }

         sleep 1000
      }

      if (bINIClosed = 1)
      {
         break
      }

      MsgBox 3, Waiting..., PDFTools.INI is still open.  Run batch file now?
      IfMsgBox Yes
      {
         Log("User is done with edits.  Continue on.")
         break
      }
      IfMsgBox No
      {
         Log("User chose to continue editing the INI file")
      }
      IfMsgBox Cancel
      {
         Log("User cancelled the split.")
         goto PDFSPLIT_EXIT
      }
   }


   ;
   ; Generate and run the batch file, 
   ; then open the containing folder.
   ;
   strCMDFile := PDF_MakeBatch("PDFTools.cmd")
   RunWait %strCMDFile% 
   RunWait %strWorkingDir%

   ; Move the original file to the archive directory
   strEntryName := GetEntryName(strPDFFile)
   loop, 5
   {
      WinClose %strEntryName%
      Sleep 1000
      if not WinExist(strEntryName)
      {
         break
      }
   }
   
   strArchiveDir := GetPath(strPDFFile) . "\Archive"
   FileCreateDir %strArchiveDir%
   FileMove %strPDFFile%, %strArchiveDir% 
PDFSPLIT_EXIT:
   LogFunctionEnd()
} 


;
; Splits the user specified PDF file into even and odd pages.
;
PDF_Extract_Even_Odd()
{
   LogFunctionStart("PDF_SplitFile")

   ; Get the working directory from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 

   ; Remove any previously specified input and output files from the INI
   PDF_ResetIni("PDFTools.ini")

   ; Show the CFD allowing the user to choose a single file.
   FileSelectFile strPDFFile, , %strWorkingDir%, Please choose the PDF file to split, *.pdf
   strWorkingDir := GetPath(strPDFFile)
   strBaseName := GetBaseName(strPDFFile)

   ;
   ; Write the input file to an INI file which can be used with PDF_MakeBatch.
   ;
   strKey  := "InFile1" 
   strValue := strPDFFile
   Log("Writing Ini: " . strKey . "," . strValue)
   strIniFile := WriteIni("PDFTools.ini", "Common", strKey, strValue)

   ;
   ; Create a section in the configuration INI for each file we intend to create
   ;
   strDocFile := strWorkingDir . strBaseName . "_E.pdf"
   WriteIni("PDFTools.ini", "OutFile1", "Filename", strDocFile)
   WriteIni("PDFTools.ini", "OutFile1", "Sec1", "A1-endeven")

   strDocFile := strWorkingDir . strBaseName . "_O.pdf"
   WriteIni("PDFTools.ini", "OutFile2", "Filename", strDocFile)
   WriteIni("PDFTools.ini", "OutFile2", "Sec1", "A1-endodd")

   ;
   ; Generate and run the batch file, 
   ; then open the containing folder.
   ;
   strCMDFile := PDF_MakeBatch("PDFTools.cmd")
   RunWait %strCMDFile% 
   RunWait %strWorkingDir%
PDFEXTRACTEVEN_EXIT:
   LogFunctionEnd()
} 


;
; Combines two files, interleaving the pages in incremental order
; from the first file, and decremental order from the second.
;
; This is typically used when the input files represent both sides
; of documents which came from a single sided scanner.
;
PDF_InterLeave_Scanner()
{
   LogFunctionStart("PDF_Interleave_Scanner")

   ; Get the working directory from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 

   ; Remove any previously specified input and output files from the INI
   PDF_ResetIni("PDFTools.ini")

   ; Show the CFD allowing the user to choose multiple files to combine.
   FileSelectFile strFileList, M, %strWorkingDir%, Please choose the PDF files to merge, *.pdf

   ;
   ; Write the list of input files to an INI file which can be used with PDF_MakeBatch.
   ; Note that selected files are always returned in alphabetical order.
   ;
   nLoop := 1
   Loop, parse, strFileList, `n
   {
      nIndex := nLoop - 1 
      if a_index > 1
      { 
         strKey  := "InFile" . nIndex 
         strValue := a_loopfield
         Log("Writing Ini: " . strKey . "," . strValue)
         WriteIni("PDFTools.ini", "Common", strKey, strValue)
      }
      else 
      {
         ; The first entry in the file list is the directory
         ; containing the selected files.
         strDocPath = %a_loopfield%
         WriteIni("PDFTools.ini", "Common", "WorkingDir", strDocPath)
      }

      nLoop++ 
   }
   nNumInputFiles := nIndex
   strLastFile := strValue

   ;
   ; Create section in the INI file for the output file.
   ; Pages from the first file are added in incremental order (1,2,3,4,5)
   ; whereas pages from the second file are added in decremental order (5,4,3,2,1)
   ;

   ; Assume that both documents have the same number of pages
   nNumPages := PDF_GetPageCount(strLastFile)

   strDocFile := "Interleaved.pdf"
   WriteIni("PDFTools.ini", "OutFile1", "Filename", strDocFile)
   strKey := "Sec1"  
   strCommand = 
   loop, %nNumPages%
   {
      strCommand := strCommand . " A" . A_Index . " B" . nNumPages-A_Index+1
   }

   WriteIni("PDFTools.ini", "OutFile1", strKey, strCommand)
   strDataFile := strDocPath . "\" . strDocFile

   ;
   ; Generate and run the batch file, 
   ; then display the output document and open the containing folder.
   ;
   strCMDFile := PDF_MakeBatch("PDFTools.cmd")
   RunWait %strCMDFile% 
   RunWait %strDataFile%  
   RunWait %strDocPath%
PDFINTERLEAVESCANNER_EXIT:
   LogFunctionEnd()
} 


;
; Combines two files, interleaving the pages in incremental order (1,1,2,2,3,3, ...)
;
PDF_InterLeave()
{
   LogFunctionStart("PDF_Interleave")

   ; Get the working directory from the INI file created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir") 

   ; Remove any previously specified input and output files from the INI
   PDF_ResetIni("PDFTools.ini")

   ; Show the CFD allowing the user to choose multiple files to combine.
   FileSelectFile strFileList, M, %strWorkingDir%, Please choose the PDF files to merge, *.pdf

   ;
   ; Write the list of input files to an INI file which can be used with PDF_MakeBatch.
   ; Note that selected files are always returned in alphabetical order.
   ;
   nLoop := 1
   Loop, parse, strFileList, `n
   {
      nIndex := nLoop - 1 
      if a_index > 1
      { 
         strKey  := "InFile" . nIndex 
         strValue := a_loopfield
         Log("Writing Ini: " . strKey . "," . strValue)
         WriteIni("PDFTools.ini", "Common", strKey, strValue)
      }
      else 
      {
         ; The first entry in the file list is the directory
         ; containing the selected files.
         strDocPath = %a_loopfield%
         WriteIni("PDFTools.ini", "Common", "WorkingDir", strDocPath)
      }

      nLoop++ 
   }
   nNumInputFiles := nIndex
   strLastFile := strValue

   ;
   ; Create section in the INI file for the output file.
   ;

   ; Assume that both documents have the same number of pages
   nNumPages := PDF_GetPageCount(strLastFile)
   Log( "Test" . nNumPages . "+++")
 

   strDocFile := "Interleaved.pdf"
   WriteIni("PDFTools.ini", "OutFile1", "Filename", strDocFile)
   strKey := "Sec1"  
   strCommand = 
   loop, %nNumPages%
   {
      strCommand := strCommand . " A" . A_Index . " B" . A_Index
   }

   WriteIni("PDFTools.ini", "OutFile1", strKey, strCommand)
   strDataFile := strDocPath . "\" . strDocFile

   ;
   ; Generate and run the batch file, 
   ; then display the output document and open the containing folder.
   ;
   strCMDFile := PDF_MakeBatch("PDFTools.cmd")
   RunWait %strCMDFile% 
   RunWait %strDataFile%  
   RunWait %strDocPath%
PDFINTERLEAVE_EXIT:
   LogFunctionEnd()
} 


;
; Generates a .CMD file containing the calls to the PDFTK utility.
; One line is generated for each output file.
; Input files and page ranges are stored in PDFTools.ini.
;
PDF_MakeBatch(strBatchFile)
{
   LogFunctionStart("PDF_MakeBatch")

   ; Get default directorys from the INI created in PDF_Startup
   strWorkingDir := ReadIni("PDFTools.ini", "Common", "WorkingDir")
   strBinDir := ReadIni("PDFTools.ini", "Common", "BinDir")

   ;
   ; If the specified batch file doesn't have an absolute path
   ; append the working directory from the INI file.
   strBatchFile := AppendWorkingDir(strBatchFile, strWorkingDir)

   ; Loop through the "Common" section of the INI file
   ; storing the names of all specified input files.
   nIndex := 1
   loop, 200
   {
      strKey = InFile%nIndex% 
      strInFile%nIndex% := ReadIni("PDFTools.ini", "Common", strKey)
      Log( strInFile%nIndex% ) 
      if (strInFile%nIndex% = "ERROR")
      {
         break 
      } 

      ; If the specified file doesn't have an absolute path
      ; append the working directory from the INI file.
      strPath := GetPath(strInFile%nIndex%)
      if (strPath = "")
      {
         strInFile%nIndex% := strWorkingDir . "\" . strInFile%nIndex%
      }

      nIndex++
   }

   nIndex--
   nNumInputFiles := nIndex

   ; Info on output files is stored in a section per output file
   ; Loop through the INI and store name and page ranges of each output file
   nIndex := 1
   loop, 200
   {
      strSection = OutFile%nIndex% 
      strOutFile%nIndex% := ReadIni("PDFTools.ini", strSection, "Filename")
      Log( strOutFile%nIndex% ) 
      if (strOutFile%nIndex% = "ERROR")
      {
         break 
      } 

      ; If the specified file doesn't have an absolute path
      ; append the working directory from the INI file.
      strPath := GetPath(strOutFile%nIndex%)
      if (strPath = "")
      {
         strOutFile%nIndex% := strWorkingDir . "\" . strOutFile%nIndex%
      }

      nIndex++
   }

   nIndex--
   nNumOutputFiles := nIndex

   ;
   ; Create the batch file which calls the PDF toolkit executable
   ;
   FileDelete %strBatchFile%
   loop, %nNumOutputFiles%
   {
      strSection = OutFile%a_Index% 
      strOutFile := ReadIni("PDFTools.ini", strSection, "Filename")
      nIndex := 1 
      loop, 100
      {      
         strKey = Sec%nIndex% 
         strSec%nIndex% := ReadIni("PDFTools.ini", strSection, strKey)
         Log( "Sec: " . strSec%nIndex% ) 
         if (strSec%nIndex% = "ERROR")
         {
            break 
         } 
         nIndex++
      }

      nIndex--
      nNumSections := nIndex

      Log("For output file " . strSection . " there are " . nNumSections . " sections.")
      
      strCmd := strBinDir . "\PDFTK"

      ;
      ; Syntax for PDFTK assigns each input file a "handle" which is a single
      ; capital letter for each input file.
      ; Since the list of input files is stored with a numeric index, the chr
      ; function is used to convert the index to an alphabetic handle.
      nAsciiCode := 65
      nIndex := 1
      loop, %nNumInputFiles%
      {
         strCmd := strCmd . " " . chr(nAsciiCode) . "=" . chr(34) . strInFile%nIndex% . chr(34)
         nIndex++
         nAsciiCode++
      }

      ; Use the PDFTK CAT command to combine all of the specified files
      strCmd := strCmd . " cat"
      nSecIndex := 1
      loop, %nNumSections%
      {
         strHandle := SubStr(strSec%nSecIndex%, 1, 1)
         StringReplace strCMDText, strSec%nSecIndex%, `,,%a_space%%strHandle%, All 
         strCmd := strCmd . " " . strCMDText
         nSecIndex++
      }

      ; Append the output filename, and don't prompt to overwrite output files.
      strCmd := strCmd . " output " . chr(34) . strOutFile%a_index% . chr(34) . " dont_ask`n"
      Log( "Command line: " . strCmd )

      ; Add the command line to the batch file.
      FileAppend %strCmd%, %strBatchFile%
   }

goto MAKEBATCH_EXIT
MAKEBATCH_EXIT:
   LogFunctionEnd()
   return %strBatchFile% 
}


;
; Clears all input and output files from the specified INI file.
; This function is used with PDF_MakeBatch.
;
PDF_ResetIni(strIniFile)
{
   LogFunctionStart("PDF_ResetIni")

   nMaxFiles := 200

   ;
   ; Check if the specified file has a fully qualified path.
   ; If not, append the default INI directory.
   ;
   StringSplit strPath, strIniFile, \
   if (strPath0 = 1)
   {
      strFolderShareDir := GetFolderShareDir()
      strIniFile := strFolderShareDir . "projects\_Ini\" . strIniFile
   }

   ;
   ; Loop through the ini file and remove any InFile keys from the Common section,
   ; and any OutFile sections.
   ;
   loop, %nMaxFiles%
   {
      strInFileKey := "InFile" . a_index 
      IniDelete %strIniFile%, Common, %strInFileKey% 

      strOutFileSec := "OutFile" . a_index 
      IniDelete %strIniFile%, %strOutFileSec% 
   }

PDF_RESETINI_EXIT:
   LogFunctionEnd()
}


AppendWorkingDir(strFile, strWorkingDir)
{
   LogFunctionStart("AppendWorkingDir")

   strPath := GetPath(strFile)
   if (strPath = "")
   {
      strFile := strWorkingDir . "\" . strFile
   }

APPENDWORKINGDIR_EXIT:
   LogFunctionEnd()
   return %strFile%
}   




;
; PaperPort Scanning functions
;
::_tp::
   PaperPort_Dismiss_Continue_Dialog() 
return

PaperPort_Dismiss_Continue_Dialog()
{
   LogFunctionStart("DismissContinueDialog")

   loop, 100
   {
      IfWinExist PaperPort ahk_class MAXMATE$MAIN
      {
         Log("PaperPort is running.  Continuing loop.")

         IfWinExist PaperPort - Scan
         {
            Log( "PaperPort scan dialog is present.  Trying to dismiss it." ) 
            WinActivate PaperPort - Scan
            ControlGetText strButtonText, Button5, A
            Log( "Button Text: " . strButtonText )
            if (strButtonText = "Continue")
            {
               Log( "Continue button is present" )
               ControlClick Button5, A
            } 
         }
         else
         {
            Log("PaperPort - Scan dialog is not present.")
         }
      }
      else
      {
         Log( "PaperPort is not running.  Exiting loop." )
         break
      }

      sleep 1000
   }

DISMISSCONTINUEDIALOG_EXIT:
   LogFunctionEnd()
   return
}