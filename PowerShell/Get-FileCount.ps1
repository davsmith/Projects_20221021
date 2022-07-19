<#
.SYNOPSIS
    Gets a count of files in a folder
.DESCRIPTION
    This script uses shell.application to get the folder contents then uses
    the .count property to work out how many files there are.    
.NOTES
    File Name  : Get-FileCount.ps1
    Author     : Thomas Lee - tfl@psp.co.uk
    Requires   : PowerShell V2
.HISTORY
    First published : 23.12.08
    Updated         : 8.8.2009 - validated for Verstion 2.
                               - added link references    
.LINK
    This script posted to: 
       http://pshscripts.blogspot.com/2008/12/get-filecountps1.html
    MSDN Sample Posted to:
        http://msdn.microsoft.com/en-us/library/bb774085(VS.85).aspx
.EXAMPLE
    PS D:\Users\tfl> .\Get-FileCount.PS1'
    Folder "c:\Foo" contains 46 files
    Folder "c:\Foo" contains 29 PS1 files    
#>

##
# Start Script
##

# First get shell object
$Shell = new-object -com Shell.Application

# Now get folder details and item counts for a folder
$foldername = "c:\Foo"
$folder = $shell.namespace($foldername)
if (!$folder) {
"Folder: {0} does not exist" -f $foldername
return
}

# Now output the count of folders
if ($folder) { 
 $folderitems = $folder.items() 
 $count = $folderitems.count 

 $folderps1items = $folderitems | where {$_.type -eq "PS1 File"}
 $countps1items=$folderps1items.count

 "Folder `"{0}`" contains {1} files"     -f $foldername, $count
 "Folder `"{0}`" contains {1} PS1 files" -f $foldername, $countps1items
 }
 # End of Script