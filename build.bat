@echo off
setlocal

set "MINGW_ROOT=c:\mingw-4.8.1"
set "MINGW_BIN=%MINGW_ROOT%\bin"
set "MAKE=%MINGW_BIN%\mingw32-make.exe"

if not exist "%MAKE%" (
    echo ERRO: mingw32-make nao encontrado: %MAKE%
    exit /b 1
)

if not exist "%MINGW_ROOT%\lib\liballeg.a" (
    echo ERRO: liballeg.a nao encontrada
    exit /b 1
)

set "PATH=%MINGW_BIN%;%PATH%"
cd /d "%~dp0"

echo Compilando doom_hb...
"%MAKE%" -f Makefile %*
if errorlevel 1 (
    echo Compilacao falhou.
    exit /b 1
)

echo.
echo Pronto: Doom_hb.exe
echo Coloque DOOM1.WAD nesta pasta.
endlocal
