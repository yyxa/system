$ErrorActionPreference = "Continue"

$logFile = "C:\Windows\Setup\Scripts\winget-install.log"
function Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host $line
}

Log "=== Старт установки $(Get-Date) ==="

$tries = 0
while (-not (Get-Command winget -ErrorAction SilentlyContinue) -and $tries -lt 30) {
    Log "winget не найден, ждём 5 сек... (попытка $tries)"
    Start-Sleep -Seconds 5
    $tries++
}
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Log "ОШИБКА: winget не найден после 150 секунд ожидания. Выход."
    return
}
Log "winget найден: $((Get-Command winget).Source)"
winget --version 2>&1 | ForEach-Object { Log "версия winget: $_" }

# gopass.gopass почему то сломан пакет
$packages = @(
    'Git.Git',
    'GitHub.cli',
    'VideoLAN.VLC',
    'Flameshot.Flameshot',
    'Obsidian.Obsidian',
    'Telegram.TelegramDesktop',
    'Modrinth.ModrinthApp',
    'Mojang.MinecraftLauncher',
    'Vivaldi.Vivaldi',
    'Valve.Steam',
    'OBSProject.OBSStudio',
    'Discord.Discord',
    'Stellarium.Stellarium',
    'qBittorrent.qBittorrent',
    'KDE.KDEConnect',
    'Ditto.Ditto',
    'kawaiiDango.pano-scrobbler',
    'Voidstar.FilePilot',
    'Microsoft.VisualStudioCode',
    'gopass.gopass',
    'gopass.gopass-jsonapi',
    'GnuPG.Gpg4win',
    'DeltaChat.DeltaChat',
    'AmneziaVPN.AmneziaVPN'
)

$failed = @()
foreach ($pkg in $packages) {
    Log ">>> Установка $pkg ..."
    try {
        $output = winget install --id $pkg --exact --silent `
            --source winget `
            --accept-package-agreements --accept-source-agreements `
            --disable-interactivity 2>&1
        
        $output | ForEach-Object { Log "    $_" }

        if ($LASTEXITCODE -ne 0) {
            Log "!!! $pkg завершился с кодом $LASTEXITCODE"
            $failed += $pkg
        } else {
            Log "OK: $pkg"
        }
    }
    catch {
        Log "!!! Исключение при установке $pkg : $_"
        $failed += $pkg
    }
}

Log "=== Итог ==="
Log "Всего: $($packages.Count)"
Log "Ошибок: $($failed.Count)"
if ($failed.Count -gt 0) {
    Log "Не установились: $($failed -join ', ')"
}
Log "=== Конец $(Get-Date) ==="

function Install-GitHubRelease {
    param(
        [string]$Repository,
        [string]$AssetPattern,
        [string]$InstallDir,
        [switch]$Portable
    )
    try {
        Log ">>> GitHub: $Repository"
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/latest"
        $asset = $release.assets | Where-Object { $_.name -match $AssetPattern } | Select-Object -First 1
        if (-not $asset) {
            Log "!!! Asset не найден в $Repository"
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
                Log "OK: ярлык создан для $mainExe"
            }
        }
        Remove-Item $downloadPath -ErrorAction SilentlyContinue
    }
    catch {
        Log "!!! Ошибка установки $Repository : $_"
    }
}

Install-GitHubRelease `
    -Repository "badmannersteam/murglar-downloads" `
    -AssetPattern "Murglar.*windows.*\.zip" `
    -InstallDir "C:\Program Files\Murglar" `
    -Portable

Log "=== Скрипт завершён ==="