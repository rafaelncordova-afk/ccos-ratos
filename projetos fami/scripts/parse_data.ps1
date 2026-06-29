$data = Get-Content "C:\Users\RafaelCordova\IA Trabalho\pdf_data.json" -Encoding UTF8 | ConvertFrom-Json

function Parse-Number($str) {
    if ($null -eq $str -or $str -eq "" -or $str -eq "N/D") { return $null }
    $clean = $str -replace '%','' -replace '\s','' -replace ',','.'
    try { return [double]$clean } catch { return $null }
}

function Format-Pct($val) {
    if ($null -eq $val) { return "N/D" }
    $s = "{0:N2}" -f $val
    $s = $s -replace '\.', ','
    return $s + "%"
}

function Format-Money($val) {
    if ($null -eq $val) { return "N/D" }
    # Use Brazilian number format
    return ("R$ " + ("{0:N2}" -f $val) -replace '\.', 'X' -replace ',', '.' -replace 'X', ',')
}

$output = @()

foreach ($client in $data) {
    $row = [ordered]@{
        Cliente = $client.Cliente
        Codigo = $client.Codigo
        HasPDF = $client.HasPDF
        PatrimMai = "N/D"
        GanhoMai = "N/D"
        RentMai = "N/D"
        PctCDIMai = "N/D"
        RentJanMai = "N/D"
        PctCDIJanMai = "N/D"
        Rent12M = "N/D"
        PctCDI12M = "N/D"
        Rent24M = "N/D"
        PctCDI24M = "N/D"
        IPCAAno = "N/D"
        IPCA12M = "N/D"
        IPCA24M = "N/D"
        GanhoRealAno = "N/D"
        GanhoReal12M = "N/D"
        GanhoReal24M = "N/D"
        PctCDIJanMaiNum = $null
    }

    if (-not $client.HasPDF) {
        $output += $row
        continue
    }

    $text = $client.RawText

    # =====================================================
    # PAGE 2: Benchmark table
    # Format (5 cols): Portfolio CDI Ibovespa IPCA Dolar
    # Row "12M": Rent12M CDI_ref_12M Ibov_12M IPCA_12M Dolar_12M
    # Row "24M": Rent24M CDI_ref_24M Ibov_24M IPCA_24M Dolar_24M
    # =====================================================

    # The benchmark table has rows like:
    # "12M 13,50% 13,81% 21,47%\n4,47% -5,27%"  (split across lines due to PDF layout)
    # So we need to match across newlines for the IPCA (4th value)

    # Normalize: replace \r\n with \n, collapse multiple spaces
    $t = $text -replace '\r\n', "`n" -replace '\r', "`n"

    # Extract Resumo section for Rent 12M, 24M, %CDI 12M, 24M
    # Pattern: "Rentabilidade X% Y%\nZ%\nW%" - split across lines
    # From the actual text:
    # "Rentabilidade 0,23% 5,73% 13,50%\n26,85%"
    # This gives us: Mes=0,23%, Ano=5,73%, 12M=13,50%, 24M=26,85%
    if ($t -match 'Rentabilidade\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s*\n\s*([-\d,]+%)') {
        $row.Rent12M = $matches[3]
        $row.Rent24M = $matches[4]
    } elseif ($t -match 'Rentabilidade\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.Rent12M = $matches[3]
        $row.Rent24M = $matches[4]
    }

    # %CDI row: "%CDI 85,84% 96,32% 97,73% 97,21%"
    if ($t -match '%CDI\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.PctCDI12M = $matches[3]
        $row.PctCDI24M = $matches[4]
    }

    # IPCA from benchmark table rows:
    # "12M 13,50% 13,81% 21,47%\n4,47% -5,27%" -> IPCA 12M = 4th value = 4,47%
    # "24M 26,85% 27,62% 36,13% 10,06% -7,00%" -> IPCA 24M = 4th value = 10,06%
    # Also need Ano row for IPCA Ano
    # "Ano 5,73% 5,94% 4,68% 3,20% -6,05%" -> IPCA Ano = 4th = 3,20%

    # Try matching "Ano" benchmark row (all on one line)
    if ($t -match 'Ano\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.IPCAAno = $matches[4]
    }

    # 12M benchmark row - may split across lines
    if ($t -match '12M\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s*\n\s*([-\d,]+%)\s+([-\d,]+%)') {
        # Split: first 3 on line 1, last 2 on line 2
        # Portfolio CDI Ibov | IPCA Dolar
        $row.IPCA12M = $matches[4]
    } elseif ($t -match '12M\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.IPCA12M = $matches[4]
    }

    # 24M benchmark row
    if ($t -match '24M\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.IPCA24M = $matches[4]
    } elseif ($t -match '24M\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s*\n\s*([-\d,]+%)\s+([-\d,]+%)') {
        $row.IPCA24M = $matches[4]
    }

    # =====================================================
    # PAGE 4: Monthly table
    # Row order in columns: jun/26 mai/26 abr/26 mar/26 fev/26 jan/26 dez/25 ...
    # =====================================================

    # Patrimônio final - get the 2nd value (mai/26), skipping jun/26
    # "Patrimônio final\nR$ 3.338.459,48 R$ 3.328.383,77 ..."
    # The jun value may not have proper sep, get 2nd R$ value
    if ($t -match 'Patrim.nio final\s*\n\s*R\$\s*([\d\.,]+)\s+R\$\s*([\d\.,]+)') {
        $row.PatrimMai = "R$ " + $matches[2]
    }

    # Ganho financeiro - 2nd value (mai/26)
    if ($t -match 'Ganho financeiro\s*\n\s*R\$\s*([\d\.,]+)\s+R\$\s*([\d\.,]+)') {
        $row.GanhoMai = "R$ " + $matches[2]
    }

    # Monthly Rent. row from bottom table: jun mai abr mar fev jan ...
    # "Rent.\n0,23% 1,25% 1,00% 1,01% 0,94% 1,17% ..."
    if ($t -match 'Rent\.\s*\n\s*([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        # jun mai abr mar fev jan
        $row.RentMai = $matches[2]
        $rentJan = $matches[6]
        $rentFev = $matches[5]
        $rentMar = $matches[4]
        $rentAbr = $matches[3]
        $rentMai_val = $matches[2]
    } elseif ($t -match 'Rent\.\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.RentMai = $matches[2]
        $rentJan = $matches[6]
        $rentFev = $matches[5]
        $rentMar = $matches[4]
        $rentAbr = $matches[3]
        $rentMai_val = $matches[2]
    }

    # Monthly %CDI row
    if ($t -match '%CDI\s*\n\s*([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.PctCDIMai = $matches[2]
        $cdiJan = $matches[6]
        $cdiFev = $matches[5]
        $cdiMar = $matches[4]
        $cdiAbr = $matches[3]
        $cdiMai_val = $matches[2]
    } elseif ($t -match '%CDI\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)\s+([-\d,]+%)') {
        $row.PctCDIMai = $matches[2]
        $cdiJan = $matches[6]
        $cdiFev = $matches[5]
        $cdiMar = $matches[4]
        $cdiAbr = $matches[3]
        $cdiMai_val = $matches[2]
    }

    # =====================================================
    # CALCULATIONS
    # =====================================================
    $rJ  = Parse-Number $rentJan
    $rF  = Parse-Number $rentFev
    $rM  = Parse-Number $rentMar
    $rA  = Parse-Number $rentAbr
    $rMai = Parse-Number $rentMai_val
    $cJ  = Parse-Number $cdiJan
    $cF  = Parse-Number $cdiFev
    $cM  = Parse-Number $cdiMar
    $cA  = Parse-Number $cdiAbr
    $cMai = Parse-Number $cdiMai_val

    if ($null -ne $rJ -and $null -ne $rF -and $null -ne $rM -and $null -ne $rA -and $null -ne $rMai) {
        $rentJanMai = (1 + $rJ/100) * (1 + $rF/100) * (1 + $rM/100) * (1 + $rA/100) * (1 + $rMai/100) - 1
        $row.RentJanMai = Format-Pct ($rentJanMai * 100)

        if ($null -ne $cJ -and $null -ne $cF -and $null -ne $cM -and $null -ne $cA -and $null -ne $cMai -and
            $cJ -ne 0 -and $cF -ne 0 -and $cM -ne 0 -and $cA -ne 0 -and $cMai -ne 0) {

            $cdiJ_v   = ($rJ/100)   / ($cJ/100)
            $cdiF_v   = ($rF/100)   / ($cF/100)
            $cdiM_v   = ($rM/100)   / ($cM/100)
            $cdiA_v   = ($rA/100)   / ($cA/100)
            $cdiMai_v = ($rMai/100) / ($cMai/100)

            $cdiJanMai = (1 + $cdiJ_v) * (1 + $cdiF_v) * (1 + $cdiM_v) * (1 + $cdiA_v) * (1 + $cdiMai_v) - 1

            if ($cdiJanMai -ne 0) {
                $pctCDIJanMai = $rentJanMai / $cdiJanMai * 100
                $row.PctCDIJanMai = Format-Pct $pctCDIJanMai
                $row.PctCDIJanMaiNum = $pctCDIJanMai
            }
        }

        $ipca_ano = Parse-Number $row.IPCAAno
        if ($null -ne $ipca_ano) {
            $ganhoRealAno = (1 + $rentJanMai) / (1 + $ipca_ano/100) - 1
            $row.GanhoRealAno = Format-Pct ($ganhoRealAno * 100)
        }
    }

    $rent12m_n = Parse-Number $row.Rent12M
    $ipca12m_n = Parse-Number $row.IPCA12M
    if ($null -ne $rent12m_n -and $null -ne $ipca12m_n) {
        $gr12 = (1 + $rent12m_n/100) / (1 + $ipca12m_n/100) - 1
        $row.GanhoReal12M = Format-Pct ($gr12 * 100)
    }

    $rent24m_n = Parse-Number $row.Rent24M
    $ipca24m_n = Parse-Number $row.IPCA24M
    if ($null -ne $rent24m_n -and $null -ne $ipca24m_n) {
        $gr24 = (1 + $rent24m_n/100) / (1 + $ipca24m_n/100) - 1
        $row.GanhoReal24M = Format-Pct ($gr24 * 100)
    }

    $output += $row
}

# Sort by %CDI Jan-Mai descending; N/D goes to end
$withCDI    = $output | Where-Object { $null -ne $_.PctCDIJanMaiNum } | Sort-Object { $_.PctCDIJanMaiNum } -Descending
$withoutCDI = $output | Where-Object { $null -eq $_.PctCDIJanMaiNum }
$sorted = @($withCDI) + @($withoutCDI)

# Markdown table
$header  = "| Cliente | Código | Patrimônio mai | Ganho mai | Rent. mai | %CDI mai | Rent. Jan-Mai | %CDI Jan-Mai | Rent. 12M | %CDI 12M | Rent. 24M | %CDI 24M | IPCA Ano | IPCA 12M | IPCA 24M | Ganho Real Ano | Ganho Real 12M | Ganho Real 24M |"
$divider = "|---------|--------|----------------|-----------|-----------|----------|---------------|--------------|-----------|----------|-----------|----------|----------|----------|----------|----------------|----------------|----------------|"

$lines = @($header, $divider)

foreach ($r in $sorted) {
    if (-not $r.HasPDF) {
        $line = "| $($r.Cliente) | $($r.Codigo) | | | | | | | | | | | | | | | | |"
    } else {
        $line = "| $($r.Cliente) | $($r.Codigo) | $($r.PatrimMai) | $($r.GanhoMai) | $($r.RentMai) | $($r.PctCDIMai) | $($r.RentJanMai) | $($r.PctCDIJanMai) | $($r.Rent12M) | $($r.PctCDI12M) | $($r.Rent24M) | $($r.PctCDI24M) | $($r.IPCAAno) | $($r.IPCA12M) | $($r.IPCA24M) | $($r.GanhoRealAno) | $($r.GanhoReal12M) | $($r.GanhoReal24M) |"
    }
    $lines += $line
}

$lines | Set-Content "C:\Users\RafaelCordova\IA Trabalho\tabela_clientes.md" -Encoding UTF8
Write-Host "Table saved. Total rows: $($sorted.Count)"

# Without PDF list
Write-Host ""
Write-Host "=== SEM PDF ==="
$output | Where-Object { -not $_.HasPDF } | ForEach-Object { Write-Host "- $($_.Cliente) ($($_.Codigo))" }

# Sample debug
Write-Host ""
Write-Host "=== SAMPLE (first 5 sorted) ==="
$sorted | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.Cliente): RentJanMai=$($_.RentJanMai) %CDI=$($_.PctCDIJanMai) Rent12M=$($_.Rent12M) %CDI12M=$($_.PctCDI12M) IPCAAno=$($_.IPCAAno) IPCA12M=$($_.IPCA12M)"
}

# Check for N/D issues
Write-Host ""
Write-Host "=== N/D COUNTS ==="
$fields = @('Rent12M','PctCDI12M','Rent24M','PctCDI24M','IPCAAno','IPCA12M','IPCA24M','RentJanMai','PctCDIJanMai')
foreach ($f in $fields) {
    $ndCount = ($output | Where-Object { $_.HasPDF -and $_.$f -eq 'N/D' }).Count
    Write-Host "  $f N/D: $ndCount"
}
