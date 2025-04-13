function Install-FontFromGitHub {
    param (
        [string]$repoUrl,
        [string]$fontName,
        [string]$versionPattern,
        [string]$zipUrlTemplate,
        [string]$fontFolderPath
    )

    $downloadPath = "$env:TEMP\$fontName.zip"
    $extractPath = "$env:TEMP\$fontName"

    $latestRelease = Invoke-WebRequest -Uri $repoUrl -UseBasicParsing | Select-String -Pattern $versionPattern
    
    if ($latestRelease -match $versionPattern) {
        $version = $matches[1]
        $zipUrl = $zipUrlTemplate -replace "{version}", $version

        Write-Host "Latest version found for ${fontName}: ${version}"
        Write-Host "Downloading $zipUrl..."

        # Download the zip file
        Invoke-WebRequest -Uri $zipUrl -OutFile $downloadPath

        # Extract files
        Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

        $fontPath = "$extractPath\$fontFolderPath"

        if (Test-Path $fontPath) {
            $fontFiles = Get-ChildItem -Path $fontPath | Where-Object { $_.Extension -match "\.(ttf|ttc)$" }

            if ($fontFiles.Count -eq 0) {
                throw "No valid font files (.ttf or .ttc) found in $fontPath. Installation aborted!"
            }

            foreach ($fontFile in $fontFiles) {
                $destinationPath = "$env:windir\Fonts\$($fontFile.Name)"
    
                Write-Host "Installing $fontFile"
                Copy-Item $fontFile.FullName -Destination $destinationPath -Force

                # Check if the registry key already exists
                $regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
                $existingKey = Get-ItemProperty -Path $regPath -Name $fontFile.Name -ErrorAction SilentlyContinue

                if ($existingKey) {
                    Write-Host "Registry key already exists. Updating font registration..."
                    Set-ItemProperty -Path $regPath -Name $fontFile.Name -Value $fontFile.Name
                }
                else {
                    Write-Host "Registering font in the registry..."
                    New-ItemProperty -Path $regPath -Name $fontFile.Name -Value $fontFile.Name -PropertyType String
                }
            }

            Write-Host "Installation complete for $fontName!"

            # Cleanup: Remove downloaded ZIP file and extracted folder
            Write-Host "Cleaning up..."
            Remove-Item -Path $downloadPath -Force
            Remove-Item -Path $extractPath -Recurse -Force

            Write-Host "Cleanup complete!"
        }
        else {
            throw "Font files not found in the expected directory."
        }
    }
    else {
        throw "Could not find the latest release for $fontName."
    }
}
