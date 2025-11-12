import '../core/config/backend_config.dart';

class ApiConstants {
  // URL base obtenida de la configuración del backend
  static String get baseUrl => BackendConfig.baseUrl;
  
  // Auth endpoints (sin /api, igual que Android)
  static String get registerStartEndpoint => '$baseUrl/iam/register-start';
  static String get loginEndpoint => '$baseUrl/iam/login';
  
  // Identity endpoints
  static String get verifyAndCreatePersonEndpoint => '$baseUrl/identity/verify-and-create';
  
  // Provider endpoints
  static String get registerCompanyEndpoint => '$baseUrl/providers/company/verify-and-register';
}