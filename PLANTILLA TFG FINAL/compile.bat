﻿@echo off
rem Crear la carpeta "auxiliares" si no existe
if not exist auxiliares mkdir auxiliares
rem Crear la carpeta "PDF" si no existe
if not exist PDF mkdir PDF

rem Compilar el documento LaTeX, enviando los archivos de salida a la carpeta "auxiliares"
pdflatex -interaction=nonstopmode -output-directory=auxiliares TFG_FS24-031-FSC_MAIN.tex

rem Obtener la fecha y hora actual en formato YYYYMMDD_HHMMSS
for /f "tokens=2 delims==." %%I in ('wmic os get localdatetime /value ^| find "="') do set datetime=%%I
set datetime=%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%

rem Copiar el PDF a la carpeta principal (manteniendo el nombre original)
copy /Y auxiliares\TFG_FS24-031-FSC_MAIN.pdf TFG_FS24-031-FSC_MAIN.pdf

rem Copiar el PDF a la carpeta "PDF" renombrándolo con fecha y hora
copy /Y auxiliares\TFG_FS24-031-FSC_MAIN.pdf PDF\TFG_FS24-031-FSC_MAIN_%datetime%.pdf

rem Guardar cambios en Git y subirlos a GitHub automáticamente
cd /d "%~dp0"  rem Ir a la carpeta del script

rem Añadir todos los archivos al commit
git add .

rem Crear el commit con un mensaje automático
git commit -m "Backup automático - %datetime%"

rem Intentar subir los cambios a GitHub
git push origin main

rem Si falla (por falta de conexión), mostrar mensaje
if %errorlevel% neq 0 (
    echo No hay conexión a Internet. Los cambios se guardarán localmente y se subirán más tarde.
)

