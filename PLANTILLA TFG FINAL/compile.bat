﻿@echo off
rem Definir rutas absolutas
set "TEX_SOURCE=D:\00000000.- REDACCION TFG\PLANTILLA TFG FINAL"
set "HISTORIAL_FOLDER=D:\00000000.- REDACCION TFG\PLANTILLA TFG FINAL\Historial"

rem Crear carpetas necesarias si no existen
if not exist "%TEX_SOURCE%\auxiliares" mkdir "%TEX_SOURCE%\auxiliares"
if not exist "%TEX_SOURCE%\PDF" mkdir "%TEX_SOURCE%\PDF"
if not exist "%HISTORIAL_FOLDER%" mkdir "%HISTORIAL_FOLDER%"

rem Obtener la fecha y hora actual en formato YYYY_MM_DD_HH-mm
for /f "tokens=2 delims==." %%I in ('wmic os get localdatetime /value ^| find "="') do set datetime=%%I
set datetime=%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%-%datetime:~8,2%-%datetime:~10,2%

rem Compilar el documento LaTeX
cd /d "%TEX_SOURCE%"
pdflatex -interaction=nonstopmode -output-directory="auxiliares" "TFG_FS24-031-FSC_MAIN.tex"

rem Copiar el PDF a la carpeta principal y a la carpeta PDF con la fecha y hora
copy /Y "auxiliares\TFG_FS24-031-FSC_MAIN.pdf" "TFG_FS24-031-FSC_MAIN.pdf"
copy /Y "auxiliares\TFG_FS24-031-FSC_MAIN.pdf" "PDF\TFG_FS24-031-FSC_MAIN_%datetime%.pdf"

rem ==============================
rem  Gestionar Historial de .tex y .sty (Mantenimiento de 10 versiones)
rem ==============================

rem Moverse a la carpeta Historial
cd /d "%HISTORIAL_FOLDER%"

rem Borrar la carpeta 10 si existe (la más antigua)
if exist "10 - "* rmdir /s /q "10 - *"

rem Desplazar las carpetas antiguas (9 -> 10, 8 -> 9, ..., 1 -> 2)
for /l %%i in (9,-1,1) do (
    if exist "%%i - "* ren "%%i - *" "%%i+1 - *"
)

rem Crear la nueva carpeta "1 - Fecha de compilación"
set "NEW_FOLDER=1 - %datetime%"
mkdir "%NEW_FOLDER%"

rem ==============================
rem  Verificar si hay archivos .tex y .sty antes de copiarlos
rem ==============================
echo Buscando archivos .tex y .sty en "%TEX_SOURCE%"...
dir "%TEX_SOURCE%\*.tex" /B
dir "%TEX_SOURCE%\*.sty" /B

rem Si no hay archivos .tex o .sty, mostrar error y salir
if not exist "%TEX_SOURCE%\*.tex" if not exist "%TEX_SOURCE%\*.sty" (
    echo ERROR: No se encontraron archivos .tex ni .sty en "%TEX_SOURCE%".
    pause
    exit /b
)

rem ==============================
rem  Copiar archivos .tex y .sty a Historial\1 - Fecha de compilación
rem ==============================
echo Copiando archivos .tex y .sty a "%NEW_FOLDER%"...
xcopy "%TEX_SOURCE%\*.tex" "%NEW_FOLDER%\" /Y /E /C /H /R /I
xcopy "%TEX_SOURCE%\*.sty" "%NEW_FOLDER%\" /Y /E /C /H /R /I

if %errorlevel% neq 0 (
    echo ERROR: No se pudieron copiar los archivos con xcopy. Intentando con copy...
    for %%f in ("%TEX_SOURCE%\*.tex") do copy /Y "%%f" "%NEW_FOLDER%\"
    for %%f in ("%TEX_SOURCE%\*.sty") do copy /Y "%%f" "%NEW_FOLDER%\"
)

rem ==============================
rem  Guardar cambios en GitHub
rem ==============================

rem Volver a la carpeta raiz del proyecto
cd /d "%TEX_SOURCE%"

rem Asegurar que Git reconoce los cambios eliminando archivos eliminados
git add -A

rem Crear el commit con un mensaje automático
git commit -m "Backup automatico - %datetime%"

rem Intentar subir los cambios a GitHub
git push origin main

rem Si falla (por falta de conexión), mostrar mensaje
if %errorlevel% neq 0 (
    echo No hay conexión a Internet. Los cambios se guardarán localmente y se subirán más tarde.
)

echo Respaldo completado y cambios subidos a GitHub: %datetime%
pause
