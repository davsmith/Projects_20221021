#
# WULog.ps1
#
# Author: leolie
# Microsoft Corp. (c) 2014
#
# $Header: //depot/fbl_marketplace_dev01/enduser/WindowsUpdate/local/test/Client/scripts/wulog.ps1#19 2015/06/10 16:41:32 NTDEV\\leolie $
# $Change: 647748 $
#
# Dependencies: 
# \\mufiles\ts\PsWULib.ps1
#

<#
    .SYNOPSIS
        Script to decode an existing WindowsUpdate ETL file into readable text file, or get verbose traces.

        To decode:
            wulog.ps1 -DecodeETL -ETLPath <ETL file or directory containing ETL files>

            For e.g.:
            wulog.ps1 -DecodeETL -ETLPath C:\Windows\Logs\WindowsUpdate
            wulog.ps1 -DecodeETL -ETLPath C:\my\windowsupdate.etl
            wulog.ps1 -DecodeETL -ETLPath "\\mufiles\upload\logs\leolie\WULogs-leolie-LEOLIE-MD9868-20141024-153900.zip"

        To start verbose traces:
            1. Start trace using -Start.
            2. Repro your issue.
            3. Stop trace using -Stop. This will produce one ETL file.
            4. Decode the ETL file. See examples for instructions.

        If you're on a platform with no Powershell, use -GetCommands or -GetCommandsPhone on your dev box. It will copy
        into clipboard the command that you can paste onto your target platform (and also spit out a script).

    .PARAMETER Start
        Start Windows Update tracing. CAUTION: This will stop WU service; use -DontStopService to override.

    .PARAMETER Stop
        Stop Windows Update tracing. CAUTION: This will stop WU service; use -DontStopService to override.

    .PARAMETER SymbolPath
        Decode WU symbols in this path. The symbols must correspond to the branch and build where the ETL is generated from.
        If not specified, script will deduce the symbol path from the ETL file.

    .PARAMETER RefreshSymbols
        Script will cache decoded symbols by default. Specify this param to reparse the symbols.

    .PARAMETER PrivateSymbols
        Specify this param to perform decoding using symbols from previously specified -SymbolPath.

    .PARAMETER UseSymbolServer 
        Specify this param to perform decoding using symbols from the Microsoft symbol server.

    .PARAMETER  SymbolServerCache
        Specify this param to provide path to cache symbol server retrieved symbols (pdb files) 

    .PARAMETER DecodeETL
        Decode an Windows Update ETL file.

    .PARAMETER ETLPath
        For -Start, this is the filepath to write ETL to.
        For -DecodeETL, this can be filepath to single ETL file, a directory containing one or more ETL files, or a zip file produced by \\mufiles\ts\copylogswin8.cmd.
        Defaults to current directory .\windowsupdate.etl

    .PARAMETER LogPath
        Filepath to write text log file to. Defaults to current directory .\windowsupdate-etl.log

    .PARAMETER VerboseLog
        Enable verbose tracing. Default is normal (TRACE_LEVEL_INFORMATION).

    .PARAMETER NoChatty
        Filter out certain noisy components like EEHandler, DataStore, IdleTimer, etc.

    .PARAMETER IncludeFlags
        Select flags of your choice. Separate by comma. Use TAB key to auto-complete.

    .PARAMETER ExcludeFlags
        Filter out flags of your choice. Separate by comma. Use TAB key to auto-complete.

    .PARAMETER ListFlags
        Print out all available flags.

    .PARAMETER ForceUpdate
        Force update tracing binaries.

    .PARAMETER Product
        [Advanced] Select the product to start/stop/decode trace. Defaults to 'WindowsUpdate', but can be used to work with SIH.

    .PARAMETER LogToDebugger
        [Advanced] Enable/disable logging to debugger if attached. This param takes a boolean: -LogToDebugger 1/0

    .PARAMETER TMFPath
        [Advanced] Path to store decoded symbols, TMF/trace message format files to.

    .PARAMETER TraceFormat
        [Advanced] You better know what you're doing.

    .PARAMETER BufferSizeInKb
        [Advanced] Tracing buffer size. Defaults to 128Kb.

    .PARAMETER UseTraceLog
        [Advanced] By default script will use built-in logman.exe on Desktop. Use this switch to use tracelog.exe

    .PARAMETER SourceLine
        [Advanced] Include source filename and line number when decoding traces.

    .PARAMETER DontStopService
        [Advanced] Script stops wuauserv when starting/stopping trace. Specify this param to not stop wuauserv.

    .PARAMETER Phone
        [Advanced] When combined with -Start, -Stop or -DecodeETL, operations will be performed on Phone via TShell (it assumes open-device has been called).

    .PARAMETER InstallRightClickMenu
        [Advanced] Add a shortcut to Explorer SendTo menu to decode cab/file/folder from Explorer.

    .EXAMPLE
        To decode an ETL using symbol servers (most accurate for shipped builds)

            wulog.ps1 -DecodeETL -UseSymbolServer -ETLPath C:\Windows\Logs\WindowsUpdate
            wulog.ps1 -DecodeETL -UseSymbolServer -SymbolServerCache c:\symbols2 -ETLPath C:\Windows\Logs\WindowsUpdate   

    .EXAMPLE
        To decode an ETL using symbols from \\winbuilds\release:

            wulog.ps1 -DecodeETL -ETLPath C:\Windows\Logs\WindowsUpdate
            wulog.ps1 -DecodeETL -ETLPath C:\my\windowsupdate.etl
            wulog.ps1 -DecodeETL -ETLPath "\\mufiles\upload\logs\leolie\WULogs-leolie-LEOLIE-MD9868-20141024-153900.zip"

    .EXAMPLE
        To decode default WU ETLs from Phone via TShell:

            wulog.ps1 -DecodeETL -Phone -UseSymbolServer

    .EXAMPLE
        To enable and collect verbose WU ETLs from Phone via TShell:

            wulog.ps1 -Start -VerboseLog -Phone
            (repro your issue)
            wulog.ps1 -Stop -DecodeETL -Phone [append your preference: -UseSymbolServer or -PrivateSymbols -SymbolPath ...]

    .EXAMPLE
        To decode an ETL using custom symbol path, pass in -PrivateSymbols together with -DecodeETL:

            WULog.ps1 -SymbolPath \\mufiles\scratch\johndoe\privates\x86chk\symbols\dll
            WULog.ps1 -DecodeETL -PrivateSymbols -ETLPath C:\my\windowsupdate.etl

        Notes:
        1. This method can be used when you have symbols that are no longer on build share, or private symbols.
        2. You can decode the symbols once, and use it to decode repeatedly without needing to specify -SymbolPath again.

    .EXAMPLE
        To collect verbose tracing without noisy components:

            WULog.ps1 -Start -VerboseLog -NoChatty
            WULog.ps1 -Stop

    .EXAMPLE
        To collect verbose tracing with component filtering, and decode:

            WULog.ps1 -Symbol -SymbolPath C:\wuprivates\symbols\dll
            WULog.ps1 -Start -VerboseLog -ExcludeFlags DataStore, EEHandler
            WULog.ps1 -Stop -DecodeETL

    .EXAMPLE
        To collect normal tracing with custom components:

            WULog.ps1 -Start -IncludeFlags Agent, ComApi
            WULog.ps1 -Stop

    .EXAMPLE
        [Advanced] To decode multiple ETL files using multiple custom symbol paths:

        WULog.ps1 -SymbolPath C:\private1 -TMFPath C:\TMF\private1
        WULog.ps1 -SymbolPath C:\private2 -TMFPath C:\TMF\private2
        WULog.ps1 -DecodeETL -PrivateSymbols -ETLPath C:\private1.etl -LogPath C:\private1.log -TMFPath C:\TMF\private1
        WULog.ps1 -DecodeETL -PrivateSymbols -ETLPath C:\private2.etl -LogPath C:\private2.log -TMFPath C:\TMF\private2
#>

[CmdletBinding()]
Param(
    # Getting trace
    [switch] $Start,
    [switch] $Stop,

    # Reading trace
    [string] $SymbolPath = "",
    [switch] $RefreshSymbols,
    [switch] $PrivateSymbols,
    [switch] $UseSymbolServer,
    [switch] $DecodeETL,

    # Path customizations
    [string] $ETLPath = ".\windowsupdate.etl",
    [string] $LogPath = ".\windowsupdate-etl.log",
    [string] $SymbolServerCache = "$env:SystemDrive\symbols",

    # Verboseness
    [switch] $VerboseLog,
    [switch] $NoChatty,

    [ValidateSet('Agent', 'DownloadManager', 'SLS', 'ProtocolTalker', 'Reporter', 'Misc', `
                 'Driver', 'Api', 'IdleTimer', 'Timer', 'Setup', 'Shared', 'Handler', `
                 'DataStore', 'WebServices', 'OfflineSync', 'ComApi', 'Inventory', 'SelfUpdate', `
                 'EndPointProvider', 'EEHandler', 'AppAU', 'SIH' )]
    [string[]]$IncludeFlags = $null,

    [ValidateSet('Agent', 'DownloadManager', 'SLS', 'ProtocolTalker', 'Reporter', 'Misc', `
                 'Driver', 'Api', 'IdleTimer', 'Timer', 'Setup', 'Shared', 'Handler', `
                 'DataStore', 'WebServices', 'OfflineSync', 'ComApi', 'Inventory', 'SelfUpdate', `
                 'EndPointProvider', 'EEHandler', 'AppAU', 'SIH' )]
    [string[]]$ExcludeFlags = $null,

    [switch] $ListFlags,

    # Other    
    [switch] $ForceUpdate,

    # Advanced usage
    [ValidateSet('WindowsUpdate', 'SIH')] $Product = 'WindowsUpdate',
    $LogToDebugger = $null,
    [string] $TMFPath = "$env:SystemDrive\TMF\Private",
    [string] $TraceFormat = "%4!s! %8!04X! %3!04X! %!FLAGS!    ", # SystemTime ProcessId ThreadId Flags
    [int] $BufferSizeInKb = 128,
    [switch] $UseTraceLog,
    [switch] $SourceLine,
    [switch] $DontStopService,
    [switch] $Phone,
    [switch] $InstallRightClickMenu,

    # Deprecated. Kept for backward compat.
    [switch] $Symbol,
    [switch] $GetCommands,
    [switch] $GetCommandsPhone
)

# --------------------------------------------------
# CONSTANTS
# --------------------------------------------------

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition

$USE_LOGMAN = (Test-Path $env:SystemRoot\System32\logman.exe) -and !$UseTraceLog

$TRACELOG_BINPATH = "$env:SystemDrive\wutrace"

$PHONE_CUSTOM_ETL_PATH = "C:\data\test\windowsupdate.etl"

$TRACE_REGKEY = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Trace"

$WU_WPP_ID = "0b7a6f19-47c4-454e-8c5c-e868d637e4d8"
$SIH_WPP_ID = "9906081d-e45a-4f41-a53f-2ac2e0225de1"

# The default PDBs to generate trace format messages from when deducing symbols from ETL file or
# using a private symbol path. This list is not used when decoding using -UseSymbolServer option
$WU_PDBS = "wuaueng.pdb", "wuapi.pdb", "storewuauth.pdb", "wuuhext.pdb", "wuuhmobile.pdb", "wuauclt.pdb", "wuautoappupdate.pdb"
$SIH_PDBS = "sihclient.pdb", "siheng.pdb"

$FLAGS_VALUES = @{
   'Agent' = 1;
   'DownloadManager' = 2;
   'SLS' = 4;
   'ProtocolTalker' = 8;
   'Reporter' = 16;
   'Misc' = 32;
   'Driver' = 64;
   'Api' = 128;
   'IdleTimer' = 256;
   'Timer' = 512;
   'Setup' = 1024;
   'Shared' = 2048;
   'Handler' = 4096;
   'DataStore' = 8192;
   'WebServices' = 16384;
   'OfflineSync' = 32768;
   'ComApi' = 65536;
   'Inventory' = 131072;
   'SelfUpdate' = 262144;
   'EndPointProvider' = 524288;
   'EEHandler' = 1048576;
   'AppAU' = 2097152;
   'SIH' = 4194304;
 }

$FLAGS_CHATTY = 'EEHandler', 'DataStore', 'Reporter', 'IdleTimer', 'Timer'

#define TRACE_LEVEL_NONE        0   // Tracing is not on
#define TRACE_LEVEL_CRITICAL    1   // Abnormal exit or termination
#define TRACE_LEVEL_ERROR       2   // Severe errors that need logging
#define TRACE_LEVEL_WARNING     3   // Warnings such as allocation failure
#define TRACE_LEVEL_INFORMATION 4   // Includes non-error cases(e.g.,Entry-Exit)
#define TRACE_LEVEL_VERBOSE     5   // Detailed traces from intermediate steps
$LEVEL_NORMAL = 4
$LEVEL_VERBOSE = 5

# --------------------------------------------------
# FUNCTIONS
# --------------------------------------------------

# Import WULib
if (Test-Path "$SCRIPT_DIR\PsWULib.ps1")
{
    . "$SCRIPT_DIR\PsWULib.ps1" -Phone $Phone
}
else
{
    . "\\mufiles\ts\PsWULib.ps1" -Phone $Phone
}

#
# Returns true if script is running elevated
#
function IsElevated
{
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $isElevated = $prp.IsInRole($adm)

    return $isElevated
}

#
# Relaunch this script elevated.
#
# Don't move. These have to be on script global scope.
$ScriptPath = $MyInvocation.MyCommand.Definition
$ScriptCmdLine = $MyInvocation.Line
function RelaunchElevated
{
    if(IsElevated)
    {
        # already elevated, nothing to do.
        return
    }

    # The new process can't resolve working dir when script is launched like .\wulog.ps1, so we have to parse
    # and rebuild the full script path and param list.
    $scriptParams = $ScriptCmdLine.Substring($ScriptCmdLine.IndexOf('-')-1)
    $scriptCmd = "$ScriptPath $scriptParams"

    $arg = "-NoExit -Command `"$scriptCmd`""

    $proc = Start-Process "$psHome\powershell.exe" -ArgumentList $arg -Wait -Verb Runas -ErrorAction Stop
}

#
# Enable/disable WU's default WPP/ETL tracing. This will stop wuauserv.
# Our tracing doesn't support multiple listeners, so we have to disable our default ETL for wulog.ps1 to work.
#
function SetDefaultWUTracing
{
    Param(
        [switch] $Enable,
        [switch] $Disable
    )

    if((!$Enable -and !$Disable) -or ($Enable -and $Disable))
    {
        throw "Coding error: Specify -Enable or -Disable"
    }
    
    $REG_VAL_NAME = "WPPLogDisabled"

    # Turn off default WU tracing.
    if($Disable)
    {
        Write-Host "Disabling WU default tracing."
        RegistryCommand "add $TRACE_REGKEY /v $REG_VAL_NAME /d 1 /t REG_DWORD /f" | Out-Host
    }
    # Turn on default WU tracing.
    elseif($Enable)
    {
        Write-Host "Enabling WU default tracing."
        RegistryCommand "delete $TRACE_REGKEY /v $REG_VAL_NAME /f" | Out-Host
    }

    if ($Disable -or ($Enable -and !$DontStopService))
    {
        Write-Verbose "Stopping wuauserv ..."
        RunCommand -cmd "net stop wuauserv" -ignoreError $true
    }
}

#
# CHK build by defaults log to file and debugger, which can slow things down. Use this function to turn it on/off.
#
function SetLogToDebugger
{
    Param($enable)
    
    if ($enable)
    {        
        # set Flags to 3 (e_traceFlagsLogToDebugger | e_traceFlagsLogToFile)
        RegistryCommand "add $TRACE_REGKEY /v Flags /d 3 /t REG_DWORD /f"
    }
    else
    {
        # set Flags to 2 (e_traceFlagsLogToFile)
        RegistryCommand "add $TRACE_REGKEY /v Flags /d 2 /t REG_DWORD /f"
    }
}

#
# Returns true if file is located exactly on %systemdrive%\
#
function IsFileOnSystemDrive
{
    Param ($path)

    $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
    $folder = Split-Path $fullPath -Parent -ErrorAction Stop

    return ($folder -eq "$env:SystemDrive\")
}

#
# Given flag enums, return the numerical value to pass into tracelog.exe
#
function GetFlagsValue
{
    Param([string[]]$flags)

    $value = 0

    if ($flags -eq $null)
    {
        $FLAGS_VALUES.Values | ForEach-Object { $value = $value -bor $_ }
        return $value
    }
    else
    {
        foreach($flag in $flags)
        {
            $value = $value -bor $FLAGS_VALUES[$flag]
        }

        return $value
    }
}

#
# Given a value, remove the flags and return the resulting value.
#
function RemoveFlagsFromValue
{
    Param($value, [string[]]$flags)

    foreach($flag in $flags)
    {
        $value = $value -bxor $FLAGS_VALUES[$flag]
    }

    return $value
}

#
# Parse the ETL file for the build/branch info and set the symbol path.
#
function FindSymbolsFromETL
{
    if (!(Test-Path $ETLPath))
    {
        throw "Can't find ETL file: $ETLPath"
    }

    $errorMsg = "Unable to deduce symbol path from ETL file.`nPlease manually specify -PrivateSymbols -SymbolPath <path to symbols>"

    Write-Host -ForegroundColor Cyan "`nAutomatically finding symbols ..."

    # If user passes in a directory as $ETLPath, use the first ETL in folder.
    $referenceETL = $null

    if (Test-Path $ETLPath -PathType Container)
    {
        $etls = Get-ChildItem $ETLPath -Filter *.etl

        Write-Verbose "Number of ETL files: $($etls.Length)"

        if ($etls.Length -le 0)
        {
            throw "There's no ETL file in $ETLPath"
        }

        $referenceETL = $etls[0].FullName.Trim()
    }
    else
    {
        $referenceETL = $ETLPath
    }

    $tmpFile = "$env:TEMP\etlstrings.txt"
    & $TRACELOG_BINPATH\strings.exe -accepteula -q -b 1024 $referenceETL | Out-File $tmpFile

    $lines = Get-Content $tmpFile

    $lines | Write-Verbose

    # Find build string 9841.0.armfre.fbl_marketplace.140917-0053
    $regex = "[0-9]{4,5}.0.[A-Za-z0-9]{6,8}.[A-Za-z0-9_]*.[0-9]{6,6}-[0-9]{4,4}"

    $match = $lines | Select-String -Pattern $regex

    if ($match -eq $null)
    {
        throw $errorMsg
    }

    $buildString = $match.Line

    Write-Verbose "Build string: $buildString"

    if ($buildString -eq $null -or $buildString.Length -eq 0)
    {
        throw $errorMsg
    }

    # Parse 9841.0.armfre.fbl_marketplace.140917-0053
    $parts = $buildString.Split('.')

    $branch = $parts[3]
    $build = "$($parts[0]).$($parts[1]).$($parts[4])"
    $arch = $parts[2]

    if ($arch -eq "armfre")
    {
        # build share doesn't use armfre in its path.
        $arch = "woafre"
    }

    $pdbPath = "\\winbuilds\release\$branch\$build\$arch\symbols.pri\retail\dll"
    $tmfPath = "$($env:SystemDrive)\TMF\$buildString"

    if (Test-Path $pdbPath)
    {
        $script:SymbolPath = $pdbPath
        $script:TMFPath = $tmfPath

        Write-Host "PDB path: $pdbPath"
    }
    else
    {
        throw "Can't find symbols at $pdbPath"
    }
}

#
# Grab trace message format (TMF) files from $SymbolPath and cache it to $TMFPath.
#
function DecodeSymbols
{
    Param(
        $DefaultPdbs = $(throw "DefaultPdbs param required.")
    )


    write-host -ForegroundColor Cyan "`nReading PDBs ..."

    if ($SymbolPath -eq $null -or $SymbolPath -eq "")
    {
        $SymbolPath = $(Read-Host -Prompt "Symbol path")
    }

    if(!(Test-Path $SymbolPath))
    {
        throw "Can't find: '$SymbolPath'"
    }

    $tmfCached = $false
    if (Test-Path $TMFPath)
    {
        $files = Get-ChildItem $TMFPath
        $tmfCached = $files.Length -gt 0
    }

    # If symbols were deduced from ETL, and we have previously decoded the PDBs from build share, used the cached TMFs.
    if (!$PrivateSymbols -and $tmfCached -and !$RefreshSymbols)
    {
        Write-Host "Using cached TMFs. Pass -RefreshSymbols if you'd like to overwrite."
        Write-Host "TMF Path: $TMFPath"
        return
    }

    Write-Host "TMF Path: $TMFPath`n"

    New-Item -Path $TMFPath -ItemType directory -Force -ErrorAction Ignore | Out-Null

    foreach($name in $DefaultPdbs)
    {
        # PDB may be directly in the path that user passes in, or under DLL/EXE folder. Iterate through all.
        $pdb = $null
        $searchPaths = "$SymbolPath\$name", ` # user passes in a dir that contains everything
                        "$SymbolPath\..\dll\$name", "$SymbolPath\..\exe\$name", ` # user passes in symbols.pri\retail\dll or exe
                        "$SymbolPath\dll\$name", "$SymbolPath\exe\$name", ` # user passes in symbols.pri\retail
                        "$SymbolPath\retail\dll\$name", "$SymbolPath\retail\exe\$name" # user passes in symbols.pri

        foreach($path in $searchPaths)
        {
            if (Test-Path $path)
            {
                $pdb = $path
                break
            }
        }

        if ($pdb -eq $null)
        {
            Write-Host -ForegroundColor Yellow "Can't find: $name (some events may be unrecognizable ...)"
            continue
        }

        Write-Host "Decoding $pdb"

        # Some folks (*cough*Raj*cough) experienced slow decoding when doing it directly from share.
        $localPdb = "$TMFPath\$name"
        Copy-Item -Path $pdb -Destination $TMFPath -Force -ErrorAction Stop

        & $TRACELOG_BINPATH\tracepdb.exe -f $localPdb -p $TMFPath | Out-Null
        if(!$?)
        {
            throw "Failed to get trace format message from $pdb."
        }
    }

    Write-Host "Done."
}

#
# Unzip file pointed by $ETLPath to a temp folder, and overwrite $ETLPath with the temp location.
#
function UnzipLog
{
    Write-Host -ForegroundColor Cyan "`nUnzipping $ETLPath ..."

    if (!(Test-Path $ETLPath))
    {
        throw "$ETLPath doesn't exist."
    }

    # Remove zone identifier from file so we don't get that stupid "This file is downloaded from Internet ... are you sure?" prompt.
    Unblock-File $ETLPath -ErrorAction SilentlyContinue

    $filename = Split-Path -Leaf $ETLPath
    $filename = $filename.Substring(0, $filename.LastIndexOf('.'))
    $destination = "$env:TEMP\$filename"

    if (Test-Path $destination)
    {
        Remove-Item $destination -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    New-Item $destination -ItemType directory -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose "Destination: $destination"

    $shell = New-Object -ComObject shell.application
    $zip = $shell.NameSpace($ETLPath)

    $copyFlags = 4 # no progress dialog

    $numUnzipped = 0

    # Anticipate various kinds of cabs:
    # - Copylogs.cmd places WU ETLs under a subfolder. 
    # - Other collector like DU/Watson places them under the root folder.

    $subfolder = $shell.NameSpace($ETLPath)
    
    foreach($file in $zip.Items())
    {
        Write-Verbose "File: $($file.Name)"

        if ($file.Name -eq "WU_Logs")
        {
            $subfolder = $shell.NameSpace("$ETLPath\WU_logs")
            break
        }
    }   

    foreach($subfile in $subfolder.Items())
    {
        $subDirPath = $subfile.Path
        $extension = [System.IO.Path]::GetExtension($subDirPath)

        Write-Verbose "Subfile: $($subfile.Name)"

        if ($subfile.Name -like "windowsupdate*" -and $extension -eq ".etl")
        {
            Write-Verbose "Found etl: $($subfile.Name)"
            $shell.NameSpace($destination).CopyHere($subfile, $copyFlags) | Out-Host
            $numUnzipped++
        }
    }

    if ($numUnzipped -le 0)
    {
        throw "Can't find windowsupdate*.etl inside $ETLPath"
    }

    $script:ETLPath = $destination
    Write-Host "ETL Path: $script:ETLPath"
}

#
# Decode $ETLPath into $LogPath
#
function DecodeETL
{
    Param(
        $FileNameFilter = $(throw 'FileNameFilter required')
    )

    Write-Host -ForegroundColor Cyan "`nDecoding ETL into text file ..."
    Write-Host "TMF Path: $TMFPath`n"

    $logIsOnRoot = IsFileOnSystemDrive -path $LogPath

    if(!(IsElevated) -and $logIsOnRoot)
    {
        RelaunchElevated
        return
    }

    # tracefmt.exe grabs format prefix from environment variable.
    if ($SourceLine)
    {
        # Append FileName_LineNumber to existing format string.
        $TraceFormat = $TraceFormat.TrimEnd() + " (%2!s!)     "
    }

    Write-Verbose "Setting TRACE_FORMAT_PREFIX=$TraceFormat"
    $env:TRACE_FORMAT_PREFIX = $TraceFormat

    
    $etlList = New-Object System.Collections.Generic.List[System.String]

    # If user passes in a directory as $ETLPath, grabs all the ETLs in that folder.
    if (Test-Path $ETLPath -PathType Container)
    {
        $etls = Get-ChildItem $ETLPath -Filter "$FileNameFilter*.etl" | Sort-Object -Property LastWriteTime

        Write-Verbose "Number of ETL files: $($etls.Length)"

        if ($etls.Length -le 0)
        {
            throw "There's no ETL file in $ETLPath"
        }

        foreach($etl in $etls)
        {
            $etlList.Add($etl.FullName.Trim())
        }
    }
    else
    {
        $etlList.Add($ETLPath.Trim())
    }

    if ($etlList.Count -gt 1)
    {
        Write-Verbose "Sorting ETLs numerically ..."    
        $etlList = $etlList | Sort-Object { [regex]::Replace($_, '\d+(?=.etl)', { $args[0].Value.PadLeft(10) }) }
    }

    # tracefmt can't decode more than 15 logs at once, so we have to manually batch it every 15.
    $logFolder = Split-Path -Parent $LogPath 
    $tempLogPath = "$logFolder\wulog.tmp"
    $tempLogCount = 0
    Remove-Item "$tempLogPath.*" -ErrorAction SilentlyContinue | Out-Null
    
    # Pad $processed so files can be sorted numerically.
    $NumFormat = "{0:00000}"

    $processed = 0;

    while ($processed -lt $etlList.Count)
    {
        $args = New-Object System.Collections.Generic.List[System.String]

        for ($index = 0; ($index -lt 15) -and (($index + $processed) -lt $etlList.Count); $index++)
        {
            $args.Add($etlList[$index + $processed])
        }

        $processed += $args.Count
        
        $args.Add("-o")
        $args.Add("$tempLogPath.$NumFormat" -f $tempLogCount)

        $tempLogCount++
        
        if ($UseSymbolServer)
        {
            $args.Add("-r") 
            $args.Add("SRV*$SymbolServerCache*http://symweb")
            #$args.Add("-v")
        }
        else
        {
            $args.Add("-p")
            $args.Add($TMFPath)
        }

        $args.Add("-nosummary")

        Write-Verbose "$TRACELOG_BINPATH\tracefmt.exe $args"
        &$TRACELOG_BINPATH\tracefmt.exe $args
    }
    
    Remove-Item $LogPath -ErrorAction SilentlyContinue | Out-Null

    # merge all the temp text logs into one.
    if ($tempLogCount -gt 1)
    {
        Get-Content "$tempLogPath.*" | Out-File $LogPath -Encoding ascii
    }
    else
    {
        $src = "$tempLogPath.$NumFormat" -f 0
        $logName = Split-Path -Leaf $LogPath
        Rename-Item -Path $src -NewName $logName -ErrorAction Stop | Out-Null
    }

    Remove-Item "$tempLogPath.*" -ErrorAction SilentlyContinue | Out-Null

    Write-Host -ForegroundColor Cyan "`nTXT: $LogPath`n"
}

#
# Calculate the flags and level that user wants, and start WU tracing.
#
function StartTrace
{
    Param(
        $SessionName = $(throw 'SessionName param required.'),
        $WppId = $(throw 'WppId param required.')
    )

    # Determine trace level
    $level = $LEVEL_NORMAL

    if ($VerboseLog)
    {
        $level = $LEVEL_VERBOSE
    }

    # Determine flags
    $chosenFlags = $null # default, turn on all flags.

    if ($IncludeFlags -ne $null)
    {
        $chosenFlags = $IncludeFlags
    }

    $flagsValue = GetFlagsValue -flags $chosenFlags

    if ($NoChatty)
    {
        $flagsValue = RemoveFlagsFromValue -value $flagsValue -flags $FLAGS_CHATTY
    }

    if ($ExcludeFlags -ne $null)
    {
        $flagsValue = RemoveFlagsFromValue -value $flagsValue -flags $ExcludeFlags
    }
    
    $fullETLPath = $ETLPath

    if ($Phone)
    {
        $fullETLPath = $PHONE_CUSTOM_ETL_PATH
    }    

    $cmdExe = ""
    $cmdArgs = ""

    $bracedGuid = "{$WppId}" # logman wants braces.

    if ($USE_LOGMAN -and !$Phone)
    {
        # these are copied from tracelog's default.
        $minNumBuffer = 2
        $maxNumBuffer = 24
        $flushTimerInSecs = '00:00:05' # flush every 5 secs

        # LogMan is inbox on Desktop.
        $cmdExe = "logman"
        $cmdArgs = `
            "start $SessionName -ets -o $fullETLPath -ft $flushTimerInSecs -nb $minNumBuffer $maxNumBuffer -bs $BufferSizeInKb -p $bracedGuid $flagsValue $level"
    }
    else
    {
        if ($Phone)
        {
            # TraceLog is inbox on Phone.
            $cmdExe = "tracelog"
        }
        else 
        {
            $cmdExe = "$TRACELOG_BINPATH\tracelog.exe"
        }

        $cmdArgs = "-start $SessionName -guid `#$WppId -f $fullETLPath -b $BufferSizeInKb -flag $flagsValue -level $level"
    }

    $cmdLine = "$cmdExe $cmdArgs"

    if(!(IsElevated) -and !$Phone)
    {
        RelaunchElevated
        return
    }

    # WU doesn't support multiple listeners, so we have to disable default tracing.
    SetDefaultWUTracing -Disable

    write-host $cmdLine

    if ($Phone)
    {
        Cmd-Device $cmdLine
    }
    else 
    {
        # Invoke-Expression doesn't like the -o in the args which it thinks is PS -outputFormat. Insert --% to tell PS to don't interpret that.
        Invoke-Expression -Command "$cmdExe --% $cmdArgs"

        if(!$?)
        {
            throw "Failed to start tracing."
        }
    }    
}

#
# Stop WU tracing.
#
function StopTrace
{
    Param(
        $SessionName = $(throw 'SessionName param required.')
    )

    $cmdLine = ""

    if ($USE_LOGMAN -and !$Phone)
    {
        $cmdLine = "logman stop $SessionName -ets"
    }
    else
    {
        $cmdArgs = "-stop $SessionName"

        if ($Phone)
        {
            $cmdLine = "tracelog $cmdArgs"
        }
        else
        {            
            $cmdLine = "$TRACELOG_BINPATH\tracelog $cmdArgs"
        }
    }

    if(!(IsElevated) -and !$Phone)
    {
        RelaunchElevated
        return
    }

    # Reenable WU's default ETL.
    SetDefaultWUTracing -Enable

    RunCommand -cmd $cmdLine -ignoreError $Phone
}

#
# Update local copies of trace binaries.
#
function CopyTraceBinaries
{
    $binsComplete = (Test-Path $TRACELOG_BINPATH\tracefmt.exe)      -and `
                    (Test-Path $TRACELOG_BINPATH\tracelog.exe)      -and `
                    (Test-Path $TRACELOG_BINPATH\dbghelp.dll)       -and `
                    (Test-Path $TRACELOG_BINPATH\symsrv.dll)        -and `
                    (Test-Path $TRACELOG_BINPATH\symsrv.yes)        -and `
                    (Test-Path $TRACELOG_BINPATH\TraceSymCfg.ini)   -and `
                    (Test-Path $TRACELOG_BINPATH\strings.exe)

    #fix the path and binscomplete
    if ($ForceUpdate -or !$binsComplete)
    {
        $arch = $env:PROCESSOR_ARCHITECTURE
        & robocopy \\mufiles\ts\trace\$arch $TRACELOG_BINPATH /E
    }
}

#
# Copy WU ETLs from Phone to the specified tempPath.
#
function CopyETLsFromPhone
{
    Param(
        $tempPath = $(throw "tempPath param must be specified."),
        $customETL = $(throw "customETL param must be specified.")
    )

    if (Test-Path $tempPath)
    {
        Remove-Item -Path $tempPath -Recurse -Force -ErrorAction Stop
    }

    New-Item -Path $tempPath -ItemType directory -ErrorAction Stop | Out-Null

    if (!$DontStopService)
    {
        Cmd-Device "net stop wuauserv"
    }

    if ($customETL)
    {
        Get-Device -Source $PHONE_CUSTOM_ETL_PATH -Destination $tempPath
    }
    else
    {
        Get-Device -Source C:\Windows\Logs\WindowsUpdate\* -Destination $tempPath
    }
}

#
# Add WULog.ps1 to Explorer's SendTo menu.
#
function InstallRightClickMenu
{
    $CmdScript = "@echo off
REM WULog.ps1 Right Click Context Menu Helper Script.

setlocal
set _LOGPATH=%~dp1\WindowsUpdate-etl.log
del `"%_LOGPATH%`" >NUL 2>&1

echo powershell.exe -ExecutionPolicy Bypass \\mufiles\ts\wulog.ps1 -DecodeETL -ETLPath '%1' -UseSymbolServer -LogPath '`"%_LOGPATH%`"'
call powershell.exe -ExecutionPolicy Bypass \\mufiles\ts\wulog.ps1 -DecodeETL -ETLPath '%1' -UseSymbolServer -LogPath '`"%_LOGPATH%`"'

if exist `"%_LOGPATH%`" (
    echo Decoded. Launching in Notepad ...
    call notepad.exe `"%_LOGPATH%`"
) else (
    echo Failed to decode.
    pause
)"

    $CmdScript | Out-File -FilePath "$env:appdata\Microsoft\Windows\SendTo\Decode WU ETL.cmd" -Encoding ascii -Force
    
    Write-Host "Done. You can now right click and select SendTo > Decode WU ETL.cmd to decode ETL cab/file/folder."
}

# --------------------------------------------------
# MAIN
# --------------------------------------------------

try
{
    $sessionName = "$($Product)LOGPS1"
    $filenameFilter = $Product

    $wppId = $null
    $defaultPdbs = $null

    switch ($Product)
    {
        'WindowsUpdate' 
        {
            $wppId = $WU_WPP_ID
            $defaultPdbs = $WU_PDBS
        }

        'SIH' 
        { 
            $wppId = $SIH_WPP_ID
            $defaultPdbs = $SIH_PDBS
        }
    }

    if ($SymbolPath -ne $null -and $SymbolPath -ne "")
    {
        $Symbol = $true
        $PrivateSymbols = $true
    }

    if ($Symbol -or $DecodeETL -or $ForceUpdate)
    {
        CopyTraceBinaries
    }

    # expand relative path to full path
    if ($ETLPath -like ".\*")
    {                
        $dir = Get-Location
        $file = Split-Path -Leaf $ETLPath
        $ETLPath = Join-Path $dir $file
    }

    if ($Start)
    {
        StartTrace -SessionName $sessionName -WppId $wppId
    }

    if ($Stop)
    {
        StopTrace -SessionName $sessionName
    }

    if ($Symbol)
    {
        DecodeSymbols -DefaultPdbs $defaultPdbs
    }

    if ($DecodeETL)
    {       
        if ($ETLPath.Trim().ToLower().EndsWith(".zip") -or 
            $ETLPath.Trim().ToLower().EndsWith(".cab"))
        {
            UnzipLog
        }

        if ($Phone)
        {
           $ETLPath = "$env:temp\PhoneETL"
           CopyETLsFromPhone -tempPath $ETLPath -customETL ($VerboseLog -or $Stop)
        }

        if (!$PrivateSymbols -and !$UseSymbolServer)
        {
            FindSymbolsFromETL
            DecodeSymbols -DefaultPdbs $defaultPdbs
        }

        DecodeETL -FileNameFilter $filenameFilter
    }

    if ($ListFlags)
    {
        $flags = ""
        $FLAGS_VALUES.Keys | foreach { $flags = "$flags $_" }
        write-host $flags
    }

    if ($GetCommands -or $GetCommandsPhone)
    {
        Write-Host -ForegroundColor Yellow "DEPRECATED: -GetCommands and -GetCommandsPhone"
        Write-Host "WULog.ps1 now supports Phone/TShell natively.`nFor instructions: Get-Help \\mufiles\ts\wulog.ps1 -Detailed"
    }

    if ($LogToDebugger -ne $null)
    {
        SetLogToDebugger -enable $LogToDebugger
    }

    if ($InstallRightClickMenu)
    {
        InstallRightClickMenu
    }
}
catch
{
    # highlight exception msg and rethrow for PS to show the accurate stack trace with line number
    Write-Host -ForegroundColor Red -BackgroundColor Yellow "$($_.Exception.Message)`n"
    throw $_.Exception
}