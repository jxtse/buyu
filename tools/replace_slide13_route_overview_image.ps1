param(
  [Parameter(Mandatory=$true)]
  [string]$HtmlPath,

  [Parameter(Mandatory=$true)]
  [string]$ImagePath
)

$ErrorActionPreference = 'Stop'

$html = Get-Content -LiteralPath $HtmlPath -Raw -Encoding UTF8
$imageBase64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($ImagePath))

$sectionStartMarker = '<section class="slide dark" data-animate="product-grid">'
$sectionStart = $html.IndexOf($sectionStartMarker)
if ($sectionStart -lt 0) {
  throw "Could not find slide 13 product-grid section."
}

$sectionEnd = $html.IndexOf('</section>', $sectionStart)
if ($sectionEnd -lt 0) {
  throw "Could not find end of slide 13 section."
}
$sectionEnd += '</section>'.Length
$section = $html.Substring($sectionStart, $sectionEnd - $sectionStart)

$replacementImg = '<img src="data:image/png;base64,' + $imageBase64 + '" alt="路线总览 · 老城南线" style="max-width:100%;max-height:100%;object-fit:contain;filter:drop-shadow(0 1.4vh 2.8vh rgba(0,0,0,.28))"'
$pattern = '<img src="data:image/png;base64,[^"]+" alt="路线总览 · 老城南线" style="[^"]*"'
$updatedSection = [regex]::Replace($section, $pattern, $replacementImg, 1)

if ($updatedSection -eq $section) {
  throw "Could not replace route overview image."
}

$backupPath = [System.IO.Path]::Combine(
  [System.IO.Path]::GetDirectoryName($HtmlPath),
  ('roadshow.backup-before-slide13-route-clean-image-{0}.html' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
)
Copy-Item -LiteralPath $HtmlPath -Destination $backupPath

$updated = $html.Substring(0, $sectionStart) + $updatedSection + $html.Substring($sectionEnd)
Set-Content -LiteralPath $HtmlPath -Value $updated -Encoding UTF8

Write-Output "Updated: $HtmlPath"
Write-Output "Backup:  $backupPath"
