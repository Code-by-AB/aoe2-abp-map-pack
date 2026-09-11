# AbP Map Pack installer / updater for Age of Empires 2 DE
# First run installs the pack; running it again updates to the latest maps.
# The repo is PRIVATE: you must be a collaborator, and Git for Windows must be
# installed (https://git-scm.com) - the first run pops a GitHub browser sign-in.
# Restart AoE2 DE afterwards - the maps appear under Custom maps.

$ErrorActionPreference = 'Stop'
$packName = 'AbP Map Pack'
$repoUrl = 'https://github.com/Code-by-AB/aoe2-abp-map-pack.git'
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

$gitCmd = Get-Command git -ErrorAction SilentlyContinue

foreach ($prof in $profiles) {
    $dest = Join-Path $prof.FullName "mods\local\$packName"

    if (Test-Path (Join-Path $dest '.git')) {
        Write-Host "Updating via git: $dest"
        git -C $dest pull
        continue
    }

    if ($gitCmd) {
        if (Test-Path $dest) {
            $backup = "$dest.old"
            Write-Host "Existing non-git copy found - moving it to '$backup'"
            if (Test-Path $backup) { Remove-Item -Recurse -Force $backup }
            Move-Item $dest $backup
        }
        Write-Host "Cloning the pack (a GitHub sign-in window may appear the first time)..."
        git clone $repoUrl $dest
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Clone failed. Make sure you accepted the GitHub collaborator invite and signed in." -ForegroundColor Red
            continue
        }
        Write-Host "  installed." -ForegroundColor Green
        continue
    }

    # no git available: zip fallback (only works if the repo is public)
    Write-Host "Git not found - trying direct download (works only if the repo is public)..."
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
    catch {
        Write-Host "Download failed - the repo is private. Install Git for Windows (git-scm.com) and rerun this script." -ForegroundColor Red
    }
    finally {
        Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "All set! Restart Age of Empires 2 DE and pick the AbP maps under Custom maps." -ForegroundColor Green
