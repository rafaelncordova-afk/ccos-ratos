# servidor.ps1 - Financas Pessoais / Rafa Cordova
# Servidor local PowerShell. Rodar via iniciar.bat.

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$PORT = 5001

function Get-MimeType($ext) {
    switch ($ext.ToLower()) {
        '.html' { return 'text/html; charset=utf-8' }
        '.css'  { return 'text/css; charset=utf-8' }
        '.js'   { return 'application/javascript; charset=utf-8' }
        '.json' { return 'application/json; charset=utf-8' }
        '.ico'  { return 'image/x-icon' }
        default { return 'application/octet-stream' }
    }
}

function Send-Response {
    param($res, [string]$body, [string]$ct = 'application/json', [int]$code = 200)
    $res.StatusCode = $code
    $res.ContentType = $ct
    $res.Headers.Set('Access-Control-Allow-Origin', '*')
    $res.Headers.Set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    $res.Headers.Set('Access-Control-Allow-Headers', 'Content-Type')
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    $res.ContentLength64 = $bytes.Length
    try { $res.OutputStream.Write($bytes, 0, $bytes.Length) } catch {}
    try { $res.OutputStream.Close() } catch {}
}

function Send-File {
    param($res, [string]$path)
    if (-not (Test-Path $path)) {
        Send-Response $res '{"erro":"Arquivo nao encontrado"}' 'application/json' 404
        return
    }
    $ext   = [System.IO.Path]::GetExtension($path)
    $ct    = Get-MimeType $ext
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $res.StatusCode = 200
    $res.ContentType = $ct
    $res.Headers.Set('Access-Control-Allow-Origin', '*')
    $res.ContentLength64 = $bytes.Length
    try { $res.OutputStream.Write($bytes, 0, $bytes.Length) } catch {}
    try { $res.OutputStream.Close() } catch {}
}

function Read-Body($req) {
    if ($req.ContentLength64 -le 0) { return '' }
    $reader = [System.IO.StreamReader]::new($req.InputStream, [System.Text.Encoding]::UTF8)
    return $reader.ReadToEnd()
}

function Read-Json($path) {
    if (-not (Test-Path $path)) { return '{}' }
    return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function Write-Json($path, $content) {
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
}

function Get-SalarioComissoes($mesPT) {
    $dashPath = Join-Path $ROOT '..\projetos fami\comissoes\dashboard.html'
    if (-not (Test-Path $dashPath)) {
        return '{"salario":null,"fonte":"arquivo_nao_encontrado"}'
    }
    $html = [System.IO.File]::ReadAllText($dashPath, [System.Text.Encoding]::UTF8)
    $dataMatch = [regex]::Match($html, 'const DATA=\[(.+?)\];', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $dataMatch.Success) {
        return '{"salario":null,"fonte":"parse_error"}'
    }
    $inner  = $dataMatch.Groups[1].Value
    $mesEsc = [regex]::Escape($mesPT)
    $entry  = [regex]::Match($inner, "\{mes:`"$mesEsc`",[^}]+\}")
    if (-not $entry.Success) {
        return '{"salario":null,"fonte":"mes_nao_encontrado"}'
    }
    $tlMatch = [regex]::Match($entry.Value, 'tl:(\d+)')
    if (-not $tlMatch.Success) {
        return '{"salario":null,"fonte":"campo_tl_ausente"}'
    }
    $tl = $tlMatch.Groups[1].Value
    return "{`"salario`":$tl,`"fonte`":`"comissoes`"}"
}

function Process-PDF($req) {
    $body = Read-Body $req
    $data = $body | ConvertFrom-Json

    $tempId  = [System.Guid]::NewGuid().ToString('N')
    $tempDir = [System.IO.Path]::GetTempPath()
    $tempPdf = Join-Path $tempDir "fatura_$tempId.pdf"
    $tempTxt = Join-Path $tempDir "fatura_$tempId.txt"

    try {
        $pdfBytes = [System.Convert]::FromBase64String($data.conteudo)
        [System.IO.File]::WriteAllBytes($tempPdf, $pdfBytes)

        $proc = Start-Process -FilePath 'pdftotext' `
            -ArgumentList @('-layout', $tempPdf, $tempTxt) `
            -Wait -PassThru -NoNewWindow

        if ($proc.ExitCode -eq 0 -and (Test-Path $tempTxt)) {
            $texto  = [System.IO.File]::ReadAllText($tempTxt, [System.Text.Encoding]::UTF8)
            $result = @{ texto = $texto; ok = $true } | ConvertTo-Json -Compress -Depth 3
            return $result
        } else {
            return '{"ok":false,"erro":"pdftotext retornou erro"}'
        }
    }
    catch {
        return (@{ ok = $false; erro = $_.ToString() } | ConvertTo-Json -Compress)
    }
    finally {
        Remove-Item $tempPdf -ErrorAction SilentlyContinue
        Remove-Item $tempTxt -ErrorAction SilentlyContinue
    }
}

# -- Inicio do servidor -------------------------------------------------------

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$PORT/")

try {
    $listener.Start()

    Write-Host ''
    Write-Host '  Financas Pessoais - Rafa Cordova' -ForegroundColor Cyan
    Write-Host "  http://localhost:$PORT" -ForegroundColor Green
    Write-Host '  Ctrl+C para encerrar' -ForegroundColor DarkGray
    Write-Host ''

    Start-Process "http://localhost:$PORT"

    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        $url = $req.Url.LocalPath
        $m   = $req.HttpMethod

        Write-Host "  $m $url" -ForegroundColor DarkGray

        try {
            if ($m -eq 'OPTIONS') {
                Send-Response $res '{}' 'application/json' 200
                continue
            }

            if ($url -eq '/' -or $url -eq '/index.html') {
                Send-File $res (Join-Path $ROOT 'index.html')
            }
            elseif ($url -match '^/static/(.+)$') {
                Send-File $res (Join-Path $ROOT "static\$($Matches[1])")
            }
            elseif ($url -eq '/api/dados') {
                if ($m -eq 'GET') {
                    Send-Response $res (Read-Json (Join-Path $ROOT 'dados\historico.json'))
                } elseif ($m -eq 'POST') {
                    Write-Json (Join-Path $ROOT 'dados\historico.json') (Read-Body $req)
                    Send-Response $res '{"ok":true}'
                }
            }
            elseif ($url -eq '/api/contas') {
                if ($m -eq 'GET') {
                    Send-Response $res (Read-Json (Join-Path $ROOT 'dados\contas_fixas.json'))
                } elseif ($m -eq 'POST') {
                    Write-Json (Join-Path $ROOT 'dados\contas_fixas.json') (Read-Body $req)
                    Send-Response $res '{"ok":true}'
                }
            }
            elseif ($url -match '^/api/salario') {
                $mesPT = [System.Uri]::UnescapeDataString($req.QueryString['mes'])
                Send-Response $res (Get-SalarioComissoes $mesPT)
            }
            elseif ($url -eq '/api/processar-pdf' -and $m -eq 'POST') {
                $result = Process-PDF $req
                Send-Response $res $result
            }
            else {
                Send-Response $res '{"erro":"rota nao encontrada"}' 'application/json' 404
            }
        }
        catch {
            Write-Host "  ERRO: $_" -ForegroundColor Red
            try {
                Send-Response $res (@{erro=$_.ToString()} | ConvertTo-Json -Compress) 'application/json' 500
            } catch {}
        }
    }
}
catch [System.Net.HttpListenerException] {
    Write-Host "  Porta $PORT ja em uso. Feche a instancia anterior." -ForegroundColor Yellow
    Write-Host '  Pressione qualquer tecla para sair...'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
catch {
    Write-Host "  Erro inesperado: $_" -ForegroundColor Red
}
finally {
    if ($listener.IsListening) { $listener.Stop() }
    Write-Host '  Encerrado.' -ForegroundColor DarkGray
}
