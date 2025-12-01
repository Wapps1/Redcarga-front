# Script para configurar ADB port forwarding
Write-Host "Configurando ADB port forwarding..." -ForegroundColor Yellow

# Intentar encontrar ADB en ubicaciones comunes
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
    $adbPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbPath) {
        $adbPath = $adbPath.Source
    }
}

if ($null -eq $adbPath) {
    Write-Host "ERROR: ADB no encontrado. Por favor:" -ForegroundColor Red
    Write-Host "1. Instala Android SDK Platform Tools" -ForegroundColor Yellow
    Write-Host "2. O ejecuta manualmente desde Android Studio: Tools > SDK Manager > SDK Tools > Android SDK Platform-Tools" -ForegroundColor Yellow
    Write-Host "3. Luego ejecuta manualmente: adb reverse tcp:8080 tcp:8080" -ForegroundColor Yellow
    exit 1
}

Write-Host "ADB encontrado en: $adbPath" -ForegroundColor Green

# Verificar que hay un dispositivo conectado
Write-Host "`nVerificando dispositivos conectados..." -ForegroundColor Cyan
$devices = & $adbPath devices
Write-Host $devices

if ($devices -notmatch "device$") {
    Write-Host "`nADVERTENCIA: No se encontró ningún dispositivo conectado." -ForegroundColor Yellow
    Write-Host "Asegúrate de que tu emulador esté corriendo." -ForegroundColor Yellow
}

# Configurar port forwarding
Write-Host "`nConfigurando port forwarding: 8080 -> 8080" -ForegroundColor Cyan
& $adbPath reverse tcp:8080 tcp:8080

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Port forwarding configurado correctamente!" -ForegroundColor Green
    Write-Host "Ahora puedes usar http://localhost:8080 en tu app Flutter" -ForegroundColor Green
} else {
    Write-Host "`n❌ Error al configurar port forwarding" -ForegroundColor Red
    Write-Host "Código de salida: $LASTEXITCODE" -ForegroundColor Red
}


