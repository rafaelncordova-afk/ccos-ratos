#Requires -Version 5.1
# gerar_controle.ps1 -- Gera controle mensal de comissoes a partir do CSV XP
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File gerar_controle.ps1 -CsvFile 2026_05.csv
#   powershell -ExecutionPolicy Bypass -File gerar_controle.ps1 -CsvFile 2026_06.csv -SoMd
#
# Parametros:
#   -CsvFile : nome do arquivo CSV (relativo a pasta do script, ou caminho absoluto)
#   -SoMd    : pula atualizacao do evolucao_mensal.csv (util para testar)

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvFile,
    [switch]$SoMd
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ---------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------

function Parse-Br([string]$s) {
    $s = $s.Trim() -replace '\.', '' -replace ',', '.'
    if ([string]::IsNullOrEmpty($s) -or $s -eq '-') { return 0.0 }
    try { return [double]$s } catch { return 0.0 }
}

function Fmt([double]$v) {
    $n   = [math]::Round([math]::Abs($v))
    $s   = "$n"
    $res = ""
    $len = $s.Length
    for ($i = 0; $i -lt $len; $i++) {
        if ($i -gt 0 -and ($len - $i) % 3 -eq 0) { $res += "." }
        $res += $s[$i]
    }
    if ($v -lt 0) { "- R$ $res" } else { "R$ $res" }
}

function FmtPct([double]$v) {
    $s = [string]([math]::Round($v, 1))
    $s -replace '\.', ','
}

function SumWhere($data, [scriptblock]$filter) {
    $r = ($data | Where-Object $filter | Measure-Object -Property Liq -Sum).Sum
    if ($null -eq $r) { 0.0 } else { $r }
}

# ---------------------------------------------------------------
# LER E PARSEAR CSV
# ---------------------------------------------------------------

$csvPath = if ([System.IO.Path]::IsPathRooted($CsvFile)) { $CsvFile } else { Join-Path $scriptDir $CsvFile }
if (-not (Test-Path $csvPath)) { Write-Error "Arquivo nao encontrado: $csvPath"; exit 1 }

$raw = Get-Content $csvPath -Encoding UTF8
if ($raw.Count -gt 0) { $raw[0] = $raw[0] -replace [char]0xFEFF, '' }

$header = $raw[0] -split ';'

function ColIdx($name, $fallback) {
    $i = [Array]::IndexOf($header, $name)
    if ($i -ge 0) { $i } else { $fallback }
}

$iArea   = ColIdx 'Area'            1
$iTipo   = ColIdx 'Tipo Receita'    2
$iCat    = ColIdx 'Categoria'       3
$iProd   = ColIdx 'Produto'         4
$iCodigo = ColIdx 'Codigo Cliente'  5
$iNome   = ColIdx 'Nome Cliente'    6
$iLiq    = $header.Count - 1

$rows = @()
for ($i = 1; $i -lt $raw.Count; $i++) {
    $line = $raw[$i].Trim()
    if ([string]::IsNullOrEmpty($line)) { continue }
    $c = $line -split ';'
    if ($c.Count -lt 7) { continue }

    $rows += [PSCustomObject]@{
        Area   = if ($c.Count -gt $iArea)   { $c[$iArea]   } else { '' }
        Tipo   = if ($c.Count -gt $iTipo)   { $c[$iTipo]   } else { '' }
        Cat    = if ($c.Count -gt $iCat)    { $c[$iCat]    } else { '' }
        Prod   = if ($c.Count -gt $iProd)   { $c[$iProd]   } else { '' }
        Codigo = if ($c.Count -gt $iCodigo) { $c[$iCodigo] } else { '' }
        Nome   = if ($c.Count -gt $iNome)   { $c[$iNome]   } else { '' }
        Liq    = Parse-Br $c[$iLiq]
    }
}

Write-Host "  -> $($rows.Count) linhas carregadas do CSV" -ForegroundColor DarkGray

# ---------------------------------------------------------------
# DERIVAR MES DO NOME DO ARQUIVO (formato: AAAA_MM.csv)
# ---------------------------------------------------------------

$mesesAbrev = @{ '01'='Jan'; '02'='Fev'; '03'='Mar'; '04'='Abr'; '05'='Mai'; '06'='Jun';
                 '07'='Jul'; '08'='Ago'; '09'='Set'; '10'='Out'; '11'='Nov'; '12'='Dez' }
$mesesSlug  = @{ '01'='jan'; '02'='fev'; '03'='mar'; '04'='abr'; '05'='mai'; '06'='jun';
                 '07'='jul'; '08'='ago'; '09'='set'; '10'='out'; '11'='nov'; '12'='dez' }

$basename = [System.IO.Path]::GetFileNameWithoutExtension($CsvFile)
$mesLabel = '??/????'
$mesSlug  = 'controle'
$anoStr   = '????'
$mesNum   = '??'

if ($basename -match '(\d{4})_(\d{2})') {
    $anoStr   = $Matches[1]
    $mesNum   = $Matches[2]
    $mesLabel = "$($mesesAbrev[$mesNum])/$anoStr"
    $mesSlug  = "$($mesesSlug[$mesNum])$anoStr"
}

# ---------------------------------------------------------------
# BLOCO A -- RECORRENTE
# ---------------------------------------------------------------

$feeFixoRows = $rows | Where-Object { $_.Cat -eq 'FEE FIXO' -and $_.Prod -ne 'Fee de Plataforma' -and $_.Liq -gt 0 }
$feePlat     = SumWhere $rows { $_.Prod -eq 'Fee de Plataforma' }
$feeFixo     = (SumWhere $rows { $_.Cat -eq 'FEE FIXO' -and $_.Prod -ne 'Fee de Plataforma' -and $_.Liq -gt 0 }) + $feePlat
$clientesFF  = ($feeFixoRows | Select-Object Codigo -Unique).Count

$mfoConsult = SumWhere $rows { $_.Tipo -eq 'Consultoria' -and $_.Liq -gt 0 }
$mfoAdm     = SumWhere $rows { $_.Tipo -eq 'Carteira ADM' -and $_.Liq -gt 0 }
$mfo        = $mfoConsult + $mfoAdm

$txRec = SumWhere $rows { $_.Cat -eq 'TX ADM' -and $_.Tipo -eq 'Fundos Recorrentes' -and $_.Liq -gt 0 }
$txFii = SumWhere $rows { $_.Cat -eq 'TX ADM' -and $_.Tipo -eq 'Fundos Imobiliarios' -and $_.Liq -gt 0 }
# Tenta tambem com acento (CSV pode ter encoding diferente)
if ($txFii -eq 0) {
    $txFii = SumWhere $rows { $_.Cat -eq 'TX ADM' -and $_.Tipo -like '*mobili*' -and $_.Liq -gt 0 }
}
$txAdm = $txRec + $txFii

$prev = SumWhere $rows { $_.Cat -like 'Previd*' -and $_.Liq -gt 0 }
$seg  = SumWhere $rows { $_.Area -eq 'Seguros' -and $_.Liq -gt 0 }

$blocoA = $feeFixo + $mfo + $txAdm + $prev + $seg

# ---------------------------------------------------------------
# BLOCO B -- SEMIRRECORRENTE
# ---------------------------------------------------------------

$rvBovEmp = SumWhere $rows { $_.Cat -eq 'BOVESPA Empacotados' -and $_.Liq -gt 0 }
$rvBov    = SumWhere $rows { $_.Cat -eq 'BOVESPA' -and $_.Liq -gt 0 }
$rvSelf   = SumWhere $rows { $_.Cat -eq 'BOVESPA Self Service' -and $_.Liq -gt 0 }
$rvBtcT   = SumWhere $rows { $_.Cat -eq 'BTC' -and $_.Prod -like '*Tomador*' -and $_.Liq -gt 0 }
$rvBtcD   = SumWhere $rows { $_.Cat -eq 'BTC' -and $_.Prod -like '*Doador*' -and $_.Liq -gt 0 }
$rvBmf    = SumWhere $rows { $_.Tipo -eq 'BMF' -and $_.Liq -gt 0 }
$rv       = $rvBovEmp + $rvBov + $rvSelf + $rvBtcT + $rvBtcD + $rvBmf

$coe = SumWhere $rows { $_.Cat -eq 'COE' -and $_.Liq -gt 0 }
$rf  = SumWhere $rows { $_.Cat -eq 'RENDA FIXA' -and $_.Liq -gt 0 }

$fiisPrim = SumWhere $rows { $_.Cat -eq 'BOVESPA FIIs' -and $_.Liq -gt 0 }

$oferta   = SumWhere $rows { $_.Tipo -like 'Fundos N*o Recorrentes' -and $_.Liq -gt 0 }
# Tenta tambem sem acento
if ($oferta -eq 0) {
    $oferta = SumWhere $rows { $_.Tipo -eq 'Fundos Nao Recorrentes' -and $_.Liq -gt 0 }
}

$banking = SumWhere $rows { $_.Area -eq 'Banking' -and $_.Liq -gt 0 }
$intl    = SumWhere $rows { $_.Tipo -eq 'Treasury & Bond & Fund & Equity' -and $_.Liq -gt 0 }

$blocoB = $rv + $coe + $rf + $fiisPrim + $oferta + $banking + $intl

# ---------------------------------------------------------------
# BLOCO C -- NAO RECORRENTE
# ---------------------------------------------------------------

$campanhas = SumWhere $rows {
    ($_.Cat -like 'Campanha*' -or ($_.Area -eq 'Assessoria' -and $_.Cat -eq 'Campanhas')) -and $_.Liq -gt 0
}

$estornos = SumWhere $rows { ($_.Prod -like '*ESTORNO*' -or $_.Cat -like '*Estorno*') -and $_.Liq -gt 0 }

$blocoC = $campanhas + $estornos

# ---------------------------------------------------------------
# DEDUCOES
# ---------------------------------------------------------------

$saude     = SumWhere $rows { $_.Cat -like 'Plano de sa*de' }
$famiStore = SumWhere $rows { $_.Cat -eq 'Fami Store' }
$totalDed  = $saude + $famiStore

# ---------------------------------------------------------------
# TOTAIS
# ---------------------------------------------------------------

$totalBruto    = $blocoA + $blocoB + $blocoC
$totalLiq      = $totalBruto + $totalDed
$totalSemCamp  = $totalLiq - $campanhas
$pctRec        = if ($totalLiq -gt 0)    { [math]::Round($blocoA / $totalLiq * 100, 1) }    else { 0 }
$pctRecSemCamp = if ($totalSemCamp -gt 0) { [math]::Round($blocoA / $totalSemCamp * 100, 1) } else { 0 }

# ---------------------------------------------------------------
# TOP CLIENTES
# ---------------------------------------------------------------

$topClientes = $rows |
    Where-Object { $_.Liq -gt 0 -and $_.Nome -ne '' -and $_.Nome -ne '-' -and $_.Codigo -ne '' -and $_.Codigo -ne '-' } |
    Group-Object Nome |
    ForEach-Object {
        [PSCustomObject]@{
            Nome   = $_.Name
            Codigo = $_.Group[0].Codigo
            Total  = ($_.Group | Measure-Object Liq -Sum).Sum
        }
    } |
    Sort-Object Total -Descending |
    Select-Object -First 10

# ---------------------------------------------------------------
# FEE FIXO DETALHADO POR CLIENTE
# ---------------------------------------------------------------

$feeFixoDetalhado = $feeFixoRows |
    Group-Object Nome |
    ForEach-Object {
        [PSCustomObject]@{
            Nome   = $_.Name
            Codigo = $_.Group[0].Codigo
            Total  = ($_.Group | Measure-Object Liq -Sum).Sum
        }
    } |
    Sort-Object Total -Descending

# ---------------------------------------------------------------
# ALERTAS
# ---------------------------------------------------------------

$alertas   = [System.Collections.Generic.List[string]]::new()
$evCsvPath = Join-Path $scriptDir 'evolucao_mensal.csv'

if (Test-Path $evCsvPath) {
    $evRaw    = Get-Content $evCsvPath -Encoding UTF8
    $evHeader = $evRaw[0] -split ';'

    $iEvRec = [Array]::IndexOf($evHeader, 'Recorrente')
    $iEvFF  = [Array]::IndexOf($evHeader, 'Fee Fixo')
    $iEvTSC = [Array]::IndexOf($evHeader, 'Total sem camp')

    $lastLine = $null
    for ($i = 1; $i -lt $evRaw.Count; $i++) {
        $l = $evRaw[$i].Trim()
        if ($l -match "^[A-Za-z][a-z]{2}/\d{4};" -and $l -notmatch ("^" + [regex]::Escape($mesLabel) + ";")) {
            $cols = $l -split ';'
            if ($cols.Count -gt 3 -and $cols[1] -ne '') { $lastLine = $cols }
        }
    }

    if ($null -ne $lastLine) {
        $prevMes = $lastLine[0]
        $prevRec = if ($iEvRec -ge 0 -and $lastLine.Count -gt $iEvRec) { Parse-Br $lastLine[$iEvRec] } else { 0 }
        $prevFF  = if ($iEvFF  -ge 0 -and $lastLine.Count -gt $iEvFF)  { Parse-Br $lastLine[$iEvFF]  } else { 0 }
        $prevTSC = 0
        if ($iEvTSC -ge 0 -and $lastLine.Count -gt $iEvTSC -and $lastLine[$iEvTSC] -ne '') {
            $prevTSC = Parse-Br $lastLine[$iEvTSC]
        }

        if ($blocoA - $prevRec -lt -500) {
            $alertas.Add("[ALERTA] RECORRENTE caiu $(Fmt ([math]::Abs($blocoA - $prevRec))) vs $prevMes -- verificar causa")
        }
        if ($feeFixo - $prevFF -lt -200) {
            $alertas.Add("[CRITICO] FEE FIXO caiu $(Fmt ([math]::Abs($feeFixo - $prevFF))) vs $prevMes -- checar se saiu cliente")
        }
        if ($prevTSC -gt 0) {
            $prevPctSC = [math]::Round($prevRec / $prevTSC * 100, 1)
            $diffPp    = $pctRecSemCamp - $prevPctSC
            if ($diffPp -lt -5) {
                $alertas.Add("[ALERTA] % REC SEM CAMP caiu $([math]::Abs($diffPp)) pp vs $prevMes ($(FmtPct $prevPctSC)% -> $(FmtPct $pctRecSemCamp)%)")
            }
        }
    }
}

if ($pctRecSemCamp -lt 50) {
    $alertas.Add("[ALERTA] % Recorrente sem camp abaixo de 50% -- hoje $(FmtPct $pctRecSemCamp)%")
}

# ---------------------------------------------------------------
# ATUALIZAR evolucao_mensal.csv
# ---------------------------------------------------------------

if (-not $SoMd -and (Test-Path $evCsvPath)) {
    $evRaw    = Get-Content $evCsvPath -Encoding UTF8
    $hasNewCols = $evRaw[0] -match 'Total sem camp'

    if (-not $hasNewCols) {
        Write-Host "[AVISO] evolucao_mensal.csv esta no formato antigo. Atualize manualmente." -ForegroundColor Yellow
    } else {
        $novaLinha = "$mesLabel;$([math]::Round($totalLiq));$([math]::Round($totalSemCamp));$([math]::Round($blocoA));$(FmtPct $pctRec)%;$(FmtPct $pctRecSemCamp)%;$([math]::Round($feeFixo));$([math]::Round($mfoConsult));$([math]::Round($mfoAdm));$([math]::Round($txAdm));$([math]::Round($prev));$([math]::Round($seg));$([math]::Round($rv));$([math]::Round($coe));$([math]::Round($rf));$([math]::Round($fiisPrim));$([math]::Round($oferta));$([math]::Round($banking));$([math]::Round($intl));$([math]::Round($campanhas));$([math]::Round($estornos));$([math]::Round($feePlat));$([math]::Round($totalDed));$clientesFF"

        $substituido = $false
        $novasLinhas = for ($i = 0; $i -lt $evRaw.Count; $i++) {
            $l = $evRaw[$i]
            if ($l -match ("^" + [regex]::Escape($mesLabel) + ";")) {
                $novaLinha
                $substituido = $true
            } else {
                $l
            }
        }
        if (-not $substituido) { $novasLinhas = @($novasLinhas) + $novaLinha }

        $novasLinhas | Set-Content $evCsvPath -Encoding UTF8
        Write-Host "[OK] evolucao_mensal.csv atualizado" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------
# GERAR CONTROLE .MD
# ---------------------------------------------------------------

$today   = Get-Date -Format 'dd/MM/yyyy'
$outFile = Join-Path $scriptDir "controle_comissoes_$mesSlug.md"

# Tabela fee fixo por cliente
$ffLines = "| Cliente | Codigo | Liquido |`n|---|---|---|"
foreach ($c in $feeFixoDetalhado) {
    $ffLines += "`n| $($c.Nome) | $($c.Codigo) | $(Fmt $c.Total) |"
}
$ffLines += "`n| Fee de Plataforma (custo) | | $(Fmt $feePlat) |"
$ffLines += "`n| **TOTAL FEE FIXO** | | **$(Fmt $feeFixo)** |"

# Tabela top clientes
$topLines = "| # | Cliente | Codigo | Receita Liquida |`n|---|---|---|---|"
$rank = 1
foreach ($c in $topClientes) {
    $topLines += "`n| $rank | $($c.Nome) | $($c.Codigo) | $(Fmt $c.Total) |"
    $rank++
}

# Bloco alertas no .md
$alertBlock = ''
if ($alertas.Count -gt 0) {
    $alertBlock = "`n## ALERTAS`n"
    foreach ($a in $alertas) { $alertBlock += "`n> $a`n" }
    $alertBlock += "`n---`n"
}

$md = "# Controle de Comissoes -- $mesLabel

Fonte: relatorio XP (CSV) | Referencia: Comissao Liquida (apos repasse)
Gerado automaticamente em: $today

---

## RESUMO EXECUTIVO

| Bloco | Liquido |
|---|---|
| **Recorrente (A)** | **$(Fmt $blocoA)** |
| Semirrecorrente (B) | $(Fmt $blocoB) |
| Nao Recorrente (C) | $(Fmt $blocoC) |
| **TOTAL BRUTO** | **$(Fmt $totalBruto)** |
| Deducoes (saude + extras) | $(Fmt $totalDed) |
| **TOTAL LIQUIDO** | **$(Fmt $totalLiq)** |
| **Total sem campanhas** | **$(Fmt $totalSemCamp)** |

> % Recorrente: **$(FmtPct $pctRec)%** | Sem campanhas: **$(FmtPct $pctRecSemCamp)%**
$alertBlock
---

## BLOCO A -- RECORRENTE

### A1. Fee Fixo ($clientesFF clientes ativos)

$ffLines

---

### A2. MFO -- Family Office

| Linha | Liquido |
|---|---|
| Consultoria MFO | $(Fmt $mfoConsult) |
| Carteira ADM | $(Fmt $mfoAdm) |
| **TOTAL MFO** | **$(Fmt $mfo)** |

---

### A3. TX ADM

| Categoria | Liquido |
|---|---|
| TX ADM Fundos Recorrentes | $(Fmt $txRec) |
| TX ADM Fundos Imobiliarios | $(Fmt $txFii) |
| **TOTAL TX ADM** | **$(Fmt $txAdm)** |

---

### A4. Previdencia

> Total consolidado. Ver CSV para detalhamento por cliente.

**TOTAL PREVIDENCIA: $(Fmt $prev)**

---

### A5. Seguros

**TOTAL SEGUROS: $(Fmt $seg)**

---

### TOTAL RECORRENTE: $(Fmt $blocoA)

---

## BLOCO B -- SEMIRRECORRENTE

| Categoria | Liquido |
|---|---|
| B1. Renda Variavel | $(Fmt $rv) |
| B2. COE produto | $(Fmt $coe) |
| B3. Renda Fixa (primario/oferta) | $(Fmt $rf) |
| B4. FIIs Primario | $(Fmt $fiisPrim) |
| B5. Oferta Fundos | $(Fmt $oferta) |
| B6. Banking | $(Fmt $banking) |
| B7. Internacional | $(Fmt $intl) |
| **TOTAL SEMIRRECORRENTE** | **$(Fmt $blocoB)** |

---

## BLOCO C -- NAO RECORRENTE

| Item | Liquido |
|---|---|
| Campanhas | $(Fmt $campanhas) |
| Estornos | $(Fmt $estornos) |
| **TOTAL NAO RECORRENTE** | **$(Fmt $blocoC)** |

---

## DEDUCOES

| Item | Valor |
|---|---|
| Fee de Plataforma (ja incluso no Fee Fixo) | $(Fmt $feePlat) |
| Saude + Fami Store | $(Fmt $totalDed) |

---

## TOP CLIENTES -- $mesLabel

$topLines

---

## NUMEROS PARA CONTROLE

| Indicador | $mesLabel |
|---|---|
| Total Liquido | $(Fmt $totalLiq) |
| Total sem campanhas | $(Fmt $totalSemCamp) |
| Recorrente | $(Fmt $blocoA) |
| % Recorrente | $(FmtPct $pctRec)% |
| % Recorrente sem camp | $(FmtPct $pctRecSemCamp)% |
| Fee Fixo | $(Fmt $feeFixo) |
| MFO + Carteira ADM | $(Fmt $mfo) |
| TX ADM | $(Fmt $txAdm) |
| Previdencia | $(Fmt $prev) |
| Seguros | $(Fmt $seg) |
| RV | $(Fmt $rv) |
| COE produto | $(Fmt $coe) |
| RF | $(Fmt $rf) |
| FIIs primario | $(Fmt $fiisPrim) |
| Oferta Fundos | $(Fmt $oferta) |
| Banking | $(Fmt $banking) |
| Internacional | $(Fmt $intl) |
| Campanhas | $(Fmt $campanhas) |
| Clientes FF ativos | $clientesFF |
| Fee Plataforma pago | $(Fmt ([math]::Abs($feePlat))) |
"

[System.IO.File]::WriteAllText($outFile, $md, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Controle gerado: $([System.IO.Path]::GetFileName($outFile))" -ForegroundColor Green

# ---------------------------------------------------------------
# RESUMO NO TERMINAL
# ---------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  COMISSOES $mesLabel" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host ("  TOTAL LIQUIDO:      " + (Fmt $totalLiq)) -ForegroundColor White
Write-Host ("  Total sem camp:     " + (Fmt $totalSemCamp)) -ForegroundColor White
Write-Host ""
Write-Host ("  [A] Recorrente:     " + (Fmt $blocoA) + "  (" + (FmtPct $pctRec) + "% / sem camp: " + (FmtPct $pctRecSemCamp) + "%)") -ForegroundColor Green
Write-Host ("    Fee Fixo:         " + (Fmt $feeFixo) + "  ($clientesFF clientes)") -ForegroundColor DarkGreen
Write-Host ("    MFO:              " + (Fmt $mfo) + "  (consult: " + (Fmt $mfoConsult) + " | adm: " + (Fmt $mfoAdm) + ")") -ForegroundColor DarkGreen
Write-Host ("    TX ADM:           " + (Fmt $txAdm)) -ForegroundColor DarkGreen
Write-Host ("    Previdencia:      " + (Fmt $prev)) -ForegroundColor DarkGreen
Write-Host ("    Seguros:          " + (Fmt $seg)) -ForegroundColor DarkGreen
Write-Host ""
Write-Host ("  [B] Semirrecorrente: " + (Fmt $blocoB)) -ForegroundColor Yellow
Write-Host ("    RV:               " + (Fmt $rv)) -ForegroundColor DarkYellow
Write-Host ("    COE produto:      " + (Fmt $coe)) -ForegroundColor DarkYellow
Write-Host ("    RF:               " + (Fmt $rf)) -ForegroundColor DarkYellow
Write-Host ("    FIIs primario:    " + (Fmt $fiisPrim)) -ForegroundColor DarkYellow
Write-Host ("    Oferta Fundos:    " + (Fmt $oferta)) -ForegroundColor DarkYellow
Write-Host ("    Banking:          " + (Fmt $banking)) -ForegroundColor DarkYellow
Write-Host ("    Internacional:    " + (Fmt $intl)) -ForegroundColor DarkYellow
Write-Host ""
Write-Host ("  [C] Nao recorrente:  " + (Fmt $blocoC)) -ForegroundColor Red
Write-Host ("    Campanhas:        " + (Fmt $campanhas)) -ForegroundColor DarkRed
Write-Host ("    Estornos:         " + (Fmt $estornos)) -ForegroundColor DarkRed
Write-Host ""
Write-Host ("  [-] Deducoes:       " + (Fmt $totalDed)) -ForegroundColor Gray
Write-Host ""

if ($alertas.Count -gt 0) {
    Write-Host "---- ALERTAS -----------------------------------" -ForegroundColor Red
    foreach ($a in $alertas) { Write-Host "  $a" -ForegroundColor Red }
    Write-Host ""
} else {
    Write-Host "  [OK] Sem alertas -- recorrente estavel." -ForegroundColor DarkGreen
}
Write-Host "============================================" -ForegroundColor Cyan
