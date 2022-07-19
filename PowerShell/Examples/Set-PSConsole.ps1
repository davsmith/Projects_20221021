#
# From the Scripting Guy blog at:
#  http://blogs.technet.com/b/heyscriptingguy/archive/2011/12/17/customize-the-powershell-console-for-increased-efficiency.aspx
#
Function Set-PsConsole 
{ 
    Set-Location -Path c:\ 
    $host.ui.RawUI.ForegroundColor = "black" 
    $host.ui.RawUI.BackgroundColor = "gray" 

    if ($host.UI.RawUI.MaxWindowSize -ne $null)
    {
        $maxWS = $host.UI.RawUI.Get_MaxWindowSize() 
        $ws = $host.ui.RawUI.WindowSize 
        if ($maxws.width -ge 85) { $ws.width = 85 } 
            else { $ws.height = $maxws.height } 
        if ($maxws.height -ge 42) { $ws.height = 42 } 
            else { $ws.height = $maxws.height } 
        $host.ui.RawUI.Set_WindowSize($ws) 

        $buffer = $host.ui.RawUI.BufferSize 
        $buffer.width = 85 
        $buffer.height = 3000 
        $host.UI.RawUI.Set_BufferSize($buffer) 
    }

    $host.PrivateData.ErrorBackgroundColor = "white" 
    $host.PrivateData.ErrorForegroundColor = "red" 
    $Host.PrivateData.WarningBackgroundColor = "white" 
    $host.PrivateData.WarningForegroundColor = "DarkGreen" 
    $Host.PrivateData.VerboseBackgroundColor = "white" 
    $host.PrivateData.VerboseForegroundColor = "DarkBlue" 
} #end function Set-PsConsole
Write-Host "Running Set-PsConsole"
Set-PsConsole