# Script para solucionar problemas de instalación ADB
Write-Host "Solucionando problemas de instalación ADB..." -ForegroundColor Yellow

# Intentar encontrar ADB
$adbPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "$env:ANDROID_HOME\platform-tools\adb.exe",
    "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
)

$adbPath = $null
foreach ($path in $adbPaths) {
    if (Test-Path $path) {
        $adbPath = $path
        break
    }
}

if ($null -eq $adbPath) {
    Write-Host "ADB no encontrado. Buscando en PATH..." -ForegroundColor Yellow
    $adbCmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbCmd) {
        $adbPath = $adbCmd.Source
    }
}

if ($null -eq $adbPath) {
    Write-Host "ERROR: ADB no encontrado." -ForegroundColor Red
    exit 1
}

Write-Host "ADB encontrado en: $adbPath" -ForegroundColor Green

# Paso 1: Matar servidor ADB
Write-Host "`n1. Deteniendo servidor ADB..." -ForegroundColor Cyan
& $adbPath kill-server
Start-Sleep -Seconds 2

# Paso 2: Iniciar servidor ADB
Write-Host "2. Iniciando servidor ADB..." -ForegroundColor Cyan
& $adbPath start-server
Start-Sleep -Seconds 2

# Paso 3: Verificar dispositivos
Write-Host "`n3. Verificando dispositivos conectados..." -ForegroundColor Cyan
$devices = & $adbPath devices
Write-Host $devices

# Paso 4: Reiniciar el emulador si está conectado
$deviceLines = $devices | Where-Object { $_ -match "device$" }
if ($deviceLines) {
    Write-Host "`n4. Dispositivo encontrado. Reiniciando ADB..." -ForegroundColor Cyan
    & $adbPath kill-server
    Start-Sleep -Seconds 2
    & $adbPath start-server
    Start-Sleep -Seconds 2
    
    Write-Host "`n✅ ADB reiniciado. Intenta ejecutar Flutter de nuevo:" -ForegroundColor Green
    Write-Host "   flutter run" -ForegroundColor White
} else {
    Write-Host "`n⚠️  No se encontró ningún dispositivo conectado." -ForegroundColor Yellow
    Write-Host "   Asegúrate de que tu emulador esté corriendo." -ForegroundColor Yellow
}

# Paso 5: Limpiar build de Flutter
Write-Host "`n5. Limpiando build de Flutter..." -ForegroundColor Cyan
Write-Host "   Ejecuta: flutter clean" -ForegroundColor White

