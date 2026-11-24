@echo off
pwsh -NoProfile -File "%~dp0tools\build.ps1"
exit /b %ERRORLEVEL%
