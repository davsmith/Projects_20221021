@echo off
REM
REM Uses XCopy to backup files from strategic directories to a removable hard disk.
REM Usage:  YTD <yyyymmdd> <srcdrv:> <destdrv:>
REM
REM This batch file is pretty brute force, making the following assumptions:
REM    - Folder containing the file exclusion list is the same as the CMD file \exclude\
REM    - Folders to backup are AngDocs, DaveDocs, SharedDocs, and FolderShare
REM    - Music, Videos, and Pictures are excluded from personal directories
REM    - Music and Videos are excluded from Shared directories
REM
REM Dave Smith 
REM            
REM
REM            -- 11/7/2011
REM               Modified to use date stamp of last modification.  This will need to be updated annually.
REM               Also added DOWNLOADS directory to exclude list for Dave (LiveDog).
REM               Excludes include:
REM                  Angela: \Temp
REM                  Dave:   \Temp, \DVDInfoCache, \Home\Temp, \Work\Temp, \Downloads
REM                  Photos: \Temp\
REM                  Music:  \Temp\, \Subscription\
REM                  Video:  \Temp
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
REM          - YTD 20110102 S: E: I: > 20110102Y.TXT
REM

if "%1" == "" goto USAGE
set outdir=%1

REM  **********************************
REM  This needs to be updated annually
REM  **********************************
set startdate=1-1-2011



set destpath=%4\Backup
set destdir=%destpath%\%outdir%Y
set fsdrv=%3
set netdrv=%2
set cmdpath=%fsdrv%\LiveDog\Projects\Batch\BackupJobs\XCopy
set exclpath=%cmdpath%\exclude\YTD


mkdir %destdir%

rem Backup the Documents in various key directories, excluding some large directories
time /t
xcopy "%netdrv%\AngDocs" "%destdir%\AngDocs" /D:%startdate% /S /I /Y /exclude:%exclpath%\exclude_angela.txt
xcopy "%fsdrv%\LiveDog" "%destdir%\LiveDog"  /D:%startdate% /S /I /Y /exclude:%exclpath%\exclude_dave.txt
xcopy "%netdrv%\Music" "%destdir%\Music"     /D:%startdate% /S /I /Y /exclude:%exclpath%\exclude_music.txt
xcopy "%netdrv%\Photos" "%destdir%\Photos"   /D:%startdate% /S /I /Y /exclude:%exclpath%\exclude_photos.txt
xcopy "%netdrv%\Video" "%destdir%\Video"     /D:%startdate% /S /I /Y /exclude:%exclpath%\exclude_video.txt
time /t

goto CLEANUP

:USAGE:
ECHO Usage: YTD ^<yymmdd^> ^<network drive:^> ^<folder share drive:^> ^<destdrv:^>
ECHO    Copies AngDocs, Photos, Music, and Video from Network drive.
ECHO    Copies LiveDog from folder share drive.


rem Cleanup
:CLEANUP

