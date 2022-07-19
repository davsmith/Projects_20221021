<#
    Functions associated with setting up a new machine.

    Should include:
    - Checking for Powershell v5, and launching install if necessary
    - Installing and configuring git.
    - Cloning the tools depot
    - Installing Notepad++, git-credential-store, etc.
    - Setting the PowerShell color scheme?


    Dave Smith
    Updates:
    7/25/2015:
        - Created the script
>#

<# Setup functionality #>
$psVersionMajor = $PSVersionTable.PSVersion.Major
if ($psVersionMajor -lt 5)
{
    Write-Host "This device is running version $psVersionMajor of PowerShell.  Please update to version 5."
    Start-Process "http://download.microsoft.com/download/B/7/0/B7075FF1-E1B7-4CEB-9A55-CA24DEA79478/WindowsBlue-KB3006193-x64.msu"
}


<# Global variables #>
$repoRoot = "c:\local\repos\tools"



function Install-Chocolatey
{
    (iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
}

function Copy-Profile
{
    $srcFile = $repoRoot+"\powershell\profile.ps1"
    if (-not(Test-path $srcFile -PathType Leaf))
    {
        Write-Error "The source profile couldn`'t be found. Profile wasn`'t copied"
        return
    }


    $destDir = Split-Path $profile
    New-Item -ItemType Directory -Force -Path $destDir
    if (-not(Test-path $destDir))
    {
        Write-Error "The profile directory doesn't exist, and couldn`'t be created. Profile wasn`'t copied"
        return
    }
    else
    {
        Copy-Item -Path $srcFile -Destination $destDir
    }
}


function Get-AppsFromChocolatey
{
    cinst poshgit -y
    cinst notepadplusplus -y
    cinst git-credential-winstore -y
    cinst kdiff3 -y
    cinst autohotkey -y
}


function Git-Go
{

    <#
    Install-Package poshgit
    Install-Package notepadplusplus
    Install-Package git-credential-winstore
    Install-Package kdiff3
    Install-package autohotkey
    #>

    git config --global user.name "Dave Smith"
    git config --global user.email=source@seattlesmiths.com
    git config --global core.editor "'c:\program files (x86)\Notepad++\notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
    git config --global diff.tool kdiff3

    git config --global difftool.prompt false

    if (-not (Test-Path $repoRoot))
    {
        New-Item -ItemType Directory -Force -Path $repoRoot
        git clone https://davsmith.visualstudio.com/DefaultCollection/_git/Tools $repoRoot
        # 47fb53cc2ozzm2q7fbldv6xultzhojev5u3w6t2un4qgkx76aeza
    }
}

