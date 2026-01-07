# Starts three PowerShell terminals for local dev on Windows:
# 1) Docker Compose (from repo root)
# 2) Backend API (from api/, activates venv, runs main.py via uv)
# 3) Frontend Flutter app (from frontend/)

$repoRoot = Split-Path -Parent (Resolve-Path $MyInvocation.MyCommand.Path)

function Start-Terminal {
    param (
        [string]$Title,
        [string]$WorkingDir,
        [string]$Command
    )

    if (-not (Test-Path -LiteralPath $WorkingDir)) {
        Write-Warning "Skip '$Title': Working directory not found ($WorkingDir)"
        return
    }

    Start-Process -FilePath "powershell.exe" -WorkingDirectory $WorkingDir -ArgumentList @(
        "-NoExit",
        "-Command",
        "Set-Location -LiteralPath `"$WorkingDir`"; $Command"
    )
}

# Docker + database + baml
Start-Terminal -Title "docker-compose" -WorkingDir $repoRoot -Command "docker compose up"

# Backend API
$backendDir = Join-Path $repoRoot "api"
Start-Terminal -Title "api" -WorkingDir $backendDir -Command ".\.venv\Scripts\Activate.ps1; uv run main.py"

# Frontend (adjust -d device if you prefer chrome/windows)
$frontendDir = Join-Path $repoRoot "frontend"
Start-Terminal -Title "frontend" -WorkingDir $frontendDir -Command "flutter run -d edge"
