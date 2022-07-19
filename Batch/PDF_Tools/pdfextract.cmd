rem
rem PDFEXTRACT.CMD
rem
rem Extracts pages from a pdf file (misc.pdf)
rem to a specified output file.
rem 
rem Usage: PDFEXTRACT <start page> <end page> <output file> 
rem 
pdftk misc.pdf cat %1-%2 output %3 dont_ask