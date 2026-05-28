# Deploy Unity Cloud Build WebGL output to a GitHub Pages repo.
# Expects env vars: GITHUB_TOKEN, GITHUB_USER, GITHUB_REPO, GITHUB_EMAIL, USER, UCB_BUILD_NUMBER

$ErrorActionPreference = "Stop"

Write-Host "====================DEPLOYMENT_TO_GITHUB_PAGES_START============================="

$requiredVars = @(
    "GITHUB_TOKEN", "GITHUB_USER", "GITHUB_REPO", "GITHUB_EMAIL", "USER", "UCB_BUILD_NUMBER"
)
foreach ($name in $requiredVars) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        Write-Error "Required environment variable is not set: $name"
        exit 1
    }
}

$buildfolder = Get-ChildItem -Path . -Directory |
    Where-Object { $_.Name -match '^temp' } |
    ForEach-Object {
        $candidate = Join-Path $_.FullName "default-webgl"
        if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    } |
    Select-Object -First 1

if (-not $buildfolder) {
    Write-Error "Could not find build folder (expected ./temp*/default-webgl)"
    exit 1
}

Write-Host "Build folder: $buildfolder"

$tmpDir = Join-Path (Get-Location) "tmp"
if (-not (Test-Path $tmpDir)) {
    $cloneUrl = "https://$($env:GITHUB_TOKEN)@github.com/$($env:GITHUB_USER)/$($env:GITHUB_REPO)"
    Write-Host "Cloning $cloneUrl -> tmp"
    git clone $cloneUrl $tmpDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Copying build output into tmp..."
Copy-Item -Path (Join-Path $buildfolder "*") -Destination $tmpDir -Recurse -Force

Push-Location $tmpDir
try {
    Get-ChildItem

    git config --global user.email $env:GITHUB_EMAIL
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    git config --global user.name $env:USER
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    git add Build
    git add StreamingAssets/aa/catalog.json
    git add StreamingAssets/aa/settings.json
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $commitMessage = "unity cloud build $($env:UCB_BUILD_NUMBER)"
    git commit -m $commitMessage
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    git log -1
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    git push --force
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}

Write-Host "====================DEPLOYMENT_TO_GITHUB_PAGES_END============================="
