Import-Module "$PSScriptRoot\..\myUtils"

function Invoke-Elevated {
    param (
        [Parameter(Mandatory)]
        [String] $Command
    )
    if (!(Test-IsCommandAvailable gsudo.exe)) {
        Write-Error 'Requires "sudo" for Windows; visit https://github.com/gerardog/gsudo'
    }
    gsudo.exe --integrity High powershell.exe -ExecutionPolicy Bypass -EncodedCommand (Get-EncodedCommand $Command)
}

function Invoke-NonElevated {
    param (
        [Parameter(Mandatory)]
        [String] $Command
    )
    if (!(Test-IsCommandAvailable gsudo.exe)) {
        Write-Error 'Requires "sudo" for Windows; visit https://github.com/gerardog/gsudo'
    }
    gsudo.exe --integrity Medium powershell.exe -ExecutionPolicy Bypass -EncodedCommand (Get-EncodedCommand $Command)
}
