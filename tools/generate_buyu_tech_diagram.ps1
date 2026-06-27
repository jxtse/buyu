Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$root = (Resolve-Path ".").Path
$outDir = Join-Path $root "outputs"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outPath = Join-Path $outDir "buyu-tech-architecture-task-interaction.png"

$W = 1600
$H = 860

function Color($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }

$C = @{
  bg = Color "#FAFAF8"
  ink = Color "#101410"
  muted = Color "#6F7670"
  line = Color "#D9DEDA"
  soft = Color "#F5F7F5"
  accent = Color "#1F7A5A"
  accent2 = Color "#36A582"
  amber = Color "#C99A53"
  blue = Color "#51A8E8"
  teal = Color "#44BFAE"
  black = Color "#0B0B0B"
  white = Color "#FFFFFF"
}

function Font($size, $style = [System.Drawing.FontStyle]::Regular) {
  New-Object System.Drawing.Font("Microsoft YaHei UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function Brush($color) { New-Object System.Drawing.SolidBrush($color) }
function Pen($color, $width = 1) { New-Object System.Drawing.Pen($color, $width) }

function RoundedPath($x, $y, $w, $h, $r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $path
}

function Draw-RoundedRect($g, $x, $y, $w, $h, $r, $fill, $stroke = $null, $sw = 1) {
  $path = RoundedPath $x $y $w $h $r
  $fb = Brush $fill
  $g.FillPath($fb, $path)
  $fb.Dispose()
  if ($stroke -ne $null) {
    $p = Pen $stroke $sw
    $g.DrawPath($p, $path)
    $p.Dispose()
  }
  $path.Dispose()
}

function Draw-Text($g, $text, $x, $y, $w, $h, $size, $color, $style = [System.Drawing.FontStyle]::Regular, $align = "Near") {
  $font = Font $size $style
  $brush = Brush $color
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::$align
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Near
  $sf.Trimming = [System.Drawing.StringTrimming]::EllipsisCharacter
  $sf.FormatFlags = 0
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $h)
  $g.DrawString($text, $font, $brush, $rect, $sf)
  $sf.Dispose()
  $brush.Dispose()
  $font.Dispose()
}

function Draw-LineArrow($g, $x1, $y1, $x2, $y2, $color, $width = 4) {
  $p = Pen $color $width
  $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(8, 10, $true)
  $p.CustomEndCap = $cap
  $g.DrawLine($p, $x1, $y1, $x2, $y2)
  $cap.Dispose()
  $p.Dispose()
}

function Draw-BezierArrow($g, $x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4, $color) {
  $p = Pen $color 3
  $p.DashPattern = @(8, 8)
  $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(7, 9, $true)
  $p.CustomEndCap = $cap
  $g.DrawBezier($p, $x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4)
  $cap.Dispose()
  $p.Dispose()
}

function Draw-PhoneItem($g, $x, $y, $num, $label, $accent) {
  Draw-RoundedRect $g $x $y 280 56 9 $C.white $C.line 1.4
  $circleBrush = Brush $accent
  $g.FillEllipse($circleBrush, $x + 20, $y + 17, 22, 22)
  $circleBrush.Dispose()
  Draw-Text $g $num ($x + 20) ($y + 17) 22 24 14 $C.white ([System.Drawing.FontStyle]::Bold) "Center"
  Draw-Text $g $label ($x + 58) ($y + 16) 205 28 21 $C.ink ([System.Drawing.FontStyle]::Bold)
}

function Draw-HarnessBlock($g, $x, $y, $color, $num, $title, $body, $code) {
  Draw-RoundedRect $g $x $y 520 106 10 $C.white $color 2.5
  Draw-Text $g $num ($x + 30) ($y + 30) 28 30 22 $C.accent ([System.Drawing.FontStyle]::Bold) "Center"
  Draw-Text $g $title ($x + 70) ($y + 27) 220 34 25 $C.accent ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g $body ($x + 70) ($y + 62) 390 24 19 $C.muted
  Draw-Text $g $code ($x + 70) ($y + 84) 390 22 17 $color ([System.Drawing.FontStyle]::Bold)
}

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.Clear($C.bg)

# Left phone endpoint
Draw-RoundedRect $g 86 74 350 680 12 $C.white $C.line 2
Draw-Text $g "端 · 游客手机" 86 106 350 38 26 $C.ink ([System.Drawing.FontStyle]::Bold) "Center"
$items = @(
  @("1", "麦克风 · 语音输入"),
  @("2", "GPS 定位触发"),
  @("3", "现场任务互动"),
  @("4", "语音播放 + 字幕"),
  @("5", "随时打断 · 追问"),
  @("6", "路线手账")
)
for ($i = 0; $i -lt $items.Count; $i++) {
  Draw-PhoneItem $g 121 (160 + $i * 78) $items[$i][0] $items[$i][1] $C.accent
}

# Harness
Draw-RoundedRect $g 535 74 610 680 12 (Color "#F7FBF8") $C.accent 3
Draw-Text $g "文旅 Harness（我们的壁垒）" 535 106 610 38 28 $C.accent ([System.Drawing.FontStyle]::Bold) "Center"
Draw-HarnessBlock $g 572 152 $C.amber "1" "策展数据" "人工把关的可信知识库 · 每条史实标注出处" "symbolic · 防幻觉"
Draw-HarnessBlock $g 572 290 $C.blue "2" "地理位置" "走到哪 · 注入当前点位上下文与路线进度" "context · 千景千讲"
Draw-HarnessBlock $g 572 428 $C.teal "3" "Memory" "记住兴趣 · 问过什么 · 走过哪" "state · 千人千讲"
Draw-RoundedRect $g 572 590 520 64 9 $C.accent $C.accent 2
Draw-Text $g "编排 → 注入 session.update / instructions" 572 607 520 38 23 $C.white ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "+ 人工策展（搭档）：选路线 · 选信源 · 设计讲解逻辑" 610 690 460 24 20 $C.muted ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "= 划定「可信边界」的那只手" 610 722 460 24 20 $C.muted ([System.Drawing.FontStyle]::Bold) "Center"

# Realtime model
Draw-RoundedRect $g 1230 244 310 292 12 $C.black $C.black 1.5
Draw-Text $g "实时语音模型" 1230 292 310 40 29 $C.white ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "FROZEN" 1230 344 310 26 19 $C.accent2 ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "Step-Audio 2.5`nRealtime" 1230 408 310 68 25 (Color "#D8D8D8") ([System.Drawing.FontStyle]::Regular) "Center"
Draw-Text $g "端到端 · 全双工`n不训练 · 不微调" 1230 498 310 58 20 (Color "#A9ADA9") ([System.Drawing.FontStyle]::Bold) "Center"

# Arrows and labels
Draw-LineArrow $g 436 260 522 260 $C.accent 4
Draw-LineArrow $g 436 344 522 344 $C.accent 4
Draw-LineArrow $g 436 498 522 498 $C.accent 4
Draw-LineArrow $g 1145 395 1215 395 $C.accent 4
Draw-BezierArrow $g 1220 445 1130 600 870 690 440 530 (Color "#7E8580")
Draw-Text $g "触发" 444 230 72 28 18 $C.accent ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "任务" 444 316 72 28 18 $C.accent ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "反馈" 444 470 72 28 18 $C.accent ([System.Drawing.FontStyle]::Bold) "Center"
Draw-Text $g "注入 harness" 1122 365 120 28 18 $C.accent ([System.Drawing.FontStyle]::Bold) "Center"

# Footer
Draw-Text $g "步语：实时语音导览 × 现场任务交互 × 记录路线手账" 86 812 820 30 20 $C.muted ([System.Drawing.FontStyle]::Bold)

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output $outPath
