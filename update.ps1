# AbP Map Pack installer / updater for Age of Empires 2 DE
# First run installs the pack; running it again updates to the latest maps.
# Restart AoE2 DE afterwards - the maps appear under Custom maps.

$ErrorActionPreference = 'Stop'
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

foreach ($prof in $profiles) {
    $dest = Join-Path $prof.FullName "mods\local\$packName"

    if (Test-Path (Join-Path $dest '.git')) {
        Write-Host "Updating via git: $dest"
        git -C $dest pull
        continue
    }

    Write-Host "Installing/updating: $dest"
    $tmp = Join-Path $env:TEMP ("abp-pack-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
        $zip = Join-Path $tmp 'pack.zip'
        Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $tmp
        $src = Join-Path $tmp 'aoe2-abp-map-pack-main'
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        robocopy $src $dest /MIR /XD .git /NFL /NDL /NJH /NJS | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit code $LASTEXITCODE" }
        Write-Host "  done." -ForegroundColor Green
    }
    finally {
        Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "All set! Restart Age of Empires 2 DE and pick the AbP maps under Custom maps." -ForegroundColor Green
