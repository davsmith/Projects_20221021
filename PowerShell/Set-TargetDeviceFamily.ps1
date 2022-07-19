<#
    .SYNOPSIS
    Resets the TargetDeviceFamily element for all APPX files in a Store bundle.

    .DESCRIPTION
    Unbundles a Store UAP .appxbundle, then unpacks all APPX files within the
    bundle, and modifies the TargetDeviceFamily element in each AppXManifest
    file.
    
    .PARAMETER destFolderName
    The working directory where output files are stored

    .PARAMETER buildNum
    The build from which APPX files are extracted. (e.g. 2014.11.25.1)

    .EXAMPLE
    Set-TargetDeviceFamily C:\Bundle 2014.11.25.1
    Sets the TargetDeviceFamily element for all packages in build 2014.11.25.1,
    placing them in c:\bundle.

    .NOTES
    Original file crated by Dave Smith (davsmith) 5/5/2015
#>
param([string]$destFolderName="c:\Bundle", [string]$buildNum="", [string]$newTargetDeviceFamily="Windows.Desktop")


<# Global variables #>
$srcExtension = "appx"
$releaseDirectoryName = "\\wsclientux\release\Daily SFUI Rel\"
$releasePrefix = "Daily SFUI Rel_"
$architectures = "x64", "x86", "ARM"
$currentTargetDeviceFamily = "Windows.Universal"
$makeappx = "\\redmond\win\users\davsmith\MakeAppX\makeappx.exe"

<# Temporary variable values for debugging #>
#$releaseDirectoryName = "\\nazgul\content\temp\Daily SFUI Rel\"
#$destFolderName = "C:\Bundle"
$buildNum = "2015.5.29.1"
#$fullBuildPath = "\\wsclientux\release\Daily SFUI Rel\Daily SFUI Rel_2014.11.25.1\Release\x64\WinStore.Desktop\AppPackages\WinStore.Desktop_2014.11.25.1_Test\WinStore.Desktop_2014.11.25.1_x64.appxbundle"

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
function Setup-Workspace($workingDir) {
    $index = 2
    while (Test-Path(($workingDir+"_"+$index))){
        $index += 1
    }

    if (Test-Path($workingDir)) {
        $createDir = $workingDir + "_" + $index
    }
    else {
        $createDir = $workingDir
    }

    Write-Host("Creating folder {0}" -f $createDir)
    New-Item $createDir -type directory | Out-Null
    
    if (Test-Path($createDir)) {
        $retVal = $createDir
    }
    else
    {
        $retVal = ""
    }

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
function Format-BuildNum($buildNum) {
    $buildParts = @($buildNum.split("."))
    if ($buildParts.Count -ne 4) {
        Write-Error ("Invalid build number specified (" + $buildNum + ")  Format: yyyy.mm.dd.increment")
        return
    }  

    # The first part of the build number must be the year, followed by up to two digits for month,
    # up to two digits for date, and an incremental build number.
    if (($buildParts[0].Substring(0,3) -ne "201") -or ($buildParts[1].Length -gt 2) -or ($buildParts[2].Length -gt 2)) {
        Write-Host ("Invalid build number specified (" + $buildNum + ")  Format: yyyy.mm.dd.increment")
        return    
    }

    if ($buildParts[1].Length -eq 1) {
        $buildParts[1] = "0" + $buildParts[1]
    }

    if ($buildParts[2].Length -eq 1) {
        $buildParts[2] = "0" + $buildParts[2]
    }

    $unpaddedBuild = $buildNum.Replace(".0",".")
    $paddedBuild = $buildParts[0] + "." + $buildParts[1] + "." + $buildParts[2] + "." + $buildParts[3]
    $zeroLeastSigDigit = $unpaddedBuild.Replace("." + $buildParts[3], ".0")
    $packedBuild = $buildParts[0] + "." + $buildParts[1] + $buildParts[2] + "." + $buildParts[3] + ".0"
    # $packedBuild = $packedBuild.Replace($buildParts[0]+".0", $buildParts[0]+".")  # Removes the padded 0 on date digits.  This may not be necessary.

    $unpaddedBuild
    $paddedBuild
    $zeroLeastSigDigit
    $packedBuild
}


function Unbundle-StoreBundle($buildNum, $destFolderName)
{
    "Unbundle-StoreBundle {0} {1}" -f $buildNum, $destFolderName

    $unpaddedBuild, $paddedBuild, $zeroLeastSigDigitBuild, $packedBuild = Format-BuildNum($buildNum)
    
    $makeAppxArgTemplate = "unbundle /o /v /kt /p `"__bundle__`" /d `"__dest__`""

    $srcFolderNameBase = $releaseDirectoryName + $releasePrefix + $paddedBuild + "\Release\"
    # "Source folder base name: {0}" -f $srcFolderNameBase
    ForEach($arch in $architectures)
    {
            $srcBundleDirName = $srcFolderNameBase + $arch +"\WinStore.Mobile\AppPackages\WinStore.Mobile_" + $zeroLeastSigDigitBuild +"_Test"
            
            "Source bundle dir name: {0}" -f $srcBundleDirName
            
            $srcBundleName = $srcBundleDirName + "WinStore.Mobile_" + $zeroLeastSigDigitBuild + "_" + $arch + ".appxbundle"
            "Source bundle name: {0}" -f $srcBundleName
            
            $checkPath = Test-Path $srcBundleDirName
#            Write-Host Check it: $checkit  ($srcBundleName)

            if (!$checkPath)
            {
                # "Source folder ({0}) does not exist" -f $srcBundleDirName
                return
            }

            $bundles = Get-ChildItem -Path $srcBundleDirName -Filter "*.appxbundle"

            foreach($bundle in $bundles)
            {
                "Unbundling {0}" -f $bundle.Name
                $args = $makeAppxArgTemplate.Replace("__bundle__", $srcBundleDirName+"\"+$bundle).Replace("__dest__", $destFolderName + "\unbundle")
                invoke-expression "$makeappx $args" | out-null
            }
    }
}


function Unpack-StorePackages($workingDirName)
{
    $makeAppxArgTemplate = "unpack /o /v /l /p `"__package__`" /d `"__dest__`""

    $packages = Get-ChildItem -Path "$workingDirName\unbundle" -Filter "*.appx"

    ForEach($package in $packages)
    {
        "Unpacking {0}" -f $package.Name
        $args = $makeAppxArgTemplate.Replace("__package__", $workingDirName+"\unbundle\"+$package).Replace("__dest__", $workingDirName + "\unpack\" + $package.Name)
        invoke-expression "$makeappx $args" | out-null
    }
}


function Replace-TargetDeviceFamily($workingDirName, $strCurrentDeviceFamily, $strNewDeviceFamily)
{
    # $workingDirName = "C:\20150430_26"
    $unpackDirName = "$workingDirName\unpack"

    $packageFolders = Get-ChildItem -Path $unpackDirName -Filter "*.appx"
    #Write-Host Check it: $packageFolders

    ForEach($package in $packageFolders)
    {
        $manifest = "$unpackDirName\$package\AppxManifest.xml"
        $manifest_out = $manifest + "_"
        $checkPath = Test-Path $manifest -PathType Leaf
        if (!$checkPath)
        {
            "Manifest file does not exist for {0}" -f $package
            return
        }

        "Modifying manifest for {0}" -f $package.Name
        $content = Get-Content $manifest
        Set-Content $manifest $content.Replace($strCurrentDeviceFamily, $strNewDeviceFamily)
    }
}


function Pack-StorePackages($workingDirName)
{
    # $workingDirName = "C:\20150430_5"
    $makeAppxArgTemplate = "pack /l /v /o /h SHA256 /d `"__folder__`" /p `"__appxfile__`""

    $packages = Get-ChildItem -Path "$workingDirName\unpack" -Filter "*.appx"

    ForEach($package in $packages)
    {
        "Packing {0}" -f $package.Name
        $args = $makeAppxArgTemplate.Replace("__folder__", $workingDirName+"\unpack\"+$package).Replace("__appxfile__", $workingDirName + "\unbundle\" + $package.Name)
        invoke-expression "$makeappx $args" | out-null
        #$args
    }
}


function Bundle-StoreBundle($workingDirName, $bundleVersion)
{
    $makeAppxArgTemplate = "bundle /v /o /d `"__folder__`" /p `"__bundlefile__`" /bv $bundleVersion"

    $bundle_folder = "$workingDirName\unbundle"
    $bundle_file = "$workingDirName\Microsoft.WindowsStore.appxbundle"

    "Bundling {0} from {1} with bundle version {2}" -f $bundle_file.Name, $bundle_folder, $bundleVersion
    $args = $makeAppxArgTemplate.Replace("__folder__", $bundle_folder).Replace("__bundlefile__", $bundle_file)
    invoke-expression "$makeappx $args" | out-null
}


<#
    Main
#>

$workingDir = Setup-Workspace $destFolderName

Write-Host Generating bundle files from build $buildNum to $workingDir

$unpaddedBuild, $paddedBuild, $zeroLeastSigDigitBuild, $packedBuild = Format-BuildNum($buildNum)

Unbundle-StoreBundle $buildNum $workingDir
Unpack-StorePackages $workingDir
Replace-TargetDeviceFamily $workingDir "Windows.Universal" "Windows.Desktop"
Pack-StorePackages $workingDir
Bundle-StoreBundle $workingDir $packedBuild
#Cleanup-Files $buildNum $workingDir
"All done!  Bundle files are in {0}" -f $workingDir