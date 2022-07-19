rem
rem PDFAPPEND.CMD
rem
rem Adds pages from a pdf file (misc.pdf)
rem to a specified output file.
rem 
rem Usage: PDFAPPEND <start page> <end page> <output file> 
rem 
pdftk A=%3 B=misc.pdf cat A1-end B%1-%2 output tmp.pdf dont_ask
copy tmp.pdf %3
del tmp.pdf
