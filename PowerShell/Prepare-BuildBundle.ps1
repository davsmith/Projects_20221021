<#
    .SYNOPSIS
    Generates the files for an APPXBundle from a Store build.

    .DESCRIPTION
    Extracts, creates, and arranges files from the Store daily build,
    such that MakeAPPX bunde can be used to create the bundle file
    checked in to the Windows build.

    The created bundle is checked in to Windows as an FCIB, not source code.
    
    .PARAMETER destFolderName
    The working directory where output files are stored

    .PARAMETER buildNum
    The build from which APPX files are extracted. (e.g. 2014.11.25.1)

    .EXAMPLE
    Prepare-BuildBundle C:\Bundle 2014.11.25.1
    Extracts and arranges the relevant files from build 2014.11.25.1,
    placing them in c:\bundle.

    .NOTES
    Original file crated by Dave Smith (davsmith) 11/22/2014
#>
param([string]$destFolderName="c:\Bundle", [string]$buildNum="")


<# Global variables #>
$srcExtension = "appx"
$releaseDirectoryName = "\\wsclientux\release\Daily SFUI Rel\"
$releasePrefix = "Daily SFUI Rel_"
$architectures = "x64", "x86"

<# Temporary variable values for debugging #>
#$releaseDirectoryName = "\\nazgul\content\temp\Daily SFUI Rel\"
#$destFolderName = "C:\Bundle"
$buildNum = "2014.12.08.1"
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
    while (Test-Path(($workingDir+$index))){
        $index += 1
    }

    if (Test-Path($workingDir)) {
        $createDir = $workingDir + $index
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
# Retrieves the files from the build share and puts them in the working directory.
# Since the files are .APPX files (which are actually ZIP files), the files
# are copied locally, and a Shell.Namespace object is used to expand them.
#
function Format-BuildNum($buildNum, [REF]$padded, [REF]$unpadded) {
    $buildParts = @($buildNum.split("."))
    if ($buildParts.Count -ne 4) {
        Write-Error ("Invalid build number specified (" + $buildNum + ")  Format: yyyy.mm.dd.increment")
        return
    }  

    if (($buildParts[0].Substring(0,3) -ne "201") -or ($buildParts[1].Length > 2) -or ($buildParts[2].Length > 2)) {
        Write-Error ("Invalid build number specified (" + $buildNum + ")  Format: yyyy.mm.dd.increment")
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

    $unpaddedBuild
    $paddedBuild
}


function Gather-Files($buildNum, $destFolderName) {
    $unpaddedBuild, $paddedBuild = Format-BuildNum($buildNum)
    
    $shell = new-object -com shell.application
    $destFolder = $shell.NameSpace($destFolderName)

    $srcFolderNameBase = $releaseDirectoryName + $releasePrefix + $paddedBuild + "\Release\"

    $architectures.ForEach({
            $srcBundleDirName = $srcFolderNameBase + $_ +"\WinStore.Desktop\AppPackages\WinStore.Desktop_"+$unpaddedBuild+"_Test\"
            $srcBundleName = $srcBundleDirName + "WinStore.Desktop_"+$unpaddedBuild+"_"+$_+".appxbundle"
            $srcBundleDir = $shell.NameSpace($srcBundleDirName)

            #$checkit = Test-Path $srcBundleDirName
            Write-Host Check it: $checkit  ($srcBundleDirName)

            if (!$srcBundleDir) {
                "Source folder ({0}) does not exist" -f $srcBundleDirName
                return
            }

            foreach($item in $srcBundleDir.items() | where {$_.type -eq "APPXBUNDLE File"}) {
                "Copying {0}" -f $item.Name
                 $shell.Namespace($destFolder).copyhere($item, 0x14)
            }

            foreach($item in $destFolder.items() | where {$_.type -eq "APPXBUNDLE File"}){
                "Renaming {0}" -f $item.Name
                $basename = $item.Name.replace(".appxbundle",".zip")
                rename-item $item.Path $basename
            }
    })
}


function Extract-ZipFiles($buildNum, $workingDir) {
    $unpaddedBuild, $paddedBuild = Format-BuildNum($buildNum)

    $zipFileBase = $workingDir + "\WinStore.Desktop_" + $unpaddedBuild + "_"

    $architectures.ForEach({
        $zipFile = $zipFileBase + $_ + ".zip"
        Extract-ZipFile $zipFile ""
    })
}


#
# The AppXBundle manifest is an XML file, and one exists for each architecture.
# Since only one is required to generate the bundle, a root manifest is chosen (from the first architecture),
# and the architecture specific sections are copied from the other manifests to the root manifest file.
#
function Make-AppXBundleManifest( $buildnum, $workingFolder )
{
    $xmlDocs = @()
    $unpaddedBuild, $paddedBuild = Format-BuildNum($buildNum)


    # Store the APPXBundle manifest for each architecture in an array
    # BUGBUG:  Need to add error checking.
    $architectures.ForEach({
        $xmlFile = $workingFolder + "\WinStore.Desktop_"+$unpaddedBuild+"_"+$_+"\AppxMetadata\AppxBundleManifest.xml"
        $xmlDoc = New-Object XML
        $xmlDoc.Load($xmlFile)

        if (!$xmlBaseBundle) {
            $xmlBaseBundle = $xmlDoc
            $xmlBaseFile = $xmlFile
        }
        else {
            $packages = $xmlDoc.Bundle.Packages
            $arch = $_
            [array]$appData = $packages.Package | Where-Object {$_.Architecture -eq $arch}
            $newPackage = $appData[0].Clone()
            $newNode = $xmlBaseBundle.ImportNode($newPackage, $true)
            $xmlBaseBundle.Bundle.Packages.AppendChild($newNode) | Out-Null
        }
    })

    $xmlBaseBundle.Save($xmlBaseFile)

}


#
# Move the relevant files from each of the ZIP directories to the root
# of the working directory
#
function Rearrange-Files($buildNum, $workingFolder) {
    $unpaddedBuild, $paddedBuild = Format-BuildNum($buildNum)


    $architectures.ForEach( {
        $fullBuildName = "WinStore.Desktop_"+$unpaddedBuild+"_"+$_

        if (!$baseDir) {
            # Copy all files from this architecture folder up one level
            $baseDir = $workingFolder
            $from = $workingFolder+"\"+ $fullBuildName +"\*"
            Copy-item -Path $from -Recurse -Destination $workingFolder -Force
        }
        else {
            # Copy the APPX file for this architecture up one level
            $from = $workingFolder+"\"+$fullBuildName+"\"+$fullBuildName+".appx"
            Copy-item -Path $from -Recurse -Destination $workingFolder -Force
        }
    })
}


#
# Get rid of the ZIP files we copied down, and the expanded directories
#
function Cleanup-Files($buildNum, $workingDir) {
    $unpaddedBuild, $paddedBuild = Format-BuildNum($buildNum)

    $architectures.ForEach( {
        $fullBuildName = "WinStore.Desktop_"+$unpaddedBuild+"_"+$_
        Remove-Item ($workingDir + "\" + $fullBuildName+"\") -recurse
        Remove-Item ($workingDir + "\" + $fullBuildName+".zip") -recurse
    })
}


#
# Helper function to extract a specified ZIP file to 
# a destination directory.
#
function Extract-ZipFile($zipFilename, $destFolderName)
 {
    if ($destFolderName -eq "")
    {
        $destFolderName = $zipFilename.replace(".zip","")
    }

    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($zipFilename)
    $destFolder = $shell.NameSpace($destFolderName)
     
    if (!$zip)
    {
        Write-Host("Couldn't open file "+$zipFilename)
        return;
    }

    if (!$destFolder) {
        "Creating folder {0}." -f $destFolderName
        New-Item $destFolderName -type directory | Out-Null
        $destFolder = $shell.NameSpace($destFolderName)
        if (!$destFolder) {
            "Couldn't create directory {0}.  Exiting." -f $destFolderName
            return
        }
    }


     foreach($item in $zip.items())
     {
         $shell.Namespace($destFolder).copyhere($item)
     }
 }


#
# Creates a text file used in the MakeAPPX bundle call.
#
function Generate-MappingFile($workingDir="", $filespec=".appx") {
    
    if ($workingDir -eq "") {
        Write-Host("No working directory was specified.")
        return;
    }
    
    $delim = "::"
    $outfile = $workingDir+"\mapping.txt"

    "[Files]" | Out-File -FilePath $outfile
    $files = dir -Path $workingDir -Filter ("*" + $filespec)
    $files | ForEach-Object {
        $file = $_.PSChildName
        $parentpath = $_.PSParentPath.Substring($_.PSParentPath.IndexOf($delim)+$delim.Length);
        $fullfile =  "`"" + $parentpath + "\" + $file +"`""
        $fullfile + " `"" + $file + "`"" | Out-File -FilePath $outfile -Append
        # $fullfile
    }
}


<#
    Main
#>

$workingDir = Setup-Workspace $destFolderName

Write-Host Generating bundle files from build $buildNum to $workingDir

Gather-Files $buildNum $workingDir
Extract-ZipFiles $buildNum $workingDir
Make-AppXBundleManifest $buildNum $workingDir
Rearrange-Files $buildNum $workingDir
Cleanup-Files $buildNum $workingDir
Generate-MappingFile $workingDir
Write-Host "All done!  Bundle files are in" $workingDir