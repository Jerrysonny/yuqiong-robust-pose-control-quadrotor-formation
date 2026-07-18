param(
    [Parameter(Mandatory = $true)]
    [string]$OutputDir
)

$ErrorActionPreference = 'Stop'

function Set-CellFormula {
    param($Shape, [string]$Cell, [string]$Formula)
    $Shape.CellsU($Cell).FormulaU = $Formula
}

function Add-Box {
    param(
        $Page,
        [double]$X,
        [double]$Y,
        [double]$Width,
        [double]$Height,
        [string]$Text,
        [string]$Fill,
        [string]$Line = 'RGB(55,65,81)',
        [double]$FontPt = 10.4
    )
    $shape = $Page.DrawRectangle($X - $Width / 2, $Y - $Height / 2, $X + $Width / 2, $Y + $Height / 2)
    $shape.Text = $Text
    Set-CellFormula $shape 'FillForegnd' $Fill
    Set-CellFormula $shape 'FillPattern' '1'
    Set-CellFormula $shape 'LineColor' $Line
    Set-CellFormula $shape 'LineWeight' '0.9 pt'
    Set-CellFormula $shape 'Rounding' '0.08 in'
    Set-CellFormula $shape 'Char.Font' 'FONT("宋体")'
    Set-CellFormula $shape 'Char.Size' ("{0} pt" -f $FontPt)
    Set-CellFormula $shape 'Char.Color' 'RGB(25,30,38)'
    Set-CellFormula $shape 'Para.HorzAlign' '1'
    Set-CellFormula $shape 'VerticalAlign' '1'
    return $shape
}

function Add-Label {
    param($Page, [double]$X, [double]$Y, [double]$Width, [double]$Height, [string]$Text, [double]$FontPt = 9.0)
    $shape = $Page.DrawRectangle($X - $Width / 2, $Y - $Height / 2, $X + $Width / 2, $Y + $Height / 2)
    $shape.Text = $Text
    Set-CellFormula $shape 'FillPattern' '0'
    Set-CellFormula $shape 'LinePattern' '0'
    Set-CellFormula $shape 'Char.Font' 'FONT("宋体")'
    Set-CellFormula $shape 'Char.Size' ("{0} pt" -f $FontPt)
    Set-CellFormula $shape 'Char.Color' 'RGB(73,80,87)'
    Set-CellFormula $shape 'Para.HorzAlign' '1'
    Set-CellFormula $shape 'VerticalAlign' '1'
    return $shape
}

function Add-Line {
    param(
        $Page,
        [double]$X1,
        [double]$Y1,
        [double]$X2,
        [double]$Y2,
        [bool]$Arrow = $true,
        [bool]$Dashed = $false
    )
    $line = $Page.DrawLine($X1, $Y1, $X2, $Y2)
    Set-CellFormula $line 'LineColor' 'RGB(55,65,81)'
    Set-CellFormula $line 'LineWeight' '0.9 pt'
    if ($Arrow) {
        Set-CellFormula $line 'EndArrow' '13'
        Set-CellFormula $line 'EndArrowSize' '2'
    }
    if ($Dashed) {
        Set-CellFormula $line 'LinePattern' '2'
    }
    return $line
}

function New-VisioDocument {
    param($Application, [double]$Width, [double]$Height)
    $document = $Application.Documents.Add('')
    $page = $document.Pages.Item(1)
    $page.PageSheet.CellsU('PageWidth').FormulaU = ("{0} in" -f $Width)
    $page.PageSheet.CellsU('PageHeight').FormulaU = ("{0} in" -f $Height)
    $page.PageSheet.CellsU('PageLeftMargin').FormulaU = '0.12 in'
    $page.PageSheet.CellsU('PageRightMargin').FormulaU = '0.12 in'
    $page.PageSheet.CellsU('PageTopMargin').FormulaU = '0.12 in'
    $page.PageSheet.CellsU('PageBottomMargin').FormulaU = '0.12 in'
    return @($document, $page)
}

function Export-Page {
    param($Document, $Page, [string]$BasePath)
    $Document.SaveAs("$BasePath.vsdx")
    $Page.Export("$BasePath.svg")
    $Page.Export("$BasePath.png")
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputDir)
if (Test-Path -LiteralPath $resolvedOutput) {
    throw "Output directory already exists: $resolvedOutput"
}
New-Item -ItemType Directory -Path $resolvedOutput | Out-Null

$visio = $null
try {
    $visio = New-Object -ComObject Visio.Application
    $visio.Visible = $false

    # Figure 2-1: official closed-loop system.
    $pair = New-VisioDocument $visio 11.4 4.1
    $doc = $pair[0]
    $page = $pair[1]

    $teal = 'RGB(220,242,239)'
    $blue = 'RGB(225,235,248)'
    $amber = 'RGB(250,238,210)'
    $green = 'RGB(226,241,224)'

    Add-Box $page 1.05 2.65 1.82 1.12 "位置参考`n期望位置向量" $teal -FontPt 10.8 | Out-Null
    Add-Box $page 3.25 2.65 1.95 1.12 "赛题PID控制器`n位置、姿态与混控" $blue -FontPt 10.8 | Out-Null
    Add-Box $page 5.55 2.65 1.95 1.12 "四路电机与旋翼`n电机指令" $amber -FontPt 10.8 | Out-Null
    Add-Box $page 7.85 2.65 1.95 1.12 "刚体机架`n气动力与地面接触" $amber -FontPt 10.8 | Out-Null
    Add-Box $page 10.15 2.65 1.80 1.12 "位置与姿态传感器`np, φ, θ, ψ" $green -FontPt 10.8 | Out-Null

    Add-Line $page 1.96 2.65 2.27 2.65 | Out-Null
    Add-Line $page 4.23 2.65 4.57 2.65 | Out-Null
    Add-Line $page 6.53 2.65 6.87 2.65 | Out-Null
    Add-Line $page 8.83 2.65 9.24 2.65 | Out-Null

    Add-Line $page 10.15 2.12 10.15 0.92 $false | Out-Null
    Add-Line $page 10.15 0.92 3.25 0.92 $false | Out-Null
    Add-Line $page 3.25 0.92 3.25 2.08 $true | Out-Null
    Add-Label $page 6.7 0.58 3.4 0.42 "位置 p 与姿态角 φ、θ、ψ 反馈" 9.6 | Out-Null

    Export-Page $doc $page (Join-Path $resolvedOutput 'figure_2_1_official_closed_loop')
    $doc.Close()
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($page) | Out-Null
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($doc) | Out-Null

    # Figure 2-2: cascaded PID topology provided with the competition model.
    $pair = New-VisioDocument $visio 11.4 5.5
    $doc = $pair[0]
    $page = $pair[1]

    Add-Box $page 0.75 4.35 1.15 0.78 "X、Y位置参考" $teal | Out-Null
    Add-Box $page 2.05 4.35 1.05 0.78 "水平位置`n误差" 'RGB(242,244,247)' | Out-Null
    Add-Box $page 3.35 4.35 1.05 0.78 "位置PD" $blue | Out-Null
    Add-Box $page 4.65 4.35 1.05 0.78 "期望姿态" $teal | Out-Null
    Add-Box $page 5.95 4.35 1.05 0.78 "±15°限幅" $amber | Out-Null
    Add-Box $page 7.25 4.35 1.15 0.78 "滚转/俯仰`nPD" $blue | Out-Null

    Add-Box $page 0.75 2.85 1.15 0.78 "Z位置参考" $teal | Out-Null
    Add-Box $page 2.05 2.85 1.05 0.78 "高度误差" 'RGB(242,244,247)' | Out-Null
    Add-Box $page 3.35 2.85 1.05 0.78 "高度PID" $blue | Out-Null
    Add-Box $page 7.25 2.85 1.15 0.78 "总推力`n控制量" $teal | Out-Null

    Add-Box $page 0.75 1.35 1.15 0.78 "偏航参考`n固定为0" $teal | Out-Null
    Add-Box $page 2.05 1.35 1.05 0.78 "偏航误差" 'RGB(242,244,247)' | Out-Null
    Add-Box $page 3.35 1.35 1.05 0.78 "偏航P" $blue | Out-Null
    Add-Box $page 7.25 1.35 1.15 0.78 "偏航`n控制量" $teal | Out-Null

    Add-Box $page 9.0 2.85 1.35 1.10 "静态四电机混控" $green | Out-Null
    Add-Box $page 10.75 2.85 0.95 1.10 "四路电机`n指令" $amber | Out-Null

    foreach ($y in 4.35, 2.85, 1.35) {
        Add-Line $page 1.33 $y 1.52 $y | Out-Null
        Add-Line $page 2.58 $y 2.82 $y | Out-Null
    }
    Add-Line $page 3.88 4.35 4.12 4.35 | Out-Null
    Add-Line $page 5.18 4.35 5.42 4.35 | Out-Null
    Add-Line $page 6.48 4.35 6.67 4.35 | Out-Null
    Add-Line $page 3.88 2.85 6.67 2.85 | Out-Null
    Add-Line $page 3.88 1.35 6.67 1.35 | Out-Null

    Add-Line $page 7.83 4.35 8.33 3.28 | Out-Null
    Add-Line $page 7.83 2.85 8.33 2.85 | Out-Null
    Add-Line $page 7.83 1.35 8.33 2.42 | Out-Null
    Add-Line $page 9.68 2.85 10.27 2.85 | Out-Null

    Add-Box $page 4.75 0.45 3.25 0.52 "传感器反馈：位置 p，姿态角 φ、θ、ψ" 'RGB(242,244,247)' 'RGB(125,132,140)' 9.5 | Out-Null
    Add-Line $page 3.12 0.45 2.68 0.45 $false $true | Out-Null
    Add-Line $page 2.68 0.45 2.68 3.85 $false $true | Out-Null
    foreach ($y in 4.35, 2.85, 1.35) {
        $branchY = $y - 0.54
        Add-Line $page 2.68 $branchY 2.05 $branchY $false $true | Out-Null
        Add-Line $page 2.05 $branchY 2.05 ($y - 0.39) $true $true | Out-Null
    }

    Export-Page $doc $page (Join-Path $resolvedOutput 'figure_2_2_pid_topology')
    $doc.Close()
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($page) | Out-Null
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($doc) | Out-Null
}
finally {
    if ($null -ne $visio) {
        $visio.Quit()
        [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($visio) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

$files = Get-ChildItem -LiteralPath $resolvedOutput -File
if ($files.Count -ne 6) {
    throw "Expected 6 Visio assets, found $($files.Count)"
}
$files | Select-Object Name, Length | Sort-Object Name
