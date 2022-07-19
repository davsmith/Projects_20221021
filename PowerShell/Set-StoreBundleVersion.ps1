<#
    .SYNOPSIS
    Sets the Store UAP bundle version to a value compatible with DSE ingestion.

    .DESCRIPTION
    Unbundles a Store UAP .appxbundle, then creates multiple bundles (for INT, Mobile, and Desktop)
    with the least-significant digit of the bundle version set to zero.
    
    .PARAMETER destFolderName
    The working directory where output files are stored

    .PARAMETER buildNum
    The build from which APPX files are extracted. (e.g. 2014.08.02.1, or 2014.8.2.1)

    .EXAMPLE
    Set-StoreBundleVersion C:\Bundle 2014.11.25.1
    Creates UAP bundles for Int, Mobile, and Desktop, with bundle version set to 2014.1125.1.0,
    placing them in c:\bundle.

    .NOTES
    Original file crated by Dave Smith (davsmith) 5/29/2015
#>
param([string]$destinationFolder="c:\Bundle", [string]$buildNumber="2015.06.05.1", [string]$branchPrefix="Rel")


<# Global variables #>
$buildNetworkRoot = "\\wsclientux\release\Daily SFUI $branchPrefix\"
$fullBranchPrefix = "Daily SFUI $branchPrefix" + "_"
$architectures = "x64", "x86", "ARM"
$makeAppXBinary = "\\redmond\win\users\davsmith\MakeAppX\makeappx.exe"

<# Temporary variable values for debugging #>
#$buildNetworkRoot = "\\wsclientux\release\Daily SFUI $branchPrefix\"
#$fullBranchPrefix = "Daily SFUI $branchPrefix" + "_"
#$architectures = "x64", "x86", "ARM"
#$makeAppXBinary = "\\redmond\win\users\davsmith\MakeAppX\makeappx.exe"

<# 
    Functions
#>

#
# Creates an empty directory to store the APPX files from the build, and other files required
# to generate the APPX bundle.
#
# Checks for the existence of the specified working directory.  If it doesn't exist, create it.
# If it does exist, append a counter to it, until we find a directory that doesn't exist.
#
function Setup-Workspace($workingDir, $buildNumber, $branchPrefix) {
    
    $fullWorkingPath = $workingDir + "\" + $buildNumber + "." + $branchPrefix
    
    if (-not (Test-Path $fullWorkingPath)) {
        New-Item $fullWorkingPath -type directory | Out-Null
    }

    if (Test-Path($fullWorkingPath)) {$retVal = $fullWorkingPath}

    return $retVal
}


#
#  The build number is used in a number of different formats throughout the
#  process of creating a relevant set of packages and bundles.  This function
#  takes the build string specified in the argument list, and generates
#  strings with the relevant formats.
#
#  Padded:
#     - The month and date of the build are padded with a leading zero if necessary to be 2 digits.  (e.g. 2015.05.05.2)
#     - This is required as part of the build path on \\wsclientux\release
#  Unpadded:
#     - This removes any leading 0s from the Padded build number.
#  Zero Least Significant Digit: 
#     - Overrides the least significant digit of the build number, setting it to 0.  (e.g. 2015.5.5.0)
#     - This is required for the bundle to pass app ingestion 
#     - All packages and bundles much have the least significant digit set to 0
#  Packed:
#     - Uses the year as the MSD, LSD as 0, packs the month and day into second spot, and increment into the third. (e.g. 2015.505.2.0)
#     - This is used for setting the bundle version using MAKEAPPX BUNDLE with the /cv option
#
function Format-BuildNum($buildNumber) {
    $buildParts = @($buildNumber.split("."))
    if ($buildParts.Count -ne 4) {
        Write-Error ("Invalid build number specified (" + $buildNumber + ")  Format: yyyy.mm.dd.increment")
        return
    }  

    # The first part of the build number must be the year, followed by up to two digits for month,
    # up to two digits for date, and an incremental build number.
    if (($buildParts[0].Substring(0,3) -ne "201") -or ($buildParts[1].Length -gt 2) -or ($buildParts[2].Length -gt 2)) {
        Write-Error ("Invalid build number specified (" + $buildNumber + ")  Format: yyyy.mm.dd.increment")
        return    
    }

    if ($buildParts[1].Length -eq 1) {
        $buildParts[1] = "0" + $buildParts[1]
    }

    if ($buildParts[2].Length -eq 1) {
        $buildParts[2] = "0" + $buildParts[2]
    }

    $unpaddedBuild = $buildNumber.Replace(".0",".")
    $paddedBuild = $buildParts[0] + "." + $buildParts[1] + "." + $buildParts[2] + "." + $buildParts[3]
    $zeroLeastSigDigit = $unpaddedBuild.Replace("." + $buildParts[3], ".0")
    $packedBuild = $buildParts[0] + "." + $buildParts[1] + $buildParts[2] + "." + $buildParts[3] + ".0"
    
    # Return the 4 formatted strings
    $unpaddedBuild
    $paddedBuild
    $zeroLeastSigDigit
    $packedBuild
}


#
# Uses the MakeAppx binary to retrieve all of the files from the AppXBundle file from
# the Store Client build, and copy them to a destination folder.
#
function Unbundle-StoreBundle($buildNumber, $destinationFolder)
{
    # Write-Host  "Entering Unbundle-StoreBundle {0} {1}" -f $buildNumber, $destinationFolder  ## Debug

    # Get the properly formatted strings for the build number
    $unpaddedBuild, $paddedBuild, $zeroLeastSigDigitBuild, $packedBuild = Format-BuildNum($buildNumber)
   
    $makeAppxBinaryArgTemplate = "unbundle /o /v /kt /p `"__bundle__`" /d `"__dest__`""

    $bundleSourceFolderBase = $buildNetworkRoot + $fullBranchPrefix + $paddedBuild + "\Release\"
    # "Source folder base name: {0}" -f $bundleSourceFolderBase  ## Debug
    ForEach($architecture in $architectures)
    {
            $bundleSourcePath = $bundleSourceFolderBase + $architecture +"\WinStore.Mobile\AppPackages\WinStore.Mobile_" + $zeroLeastSigDigitBuild +"_Test"
            
            Write-Debug "Source bundle folder: $bundleSourcePath"
                        
#            $sourceBundleFullName = $bundleSourcePath + "WinStore.Mobile_" + $zeroLeastSigDigitBuild + "_" + $architecture + ".appxbundle"
#            "Source bundle name: {0}" -f $sourceBundleFullName
            
            $checkPath = Test-Path $bundleSourcePath
#            Write-Host Check it: $checkit  ($sourceBundleFullName)  ## Debug

            if (!$checkPath)
            {
                "Source folder ({0}) does not exist" -f $bundleSourcePath
                return
            }

            $bundles = Get-ChildItem -Path $bundleSourcePath -Filter "*.appxbundle"

            foreach($bundle in $bundles)
            {
                Write-Host "Unbundling $bundle to $destinationFolder"
                $args = $makeAppxBinaryArgTemplate.Replace("__bundle__", $bundleSourcePath+"\"+$bundle).Replace("__dest__", $destinationFolder + "\Universal")
                invoke-expression "$makeAppxBinary $args" | out-null
            }
    }
}


#
# Make a copy of the unbundles packages for use in multiple bundles
#
function Duplicate-UnbundledFolder($workingDir, $sourceSubfolder, $desinationSubfolders)
{
    $sourceFullPath = $workingDir + "\" + $sourceSubfolder
    $desinationSubfolders | foreach-object {
        "Duplicating $sourceFullPath to $workingDir\$_"
        Copy-Item -Path $sourceFullPath -Destination $workingDir\$_ -Recurse -Force
    }
}


#
# Remove unnecessary files from the folder which will ultimately be submitted
# to the INT environment.
#
# For the INT environment all of the language files are removed since they
# require meta-data in the Developer Portal, and we only use English.
#
function Clean-IntFiles($workingDir)
{
   "Removing the language files from $workingDir"
   $files = Get-ChildItem $workingDir | Where-Object {$_.Name -like '*language*'}
   $files | foreach-object {
        # $_.FullName                         ## Debug
        Remove-Item $_.FullName
    }
}


#
# Remove unnecessary files from the folder which will ultimately be checked
# in to Windows source tree for the mobile build.
#
# For mobile, the x64 and x86 packages are removed to save space in the build.
#
function Clean-x86Files($workingDir)
{
   "Removing non-essential packages from $workingDir"
   $files = Get-ChildItem $workingDir | Where-Object {$_.Name -like '*0_x64.appx' -or $_.Name -like "*0_ARM.appx"}
   $files | foreach-object {
        Write-Debug ("Removing $_.FullName")
        Remove-Item $_.FullName
    }
}


#
# Removes files which are not necessary for the ARM bundle.
#
function Clean-ARMFiles($workingDir)
{
   "Removing non-essential packages from $workingDir"
   $files = Get-ChildItem $workingDir | Where-Object {$_.Name -like '*0_x64.appx' -or $_.Name -like "*0_x86.appx"}
   $files | for-eachobject {
        Write-Debug ("Removing $_.FullName")
        Remove-Item $_.FullName
    }
}


#
# Removes files which are not necessary for the ARM bundle.
#
function Remove-ExtraFiles($workingDir, $bundleType)
{
   "Removing non-essential packages from $workingDir"
    Switch ($bundleType.ToLower()) {
        "x86" {
            $files = Get-ChildItem $workingDir | Where-Object {$_.Name -like '*0_x64.appx' -or $_.Name -like "*0_ARM.appx"}
            $files | foreach-object {
                Write-Debug ("Removing $_.FullName")
                Remove-Item $_.FullName
            }
        }
        "ARM" {
            $files = Get-ChildItem $workingDir | Where-Object {$_.Name -like '*0_x64.appx' -or $_.Name -like "*0_x86.appx"}
            $files | foreach-object {
                Write-Debug ("Removing $_.FullName")
                Remove-Item $_.FullName
            }
        }
        "INT" {
            $files = Get-ChildItem $workingDir | Where-Object {$_.Name -like '*language*'}
            $files | foreach-object {
                Write-Debug ("Removing $_")
                Remove-Item $_.FullName
            }
        }
        default {
            Write-Warning("$bundleType is not a recognized bundle type.  No files were removed.")    
        }
    } # End of switch block
}


#
# Use MakeAppX to rebundle the folders containing APPX packages into an 
# .AppXBundle file which will be submitted to the Developer Portal, and
# ultimately checked in to the Windows source tree as an FCIB.
#
# The $bundleTypes parameter is an array of 1-n types
# typically, INT, Desktop and Mobile for which a bundle will be created
# for each type.
#
function Create-StoreBundles($workingDir, $bundleVersion, $bundleTypes)
{
    $bundleNameTemplate = "Microsoft.WindowsStore_8wekyb3d8bbwe___bundleversion__.__buildbranch__.__bundletype__.appxbundle"
    $makeAppxBinaryArgTemplate = "bundle /v /o /d `"__folder__`" /p `"__bundlefile__`" /bv __bundleversion__"
    
    $versionParts = $bundleVersion.split(".")
    $priority = 4

    ForEach($bundleType in $bundleTypes)
    {
        $prioritizedVersionString = $versionParts[0] +"." + $versionParts[1] + "." + [string]$versionParts[2] + [string]$priority +".0"
        $bundleSourcePath = "$workingDir\$bundleType"
        $bundleFullName = "$workingDir\$bundleNameTemplate"
        $bundleFullName = $bundleFullName.Replace("__bundleversion__", $prioritizedVersionString)
        $bundleFullName = $bundleFullName.Replace("__buildbranch__", $branchPrefix)
        $bundleFullName = $bundleFullName.Replace("__bundletype__", $bundleType)

        "Bundling {0} from {1} (Version:{2})" -f $bundleSourcePath, $bundleFullName, $prioritizedVersionString
        $args = $makeAppxBinaryArgTemplate.Replace("__folder__", $bundleSourcePath).Replace("__bundlefile__", $bundleFullName).Replace("__bundleversion__", $prioritizedVersionString)
        invoke-expression "$makeAppxBinary $args" | out-null

        $priority--
    }
}


<#
    Main
#>

$alteredBundles = @("x86", "ARM", "INT")

Write-Host "Extracting bundle files from build $buildNumber ($branchPrefix) to $workingDir"

$unpaddedBuild, $paddedBuild, $zeroLeastSigDigitBuild, $packedBuild = Format-BuildNum($buildNumber)

$workingDir = Setup-Workspace $destinationFolder $unpaddedBuild $branchPrefix

Unbundle-StoreBundle $buildNumber $workingDir
#$workingDir = "C:\bundle_4" ## Debug
Duplicate-UnbundledFolder $workingDir "Universal" $alteredBundles

$alteredBundles | foreach-object {
    Remove-ExtraFiles "$workingDir\$_" $_
}

Create-StoreBundles $workingDir $packedBuild @("Universal", "x86", "ARM", "INT")
Write-Host "All done!  Bundle files are in $workingDir"