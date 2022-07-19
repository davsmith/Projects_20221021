<#
    PowerShell cookbook
#>

function MessageBox([string]$message, [string]$title="Warning")
{
    $oShell = New-Object -comobject WScript.Shell

    $ret= $oShell.popup($message, 0, $title, 0+48)
}
