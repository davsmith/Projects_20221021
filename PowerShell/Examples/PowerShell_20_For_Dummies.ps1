<#
    Examples and snippets from the Windows PowerShell 2 For Dummies book





#>





<# --- Chapter 18 --- #>
function WarningPopup([string]$message)
{
    $oShell = New-Object -comobject WScript.Shell

    $ret= $oShell.popup($message, 0, "Warning", 0+48)
}

Function CheckDrives()
{
    $free_spacethreshold = 5
    Write-Host "Performing disk space check..."
    Write-Host "Looking for disks with less than $free_spacethreshold free space"

    $drives = [System.IO.DriveInfo]::GetDrives()

    foreach ($drive in $drives)
    {
        if (($drive.DriveType -eq "Fixed") -and ($drive.IsReady -eq $true))
        {
            $freespace = [Math]::Round(($drive.TotalFreeSpace / $drive.TotalSize) * 100,2)
            if ($freespace -lt $free_spacethreshold)
            {
                WarningPopup "$drive.Name - $freespace % free space"
            }
        }
    }
}