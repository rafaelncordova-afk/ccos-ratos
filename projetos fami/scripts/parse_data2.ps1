# Parse all client PDF data and build consolidated table
$data = Get-Content "C:\Users\RafaelCordova\IA Trabalho\pdf_data.json" -Encoding UTF8 | ConvertFrom-Json

function Parse-Number($str) {
    if ($null -eq $str -or $str -eq "" -or $str -eq "N/D") { return $null }
    # Remove % and spaces; remove thousands separator (period before comma group); replace decimal comma with dot
    $clean = $str -replace '%','' -replace '\s',''
    # Handle Brazilian number format: 1.234,56 -> 1234.56
    # Remove periods used as thousands separators (period followed by 3 digits then comma or end)
    $clean = [regex]::Replace($clean, '\.(\d{3})(?=[\d,])', '$1')
    $clean = $clean -replace ',','.'
    try { return [double]$clean } catch { return $null }
}

function Format-Pct($val) {
    if ($null -eq $val) { return "N/D" }
    $s = [string]("{0:N2}" -f $val)
    $s = $s -replace '\.', ','
    return $s + "%"
}

# Extract all numbers from a segment of text that follows a keyword
# Returns array of number strings (with % sign)
function Extract-Numbers-After($text, $keyword, $maxCount) {
    # Find position of keyword, then extract all %-numbers after it
    $pos = $text.IndexOf($keyword)
    if ($pos -lt 0) { return @() }
    $segment = $text.Substring($pos + $keyword.Length, [Math]::Min(500, $text.Length - $pos - $keyword.Length))
    # Match all percent values (including negative, with optional thousands separator)
    $matches = [regex]::Matches($segment, '-?[\d]+(?:\.[\d]{3})*,[\d]+%')
    $result = @()
    foreach ($m in $matches) {
        if ($result.Count -ge $maxCount) { break }
        $result += $m.Value
    }
    return $result
}

$output = @()
$debugLines = @()

foreach ($client in $data) {
    # Reset all per-client variables to avoid carry-over between iterations
    $rentJan = $null; $rentFev = $null; $rentMar = $null; $rentAbr = $null; $rentMai_v = $null
    $cdiJan = $null; $cdiFev = $null; $cdiMar = $null; $cdiAbr = $null; $cdiMai_v = $null

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
    # Normalize line endings
    $t = $text -replace '\r\n', "`n" -replace '\r', "`n"

    # =====================================================
    # RESUMO: Rentabilidade row -> Mes Ano 12M 24M (4 values)
    # =====================================================
    $rentVals = Extract-Numbers-After $t "Rentabilidade" 4
    # Filter out the "Resumo" table values vs benchmark values
    # The Resumo table comes after "RESUMO DE INFORMAÇÕES DA CARTEIRA"
    $resumoIdx = $t.IndexOf("RESUMO DE INFORMA")
    if ($resumoIdx -lt 0) { $resumoIdx = $t.IndexOf("Resumo de Informa") }

    if ($resumoIdx -gt 0) {
        $resumoText = $t.Substring($resumoIdx)
        $resumoLines = $resumoText -split "`n"

        # Find lines starting with "Rentabilidade" (lowercase r, not RENTABILIDADE) and "%CDI"
        # We need to reconstruct the full row (may span 2 lines due to PDF layout)
        # Only look within first 30 lines of RESUMO section to avoid catching page 3/4 content
        $rentLineIdx = -1
        $cdiLineIdx = -1
        $maxSearchLines = [Math]::Min(30, $resumoLines.Count)
        for ($li = 0; $li -lt $maxSearchLines; $li++) {
            # Match "Rentabilidade" followed by space and a number (not "RENTABILIDADE HIST...")
            if ($resumoLines[$li] -match '^Rentabilidade\s+[-\d,]') { $rentLineIdx = $li }
            if ($resumoLines[$li] -match '^%CDI\s') { $cdiLineIdx = $li }
        }

        # Extract rent values: combine the Rentabilidade line with the next non-empty line
        # (because sometimes the values wrap: "Rentabilidade X%\nY% Z% W%")
        if ($rentLineIdx -ge 0) {
            $rentCombined = $resumoLines[$rentLineIdx]
            # Look ahead for continuation (next line that has % values and is NOT a new keyword)
            if ($rentLineIdx + 1 -lt $resumoLines.Count) {
                $nextLine = $resumoLines[$rentLineIdx + 1]
                if ($nextLine -match '^[-\d,\.]+%') {
                    $rentCombined = $rentCombined + " " + $nextLine
                }
            }
            # Extract numbers from combined line, but stop at "-" standalone (no data)
            # Replace " - " and trailing " -" with end marker
            $rentCombined = $rentCombined -replace '\s+-$','' -replace '\s+-\s*$',''
            $rentVals2 = [regex]::Matches($rentCombined, '-?[\d]+(?:\.[\d]{3})*,[\d]+%')
            $rentVals2 = $rentVals2 | ForEach-Object { $_.Value }

            if ($rentVals2.Count -ge 4) {
                $row.Rent12M = $rentVals2[2]
                $row.Rent24M = $rentVals2[3]
            } elseif ($rentVals2.Count -eq 3) {
                $row.Rent12M = $rentVals2[1]
                $row.Rent24M = $rentVals2[2]
            }
            # Count < 3: not enough data (new client), leave as N/D
        }

        # Extract %CDI values similarly
        if ($cdiLineIdx -ge 0) {
            $cdiCombined = $resumoLines[$cdiLineIdx]
            if ($cdiLineIdx + 1 -lt $resumoLines.Count) {
                $nextLine = $resumoLines[$cdiLineIdx + 1]
                if ($nextLine -match '^[-\d,\.]+%') {
                    $cdiCombined = $cdiCombined + " " + $nextLine
                }
            }
            $cdiCombined = $cdiCombined -replace '\s+-$','' -replace '\s+-\s*$',''
            $cdiVals2 = [regex]::Matches($cdiCombined, '-?[\d]+(?:\.[\d]{3})*,[\d]+%')
            $cdiVals2 = $cdiVals2 | ForEach-Object { $_.Value }

            if ($cdiVals2.Count -ge 4) {
                $row.PctCDI12M = $cdiVals2[2]
                $row.PctCDI24M = $cdiVals2[3]
            } elseif ($cdiVals2.Count -eq 3) {
                $row.PctCDI12M = $cdiVals2[1]
                $row.PctCDI24M = $cdiVals2[2]
            }
        }
    }

    # =====================================================
    # BENCHMARK table: line-based extraction
    # Format: "Ano X% X% X% X% X%" -> Portfolio CDI Ibov IPCA Dolar
    # If Portfolio="-": "Ano -\nX% X% X% X%" or only 4 values
    # IPCA is always 4th benchmark column (after Portfolio CDI Ibov)
    # =====================================================
    $benchText = if ($resumoIdx -gt 0) { $t.Substring(0, $resumoIdx) } else { $t }
    $benchLines = $benchText -split "`n"

    function Get-BenchmarkIPCA($lines, $rowLabel) {
        # Find the line starting with rowLabel (e.g. "Ano", "12M", "24M")
        $rowIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^$rowLabel\s") { $rowIdx = $i; break }
        }
        if ($rowIdx -lt 0) { return $null }

        # Combine the row line with up to 2 continuation lines (values may wrap across multiple lines)
        $combined = $lines[$rowIdx]
        for ($ci = 1; $ci -le 2; $ci++) {
            if ($rowIdx + $ci -lt $lines.Count -and $lines[$rowIdx + $ci] -match '^[-\d,\.]') {
                $combined = $combined + " " + $lines[$rowIdx + $ci]
            } else { break }
        }

        # Extract numbers from this single combined row
        $nums = [regex]::Matches($combined, '-?[\d]+(?:\.[\d]{3})*,[\d]+%') | ForEach-Object { $_.Value }

        # Check if Portfolio column is absent: line is "12M -" (dash then whitespace/end)
        # vs "12M -36,68%" (negative number, portfolio present)
        # Standalone "-" = no portfolio; "-\d" = negative portfolio value
        $hasPortfolio = $lines[$rowIdx] -notmatch "^$rowLabel\s+-\s*$"

        if ($hasPortfolio) {
            # 5 values: Portfolio CDI Ibov IPCA Dolar -> IPCA=[3]
            if ($nums.Count -ge 4) { return $nums[3] }
            if ($nums.Count -ge 3) { return $nums[2] }  # Dolar missing
        } else {
            # No Portfolio: CDI Ibov IPCA Dolar -> IPCA=[2]
            if ($nums.Count -ge 3) { return $nums[2] }
            if ($nums.Count -ge 2) { return $nums[1] }
        }
        return $null
    }

    $ipca_ano_raw = Get-BenchmarkIPCA $benchLines "Ano"
    if ($null -ne $ipca_ano_raw) { $row.IPCAAno = $ipca_ano_raw }

    $ipca_12m_raw = Get-BenchmarkIPCA $benchLines "12M"
    if ($null -ne $ipca_12m_raw) { $row.IPCA12M = $ipca_12m_raw }

    $ipca_24m_raw = Get-BenchmarkIPCA $benchLines "24M"
    if ($null -ne $ipca_24m_raw) { $row.IPCA24M = $ipca_24m_raw }

    # =====================================================
    # PAGE 4: Monthly table
    # Columns: jun mai abr mar fev jan dez nov out set ago jul (12 values)
    # We need mai (index 1) for Rent/CDI and also jan-mai (indices 5,4,3,2,1)
    # =====================================================

    # Find page 4 section - look for "Patrimônio final" table
    $p4idx = $t.LastIndexOf("Patrim")
    $p4text = if ($p4idx -gt 0) { $t.Substring($p4idx) } else { $t }

    # Patrimônio final row: first R$ value is jun/26, second is mai/26
    $patrimMatches = [regex]::Matches($p4text, 'R\$\s*([\d\.,]+)')
    if ($patrimMatches.Count -ge 2) {
        # Find "Patrimônio final" then get 2nd R$ after it
        $pfIdx = $p4text.IndexOf("Patrim")
        if ($pfIdx -ge 0) {
            $pfSeg = $p4text.Substring($pfIdx, [Math]::Min(600, $p4text.Length - $pfIdx))
            $pfVals = [regex]::Matches($pfSeg, 'R\$\s*([\d\.,]+)')
            if ($pfVals.Count -ge 2) {
                $row.PatrimMai = "R$ " + $pfVals[1].Groups[1].Value
            }
        }
    }

    # Ganho financeiro row: 2nd value is mai/26
    $gfIdx = $p4text.IndexOf("Ganho financeiro")
    if ($gfIdx -ge 0) {
        $gfSeg = $p4text.Substring($gfIdx, [Math]::Min(600, $p4text.Length - $gfIdx))
        # Values can be negative: -R$ or R$
        $gfVals = [regex]::Matches($gfSeg, '(?:-R\$\s*|R\$\s*)([\d\.,]+)')
        if ($gfVals.Count -ge 2) {
            $isNeg = $gfVals[1].Value.StartsWith('-')
            $val = $gfVals[1].Groups[1].Value
            $row.GanhoMai = if ($isNeg) { "-R$ $val" } else { "R$ $val" }
        }
    }

    # Rent. monthly: extract all values, take indices 1 (mai) and 5(jan) 4(fev) 3(mar) 2(abr) 1(mai)
    $rentIdx = $p4text.LastIndexOf("`nRent.")
    if ($rentIdx -lt 0) { $rentIdx = $p4text.LastIndexOf("Rent.") }
    if ($rentIdx -ge 0) {
        $rentSeg = $p4text.Substring($rentIdx, [Math]::Min(300, $p4text.Length - $rentIdx))
        $rentMonths = [regex]::Matches($rentSeg, '-?[\d]+(?:\.[\d]{3})*,[\d]+%')
        if ($rentMonths.Count -ge 6) {
            # jun=0, mai=1, abr=2, mar=3, fev=4, jan=5
            $row.RentMai = $rentMonths[1].Value
            $rentJan = $rentMonths[5].Value
            $rentFev = $rentMonths[4].Value
            $rentMar = $rentMonths[3].Value
            $rentAbr = $rentMonths[2].Value
            $rentMai_v = $rentMonths[1].Value
        } elseif ($rentMonths.Count -ge 2) {
            $row.RentMai = $rentMonths[1].Value
        }
    }

    # %CDI monthly
    $cdiIdx = $p4text.LastIndexOf("`n%CDI")
    if ($cdiIdx -lt 0) { $cdiIdx = $p4text.LastIndexOf("%CDI") }
    if ($cdiIdx -ge 0) {
        $cdiSeg = $p4text.Substring($cdiIdx, [Math]::Min(300, $p4text.Length - $cdiIdx))
        $cdiMonths = [regex]::Matches($cdiSeg, '-?[\d]+(?:\.[\d]{3})*,[\d]+%')
        if ($cdiMonths.Count -ge 6) {
            $row.PctCDIMai = $cdiMonths[1].Value
            $cdiJan = $cdiMonths[5].Value
            $cdiFev = $cdiMonths[4].Value
            $cdiMar = $cdiMonths[3].Value
            $cdiAbr = $cdiMonths[2].Value
            $cdiMai_v = $cdiMonths[1].Value
        } elseif ($cdiMonths.Count -ge 2) {
            $row.PctCDIMai = $cdiMonths[1].Value
        }
    }

    # =====================================================
    # CALCULATIONS
    # =====================================================
    $rJ  = Parse-Number $rentJan
    $rF  = Parse-Number $rentFev
    $rM  = Parse-Number $rentMar
    $rA  = Parse-Number $rentAbr
    $rMai = Parse-Number $rentMai_v
    $cJ  = Parse-Number $cdiJan
    $cF  = Parse-Number $cdiFev
    $cM  = Parse-Number $cdiMar
    $cA  = Parse-Number $cdiAbr
    $cMai = Parse-Number $cdiMai_v

    if ($null -ne $rJ -and $null -ne $rF -and $null -ne $rM -and $null -ne $rA -and $null -ne $rMai) {
        $rentJanMai = (1 + $rJ/100) * (1 + $rF/100) * (1 + $rM/100) * (1 + $rA/100) * (1 + $rMai/100) - 1
        $row.RentJanMai = Format-Pct ($rentJanMai * 100)

        if ($null -ne $cJ -and $null -ne $cF -and $null -ne $cM -and $null -ne $cA -and $null -ne $cMai) {
            # For months where client had no position (Rent=0 and CDI%=0), treat CDI contribution = 0%
            # CDI_month = Rent / (%CDI/100) -- only compute if %CDI != 0
            $cdiJ_v   = if ($cJ -ne 0) { ($rJ/100) / ($cJ/100) } else { 0.0 }
            $cdiF_v   = if ($cF -ne 0) { ($rF/100) / ($cF/100) } else { 0.0 }
            $cdiM_v   = if ($cM -ne 0) { ($rM/100) / ($cM/100) } else { 0.0 }
            $cdiA_v   = if ($cA -ne 0) { ($rA/100) / ($cA/100) } else { 0.0 }
            $cdiMai_v2 = if ($cMai -ne 0) { ($rMai/100) / ($cMai/100) } else { 0.0 }

            # Only compute if at least the key months (mai) have valid CDI
            if ($cMai -ne 0) {
                $cdiJanMai = (1 + $cdiJ_v) * (1 + $cdiF_v) * (1 + $cdiM_v) * (1 + $cdiA_v) * (1 + $cdiMai_v2) - 1

                if ($cdiJanMai -ne 0) {
                    $pctCDIJanMai = $rentJanMai / $cdiJanMai * 100
                    $row.PctCDIJanMai = Format-Pct $pctCDIJanMai
                    $row.PctCDIJanMaiNum = $pctCDIJanMai
                }
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

Write-Host ""
Write-Host "=== SEM PDF ==="
$output | Where-Object { -not $_.HasPDF } | ForEach-Object { Write-Host "- $($_.Cliente) ($($_.Codigo))" }

Write-Host ""
Write-Host "=== N/D COUNTS (com PDF) ==="
$fields = @('Rent12M','PctCDI12M','Rent24M','PctCDI24M','IPCAAno','IPCA12M','IPCA24M','RentJanMai','PctCDIJanMai','PatrimMai','GanhoMai','RentMai','PctCDIMai')
foreach ($f in $fields) {
    $ndCount = ($output | Where-Object { $_.HasPDF -and $_.$f -eq 'N/D' }).Count
    if ($ndCount -gt 0) {
        Write-Host "  $f N/D: $ndCount"
        $output | Where-Object { $_.HasPDF -and $_.$f -eq 'N/D' } | ForEach-Object { Write-Host "    - $($_.Cliente)" }
    }
}

Write-Host ""
Write-Host "=== SAMPLE TOP 5 ==="
$sorted | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.Cliente) ($($_.Codigo)): Rent=$($_.RentJanMai) CDI=$($_.PctCDIJanMai) R12=$($_.Rent12M) IPCA_A=$($_.IPCAAno)"
}
