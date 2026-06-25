@echo off
title Financas Pessoais — Rafa Cordova
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0servidor.ps1"
pause
