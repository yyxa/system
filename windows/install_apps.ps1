$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Install-GitHubRelease {
    param(
        [string]$Repository,
        [string]$AssetPattern,
        [string]$InstallerArgs = "/S",
        [string]$InstallDir,
        [switch]$Portable
    )
    
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/latest"
        $asset = $release.assets | Where-Object { $_.name -match $AssetPattern } | Select-Object -First 1
        
        if (-not $asset) {
            Write-Warning "Asset не найден в $Repository"
            return
        }
        
        $downloadPath = "$env:TEMP\$($asset.name)"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath
        
        if ($Portable -or $asset.name -match '\.zip$') {
            $targetDir = if ($InstallDir) { $InstallDir } else { "C:\Program Files\$($asset.name -replace '\.zip$','')" }
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
            Expand-Archive -Path $downloadPath -DestinationPath $targetDir -Force
            
            $exeFiles = Get-ChildItem -Path $targetDir -Filter "*.exe" -Recurse | Where-Object { $_.Name -notmatch "unins" }
            if ($exeFiles.Count -gt 0) {
                $mainExe = $exeFiles[0].FullName
                $shortcutPath = "$env:PUBLIC\Desktop\$($exeFiles[0].BaseName).lnk"
                $WshShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut($shortcutPath)
                $Shortcut.TargetPath = $mainExe
                $Shortcut.WorkingDirectory = Split-Path $mainExe
                $Shortcut.Save()
            }
            
        }
        else {
            Start-Process -FilePath $downloadPath -ArgumentList $InstallerArgs -Wait
        }
        
        Remove-Item $downloadPath -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Ошибка установки $Repository : $_"
    }
}

$packagesFile = Join-Path $scriptDir "packages.json"
if (Test-Path $packagesFile) {
    winget import $packagesFile --accept-package-agreements --accept-source-agreements --silent
} else {
    Write-Warning "packages.json not found!"
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Install-GitHubRelease `
    -Repository "badmannersteam/murglar-downloads" `
    -AssetPattern "Murglar.*windows.*\.zip" `
    -InstallDir "C:\Program Files\Murglar" `
    -Portable

pause