rem
rem	This batch file is the same as FULL.BAT, except that it uses the -i flag, rather than the -a+ flag.
rem	

if "%1" == "" (set label=%date%) else set label=%1
if "%1" == "" (set outdir=data) else set outdir=%1
echo %label%

set zipexe="c:\program files\winzip\wzzip.exe"
set zipparms=-ee -i -P -r -o -z
set files=@docs.inc -x@docs.xcl docs.zip
set archivepath=h:\backup
set archivedir=%archivepath%\%outdir%
set splitdir=%archivedir%\split
set scriptpath=%archivepath%\zipscript


mkdir %archivedir%
mkdir %splitdir%


rem Backup the Documents in "My Documents" excluding the photos, music, and video
echo Full docs archive (%label%) > comment.txt
%zipexe% %zipparms% @%scriptpath%\docs.inc -x@%scriptpath%\docs.xcl "%archivedir%\docs.zip" < comment.txt
%zipexe% "%archivedir%\docs.zip" -ys4400000 "%splitdir%\docs.zip"


rem Backup the My Pictures directory
echo Full pictures archive (%label%) > comment.txt
%zipexe% %zipparms% @%scriptpath%\pictures.inc -x@%scriptpath%\pictures.xcl "%archivedir%\pictures.zip" < comment.txt
%zipexe% "%archivedir%\pictures.zip" -ys4400000 "%splitdir%\pictures.zip"

rem Backup the My Music directory
echo Full Music archive (%label%) > comment.txt
%zipexe% %zipparms% @%scriptpath%\music.inc -x@%scriptpath%\music.xcl "%archivedir%\music.zip" < comment.txt
%zipexe% "%archivedir%\music.zip" -ys4400000 "%splitdir%\music.zip"

rem Backup the My Videos directory
echo Full Videos archive (%label%) > comment.txt
%zipexe% %zipparms% @%scriptpath%\videos.inc -x@%scriptpath%\videos.xcl "%archivedir%\videos.zip" < comment.txt
%zipexe% "%archivedir%\videos.zip" -ys4400000 "%splitdir%\videos.zip"


rem Cleanup
del comment.txt
