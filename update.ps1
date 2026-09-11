# AbP Map Pack installer / updater for Age of Empires 2 DE
# First run installs the pack; running it again updates to the latest maps.
# Private repo: you must be a collaborator (accept the GitHub invite email).
# Needs Git OR GitHub CLI - and if neither is installed, this script installs
# the GitHub CLI itself via winget and walks you through a one-time sign-in.
# Restart AoE2 DE afterwards - the maps appear under Custom maps.

$ErrorActionPreference = 'Stop'
$packName = 'AbP Map Pack'
$repo = 'Code-by-AB/aoe2-abp-map-pack'
$repoUrl = "https://github.com/$repo.git"
$zipUrl = "https://github.com/$repo/archive/refs/heads/main.zip"

function Find-Gh {
    $c = Get-Command gh -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($cand in @("$env:ProgramFiles\GitHub CLI\gh.exe", "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe")) {
        if (Test-Path $cand) { return $cand }
    }
    return $null
}

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
$ghExe = Find-Gh

# bootstrap: no git and no gh -> install GitHub CLI via winget
if (-not $gitCmd -and -not $ghExe) {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Host "Neither Git nor GitHub CLI is installed, and winget is unavailable." -ForegroundColor Red
        Write-Host "Install Git (git-scm.com) or GitHub CLI (cli.github.com) and rerun this script."
        return
    }
    Write-Host "Installing GitHub CLI (one-time)..." -ForegroundColor Yellow
    winget install -e --id GitHub.cli --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
    $ghExe = Find-Gh
    if (-not $ghExe) {
        Write-Host "GitHub CLI install did not complete - rerun this script (or install it manually from cli.github.com)." -ForegroundColor Red
        return
    }
}

# if gh is our tool, make sure it is signed in (one-time browser sign-in)
if (-not $gitCmd -and $ghExe) {
    & $ghExe auth status 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "One-time GitHub sign-in (a browser window will open)..." -ForegroundColor Yellow
        & $ghExe auth login --hostname github.com --git-protocol https --web
        & $ghExe auth status 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Sign-in did not complete - rerun this script to try again." -ForegroundColor Red
            return
        }
    }
}

foreach ($prof in $profiles) {
    $dest = Join-Path $prof.FullName "mods\local\$packName"

    if ($gitCmd -and (Test-Path (Join-Path $dest '.git'))) {
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

    if ($ghExe) {
        Write-Host "Updating via GitHub CLI: $dest"
        $tmp = Join-Path $env:TEMP ("abp-pack-" + [guid]::NewGuid())
        New-Item -ItemType Directory -Path $tmp | Out-Null
        try {
            $zip = Join-Path $tmp 'pack.zip'
            cmd /c "`"$ghExe`" api repos/$repo/zipball/main > `"$zip`""
            if ($LASTEXITCODE -ne 0) { throw "gh api download failed - did you accept the collaborator invite?" }
            Expand-Archive -Path $zip -DestinationPath $tmp
            $src = (Get-ChildItem $tmp -Directory | Select-Object -First 1).FullName
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            robocopy $src $dest /MIR /XD .git /NFL /NDL /NJH /NJS | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit code $LASTEXITCODE" }
            Write-Host "  done." -ForegroundColor Green
        }
        catch {
            Write-Host "GitHub CLI update failed: $_" -ForegroundColor Red
        }
        finally {
            Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
        }
        continue
    }

    # last resort: anonymous zip (only works if the repo is public)
    Write-Host "Trying direct download (works only if the repo is public)..."
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
        Write-Host "Download failed - the repo is private and no tools are available." -ForegroundColor Red
    }
    finally {
        Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "All set! Restart Age of Empires 2 DE and pick the AbP maps under Custom maps." -ForegroundColor Green
