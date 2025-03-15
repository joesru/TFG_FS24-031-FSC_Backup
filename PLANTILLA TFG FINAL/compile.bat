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
rem  Gestionar Historial de .tex
rem ==============================

rem Asegurar que la carpeta Historial existe
if not exist "%HISTORIAL_FOLDER%" mkdir "%HISTORIAL_FOLDER%"

rem Moverse a la carpeta Historial
cd /d "%HISTORIAL_FOLDER%"

rem Desplazar las carpetas antiguas en el historial (manteniendo solo 5 versiones)
if exist "5" rmdir /s /q "5"
if exist "4" ren "4" "5"
if exist "3" ren "3" "4"
if exist "2" ren "2" "3"
if exist "1" ren "1" "2"

rem Crear la nueva carpeta "1" para la ultima version
if not exist "1" mkdir "1"

rem Verificar si los archivos existen antes de copiarlos
echo Buscando archivos .tex en "%TEX_SOURCE%"
dir "%TEX_SOURCE%\*.tex"

rem **Copiar los archivos .tex asegurando que todos sean incluidos**
xcopy "%TEX_SOURCE%\*.tex" "1\" /Y /E /C /H /R /I

rem ==============================
rem  Guardar cambios en GitHub
rem ==============================

rem Volver a la carpeta raiz del proyecto
cd /d "%TEX_SOURCE%"

rem Asegurar que Git reconoce los cambios eliminando archivos eliminados
git add -A

rem Crear el commit con un mensaje automatico
git commit -m "Backup automatico - %datetime%"

rem Intentar subir los cambios a GitHub
git push origin main

rem Si falla (por falta de conexion), mostrar mensaje
if %errorlevel% neq 0 (
    echo No hay conexion a Internet. Los cambios se guardaran localmente y se subiran mas tarde.
)
