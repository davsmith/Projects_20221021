<#
    .SYNOPSIS
    Used primarily to create the MyMapping.txt file for generating an AppXBundle for checking in
    to the Windows code base, as well as ingestion by DSE.

    .DESCRIPTION
    The created bundle is checked in to Windows as an FCIB, not source code.
    
    .PARAMETER FileSpec
    The extension for files to be listed.  Defaults to .appx

    .PARAMETER OutFile
    The absolute path of the destination file to be created.  Default: c:\temp\mymapping.txt

    .NOTES
    Dave Smith
    11/22/2014
#>
param([string]$outFile="c:\temp\MyMapping.txt", [string]$fileSpec=".appx")

$delim = "::"

"Filespec: " + $filespec
"[Files]" | Out-File -FilePath $outfile
$files = dir -Filter ("*" + $filespec)
$files | ForEach-Object {
    $file = $_.PSChildName
    $parentpath = $_.PSParentPath.Substring($_.PSParentPath.IndexOf($delim)+$delim.Length);
    $fullfile =  "`"" + $parentpath + "\" + $file +"`""
    $fullfile + " `"" + $file + "`"" | Out-File -FilePath $outfile -Append
    $fullfile
}
