# Elizabeth Live v1.1 Codex handoff fetcher
# Codex: run this script on Ben's Windows desktop. It downloads, verifies,
# and expands the complete handoff, then prints the START_HERE.md path.

$ErrorActionPreference = 'Stop'

$sourceCommit = '65f33e7181d9ef8bad7cd517bf0feee800f5263b'
$baseUrl = "https://raw.githubusercontent.com/BenjaminMcMahan/PulsePoint-Standalone/$sourceCommit/codex-handoff"
$expectedSha256 = '311240613d0dec0e4792b1a69b5f3e5239446dd8d1fdfde94391588e3dcae17c'
$zipPath = Join-Path $PWD 'Elizabeth-Codex-Handoff-v1.1-CodexURL.zip'
$extractPath = Join-Path $PWD 'Elizabeth-Codex-Handoff-v1.1-CodexURL'

Write-Host 'Downloading Elizabeth Codex handoff pieces...'
$pieces = for ($index = 0; $index -le 5; $index++) {
    $name = 'zip.b64.part{0:D2}' -f $index
    $url = "$baseUrl/$name"
    (Invoke-RestMethod -Uri $url -Method Get).Trim()
}

$bytes = [Convert]::FromBase64String(($pieces -join ''))
[IO.File]::WriteAllBytes($zipPath, $bytes)

$actualSha256 = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $expectedSha256) {
    throw "Handoff SHA-256 mismatch. Expected $expectedSha256 but received $actualSha256"
}

if (Test-Path $extractPath) {
    Remove-Item $extractPath -Recurse -Force
}
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

$startHere = Get-ChildItem -Path $extractPath -Filter 'START_HERE.md' -Recurse | Select-Object -First 1
if (-not $startHere) {
    throw 'START_HERE.md was not found after extraction.'
}

Write-Host "`nElizabeth handoff downloaded and verified." -ForegroundColor Green
Write-Host "Open: $($startHere.FullName)" -ForegroundColor Cyan
Write-Output $startHere.FullName
