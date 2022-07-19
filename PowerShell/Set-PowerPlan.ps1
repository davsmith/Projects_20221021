#requires -version 2.0
 
# (c) 2012 by John Robbins\Wintellect
 
<#.SYNOPSIS
Sets the current power plan.
.DESCRIPTION
The POWERCFG.EXE utility requires GUIDS when changing a power plan instead of
the name of the plan. That's highly inconvenient so this simple script allows 
you to use common sense names like "Balanced" or "Power Saver" instead.
 
To get the list of power plans on your computer execute 'powercfg -l'
.PARAMETER Plan
The name of the power plan to use.
.EXAMPLE 
Set-PowerPlan -Plan Balanced
Sets the power plan to the Balanced plan, the recommnded Microsoft plan.
.EXAMPLE 
Set-PowerPlan "Power Saver"
Sets the power plan to the Power Saver plan to reduce battery usage.
.LINK
http://www.wintellect.com/CS/blogs/jrobbins/archive/tags/PowerShell/default.aspx
#>
 
param ($Plan = $(throw 'You must specify the power plan, use "powercfg -l" for the plan names' ))
 
Set-StrictMode -Version Latest
 
# Get the list of plans on the current machine.
$planList = powercfg.exe -l
 
# The regular expression to pull out the GUID for the specified plan.
$planRegEx = "(?<PlanGUID>[A-Fa-f0-9]{8}-(?:[A-Fa-f0-9]{4}\-){3}[A-Fa-f0-9]{12})" + ("(?:\s+\({0}\))" -f $Plan)
 
# If the plan appears in the list...
if ( ($planList | Out-String) -match $planRegEx )
{
    # Pull out the matching GUID and capture both stdout and stderr.
    $result = powercfg -s $matches["PlanGUID"] 2>&1
    
    # If there were any problems, show the error.
    if ( $LASTEXITCODE -ne 0)
    {
        $result
    }
}
else
{
    Write-Error ("The requested power scheme '{0}' does not exist on this machine" -f $Plan) 
}
