<#
    Derived from script in Scripting Guy blog:
    http://blogs.technet.com/b/heyscriptingguy/archive/2010/08/28/change-colors-used-by-the-windows-powershell-ise.aspx

    Created 5/30/2015
#>

function List-EnvironmentColors()
{
    [windows.media.colors] | Get-Member -Static -MemberType property
}

#
# Script to display all available background colors in PowerShell ISE
#
function Cycle-EnvironmentColors()
{
    $initialColor = $psISE.Options.ConsolePaneTextBackgroundColor

    [windows.media.colors] | Get-Member -Static -MemberType property |  
        ForEach-Object {  
        $psISE.Options.ConsolePaneTextBackgroundColor = ` 
        ([windows.media.colors]::$($_.name)).tostring()  
        "$($_.name) `t $([windows.media.colors]::$($_.name))"
    }  

    $psISE.Options.ConsolePaneTextBackgroundColor = $initialColor
}


#
# Sets colors of the PowerShell ISE environment
#
# Colors can be named colors, or ARGB (e.g. #FFFF00FF)
#
function Set-ISEColors()
{
    $psISE.Options.TokenColors.item("member")='green'
    $psISE.Options.ConsolePaneBackgroundColor="darkblue"
    $psISE.Options.ConsolePaneTextBackgroundColor="darkblue"
    $psISE.Options.ConsolePaneForegroundColor="white"
}