$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent
$iconStream = [System.IO.MemoryStream]::new()
$writer = [System.IO.BinaryWriter]::new($iconStream)
$sizes = @(16, 20, 24, 32, 40, 48, 64, 128, 256)
$images = @()
foreach ($size in $sizes) {
    $bitmap = [System.Drawing.Bitmap]::new($size * 4, $size * 4)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.ScaleTransform($size * 4 / 256.0, $size * 4 / 256.0)
    $background = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#202020'))
    $accent = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#60CDFF'), 12)
    $foreground = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $graphics.FillEllipse($background, 8, 8, 240, 240)
    $graphics.DrawEllipse($accent, 14, 14, 228, 228)
    $points = [System.Drawing.PointF[]]@([System.Drawing.PointF]::new(103,72), [System.Drawing.PointF]::new(103,184), [System.Drawing.PointF]::new(184,128))
    $graphics.FillPolygon($foreground, $points)
    $output = [System.Drawing.Bitmap]::new($size, $size)
    $scaled = [System.Drawing.Graphics]::FromImage($output)
    $scaled.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $scaled.DrawImage($bitmap, 0, 0, $size, $size)
    # DIB-backed ICO entries work with Delphi's bundled resource compiler.
    $dib = [System.IO.MemoryStream]::new()
    $pixels = [System.IO.BinaryWriter]::new($dib)
    $maskStride = [int]([Math]::Ceiling($size / 32.0) * 4)
    $pixels.Write([uint32]40); $pixels.Write([int]$size); $pixels.Write([int]($size * 2))
    $pixels.Write([uint16]1); $pixels.Write([uint16]32); $pixels.Write([uint32]0)
    $pixels.Write([uint32]($size * $size * 4 + $maskStride * $size))
    1..4 | ForEach-Object { $pixels.Write([uint32]0) }
    for ($y = $size - 1; $y -ge 0; $y--) {
        for ($x = 0; $x -lt $size; $x++) {
            $pixel = $output.GetPixel($x, $y)
            $pixels.Write([byte]$pixel.B); $pixels.Write([byte]$pixel.G)
            $pixels.Write([byte]$pixel.R); $pixels.Write([byte]$pixel.A)
        }
    }
    for ($y = $size - 1; $y -ge 0; $y--) {
        $mask = [byte[]]::new($maskStride)
        for ($x = 0; $x -lt $size; $x++) {
            if ($output.GetPixel($x, $y).A -eq 0) {
                $byteIndex = [int][Math]::Floor($x / 8.0)
                $mask[$byteIndex] = $mask[$byteIndex] -bor (128 -shr ($x % 8))
            }
        }
        $pixels.Write($mask)
    }
    $images += ,$dib.ToArray()
    if ($size -eq 256) { $output.Save((Join-Path $projectRoot 'app_icon.png'), [System.Drawing.Imaging.ImageFormat]::Png) }
    $pixels.Dispose(); $dib.Dispose(); $scaled.Dispose(); $output.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
    $background.Dispose(); $accent.Dispose(); $foreground.Dispose()
}
$writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($index = 0; $index -lt $sizes.Count; $index++) {
    $dimension = $sizes[$index] % 256
    $writer.Write([byte]$dimension); $writer.Write([byte]$dimension)
    $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]32)
    $writer.Write([uint32]$images[$index].Length); $writer.Write([uint32]$offset)
    $offset += $images[$index].Length
}
foreach ($bytes in $images) { $writer.Write([byte[]]$bytes) }
[System.IO.File]::WriteAllBytes((Join-Path $projectRoot 'app_icon.ico'), $iconStream.ToArray())
$writer.Dispose(); $iconStream.Dispose()
