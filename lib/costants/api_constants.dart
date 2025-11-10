class ApiConstants {
  // URL base para desarrollo local
  // IMPORTANTE: Elige UNA de estas opciones:
  //
  // OPCIÓN 1 (Recomendada): ADB Port Forwarding
  //   1. Ejecuta: .\setup_adb_port_forward.ps1
  //   2. Usa: http://localhost:8080
  //
  // OPCIÓN 2: IP del emulador
  //   Usa: http://10.0.2.2:8080
  //
  // OPCIÓN 3: IP real de tu máquina (si el emulador está en la misma red)
  //   Usa: http://192.168.1.96:8080 (cambia por tu IP local)
  //
  // Si ninguna funciona, verifica:
  // - Que el backend esté corriendo: netstat -ano | findstr :8080
  // - Que el firewall permita conexiones en el puerto 8080
  // IMPORTANTE: En el emulador Android, 'localhost' se refiere al emulador mismo, NO a tu máquina
  // Por eso DEBEMOS usar '10.0.2.2' que es el alias especial del emulador para el host
  // NO usar 'localhost' a menos que hayas configurado ADB port forwarding
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  // Auth endpoints (sin /api, igual que Android)
  static const String registerStartEndpoint = '$baseUrl/iam/register-start';
  static const String loginEndpoint = '$baseUrl/iam/login';
  
  // Identity endpoints
  static const String verifyAndCreatePersonEndpoint = '$baseUrl/identity/verify-and-create';
  
  // Provider endpoints
  static const String registerCompanyEndpoint = '$baseUrl/providers/company/verify-and-register';
}