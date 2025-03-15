@echo off
rem Definir ruta absoluta de los archivos fuente
set TEX_SOURCE="C:\Users\josee\OneDrive - Universidad de Córdoba\FÍSICA\4º DE FÍSICA\2.- CURSO 2024-25 - UCO\TFG\00.- REDACCION TFG\PLANTILLA TFG FINAL"
set HISTORIAL_FOLDER="C:\Users\josee\OneDrive - Universidad de Córdoba\FÍSICA\4º DE FÍSICA\2.- CURSO 2024-25 - UCO\TFG\00.- REDACCION TFG\Historial"

rem Crear carpetas necesarias si no existen
if not exist auxiliares mkdir auxiliares
if not exist PDF mkdir PDF
if not exist %HISTORIAL_FOLDER% mkdir %HISTORIAL_FOLDER%

rem Obtener la fecha y hora actual en formato YYYY_MM_DD_HH-mm
for /f "tokens=2 delims==." %%I in ('wmic os get localdatetime /value ^| find "="') do set datetime=%%I
set datetime=%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%

rem Compilar el documento LaTeX
pdflatex -interaction=nonstopmode -output-directory=auxiliares "%TEX_SOURCE%\TFG_FS24-031-FSC_MAIN.tex"

rem Copiar el PDF a la carpeta principal y a la carpeta PDF con la fecha y hora
copy /Y auxiliares\TFG_FS24-031-FSC_MAIN.pdf TFG_FS24-031-FSC_MAIN.pdf
copy /Y auxiliares\TFG_FS24-031-FSC_MAIN.pdf PDF\TFG_FS24-031-FSC_MAIN_%datetime%.pdf

rem ==============================
rem  GESTIONAR HISTORIAL DE .TEX
rem ==============================

rem Crear nuevamente la carpeta Historial si no existe
if not exist %HISTORIAL_FOLDER% mkdir %HISTORIAL_FOLDER%

rem Moverse a la carpeta Historial
cd /d %HISTORIAL_FOLDER%

rem Desplazar las carpetas antiguas en el historial (manteniendo solo 5 versiones)
if exist 5 rmdir /s /q 5
if exist 4 ren 4 5
if exist 3 ren 3 4
if exist 2 ren 2 3
if exist 1 ren 1 2

rem Crear la nueva carpeta "1" para la última versión
mkdir 1

rem Verificar si los archivos existen antes de copiarlos
echo Buscando archivos .tex en %TEX_SOURCE%
dir %TEX_SOURCE%\*.tex

rem Copiar los archivos .tex a la nueva carpeta 1
xcopy /Y /E "%TEX_SOURCE%\*.tex" "%HISTORIAL_FOLDER%\1\" /I

rem ==============================
rem  GUARDAR CAMBIOS EN GITHUB
rem ==============================

rem Volver a la carpeta raíz del proyecto
cd /d "%~dp0"

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
