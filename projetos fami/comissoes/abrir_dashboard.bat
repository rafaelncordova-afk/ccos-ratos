@echo off
cd /d "%~dp0"
echo Gerando dashboard...
powershell -ExecutionPolicy Bypass -File gerar_dashboard.ps1
if %errorlevel% equ 0 (
    start "" dashboard.html
) else (
    echo Erro ao gerar dashboard.
    pause
)
