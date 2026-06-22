$ErrorActionPreference = "Stop"

$HtmlPath = "C:\Users\jxTse\Downloads\步语BuYu-路演.html"
$BackupPath = "C:\Users\jxTse\Downloads\步语BuYu-路演.backup-before-three-images.html"

$Images = @(
  @{
    Path = "C:\Users\jxTse\AppData\Local\Temp\codex-clipboard-178ebad5-9f74-4c05-bbce-e90e53988f14.png"
    Alt = "路线地图 · 老城南线"
    Title = "路线地图 · 老城南线"
    Desc = "中华门 → 城墙博物馆 → 老门东 → 小西湖 → 乌衣巷"
    Color = "var(--accent-bright)"
  },
  @{
    Path = "C:\Users\jxTse\AppData\Local\Temp\codex-clipboard-aa0210e6-76e9-4b0d-8f61-3b81ca0328b4.png"
    Alt = "文化点位 · 中华门瓮城"
    Title = "文化点位 · 中华门瓮城"
    Desc = "走进瓮城结构，听六百年前的南京城"
    Color = "#fff"
  },
  @{
    Path = "C:\Users\jxTse\AppData\Local\Temp\codex-clipboard-531c8727-e7d5-481b-81b0-502ebbe0870b.png"
    Alt = "文化点位 · 小西湖街区"
    Title = "文化点位 · 小西湖街区"
    Desc = "走完一键生成图文 Plog，分享到社交平台"
    Color = "#fff"
  }
)

if (-not (Test-Path -LiteralPath $HtmlPath)) {
  throw "HTML not found: $HtmlPath"
}
foreach ($image in $Images) {
  if (-not (Test-Path -LiteralPath $image.Path)) {
    throw "Image not found: $($image.Path)"
  }
}
if (-not (Test-Path -LiteralPath $BackupPath)) {
  Copy-Item -LiteralPath $HtmlPath -Destination $BackupPath
}

function Get-PngDataUri([string]$Path) {
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  return "data:image/png;base64," + [Convert]::ToBase64String($bytes)
}

$ImageStyle = "max-height:100%;max-width:100%;width:auto;height:auto;object-fit:contain;border-radius:14px;box-shadow:0 6px 30px rgba(0,0,0,.32),0 0 0 1px rgba(255,255,255,.06)"
$Items = foreach ($image in $Images) {
  $src = Get-PngDataUri $image.Path
@"
      <div style="display:flex;flex-direction:column;align-items:center;height:100%;min-height:0">
        <div style="flex:1;display:flex;align-items:center;justify-content:center;min-height:0;width:100%"><img src="$src" alt="$($image.Alt)" style="$ImageStyle"></div>
        <div style="margin-top:1.4vh;text-align:center"><div style="font-family:var(--sans),var(--sans-zh);font-weight:600;font-size:max(14px,1.02vw);color:$($image.Color)">$($image.Title)</div><div style="font-family:var(--sans),var(--sans-zh);font-size:max(12px,.8vw);opacity:.66;margin-top:.4vh">$($image.Desc)</div></div>
      </div>
"@
}

$NewSection = @"
<section class="slide dark" data-animate="product-grid">
  <div class="canvas-card">
    <div class="chrome-min"><div class="l">步语 BuYu · 南京老城南实时语音导览</div><div class="r">PRODUCT · 产品演示 · 13 / 15</div></div>
    <div data-anim="line"><div class="t-cat accent" style="margin-bottom:1vh;color:var(--accent-bright)">PRODUCT · 真实可运行的导览 App</div><div style="font-family:var(--sans),var(--sans-zh);font-weight:200;font-size:min(3.6vw,6.2vh);line-height:1.04;letter-spacing:-.022em">从一条老城南线，到走完留下一篇 Plog</div></div>
    <div data-anim="up" style="flex:1;display:grid;grid-template-columns:repeat(3,1fr);gap:2.2vw;margin-top:2.4vh;align-items:start;min-height:0;justify-items:center">
$($Items -join "`r`n")
    </div>
    <div style="margin-top:auto;padding-top:1.4vh;border-top:1px solid rgba(255,255,255,.18);display:flex;justify-content:space-between;align-items:baseline;gap:2.4vw"><div style="font-family:var(--mono);font-size:13px;letter-spacing:.16em;text-transform:uppercase;flex:0 0 auto;opacity:.7">步语 BuYu</div><div style="font-family:var(--sans),var(--sans-zh);font-size:max(13px,.9vw);line-height:1.45;text-align:right;opacity:.85">手绘治愈风界面 · 老城南路线总览 → 单点文化讲解 → 走完生成可保存、分享的 Plog。</div></div>
  </div>
</section>
"@

$Html = [System.IO.File]::ReadAllText($HtmlPath, [System.Text.Encoding]::UTF8)
$Pattern = '<section class="slide dark" data-animate="product-grid">.*?</section>'
$Match = [regex]::Match($Html, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $Match.Success) {
  throw "Slide 13 product-grid section not found."
}

$Updated = $Html.Substring(0, $Match.Index) + $NewSection + $Html.Substring($Match.Index + $Match.Length)
[System.IO.File]::WriteAllText($HtmlPath, $Updated, [System.Text.UTF8Encoding]::new($false))

$CheckSection = [regex]::Match($Updated, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline).Value
Write-Output "Updated: $HtmlPath"
Write-Output "Backup: $BackupPath"
Write-Output ("pngDataUris=" + ([regex]::Matches($CheckSection, 'data:image/png;base64').Count))
Write-Output ("svgDataUris=" + ([regex]::Matches($CheckSection, 'data:image/svg\+xml;base64').Count))
Write-Output ("grid3=" + $CheckSection.Contains('grid-template-columns:repeat(3,1fr)'))
