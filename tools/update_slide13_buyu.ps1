$ErrorActionPreference = "Stop"

$HtmlPath = "C:\Users\jxTse\Downloads\步语BuYu-路演.html"
$BackupPath = "C:\Users\jxTse\Downloads\步语BuYu-路演.backup-before-slide13.html"
$AssetDir = "C:\Users\jxTse\Documents\New project 2\generated-slide13"

New-Item -ItemType Directory -Force -Path $AssetDir | Out-Null
if (-not (Test-Path -LiteralPath $BackupPath)) {
  Copy-Item -LiteralPath $HtmlPath -Destination $BackupPath
}

function ConvertTo-DataUri([string]$Svg) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Svg)
  return "data:image/svg+xml;base64," + [Convert]::ToBase64String($bytes)
}

function Save-Svg([string]$Name, [string]$Svg) {
  $path = Join-Path $AssetDir $Name
  [System.IO.File]::WriteAllText($path, $Svg, [System.Text.UTF8Encoding]::new($false))
}

function PhoneChrome([string]$Body, [string]$ExtraDefs = "") {
@"
<svg xmlns="http://www.w3.org/2000/svg" width="680" height="1474" viewBox="0 0 680 1474">
  <defs>
    <filter id="paper" x="-10%" y="-10%" width="120%" height="120%">
      <feColorMatrix in="SourceGraphic" type="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 1 0"/>
    </filter>
    <filter id="pencil" x="-20%" y="-20%" width="140%" height="140%">
      <feTurbulence type="fractalNoise" baseFrequency=".045" numOctaves="3" seed="4" result="n"/>
      <feDisplacementMap in="SourceGraphic" in2="n" scale="1.8"/>
    </filter>
    <style>
      .ui{font-family:"Noto Sans SC","PingFang SC","Microsoft YaHei",sans-serif;fill:#171b22}
      .en{font-family:"Inter","Helvetica Neue",Arial,sans-serif}
      .hand{font-family:"Noto Sans SC","PingFang SC","Microsoft YaHei",sans-serif;fill:#263038}
      .thin{stroke:#252b2d;stroke-width:4;stroke-linecap:round;stroke-linejoin:round;fill:none}
      .route{stroke:#1f7a5a;stroke-width:11;stroke-linecap:round;stroke-linejoin:round;fill:none;stroke-dasharray:20 15;filter:url(#pencil)}
      .routeSolid{stroke:#1f7a5a;stroke-width:12;stroke-linecap:round;stroke-linejoin:round;fill:none;filter:url(#pencil)}
      .label{fill:#fffdf8;stroke:#d8a86f;stroke-width:2}
      .chip{fill:#dff3d5}
      .muted{fill:#687078}
    </style>
    $ExtraDefs
  </defs>
  <rect width="680" height="1474" fill="#fffdf8"/>
  <path d="M-20 265 C120 330 245 205 398 283 S570 220 708 276" stroke="#e8d4ff" stroke-width="18" fill="none" opacity=".75" filter="url(#pencil)"/>
  <text x="64" y="50" class="ui en" font-size="28" font-weight="700">9:41</text>
  <g transform="translate(548 31)" fill="#111">
    <rect x="0" y="16" width="7" height="15" rx="2"/><rect x="12" y="10" width="7" height="21" rx="2"/><rect x="24" y="4" width="7" height="27" rx="2"/>
    <path d="M52 14 q18 -15 36 0" stroke="#111" stroke-width="5" fill="none"/><path d="M59 22 q11 -9 22 0" stroke="#111" stroke-width="5" fill="none"/>
    <rect x="99" y="4" width="38" height="22" rx="4" fill="none" stroke="#111" stroke-width="4"/><rect x="103" y="8" width="28" height="14" rx="2"/>
  </g>
  $Body
</svg>
"@
}

function DrawGate([int]$X, [int]$Y, [double]$S=1) {
@"
<g transform="translate($X $Y) scale($S)" filter="url(#pencil)">
  <rect x="0" y="88" width="210" height="78" fill="#96ad8c" stroke="#263038" stroke-width="4"/>
  <path d="M78 166 v-45 q27 -35 54 0 v45" fill="#fff6df" stroke="#263038" stroke-width="4"/>
  <rect x="50" y="36" width="112" height="58" fill="#d55631" stroke="#263038" stroke-width="4"/>
  <path d="M36 43 q70 -36 140 0 q-6 16 -18 20 q-54 -16 -108 0 q-12 -5 -14 -20z" fill="#c84a2c" stroke="#263038" stroke-width="4"/>
  <path d="M58 18 q48 -25 96 0 q-5 14 -15 18 q-34 -10 -68 0 q-10 -4 -13 -18z" fill="#e27639" stroke="#263038" stroke-width="4"/>
  <rect x="74" y="50" width="16" height="22" fill="#2ab08d" stroke="#263038" stroke-width="3"/><rect x="122" y="50" width="16" height="22" fill="#2ab08d" stroke="#263038" stroke-width="3"/>
  <path d="M21 107 h18 M172 107 h18 M22 130 h28 M157 130 h28" stroke="#5a6c5b" stroke-width="4"/>
</g>
"@
}

function DrawMuseum([int]$X, [int]$Y, [double]$S=1) {
@"
<g transform="translate($X $Y) scale($S)" filter="url(#pencil)">
  <rect x="14" y="58" width="178" height="88" fill="#e8c08b" stroke="#263038" stroke-width="4"/>
  <path d="M0 60 L103 8 L206 60 Z" fill="#8fa9c9" stroke="#263038" stroke-width="4"/>
  <rect x="42" y="84" width="24" height="34" fill="#fff2d5" stroke="#263038" stroke-width="3"/>
  <rect x="90" y="82" width="26" height="64" fill="#7c5a43" stroke="#263038" stroke-width="3"/>
  <rect x="140" y="84" width="24" height="34" fill="#fff2d5" stroke="#263038" stroke-width="3"/>
  <path d="M20 149 h166" stroke="#263038" stroke-width="4"/>
</g>
"@
}

function DrawArch([int]$X, [int]$Y, [double]$S=1) {
@"
<g transform="translate($X $Y) scale($S)" filter="url(#pencil)">
  <rect x="30" y="72" width="162" height="34" fill="#b77749" stroke="#263038" stroke-width="4"/>
  <path d="M14 72 q97 -48 194 0" fill="none" stroke="#263038" stroke-width="5"/>
  <rect x="35" y="106" width="18" height="86" fill="#7d513b" stroke="#263038" stroke-width="4"/>
  <rect x="169" y="106" width="18" height="86" fill="#7d513b" stroke="#263038" stroke-width="4"/>
  <path d="M72 106 q39 44 78 0 v86 H72z" fill="#f8e5c5" stroke="#263038" stroke-width="4"/>
  <path d="M62 52 q50 -30 100 0 q-4 12 -16 16 q-34 -10 -68 0 q-10 -4 -16 -16z" fill="#a45b35" stroke="#263038" stroke-width="4"/>
</g>
"@
}

function DrawHouse([int]$X, [int]$Y, [double]$S=1) {
@"
<g transform="translate($X $Y) scale($S)" filter="url(#pencil)">
  <rect x="28" y="54" width="112" height="82" fill="#f0c27e" stroke="#263038" stroke-width="4"/>
  <path d="M14 58 L86 12 L154 58 Z" fill="#5f87ad" stroke="#263038" stroke-width="4"/>
  <rect x="48" y="82" width="24" height="28" fill="#fff6df" stroke="#263038" stroke-width="3"/>
  <rect x="94" y="80" width="28" height="56" fill="#7d513b" stroke="#263038" stroke-width="3"/>
  <circle cx="152" cy="114" r="25" fill="#7bb567" stroke="#263038" stroke-width="3"/>
  <path d="M153 95 v62 M132 128 q22 -12 42 -1" stroke="#4c7d42" stroke-width="4" fill="none"/>
</g>
"@
}

function DrawTree([int]$X, [int]$Y, [double]$S=1) {
@"
<g transform="translate($X $Y) scale($S)" filter="url(#pencil)">
  <path d="M50 145 C44 92 55 54 82 20" stroke="#5d4435" stroke-width="7" fill="none"/>
  <path d="M74 42 C37 62 22 92 20 130 M82 50 C94 86 76 116 60 143 M96 38 C136 62 133 96 119 132" stroke="#5aa65d" stroke-width="5" fill="none" stroke-dasharray="10 8"/>
</g>
"@
}

function DrawFlowers([int]$X, [int]$Y) {
@"
<g transform="translate($X $Y)" filter="url(#pencil)">
  <path d="M6 42 q10 -18 20 0 q-10 18 -20 0z M34 34 q10 -18 20 0 q-10 18 -20 0z" fill="#f48ab2" stroke="#263038" stroke-width="2"/>
  <path d="M18 58 v28 M46 50 v34" stroke="#5fa75d" stroke-width="4"/>
  <path d="M18 70 q-16 -8 -20 8 M46 68 q16 -8 20 8" stroke="#5fa75d" stroke-width="4" fill="none"/>
</g>
"@
}

function DrawLabel([int]$X, [int]$Y, [string]$No, [string]$Zh, [string]$En) {
@"
<g transform="translate($X $Y)">
  <circle cx="0" cy="0" r="24" fill="#1f7a5a" stroke="#fffdf8" stroke-width="5"/>
  <text x="0" y="9" class="ui en" font-size="28" fill="#fffdf8" text-anchor="middle">$No</text>
  <rect class="label" x="24" y="-26" width="170" height="52" rx="8"/>
  <text x="38" y="-2" class="ui" font-size="25">$Zh</text>
  <text x="38" y="19" class="ui en" font-size="14" fill="#1f7a5a">$En</text>
</g>
"@
}

$mapIllustration = @"
<rect x="0" y="0" width="680" height="1474" fill="#fbf4e7"/>
<g opacity=".24" filter="url(#pencil)">
  <path d="M20 0 C210 130 120 280 302 430 S460 760 288 1010 S250 1260 550 1474" stroke="#d7b889" stroke-width="10" fill="none" stroke-dasharray="7 14"/>
  <path d="M-20 1120 C130 1030 285 1108 420 1010 S558 900 710 956" stroke="#d7b889" stroke-width="8" fill="none" stroke-dasharray="6 16"/>
</g>
<g transform="translate(28 60)">
  <rect x="0" y="0" width="455" height="82" rx="10" fill="#fffdf8" opacity=".88" stroke="#d8a86f" stroke-width="1.5"/>
  <text x="20" y="42" class="ui" font-size="34">步语 · 老城南线</text>
  <text x="21" y="64" class="ui en" font-size="16" fill="#1f7a5a">BuYu · Walk the Story of a City</text>
</g>
<g transform="translate(520 50)">
  <text x="56" y="0" class="ui en" font-size="24" text-anchor="middle">N</text>
  <circle cx="56" cy="44" r="25" fill="#fffdf8" stroke="#d8a86f"/>
  <path d="M56 15 l8 28 h-16z" fill="#9d4d3f"/><path d="M56 73 l-8 -28 h16z" fill="#4a5360"/>
</g>
<path class="route" d="M66 886 C162 858 160 934 236 900 S317 945 376 914 S456 902 497 958 S449 1052 516 1084 S585 1183 501 1243"/>
<path class="route" d="M497 958 C498 814 438 760 454 662 S547 566 501 454 S530 336 610 245"/>
$(DrawGate 48 710 .92)
$(DrawMuseum 230 880 .78)
$(DrawArch 380 1075 .82)
$(DrawHouse 444 500 .72)
$(DrawHouse 444 205 .58)
$(DrawTree 514 620 .55)
$(DrawTree 78 1010 .55)
$(DrawFlowers 560 748)
$(DrawLabel 54 910 "1" "中华门瓮城" "Zhonghua Gate")
$(DrawLabel 165 970 "2" "城墙博物馆" "City Wall Museum")
$(DrawLabel 486 1110 "3" "老门东" "Laomendong")
$(DrawLabel 423 676 "4" "小西湖" "Xiaoxihu")
$(DrawLabel 590 250 "5" "乌衣巷" "Wuyi Alley")
<g filter="url(#pencil)" opacity=".85">
  <path d="M552 205 q34 -32 68 0" stroke="#88c7d9" stroke-width="18" fill="none"/>
  <path d="M552 220 q34 -32 68 0" stroke="#88c7d9" stroke-width="8" fill="none"/>
  <path d="M518 175 q-20 -26 -48 2 q-22 -18 -43 4 q-21 2 -21 24 q56 16 116 -1" fill="#e8f8fb" stroke="#6e8fa0" stroke-width="3"/>
  <path d="M94 1260 q22 -35 44 0 M108 1292 q24 -36 48 0" stroke="#5fa75d" stroke-width="6" fill="none"/>
  <circle cx="118" cy="600" r="5" fill="#e26a6a"/><circle cx="572" cy="820" r="5" fill="#7a93d9"/><circle cx="425" cy="840" r="5" fill="#9b6bc5"/><circle cx="318" cy="760" r="5" fill="#e4b24f"/><path d="M620 720 l9 18 18 9 -18 9 -9 18 -9 -18 -18 -9 18 -9z" fill="#f4d467" stroke="#263038" stroke-width="2"/>
</g>
<rect x="24" y="1370" width="632" height="48" rx="6" fill="#fffdf8" opacity=".85"/>
<text x="48" y="1402" class="ui" font-size="19" fill="#5d5246">中华门 → 城墙博物馆 → 老门东 → 小西湖 → 乌衣巷　全程约 2.0km · 步行约 26min</text>
"@

$svg1 = PhoneChrome @"
  <text x="44" y="170" class="ui" font-size="45" font-weight="800">✏️ 步语</text>
  <text x="44" y="222" class="ui" font-size="29" fill="#3d454d">Hi, Huan · 今天想去哪走？</text>
  <circle cx="612" cy="165" r="20" fill="none" stroke="#111" stroke-width="5"/><path d="M628 181 l24 24" stroke="#111" stroke-width="5" stroke-linecap="round"/>
  <g transform="translate(36 308)">
    <rect x="0" y="0" width="178" height="76" rx="38" fill="#ffe6ae"/><text x="89" y="48" class="ui" font-size="27" text-anchor="middle">历史(3)</text>
    <rect x="230" y="0" width="178" height="76" rx="38" fill="#ead6ff"/><text x="319" y="48" class="ui" font-size="27" text-anchor="middle">巷子(2)</text>
    <rect x="422" y="0" width="178" height="76" rx="38" fill="#d8f3d5"/><text x="511" y="48" class="ui" font-size="27" text-anchor="middle">文化(5)</text>
  </g>
  <g transform="translate(28 455)">
    <rect x="0" y="0" width="294" height="573" rx="28" fill="#fff" filter="url(#paper)" stroke="#efeee9"/>
    <svg x="14" y="14" width="266" height="350" viewBox="0 0 680 1474" preserveAspectRatio="xMidYMid slice">$mapIllustration</svg>
    <text x="24" y="410" class="ui" font-size="30" font-weight="700">老城南线</text>
    <text x="24" y="457" class="ui en" font-size="23" fill="#69717a">2.0km  26min</text>
    <circle cx="246" cy="514" r="32" fill="#dff3d5"/><text x="246" y="525" class="ui" font-size="28" text-anchor="middle">城</text>
  </g>
  <g transform="translate(358 455)">
    <rect x="0" y="0" width="294" height="573" rx="28" fill="#fff" filter="url(#paper)" stroke="#efeee9"/>
    <rect x="14" y="14" width="266" height="350" rx="18" fill="#fff8e8"/>
    $(DrawHouse 34 80 1.1) $(DrawArch 80 228 .72) $(DrawTree 10 175 .72) $(DrawFlowers 208 250)
    <path class="route" d="M38 330 C98 260 150 300 184 226 S214 116 258 72" transform="scale(.9) translate(20 10)"/>
    <text x="24" y="410" class="ui" font-size="30" font-weight="700">安静巷子</text>
    <text x="24" y="457" class="ui en" font-size="23" fill="#69717a">1.3km  18min</text>
    <circle cx="246" cy="514" r="32" fill="#ead6ff"/><text x="246" y="525" class="ui" font-size="26" text-anchor="middle">巷</text>
  </g>
  <g filter="url(#pencil)">
    <path d="M148 1108 q38 70 74 0" stroke="#f4c431" stroke-width="18" fill="none"/>
    <path d="M470 1190 q8 32 24 0 q14 30 28 0" stroke="#64b75d" stroke-width="9" fill="none"/>
    <path d="M565 1160 q8 -22 24 0 q8 -22 24 0" stroke="#f48ab2" stroke-width="8" fill="none"/>
  </g>
  <rect x="16" y="1294" width="648" height="91" rx="44" fill="#101010"/>
  <circle cx="340" cy="1294" r="54" fill="#91d881" stroke="#101010" stroke-width="4"/><text x="340" y="1314" class="ui" font-size="66" text-anchor="middle">+</text>
  <text x="88" y="1352" class="ui" fill="#fff" font-size="33">⌂</text><text x="200" y="1352" class="ui" fill="#888" font-size="33">◉</text><text x="452" y="1352" class="ui" fill="#888" font-size="33">▦</text><text x="574" y="1352" class="ui" fill="#888" font-size="33">♙</text>
"@

$svg2 = PhoneChrome @"
  <path d="M48 126 l-20 22 20 22" class="thin"/>
  <text x="340" y="150" class="ui" font-size="35" font-weight="700" text-anchor="middle">路线详情</text>
  <g transform="translate(24 210)">
    <rect x="0" y="0" width="632" height="620" rx="16" fill="#fbf4e7" filter="url(#paper)"/>
    <svg x="0" y="0" width="632" height="620" viewBox="0 0 680 1474" preserveAspectRatio="xMidYMid slice">$mapIllustration</svg>
  </g>
  <text x="47" y="920" class="ui" font-size="48" font-weight="800">老城南线 · 文化巷行</text>
  <path d="M48 944 C190 930 300 956 450 938" stroke="#d8c3ff" stroke-width="8" fill="none" filter="url(#pencil)"/>
  <g transform="translate(46 990)">
    <rect class="chip" x="0" y="0" width="76" height="45" rx="22"/><text x="38" y="31" class="ui" font-size="22" text-anchor="middle">历史</text>
    <rect class="chip" x="106" y="0" width="76" height="45" rx="22"/><text x="144" y="31" class="ui" font-size="22" text-anchor="middle">城墙</text>
    <rect class="chip" x="212" y="0" width="102" height="45" rx="22"/><text x="263" y="31" class="ui" font-size="22" text-anchor="middle">适合漫步</text>
  </g>
  <g transform="translate(72 1116)" class="ui" font-size="26">
    <text x="0" y="0" fill="#62a955">◎</text><text x="42" y="0">2.0km</text>
    <line x1="150" y1="-28" x2="150" y2="25" stroke="#dadada"/>
    <text x="192" y="0" fill="#8d72d8">◷</text><text x="232" y="0">26min</text>
    <line x1="340" y1="-28" x2="340" y2="25" stroke="#dadada"/>
    <text x="382" y="0" fill="#e5af1f">△</text><text x="425" y="0">平坦</text>
  </g>
  <text x="65" y="1240" class="hand" font-size="27">从明城墙走进街巷，听一条城市南线的前世今生。</text>
  <path d="M72 1264 C208 1248 374 1260 510 1242" stroke="#d8c3ff" stroke-width="7" fill="none" filter="url(#pencil)"/>
  <rect x="90" y="1340" width="500" height="86" rx="43" fill="#77c85e" filter="url(#paper)"/>
  <text x="340" y="1395" class="ui" font-size="34" font-weight="700" fill="#fff" text-anchor="middle">出发 →</text>
"@

$svg3 = PhoneChrome @"
  <path d="M48 104 l-20 22 20 22" class="thin"/>
  <text x="84" y="130" class="ui en" font-size="26">My Walk 〉 6月21日</text>
  <text x="120" y="250" class="ui" font-size="55" font-weight="900">散步笔记</text>
  <path d="M0 296 C150 250 300 334 486 288" stroke="#e8d4ff" stroke-width="14" fill="none" filter="url(#pencil)"/>
  <rect x="50" y="360" width="160" height="44" rx="6" fill="#ead6ff"/><text x="65" y="392" class="ui en" font-size="28" font-weight="700">Key Points</text>
  <text x="54" y="468" class="ui" font-size="25">• 走了 2.0km，从城门进入街巷肌理</text>
  <text x="54" y="528" class="ui" font-size="25">• 在城墙砖铭里听见明代工匠责任制</text>
  <text x="54" y="588" class="ui" font-size="25">• 小西湖的更新故事，比想象中温柔</text>
  <g transform="translate(36 690)">
    <path class="routeSolid" d="M42 584 C54 470 154 450 140 350 S245 262 248 178 S330 94 470 72"/>
    <path d="M42 584 C160 536 250 620 370 540 S478 490 602 560" stroke="#ead6ff" stroke-width="6" fill="none" stroke-dasharray="16 16" filter="url(#pencil)"/>
    <circle cx="42" cy="584" r="28" fill="#3e76dd" stroke="#fff" stroke-width="7"/><circle cx="470" cy="72" r="11" fill="#3e76dd"/>
    $(DrawGate 18 405 .52)
    $(DrawMuseum 198 282 .42)
    $(DrawArch 320 148 .45)
    $(DrawTree 18 105 .66)
    $(DrawFlowers 510 410)
    <text x="266" y="414" class="hand" font-size="27">城砖上的名字</text>
    <path d="M265 430 q88 16 176 0" stroke="#e4c7ff" stroke-width="7" fill="none" filter="url(#pencil)"/>
    <text x="374" y="218" class="hand" font-size="25">老门东的牌坊</text>
    <path d="M374 234 q76 14 156 0" stroke="#f7d15a" stroke-width="7" fill="none" filter="url(#pencil)"/>
    <text x="102" y="622" class="hand en" font-size="24">START</text>
  </g>
  <circle cx="586" cy="1326" r="58" fill="#91d881" filter="url(#paper)"/><text x="586" y="1348" class="ui" font-size="56" text-anchor="middle">♬</text>
"@

$svg4 = PhoneChrome @"
  <path d="M48 118 l-20 22 20 22" class="thin"/>
  <text x="340" y="142" class="ui" font-size="38" font-weight="800" text-anchor="middle">你的散步Plog</text>
  <path d="M205 177 C260 135 307 205 364 166 S430 184 474 168" stroke="#e8d4ff" stroke-width="12" fill="none" filter="url(#pencil)"/>
  <g transform="translate(68 260) rotate(-5 270 250)">
    <rect x="0" y="0" width="552" height="500" rx="14" fill="#fffaf0" filter="url(#paper)" stroke="#eee7da"/>
    <rect x="36" y="50" width="480" height="290" rx="22" fill="#fbf4e7"/>
    <svg x="36" y="50" width="480" height="290" viewBox="0 0 680 1474" preserveAspectRatio="xMidYMid slice">$mapIllustration</svg>
    <path d="M70 278 C160 220 222 275 300 212 S405 185 492 96" stroke="#fff" stroke-width="9" fill="none" stroke-linecap="round"/>
    <text x="74" y="420" class="hand" font-size="28">今天从中华门一路走到乌衣巷</text>
    <path d="M190 445 C274 430 350 450 432 432" stroke="#d8c3ff" stroke-width="7" fill="none" filter="url(#pencil)"/>
  </g>
  <g transform="translate(64 820) rotate(3 270 150)">
    <rect x="0" y="0" width="552" height="250" rx="14" fill="#fffaf0" filter="url(#paper)" stroke="#eee7da"/>
    <rect x="34" y="38" width="265" height="172" rx="16" fill="#fbf4e7"/>
    $(DrawHouse 72 56 .72) $(DrawTree 178 34 .72) $(DrawFlowers 42 132)
    <text x="335" y="94" class="hand" font-size="29">小西湖的</text>
    <text x="335" y="136" class="hand" font-size="29">共生院故事</text>
    <path d="M334 166 q84 20 170 0" stroke="#8fd17b" stroke-width="7" fill="none" filter="url(#pencil)"/>
  </g>
  <g filter="url(#pencil)">
    <path d="M66 1210 l13 28 28 13 -28 13 -13 28 -13 -28 -28 -13 28 -13z" fill="#fff9d9" stroke="#f0c23b" stroke-width="5"/>
    <path d="M560 770 q32 10 18 38 q36 -2 28 28" stroke="#ef6ba2" stroke-width="7" fill="none"/>
    <path d="M102 235 q14 -34 32 0 M535 1140 q12 -30 28 0" stroke="#61b85b" stroke-width="8" fill="none"/>
  </g>
  <rect x="34" y="1315" width="312" height="90" rx="45" fill="#9ada82"/>
  <text x="190" y="1371" class="ui" font-size="30" font-weight="700" text-anchor="middle">分享到小红书 ↗</text>
  <rect x="374" y="1315" width="272" height="90" rx="45" fill="#fff" stroke="#111" stroke-width="3"/>
  <text x="510" y="1371" class="ui" font-size="30" font-weight="500" text-anchor="middle">保存全部 ⇩</text>
"@

$svgs = @($svg1, $svg2, $svg3, $svg4)
$names = @("slide13-1-home.svg", "slide13-2-detail.svg", "slide13-3-notes.svg", "slide13-4-plog.svg")
for ($i = 0; $i -lt 4; $i++) {
  Save-Svg $names[$i] $svgs[$i]
}

$html = [System.IO.File]::ReadAllText($HtmlPath, [System.Text.Encoding]::UTF8)
$match = [regex]::Match($html, '<section class="slide dark" data-animate="product-grid">.*?</section>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $match.Success) { throw "Slide 13 section not found." }

$section = $match.Value
$script:idx = 0
$script:svgs = $svgs
$sectionNew = [regex]::Replace($section, 'src="data:image/(?:png|jpeg|svg\+xml);base64,[^"]+"', {
  param($m)
  if ($script:idx -ge 4) { return $m.Value }
  $uri = ConvertTo-DataUri $script:svgs[$script:idx]
  $script:idx++
  return 'src="' + $uri + '"'
}, 4)

$sectionNew = $sectionNew.Replace('按兴趣筛选：湖边 / 巷子 / 咖啡', '按兴趣筛选：历史 / 巷子 / 城墙')

$htmlNew = $html.Substring(0, $match.Index) + $sectionNew + $html.Substring($match.Index + $match.Length)
[System.IO.File]::WriteAllText($HtmlPath, $htmlNew, [System.Text.UTF8Encoding]::new($false))

Write-Output "Updated slide 13 images in $HtmlPath"
Write-Output "Backup: $BackupPath"
Write-Output "SVG assets: $AssetDir"
