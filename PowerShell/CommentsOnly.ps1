<#

.SYNOPSIS

Retrieves service pack and operating system information from one or more remote computers.



.DESCRIPTION

The Get-Inventory function uses Windows Management Instrumentation (WMI) toretrieve service pack version, operating system build number, and BIOS serial number from one or more remote computers. 

Computer names or IP addresses are expected as pipeline input, or may bepassed to the –computerName parameter. 

Each computer is contacted sequentially, not in parallel.



.PARAMETER computerNameAccepts 

a single computer name or an array of computer names. You mayalso provide IP addresses.



.PARAMETER path

The path and file name of a text file. Any computers that cannot be reached will be logged to this file. 

This is an optional parameter; if it is notincluded, no log file will be generated.



.EXAMPLE

Read computer names from Active Directory and retrieve their inventory information.

Get-ADComputer –filter * | Select{Name="computerName";Expression={$_.Name}} | Get-Inventory.



.EXAMPLE 

Read computer names from a file (one name per line) and retrieve their inventory information

Get-Content c:\names.txt | Get-Inventory.



.NOTES

You need to run this function as a member of the Domain Admins group; doing so is the only way to ensure you have permission to query WMI from the remote computers.

#>
