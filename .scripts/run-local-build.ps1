# Serve the Unity WebGL build at <project>/Build over HTTP (avoids file:// CORS issues).
# Usage: .\.scripts\run-local-build.ps1 [port]

param(
    [int]$Port = 8989
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BuildDir = Join-Path $ProjectRoot "Build"

if (-not (Test-Path $BuildDir)) {
    Write-Error "Build folder not found: $BuildDir`nBuild WebGL to <project>/Build first (File > Build Settings > Build)."
    exit 1
}

if (-not (Test-Path (Join-Path $BuildDir "index.html"))) {
    Write-Error "index.html not found in $BuildDir`nBuild WebGL to <project>/Build first."
    exit 1
}

function Find-Python {
    foreach ($cmd in @("python3", "python", "py")) {
        $exe = Get-Command $cmd -ErrorAction SilentlyContinue
        if (-not $exe) { continue }

        if ($cmd -eq "py") {
            $version = & py -3 -c "import sys; print(sys.version_info[0])" 2>$null
            if ($LASTEXITCODE -eq 0 -and $version -eq "3") {
                return @("py", "-3", "-m", "http.server", "$Port")
            }
            continue
        }

        $major = & $exe.Source -c "import sys; print(sys.version_info[0])" 2>$null
        if ($LASTEXITCODE -eq 0 -and $major -eq "3") {
            return @($exe.Source, "-m", "http.server", "$Port")
        }
    }
    return $null
}

$pythonCmd = Find-Python
if (-not $pythonCmd) {
    Write-Host ""
    Write-Host "Python 3 is not installed or not on PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Python 3 from https://www.python.org/downloads/"
    Write-Host "On Windows, enable 'Add python.exe to PATH' during setup."
    Write-Host ""
    Write-Host "Then run this script again."
    Write-Host ""
    exit 1
}

$url = "http://localhost:$Port/"
Write-Host ""
Write-Host "Serving WebGL build from:" -ForegroundColor Cyan
Write-Host "  $BuildDir"
Write-Host ""
Write-Host "Opening in your default browser:" -ForegroundColor Green
Write-Host "  $url"
Write-Host ""
Write-Host "Press Ctrl+C to stop the server."
Write-Host ""

Start-Process $url

Set-Location $BuildDir
& $pythonCmd[0] $pythonCmd[1..($pythonCmd.Length - 1)]
