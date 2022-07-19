if ($args.Length -eq 0) {
    $filespec = ".appx"
}
else {
    $filespec = $args[0]
}

$outfile = "c:\temp\MyMapping.txt"
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
