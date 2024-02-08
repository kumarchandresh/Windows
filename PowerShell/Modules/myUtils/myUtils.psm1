function Test-IsCommandAvailable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Command
    )
    [Boolean](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-IsProcessElevated {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = [Security.Principal.WindowsPrincipal]$Identity
    $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsSymbolicLink {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )
    [Boolean]((Get-ItemProperty $Path).LinkType)
}

function Test-IsDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )
    Test-Path -Path $Path -PathType Container
}

function Test-IsFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )
    Test-Path -Path $Path -PathType Leaf
}

function Restore-EnvPath {
    $env:Path = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User')
    ) -join ';'
}

function Get-EncodedCommand {
    param (
        [Parameter(Mandatory)]
        [String] $Command
    )
    [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Command))
}

# https://stackoverflow.com/a/74297741
function ConvertFrom-FixedColumnTable {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [String] $InputObject
    )

    begin {
        Set-StrictMode -Version 1
        $lineNdx = 0
    }

    process {

        $lines =
        if ($InputObject.Contains("`n")) { $InputObject -split '\r?\n' }
        else { $InputObject }
        foreach ($line in $lines) {
            ++$lineNdx
            if ($lineNdx -eq 1) {
                # header line
                $headerLine = $line
                # Get the indices where the fields start.
                $fieldStartIndices = [regex]::Matches($headerLine, '\b\S').Index
                # Calculate the field lengths.
                $fieldLengths = foreach ($i in 1..($fieldStartIndices.Count - 1)) {
                    $fieldStartIndices[$i] - $fieldStartIndices[$i - 1] - 1
                }
                # Get the column names
                $colNames = foreach ($i in 0..($fieldStartIndices.Count - 1)) {
                    if ($i -eq $fieldStartIndices.Count - 1) {
                        $headerLine.Substring($fieldStartIndices[$i]).Trim()
                    }
                    else {
                        $headerLine.Substring($fieldStartIndices[$i], $fieldLengths[$i]).Trim()
                    }
                }
            }
            else {
                # data line
                $oht = [ordered] @{} # ordered helper hashtable for object constructions.
                $i = 0
                foreach ($colName in $colNames) {
                    $oht[$colName] =
                    if ($fieldStartIndices[$i] -lt $line.Length) {
                        if ($fieldLengths[$i] -and $fieldStartIndices[$i] + $fieldLengths[$i] -le $line.Length) {
                            $line.Substring($fieldStartIndices[$i], $fieldLengths[$i]).Trim()
                        }
                        else {
                            $line.Substring($fieldStartIndices[$i]).Trim()
                        }
                    }
                    ++$i
                }
                # Convert the helper hashable to an object and output it.
                [pscustomobject] $oht
            }
        }
    }

}
