<# http://blogs.technet.com/b/heyscriptingguy/archive/2013/11/15/use-powershell-to-find-installed-software.aspx #>
<#
    PowerShell profile script version 1.1.

    Dave Smith
    Updates:
    6/11/2015:
        - Added alias scripts for psscripts, ahkscripts, and redmond
        - Added functions for StoreVer and Bundle
>#

<# Setup functionality #>
$psVersionMajor = $PSVersionTable.PSVersion.Major
if ($psVersionMajor -lt 5)
{
    Write-Host "This device is running version $psVersionMajor of PowerShell.  Please update to version 5."
    Start-Process "http://download.microsoft.com/download/B/7/0/B7075FF1-E1B7-4CEB-9A55-CA24DEA79478/WindowsBlue-KB3006193-x64.msu"
}

function Install-Chocolatey
{
    (iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
}

function Git-Go
{
    $repoRoot = "c:\local\repos\tools\"

    Install-Package poshgit
    Install-Package notepadplusplus
    Install-Package git-credential-winstore
    Install-Package kdiff3
    Install-package autohotkey

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


<#
    ZIP file functionality
#>
function Expand-ZIPFile($file, $destination)
 {
    [CmdletBinding()]
     $shell = new-object -com shell.application
     $zip = $shell.NameSpace($file)
     foreach($item in $zip.items())
     {
        Write-Debug ("Extracting " + $item.Name)
        $shell.Namespace($destination+"\Test").copyhere($item, 0x10)
     }
 }

function my-function
{
 [cmdletbinding()]
 Param()
 # Set $DebugPreference = "Continue" to view debug output
 Write-Debug "Hello!"
}




<#
    Registry functionality
#>

function Get-RegistryValues($key) {    (Get-Item $key).GetValueNames()}
function Get-RegistryValue($key, $value) {    (Get-ItemProperty -path $key -name $value).$value}

function Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
        ,
        [Switch]$PassThru
    ) 

    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path #                -LiteralPath means no wildcards
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty -path $Path -name $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
}

<#
    Example:  (Get-CatalogProduct -ProductId 9WZDNCRFHVFW).LocalizedProperties.ProductTitle
#>
function Get-CatalogProductv5(
  [string]$ProductId = $null,
  [string]$PackageFamilyName = $null,
  [string]$ContentId = $null,
  [string]$LegacyPhoneProductId = $null,
  [switch]$Raw,
  [string]$Market='US',
  [string]$Language='en-US',
  [switch]$ProdName)
{
  if ($ProductId) {
    $x = Invoke-WebRequest "https://displaycatalog.md.mp.microsoft.com/products/$($ProductId)?fieldsTemplate=Full&market=$($Market)&language=$($Language)" -Headers @{ 'MS-Contract-Version'=5; }
    if ($Raw) {
      return $x.Content
    } else {
      return (convertfrom-json $x.Content).Product
    }
  } elseif ($PackageFamilyName) {
    $x = Invoke-WebRequest "https://displaycatalog.md.mp.microsoft.com/products?rank=PackageFamilyName&count=1&alternateId=$($PackageFamilyName)&market=$($Market)&language=$($Language)&fieldsTemplate=Full" -Headers @{ 'MS-Contract-Version'=5; }
    if ($Raw) {
      return $x.Content
    } else {
      $y = convertfrom-json $x.Content
      return $y.DisplayProductSearchResult.Products[0]
    }
  } elseif ($LegacyPhoneProductId) {
    $x = Invoke-WebRequest "https://displaycatalog.md.mp.microsoft.com/products?rank=LegacyWindowsPhoneProductId&count=1&alternateId=$($LegacyPhoneProductId)&market=$($Market)&language=$($Language)&fieldsTemplate=Full" -Headers @{ 'MS-Contract-Version'=5; }
    if ($Raw) {
      return $x.Content
    } else {
      $y = convertfrom-json $x.Content
      return $y.DisplayProductSearchResult.Products[0]
    }  
  } else {
    $x = Invoke-WebRequest "https://displaycatalog.md.mp.microsoft.com/skus?rank=ContentId&count=1&alternateId=$($ContentId)&market=$($Market)&language=$($Language)&fieldsTemplate=Full" -Headers @{ 'MS-Contract-Version'=5; }
    if ($Raw) {
      return $x.Content
    } else {
      $y = convertfrom-json $x.Content
      return $y.DisplaySkuSearchResult.Products[0]
    }
  }
}


function Get-CatalogProduct(
  [string]$ProductId = $null,
  [string]$PackageFamilyName = $null,
  [string]$ContentId = $null,
  [string]$LegacyPhoneProductId = $null,
  [string]$LegacyDesktopProductId = $null,
  [switch]$Raw,
  [string]$Market='US',
  [string]$Language='en-US')
{
  $hdr = @{ 'MS-CV'="LxFzVzL+JUG/kPoc.99"; }
  $local:ErrorActionPreference = "Stop"

  if ($ProductId) {
    $url = "https://displaycatalog.md.mp.microsoft.com/v6.0/products/$($ProductId)?fieldsTemplate=Full&market=$($Market)&languages=$($Language)"
  } elseif ($PackageFamilyName) {
    $url = "https://displaycatalog.md.mp.microsoft.com/v6.0/products?rank=PackageFamilyName&alternateId=$($PackageFamilyName)&market=$($Market)&languages=$($Language)&fieldsTemplate=Full"
  } elseif ($LegacyPhoneProductId) {
    $url = "https://displaycatalog.md.mp.microsoft.com/v6.0/products?rank=LegacyWindowsPhoneProductId&alternateId=$($LegacyPhoneProductId)&market=$($Market)&languages=$($Language)&fieldsTemplate=Full"
  } elseif ($LegacyDesktopProductId) {
    $url = "https://displaycatalog.md.mp.microsoft.com/v6.0/skus?rank=WuCategoryId&alternateId=$($LegacyDesktopProductId)&market=$($Market)&languages=$($Language)&fieldsTemplate=Full"
  } else {
    $url = "https://displaycatalog.md.mp.microsoft.com/v6.0/skus?rank=ContentId&alternateId=$($ContentId)&market=$($Market)&languages=$($Language)&fieldsTemplate=Full"
  }

  write-host $url

  $x = Invoke-WebRequest $url -Headers $hdr
  if ($Raw) {
    return $x.Content
  } else {
    $y = convertfrom-json $x.Content
    if ($y.Product) {
      return $y.Product
    } elseif ($y.DisplayProductSearchResult) {
      return $y.DisplayProductSearchResult.Products[0]
    } elseif ($y.DisplaySkuSearchResult) {
      return $y.DisplaySkuSearchResult.Products[0]
    }
  }
}

    
<#
    Global values
#>

<#  Store the path of where the OneDrive files are synced   #> 
$onedriveUserFolder = Test-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Personal\" -Name "UserFolder" -PassThru
if (-not $onedriveUserFolder) {
    $onedriveUserFolder = (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SkyDrive\" -Name "UserFolder" -PassThru).UserFolder
}

<# Define a working directory #>
$workingDir = "$onedriveUserFolder\Projects\PowerShell"
if (-not (Test-Path $workingDir))
{
    Write-Warning "$workingDir doesn`'t exist.  Using alternate."
    $workingDir = Split-Path $profile
    if (-not (Test-Path $workingDir))
    {
        New-Item $workingDir -type directory | Out-Null
    }
}

Set-Location "$workingDir"

<# --- Includes --- #>
if (Test-Path $workingDir\_include)
{
    . "$workingDir\_include\Tools.ps1"
    . "$workingDir\_include\ISEColorThemeCmdlets.ps1"
}
else
{
    Write-Warning "$workingDir\_include folder doesn`'t exist.  No includes will be loaded."
}

<# --- Alias scripts --- #>
function psscripts(){ Start-Process "$onedriveUserFolder\Projects\Powershell\" }
function ahkscripts(){ Start-Process "$onedriveUserFolder\Projects\AutoHotkey\" }
function redmond(){ Start-Process "\\redmond\win\users\davsmith\projects\powershell" }
function bundle() { . \\redmond\win\users\davsmith\projects\powershell\Set-StoreBundleVersion.ps1 c:\bundle $buildnum } 
function StoreVer() {get-appxpackage | findstr /i windowsstore}
function Int() { Powershell –ExecutionPolicy Bypass \\mufiles\ts\sls\sls.ps1 -ResetDataStore -Programs DCatPPE }
function Get-MachineID() { reg query hkey_local_machine\software\microsoft\sqmclient /v MachineID }
function XPert_Store { start-process "https://xpert/osg/?view=ClientVEFRateStatic&source=PROD|Realtime|Microsoft.Windows|Store" }
function XPert_StoreAgent { start-process "https://xpert/osg/?view=ClientVEFRateStatic&source=PROD|Realtime|Microsoft.Windows|StoreAgent|Telemetry" }
function XPert_LM { start-process "https://xpert/osg/?view=ClientVEFRateStatic&source=PROD|Realtime|Microsoft.Windows|LicenseManager|Telemetry" }
function Launch-Autoupdates { start-process "schtasks.exe /run /tn "\Microsoft\Windows\WindowsUpdate\Automatic App Update" /I"}
$profile = $profile.Replace("Microsoft.PowerShellISE_profile.ps1", "profile.ps1")