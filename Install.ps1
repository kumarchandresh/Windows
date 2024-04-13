# https://stackoverflow.com/a/49481797
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [Text.UTF8Encoding]::new()

Import-Module "$PSScriptRoot\PowerShell\Modules\myUtils" -Force
Import-Module "$PSScriptRoot\PowerShell\Modules\myGsudo" -Force
Import-Module "$PSScriptRoot\PowerShell\Modules\myScoop" -Force
Import-Module "$PSScriptRoot\PowerShell\Modules\myWinGet" -Force

if (!(Test-IsProcessElevated)) {
    Write-Error -Message '[?] Should be run from elevate PowerShell' -ErrorAction Stop
}

if (!(Test-IsCommandAvailable winget)) {
    Write-Error -Message '[?] WinGet is required to continue; visit https://github.com/microsoft/winget-cli' -ErrorAction Stop
}

Write-Host '[*] Update WinGet sources' -ForegroundColor Magenta
winget source update

# https://github.com/gerardog/gsudo
Write-Host '[+] Install "sudo" for Windows' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id gerardog.gsudo; Restore-EnvPath

# http://aka.ms/powershell
Write-Host '[+] Install PowerShell' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Microsoft.PowerShell; Restore-EnvPath

# https://ohmyposh.dev/
Write-Host '[+] Install Oh My Posh' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id JanDeDobbeleer.OhMyPosh

# https://starship.rs/
Write-Host '[+] Install Starship' -ForegroundColor Magenta
Install-WinGetPackage -Id Starship.Starship

Write-Host '[+] Install PowerShell profiles' -ForegroundColor Magenta
@(
    "$HOME\Documents\WindowsPowerShell",
    "$HOME\Documents\PowerShell"
) | ForEach-Object {
    if (Test-Path $_) {
        if (Test-IsSymbolicLink $_) {
            (Get-Item $_).Delete()
        }
        elseif (Test-IsDirectory $_) {
            Move-Item -Path $_ -Destination "$_.Backup"
        }
    }
    New-Item -ItemType SymbolicLink -Path $_ -Value "$PSScriptRoot\PowerShell"
}

# https://github.com/microsoft/terminal
if (Test-IsWinGetPackageInstalled 9N0DX20HK701) {
    Write-Host '[-] Remove Windows Terminal installed from Microsoft Store' -ForegroundColor Red
    Uninstall-WinGetPackage -Id 9N0DX20HK701
}
Write-Host '[+] Install Windows Terminal' -ForegroundColor Magenta
Install-WinGetPackage -Id Microsoft.WindowsTerminal

# https://gitforwindows.org/
Write-Host '[+] Install "git" for Windows' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Git.Git; Restore-EnvPath

# https://scoop.sh/
Write-Host '[+] Install Scoop' -ForegroundColor Magenta
if (!(Test-IsCommandAvailable scoop)) {
    Invoke-NonElevated -Command 'Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression'; Restore-EnvPath

    # https://scoop.sh/#/buckets
    Write-Host '[+] Add Scoop buckets' -ForegroundColor Magenta
    Invoke-NonElevated -Command @'
scoop bucket add nerd-fonts
scoop bucket add java
'@
}
else {
    scoop update
}

# https://github.com/tonsky/FiraCode
Write-Host '[+] Install Font: Fira Code' -ForegroundColor Magenta
Install-ScoopPackage -Global nerd-fonts/FiraCode
Write-Host '[+] Install Nerd Font: Fira Code' -ForegroundColor Magenta
Install-ScoopPackage -Global nerd-fonts/FiraCode-NF

# https://github.com/microsoft/cascadia-code
# Write-Host '[+] Install Font: Cascadia Code' -ForegroundColor Magenta
# Install-ScoopPackage -Global nerd-fonts/Cascadia-Code
Write-Host '[+] Install Nerd Font: Cascadia Code' -ForegroundColor Magenta
Install-ScoopPackage -Global nerd-fonts/CascadiaCode-NF

# https://notepad-plus-plus.org/
Write-Host '[+] Install Notepad++' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Notepad++.Notepad++

# https://aka.ms/vscode
Write-Host '[+] Install Visual Studio Code' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Microsoft.VisualStudioCode

# https://aka.ms/vscode-insiders
Write-Host '[+] Install Visual Studio Code Insiders' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Microsoft.VisualStudioCode.Insiders

# https://obsidian.md/
Write-Host '[+] Install Obsidian' -ForegroundColor Magenta
Install-WinGetPackage -Id Obsidian.Obsidian

# https://www.notion.so/
Write-Host '[+] Install Notion' -ForegroundColor Magenta
Install-WinGetPackage -Id Notion.Notion

# https://store.steampowered.com/
Write-Host '[+] Install Steam' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Valve.Steam -Location $(Join-Path (Get-WmiObject Win32_OperatingSystem).SystemDrive Steam)

# https://spotify.com/
Write-Host '[+] Install Spotify' -ForegroundColor Magenta
Invoke-NonElevated -Command @"
Import-Module '$PSScriptRoot\PowerShell\Modules\myWinGet'
Install-WinGetPackage -Id Spotify.Spotify
"@

# https://discord.com/
Write-Host '[+] Install Discord' -ForegroundColor Magenta
Install-WinGetPackage -Id Discord.Discord

Write-Host '[+] Install WhatsApp' -ForegroundColor Magenta
Install-WinGetPackage -Source MSStore -Id 9NKSQGP7F2NH
<#
# https://www.microsoft.com/en-in/microsoft-teams
Write-Host '[+] Install MS Teams' -ForegroundColor Magenta
Install-WinGetPackage -Id Microsoft.Teams

# https://www.skype.com/
Write-Host '[+] Install Skype' -ForegroundColor Magenta
Install-WinGetPackage -Scope Machine -Id Microsoft.Skype
#>
# https://www.postman.com/
Write-Host '[+] Install Postman' -ForegroundColor Magenta
Install-WinGetPackage -Id Postman.Postman

# https://www.figma.com/
Write-Host '[+] Install Figma' -ForegroundColor Magenta
Install-WinGetPackage -Id Figma.Figma

# https://github.com/coreybutler/nvm-windows
Write-Host '[+] Install "nvm" for Windows' -ForegroundColor Magenta
Install-ScoopPackage -Global main/nvm; Restore-EnvPath

# https://nodejs.org/en
Write-Host '[+] Install Node.js' -ForegroundColor Magenta
Invoke-Expression 'nvm install latest; nvm use latest'

# https://devguide.python.org/versions/
Write-Host '[+] Install Python' -ForegroundColor Magenta
Install-ScoopPackage -Global main/python
reg import "$(which python | Split-Path -Parent | Join-Path -ChildPath 'install-pep-514.reg')"

# https://www.postgresql.org/
Write-Host '[+] Install PostgreSQL' -ForegroundColor Magenta
Install-ScoopPackage -Global main/postgresql
if (![bool](Get-Service PostgreSQL -ea SilentlyContinue)) { pg_ctl register -N PostgreSQL }
if ((Get-Service -Name PostgreSQL).Status -ne 'Running') { Start-Service -Name PostgreSQL }

# https://www.oracle.com/java/
Write-Host '[+] Install Java' -ForegroundColor Magenta
Install-ScoopPackage -Global java/openjdk

# https://maven.apache.org/
Write-Host '[+] Install Java' -ForegroundColor Magenta
Install-ScoopPackage -Global main/maven

# https://groovy-lang.org/
Write-Host '[+] Install Groovy' -ForegroundColor Magenta
Install-ScoopPackage -Global main/groovy

