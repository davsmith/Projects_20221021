<#

 Checkin-Store.ps1

 Author: davsmith
 Microsoft Corp. (c) 2015


#>

<#
    .SYNOPSIS
        Verifies and checks in store bundles, created by Set-StoreBundleVersion, to the Windows source depot,
        in the specified branch.
    .EXAMPLE
        enlist -branch "FBL_MARKETPLACE" -sdroot "C:\mkt" -FCIB
#>

function Enlist() {
[CmdletBinding(DefaultParameterSetName="FCIB")] 

param ( 
  [parameter(Position=0,
   Mandatory=$true)]
   [string]$branch,

  [parameter(Position=1,
   Mandatory=$true)]
   [string]$sdxroot,

   [parameter(Position=2,
   Mandatory=$true,
   ParameterSetName="Developer")]
   [switch]$Developer,

   [parameter(Position=2,
   Mandatory=$true,
   ParameterSetName="FCIB")]
   [switch]$FCIB,
  
   [parameter(Position=2,
   Mandatory=$true,
   ParameterSetName="Projects")]
   [string]$ProjectList
) 

    $workingDir = Setup-SDRoot $branch $sdxroot

    $projects = "enduser"
    switch ($psCmdlet.ParameterSetName) {
        "Developer" {
            $projects = "enduser"
        }
        "FCIB" {
            $projects = "redist wpuxplat"
        }
        "Projects" {
            $projecs = $ProjectList
        }
    }

    $wholestring = @"
    set sdxroot=$sdxroot
    pushd %sdxroot%
    \\glacier\sdx\sdx enlist th $branch $projects
    pushd mspartners
    \\glacier\sdx\sd sync ...
"@

    $wholestring | Set-Content $workingDir\enlist.cmd
    Start-Process "c:\Windows\System32\cmd.exe" -argumentlist "/k $workingDir\enlist.cmd"
    CreateRazzleShortcut "$branch" "$sdxroot"
}

#
# Returns a directory to use as the root of the Source Depot enlistment.  If the directory doesn't
# exist, a new, empty one is created.
#
function Setup-SDRoot([string]$branchName, [string]$directoryName=$branchName) {
    
    $fullWorkingPath = $directoryName
    
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

function DisplayIconCollection(){
    $targetDir = "c:\temp"
    $iconName = "Icon "
    $shell = New-Object -ComObject WScript.Shell
    For ($i = 1; $i -le 330; $i++)
    {
        $shortcut = $shell.CreateShortcut("$targetDir\$iconName$i.lnk")
        $shortcut.TargetPath = "%windir%\system32\cmd.exe"
        $shortcut.IconLocation = "shell32.dll,$i"
        $shortcut.Description = "Icon at index $i"
        $shortcut.Save()
    }
}

function CreateRazzleShortcut($branch, $sdroot, $iconIndex=94){
    $shell = New-Object -ComObject WScript.Shell
    $desktop = [System.Environment]::GetFolderPath('Desktop')
    $shortcut = $shell.CreateShortcut("$desktop\$branch.lnk")
    $shortcut.TargetPath = "%windir%\system32\cmd.exe"
    $shortcut.Arguments = "/k $sdroot\tools\razzle.cmd"
    $shortcut.IconLocation = "shell32.dll,$iconIndex"
    $shortcut.Description = "Razzle window for $branch"
    $shortcut.Save()
}