param(
  [Parameter(Mandatory=$true)]
  [string]$HtmlPath,

  [Parameter(Mandatory=$true)]
  [string]$ImagePath
)

$ErrorActionPreference = 'Stop'

$html = Get-Content -LiteralPath $HtmlPath -Raw -Encoding UTF8
$imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
$imageBase64 = [Convert]::ToBase64String($imageBytes)

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

$oldGrid = 'grid-template-columns:repeat(3,1fr);gap:2.2vw;'
$newGrid = 'grid-template-columns:repeat(4,1fr);gap:1.45vw;'
if (-not $section.Contains($oldGrid) -and -not $section.Contains($newGrid)) {
  throw "Could not find expected grid column style."
}
$section = $section.Replace($oldGrid, $newGrid)

$firstCardStart = $section.IndexOf('      <div style="display:flex;flex-direction:column;align-items:center;height:100%;min-height:0">')
if ($firstCardStart -lt 0) {
  throw "Could not find first card insertion point."
}

$newCard = @"
      <div style="display:flex;flex-direction:column;align-items:center;height:100%;min-height:0">
        <div style="flex:1;display:flex;align-items:center;justify-content:center;min-height:0;width:100%"><img src="data:image/png;base64,$imageBase64" alt="路线总览 · 老城南线" style="max-width:100%;max-height:100%;object-fit:contain;border-radius:min(1vw,1.7vh);box-shadow:0 1.6vh 4vh rgba(0,0,0,.22)"></div>
        <div style="margin-top:1.4vh;text-align:center"><div style="font-weight:400;font-size:min(1.55vw,2.7vh);color:var(--accent-bright)">路线总览 · 老城南线</div><div style="font-size:min(.9vw,1.55vh);color:rgba(255,255,255,.58);margin-top:.55vh">单点文化精讲，多种版本可选</div></div>
      </div>

"@

$section = $section.Insert($firstCardStart, $newCard)

$backupPath = [System.IO.Path]::Combine(
  [System.IO.Path]::GetDirectoryName($HtmlPath),
  ('roadshow.backup-before-slide13-four-cols-{0}.html' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
)
Copy-Item -LiteralPath $HtmlPath -Destination $backupPath

$updated = $html.Substring(0, $sectionStart) + $section + $html.Substring($sectionEnd)
Set-Content -LiteralPath $HtmlPath -Value $updated -Encoding UTF8

Write-Output "Updated: $HtmlPath"
Write-Output "Backup:  $backupPath"
