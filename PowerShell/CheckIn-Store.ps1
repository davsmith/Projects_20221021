<#

 Checkin-Store.ps1

 Author: davsmith
 Microsoft Corp. (c) 2015


#>

<#
    .SYNOPSIS
        Verifies and checks in store bundles, created by Set-StoreBundleVersion, to the Windows source depot,
        in the specified branch.
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


#
# Creates an empty directory to store the APPX files from the build, and other files required
# to generate the APPX bundle.
#
# Checks for the existence of the specified working directory.  If it doesn't exist, create it.
# If it does exist, append a counter to it, until we find a directory that doesn't exist.
#
function Setup-Workspace($branchName) {
    
    $fullWorkingPath = $branchName
    
    if (-not (Test-Path $fullWorkingPath)) {
        New-Item $fullWorkingPath -type directory | Out-Null
    }

    if (Test-Path($fullWorkingPath)) {$retVal = $fullWorkingPath}

    return $retVal
}

function Checkin-Store()
{
    if (-not (Test-Path env:sdxroot)) {
        Write-Error "SDXRoot is not defined.  Please run from a Razzle window."
    } else {
        pushd $env:sdxroot\redist\mspartners\ipa\WinStore
    }
}

<# $binPath = "D:\dev_01\redist\mspartners\ipa\WinStore
if (Test-Path $binPath)
{
    pushd $env:SDXROOT\redist\mspartners\ipa\WinStore
    Write-Host "Changed path to Store binary"
} else {
    Write-Error Path to Store binary doesn`'t exist.
}
#>

function Enlist() {
    $sdroot = "C:\t2"
    $workingDir = Setup-Workspace($sdroot)

    $wholestring = @"
    set sdxroot=$sdroot
    \\glacier\sdx\sdx enlist th $branch redist
"@

    $wholestring | Set-Content $workingDir\enlist.cmd
    invoke-item $workingDir\enlist.cmd
}

function CreateShortcut(){
    $shell = New-Object -ComObject WScript.Shell
    $desktop = [System.Environment]::GetFolderPath('Desktop')
    $shortcut = $shell.CreateShortcut("$desktop\$branch.lnk")
    $shortcut.TargetPath = "%windir%\system32\cmd.exe"
    $shortcut.Arguments = "/k $sdroot\tools\razzle.cmd"
    $shortcut.IconLocation = "shell32.dll,23"
    $shortcut.Save()
}

$branch = "FBL_MARKETPLACE_DEV01"