@echo off
rem Crear carpetas necesarias si no existen
if not exist auxiliares mkdir auxiliares
if not exist PDF mkdir PDF
if not exist Historial mkdir Historial

rem Obtener la fecha y hora actual en formato YYYY_MM_DD_HH-mm
for /f "tokens=2 delims==." %%I in ('wmic os get localdatetime /value ^| find "="') do set datetime=%%I
set datetime=%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%

rem Compilar el documento LaTeX
pdflatex -interaction=nonstopmode -output-directory=auxiliares "PLANTILLA TFG FINAL\TFG_FS24-031-FSC_MAIN.tex"

rem Copiar el PDF a la carpeta principal y a la carpeta PDF con la fecha y hora
copy /Y auxiliares\TFG_FS24-031-FSC_MAIN.pdf TFG_FS24-031-FSC_MAIN.pdf
copy /Y auxiliares\TFG_FS24-031-FSC_MAIN.pdf PDF\TFG_FS24-031-FSC_MAIN_%datetime%.pdf

rem ==============================
rem  GESTIONAR HISTORIAL DE .TEX
rem ==============================

rem Moverse a la carpeta "Historial"
cd Historial

rem Desplazar las carpetas antiguas (Eliminar la más antigua y renombrar las demás)
if exist 5 rmdir /s /q 5
if exist 4 ren 4 5
if exist 3 ren 3 4
if exist 2 ren 2 3
if exist 1 ren 1 2

rem Crear la nueva carpeta "1" para la última versión y copiar los archivos .tex
mkdir 1
xcopy /Y /E "..\PLANTILLA TFG FINAL\*.tex" "1\" /I

rem Volver a la carpeta raíz del proyecto
cd ..

rem ==============================
rem  GUARDAR CAMBIOS EN GITHUB
rem ==============================

rem Asegurar que Git reconoce los cambios eliminando archivos eliminados
git add -A

rem Crear el commit con un mensaje automático
git commit -m "Backup automático - %datetime%"

rem Intentar subir los cambios a GitHub
git push origin main

rem Si falla (por falta de conexión), mostrar mensaje
if %errorlevel% neq 0 (
    echo No hay conexión a Internet. Los cambios se guardarán localmente y se subirán más tarde.
)
