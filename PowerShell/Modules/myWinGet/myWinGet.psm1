Import-Module "$PSScriptRoot\..\myUtils"

function Get-WinGetList {
    (winget.exe list) -match '^\p{L}' | ConvertFrom-FixedColumnTable
}

function Test-IsWinGetPackageInstalled {
    param (
        [Parameter(Mandatory)]
        [String] $PackageId
    )
    [Boolean](Get-WinGetList | Where-Object -Property Id -EQ $PackageId)
}

function Install-WinGetPackage {
    param (
        [Parameter(Mandatory, Position = 0)]
        [String] $Id,
        [Parameter()]
        [ValidateSet('Machine', 'User')]
        [String] $Scope,
        [Parameter()]
        [ValidateSet('WinGet', 'MSStore')]
        [String] $Source,
        [Parameter()]
        [String] $Location
    )

    $CommandArray = @('winget')

    if (!(Test-IsWinGetPackageInstalled $Id)) {
        $CommandArray = $($CommandArray; 'install')
    }
    else {
        $CommandArray = $($CommandArray; 'update')
    }

    if ($Scope) {
      $CommandArray = $($CommandArray; @('--scope', $Scope.ToLower()))
    }
    if ($Source) {
      $CommandArray = $($CommandArray; @('--source', $Source.ToLower()))
    }

    if ($Source -eq 'MSStore') {
        $CommandArray = $($CommandArray; '--accept-package-agreements')
    }

    $CommandArray = $($CommandArray; @('--exact', '--id', $Id))

    if (![String]::IsNullOrEmpty($Location)) {
        $CommandArray = $($CommandArray; @('--location', "'$Location'"))
    }

    $InstallerConfig = "$PSScriptRoot\Config\$Id"
    if (Test-Path "$InstallerConfig.inf") {
        $CommandArray = $($CommandArray; @('--custom', "/LOADINF=`"$InstallerConfig.inf`""))
    }
    elseif (Test-Path "$InstallerConfig.txt") {
        $CommandArray = $($CommandArray; @('---custom', "'$((Get-Content "$InstallerConfig.txt"))'"))
    }

    $Command = $CommandArray -join ' '
    Write-Host $Command -ForegroundColor DarkGray
    Invoke-Expression $Command
}

function Uninstall-WinGetPackage {
    param (
        [Parameter(Mandatory)]
        [String] $Id
    )
    $Command = "winget.exe uninstall --exact --id $Id"
    Write-Host $Command -ForegroundColor DarkGray
    Invoke-Expression $Command
}
