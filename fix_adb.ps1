# Script para reiniciar ADB y solucionar problemas de conexión
Write-Host "Reiniciando ADB..." -ForegroundColor Yellow

# Obtener la ruta del SDK de Android
$env:ANDROID_HOME = $env:LOCALAPPDATA + "\Android\Sdk"
$adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"

if (Test-Path $adbPath) {
    Write-Host "Deteniendo servidor ADB..." -ForegroundColor Cyan
    & $adbPath kill-server
    
    Start-Sleep -Seconds 2
    
    Write-Host "Iniciando servidor ADB..." -ForegroundColor Cyan
    & $adbPath start-server
    
    Start-Sleep -Seconds 2
    
    Write-Host "`nDispositivos conectados:" -ForegroundColor Green
    & $adbPath devices
    
    Write-Host "`nSi no ves tu emulador, inícialo desde Android Studio o ejecuta:" -ForegroundColor Yellow
    Write-Host "flutter emulators --launch <emulator_id>" -ForegroundColor White
} else {
    Write-Host "ADB no encontrado en: $adbPath" -ForegroundColor Red
    Write-Host "Asegúrate de tener Android SDK instalado correctamente." -ForegroundColor Yellow
}

