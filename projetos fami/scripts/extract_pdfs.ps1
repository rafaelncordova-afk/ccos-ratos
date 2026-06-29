$PDFTOTEXT = "C:\Users\RafaelCordova\AppData\Local\Programs\Git\mingw64\bin\pdftotext.exe"
$CLIENTDIR = "C:\Users\RafaelCordova\IA Trabalho\clientes"

$results = @()

Get-ChildItem $CLIENTDIR -Directory | Where-Object { $_.Name -ne '_indice' } | ForEach-Object {
    $folder = $_.Name
    $code = if ($folder -match '- (\d+)$') { $matches[1] } else { "" }
    $clientName = ($folder -replace ' - \d+$', '').Trim()

    $pdfPath = Join-Path $_.FullName "relatorios\XPerformance - $code - Ref.08.06.pdf"

    if (-not (Test-Path $pdfPath)) {
        $results += [PSCustomObject]@{
            Cliente = $clientName
            Codigo = $code
            HasPDF = $false
            RawText = ""
        }
        return
    }

    $text = & $PDFTOTEXT -f 2 -l 4 $pdfPath - 2>$null

    $results += [PSCustomObject]@{
        Cliente = $clientName
        Codigo = $code
        HasPDF = $true
        RawText = $text -join "`n"
    }
}

# Save results to JSON for further processing
$results | ConvertTo-Json -Depth 5 | Set-Content "C:\Users\RafaelCordova\IA Trabalho\pdf_data.json" -Encoding UTF8
Write-Host "Done: $($results.Count) clients processed"
Write-Host "With PDF: $(($results | Where-Object { $_.HasPDF }).Count)"
Write-Host "Without PDF: $(($results | Where-Object { -not $_.HasPDF }).Count)"
