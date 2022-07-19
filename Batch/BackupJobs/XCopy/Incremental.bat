rem @echo off
REM
REM Uses XCopy to backup files from strategic directories to a removable hard disk.
REM Usage:  INCREMENTAL <yyyymmdd> <srcdrv:> <destdrv:>
REM
REM This batch file is pretty brute force, making the following assumptions:
REM    - Folder containing the file exclusion list is the same as the CMD file \exclude\
REM    - Folders to backup are AngDocs, DaveDocs, SharedDocs, and FolderShare
REM    - Music, Videos, and Pictures are excluded from personal directories
REM    - Music and Videos are excluded from Shared directories
REM
REM Dave Smith 
REM            
REM            -- 1/2/2011
REM            -- Modified to use new file structure (moved LiveDog to DaveDocs, and SharedDocs to AngDocs, Photos, etc)
REM
REM            -- 12/19/2009
REM            -- Updated 6/6/2010 to take 3 args instead of 1
REM            -- 10/2/2010 added lines to set archive bit
REM
REM Example:
REM          - Map network drive (S:) to \\nazgul\content
REM          - Open Command Window
REM          - INCREMENTAL 20110102 S: I: > 20110102I.TXT
REM

if "%1" == "" goto USAGE
set outdir=%1

set destpath=%3\backup
set destdir=%destpath%\%outdir%I
set srcdrv=%2
set cmdpath=%srcdrv%\DaveDocs\Projects\Batch\BackupJobs\XCopy
set exclpath=%cmdpath%\exclude\full

rem time /t
rem attrib /S +A "%srcdrv%\AngDocs\*.*"
rem attrib /S +A "%srcdrv%\DaveDocs\*.*"
rem attrib /S +A "%srcdrv%\Photos\2011\*.*"
rem attrib /S +A "%srcdrv%\Video\2011\*.*"



mkdir %destdir%

rem Backup the Documents in various key directories, excluding some large directories
time /t
xcopy "%srcdrv%\AngDocs" "%destdir%\AngDocs" /M /S /I /Y /exclude:%exclpath%\exclude_angela.txt
xcopy "%srcdrv%\DaveDocs" "%destdir%\DaveDocs" /M /S /I /Y /exclude:%exclpath%\exclude_dave.txt
xcopy "%srcdrv%\Photos" "%destdir%\Photos" /M /S /I /Y /exclude:%exclpath%\exclude_photos.txt
xcopy "%srcdrv%\Music" "%destdir%\Music" /M /S /I /Y /exclude:%exclpath%\exclude_music.txt
xcopy "%srcdrv%\Video" "%destdir%\Video" /M /S /I /Y /exclude:%exclpath%\exclude_video.txt

goto CLEANUP

:USAGE:
ECHO Usage: INCREMENTAL ^<yymmdd^> ^<srcdrv:^> ^<destdrv:^>


rem Cleanup
:CLEANUP
time /t

