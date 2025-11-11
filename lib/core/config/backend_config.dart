/// Configuración del backend
/// 
/// Para cambiar entre localhost y el backend desplegado,
/// modifica el valor de [BackendEnvironment] en [currentEnvironment]
class BackendConfig {
  // Cambia este valor para cambiar entre localhost y producción
  static const BackendEnvironment currentEnvironment = BackendEnvironment.production;
  
  // URLs de los diferentes entornos
  static const String _localBaseUrl = 'http://10.0.2.2:8080';
  static const String _productionBaseUrl = 'https://redcargabk-b4b7cng3ftb2bfea.canadacentral-01.azurewebsites.net';
  
  /// Obtiene la URL base según el entorno actual
  static String get baseUrl {
    switch (currentEnvironment) {
      case BackendEnvironment.local:
        return _localBaseUrl;
      case BackendEnvironment.production:
        return _productionBaseUrl;
    }
  }
  
  /// Indica si estamos en modo local
  static bool get isLocal => currentEnvironment == BackendEnvironment.local;
  
  /// Indica si estamos en modo producción
  static bool get isProduction => currentEnvironment == BackendEnvironment.production;
}

/// Entornos disponibles para el backend
enum BackendEnvironment {
  /// Backend local (localhost o emulador)
  local,
  
  /// Backend desplegado en producción
  production,
}

