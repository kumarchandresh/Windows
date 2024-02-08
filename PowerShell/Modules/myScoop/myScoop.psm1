Import-Module "$PSScriptRoot\..\myUtils"

function Test-IsScoopPackageInstalled {
    param (
        [Parameter(Mandatory)]
        [String] $PackageName
    )
    if (!(Test-IsCommandAvailable scoop)) {
        Write-Error 'Requires "Scoop" package manager; visit https://scoop.sh/'
    }
    [Boolean](scoop list | Where-Object -Property Name -EQ $PackageName)
}

function Install-ScoopPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Name,
        [Parameter()]
        [Switch] $Global
    )
    $CommandArray = @('scoop')
    $PackageName = $Name -split '\/' | Select-Object -Last 1

    if (!(Test-IsScoopPackageInstalled $PackageName)) {
        $CommandArray = $($CommandArray; 'install')
    }
    else {
        $CommandArray = $($CommandArray; 'update')
    }

    if ($Global) {
        $CommandArray = $($CommandArray; '--global')
    }

    $CommandArray = $($CommandArray; $Name)
    $Command = $CommandArray -join ' '
    Write-Host $Command -ForegroundColor DarkGray
    Invoke-Expression $Command
}
