# AbP Map Pack installer / updater for Age of Empires 2 DE
# First run installs the pack; running it again updates it to the latest maps.
# No setup needed - no Git, no accounts, nothing to install. Just run it.
# Restart AoE2 DE afterwards - the maps appear under Custom maps.

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$packName = 'AbP Map Pack'
$zipUrl = 'https://github.com/Code-by-AB/aoe2-abp-map-pack/archive/refs/heads/main.zip'

$gameRoot = Join-Path $env:USERPROFILE 'Games\Age of Empires 2 DE'
if (-not (Test-Path $gameRoot)) {
    Write-Host "Could not find '$gameRoot' - is Age of Empires 2 DE installed on this machine?" -ForegroundColor Red
    return
}
$profiles = Get-ChildItem $gameRoot -Directory | Where-Object { $_.Name -match '^[0-9]+$' }
if (-not $profiles) {
    Write-Host "No AoE2 DE profile folder found under '$gameRoot'. Start the game once, then rerun this." -ForegroundColor Red
    return
}

if (Get-Process 'AoE2DE*' -ErrorAction SilentlyContinue) {
    Write-Host "Age of Empires 2 DE is running - close it first, then rerun this." -ForegroundColor Red
    return
}

$tmp = Join-Path $env:TEMP ("abp-pack-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    Write-Host "Downloading the latest maps..."
    $zip = Join-Path $tmp 'pack.zip'
    Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $tmp
    $src = Join-Path $tmp 'aoe2-abp-map-pack-main'
    if (-not (Test-Path $src)) {
        $src = (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName
    }
    # the copy below mirrors, i.e. it deletes anything not in the download, so make
    # sure the download really is the map pack before pointing it at the mod folder
    if (-not (Test-Path (Join-Path $src 'resources\_common\random-map-scripts'))) {
        Write-Host "That download does not look like the map pack - stopping so nothing is deleted." -ForegroundColor Red
        return
    }
    foreach ($prof in $profiles) {
        $dest = Join-Path $prof.FullName "mods\local\$packName"
        Write-Host "Installing into $dest"
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        # /MIR makes the folder an exact copy of the download: new maps in,
        # removed maps out, and any leftover .git from an older install cleared.
        # /XF update.ps1 leaves this script alone in case it is being run from
        # inside the mod folder - it is neither overwritten nor deleted.
        robocopy $src $dest /MIR /XF update.ps1 /NFL /NDL /NJH /NJS | Out-Null
        if ($LASTEXITCODE -ge 8) {
            Write-Host "  copy failed with robocopy exit code $LASTEXITCODE" -ForegroundColor Red
            continue
        }
        Write-Host "  done." -ForegroundColor Green
    }
}
catch {
    Write-Host "Update failed: $_" -ForegroundColor Red
    Write-Host "Check your internet connection and try again." -ForegroundColor Red
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "All set! Restart Age of Empires 2 DE and pick the AbP maps under Custom maps." -ForegroundColor Green
