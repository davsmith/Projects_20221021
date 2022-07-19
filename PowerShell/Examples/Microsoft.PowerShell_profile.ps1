Function Set-PsConsole 
{ 
    Set-Location -Path c:\ 
    $host.ui.RawUI.ForegroundColor = "black" 
    $host.ui.RawUI.BackgroundColor = "gray" 
    $buffer = $host.ui.RawUI.BufferSize 
    $buffer.width = 85 
    $buffer.height = 3000 
    $host.UI.RawUI.Set_BufferSize($buffer) 
    $maxWS = $host.UI.RawUI.Get_MaxWindowSize() 
    $ws = $host.ui.RawUI.WindowSize 
    IF($maxws.width -ge 85) 
    { $ws.width = 85 } 
    ELSE { $ws.height = $maxws.height } 
    IF($maxws.height -ge 42) 
    { $ws.height = 42 } 
    ELSE { $ws.height = $maxws.height } 
    $host.ui.RawUI.Set_WindowSize($ws) 
    $host.PrivateData.ErrorBackgroundColor = "white" 
    $Host.PrivateData.WarningBackgroundColor = "white" 
    $Host.PrivateData.VerboseBackgroundColor = "white" 
    $host.PrivateData.ErrorForegroundColor = "red" 
    $host.PrivateData.WarningForegroundColor = "DarkGreen" 
    $host.PrivateData.VerboseForegroundColor = "DarkBlue" 
} #end function Set-PsConsole

# *** Entry point ***
Set-PsConsole