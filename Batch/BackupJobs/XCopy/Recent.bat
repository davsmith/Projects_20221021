@ECHO OFF
REM
REM Uses XCopy to backup files from strategic directories to a removable hard disk.
REM Only files with the archive bit are copied, and the archive bit is reset.
REM
REM Usage:  RECENT <yyyymmdd> <srcdrv:> <destdrv:>
REM
REM 
REM This batch file is pretty brute force, making the following assumptions:
REM    - Folder containing the file exclusion list is the same as the CMD file \exclude\
REM    - Folders to backup are AngDocs, DaveDocs, SharedDocs, and FolderShare
REM    - Music, Videos, and Pictures are excluded from personal directories
REM    - Music and Videos are excluded from Shared directories
REM
REM Dave Smith -- 12/19/2009
REM            -- Updated 6/6/2010 to take 3 args instead of 1
REM            -- 10/4/2010 removed /L flag so files are actually copied.  Updated for LiveDog.
REM


if "%1" == "" goto USAGE
set outdir=%1

set destpath=%3\backup
set destdir=%destpath%\%outdir%R
set srcdrv=%2
set cmdpath=%srcdrv%\LiveDog\Projects\Batch\BackupJobs\XCopy
set exclpath=%cmdpath%\exclude\recent


mkdir %destdir%

rem Backup the Documents in various key directories, excluding some large directories
xcopy "%srcdrv%\AngDocs" "%destdir%\AngDocs" /M /S /I /Y /exclude:%exclpath%\exclude_angela.txt
xcopy "%srcdrv%\DaveDocs" "%destdir%\DaveDocs" /M /S /I /Y /exclude:%exclpath%\exclude_dave.txt
xcopy "%srcdrv%\SharedDocs" "%destdir%\SharedDocs" /M /S /I /Y /exclude:%exclpath%\exclude_shared.txt
xcopy "%srcdrv%\LiveDog" "%destdir%\LiveDog" /M /S /I /Y /exclude:%exclpath%\exclude_foldershare.txt

goto CLEANUP

:USAGE:
ECHO Usage: RECENT ^<yymmdd^> ^<srcdrv:^> ^<destdrv:^>


rem Cleanup
:CLEANUP


