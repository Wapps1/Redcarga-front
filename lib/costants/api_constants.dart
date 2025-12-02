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

  // -------------------------
  // Fleet - Drivers endpoints
  // -------------------------
  static String driverById(int driverId) => '$baseUrl/fleet/drivers/$driverId';
  static String companyDrivers(int companyId) => '$baseUrl/fleet/companies/$companyId/drivers';

  // --------------------------
  // Fleet - Vehicles endpoints
  // --------------------------
  static String vehicleById(int vehicleId) => '$baseUrl/fleet/vehicles/$vehicleId';
  static String companyVehicles(int companyId) => '$baseUrl/fleet/companies/$companyId/vehicles';

  // --------------------------
  // Requests endpoints
  // --------------------------
  static String get createRequestEndpoint => '$baseUrl/requests/create-request';
  static String requestById(int requestId) => '$baseUrl/requests/$requestId';
  
  // --------------------------
  // Geo endpoints
  // --------------------------
  static String get geoCatalogEndpoint => '$baseUrl/geo/catalog';
  
  // --------------------------
  // Media endpoints
  // --------------------------
  static String get uploadImageEndpoint => '$baseUrl/media/uploads:image';
  static String get uploadPdfEndpoint => '$baseUrl/media/uploads:pdf';
  
  // --------------------------
  // Deals endpoints
  // --------------------------
  static String get createQuoteEndpoint => '$baseUrl/api/deals/quotes';
  static String rejectQuote(int quoteId) => '$baseUrl/api/deals/quotes/$quoteId:reject';
  
  // --------------------------
  // Dimensions estimation endpoints
  // --------------------------
  static String get estimateDimensionsEndpoint => '$baseUrl/requests/dimensions/:estimate';
  
  // --------------------------
  // Planning - Routes endpoints
  // --------------------------
  // GET: Obtener rutas de un proveedor
  static String providerRoutes(int companyId) => '$baseUrl/planning/providers/$companyId/routes';
  // POST/PUT/DELETE: Crear/actualizar/eliminar rutas de una compañía
  static String companyRoutes(int companyId) => '$baseUrl/planning/companies/$companyId/routes';
  
  // --------------------------
  // Planning - Request Inbox endpoints
  // --------------------------
  static String requestInbox(int companyId) => '$baseUrl/planning/companies/$companyId/request-inbox';
}