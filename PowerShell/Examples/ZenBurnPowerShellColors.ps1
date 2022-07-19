# ZenburnPowerShell.psm1 by Adam Boddington
# http://stackingcode.com/blog/2011/11/14/zenburn-powershell
# Zenburn by Jani Nurminen
# http://slinky.imukuppi.org/zenburnpage

function New-ZenburnPowerShell {
    param (
        [string]$Name = $(throw "Name required.")
    )
    $shortcutPath = Join-Path $home "Desktop\$Name.lnk"
    $registryItemPath = Join-Path HKCU:\Console $Name

    # Remove existing shortcut and registry item.
    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath
    }
    if (Test-Path $registryItemPath) {
        Remove-Item $registryItemPath
    }

    # Create new shortcut and registry item.
    New-Shortcut $shortcutPath
    New-RegistryItem $registryItemPath

    # Remember the registry item path.
    if (-not $script:registryItemPaths) {
        $script:registryItemPaths = @()
    }
    $script:registryItemPaths += $registryItemPath

    # Instructions for the final steps.
    "Change properties on `"$Name`" to internalise the registry values."
    "Then call Reset-Registry to perform the final cleanup."
}


function Reset-Registry {
    foreach ($registryItemPath in $script:registryItemPaths) {
        if (Test-Path $registryItemPath) {
            Remove-Item $registryItemPath
            "Removed `"$registryItemPath`""
        }
    }
}


function New-Shortcut {
    param (
        [string]$Path
    )
    $ws = New-Object -ComObject wscript.shell
    $shortcut = $ws.CreateShortcut($Path)
    $shortcut.TargetPath = Join-Path $Env:windir System32\WindowsPowerShell\v1.0\powershell.exe
    $shortcut.WorkingDirectory = "%HOMEDRIVE%%HOMEPATH%"
    $shortcut.Save()
    "Created `"$Path`""
}


function New-RegistryItem {
    param (
        [string]$Path
    )
    $x = New-Item $Path
    # http://twinside.free.fr/dotProject/?p=125
    $colors = @(
        0x003f3f3f, 0x00af6464, 0x00008000, 0x00808000,
        0x00232333, 0x00aa50aa, 0x0000dcdc, 0x00ccdcdc,
        0x008080c0, 0x00ffafaf, 0x007f9f7f, 0x00d3d08c,
        0x007071e3, 0x00c880c8, 0x00afdff0, 0x00ffffff
    )

    for ($index = 0; $index -lt $colors.Length; $index++) {
        $x = New-ItemProperty $Path -Name ("ColorTable" + $index.ToString("00")) -PropertyType DWORD -Value $colors[$index]
    }

    "Created `"$Path`""
}


# Export-ModuleMember New-ZenburnPowerShell, Reset-Registry