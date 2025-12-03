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
  // Deals - Guides endpoints
  // --------------------------
  static String getGuides(int quoteId) => '$baseUrl/api/deals/$quoteId/docs/guides';
  static String createGuide(int quoteId, String type, String guideUrl) => '$baseUrl/api/deals/$quoteId/docs/guides?type=${Uri.encodeComponent(type)}&guideUrl=${Uri.encodeComponent(guideUrl)}';
  static String updateGuideUrl(int quoteId, int guideId, String guideUrl) => '$baseUrl/api/deals/$quoteId/docs/guides/$guideId/url?guideUrl=${Uri.encodeComponent(guideUrl)}';
  static String getTransportistaGuide(int quoteId) => '$baseUrl/api/deals/$quoteId/docs/gre/transportista';
  static String getRemitenteGuide(int quoteId) => '$baseUrl/api/deals/$quoteId/docs/gre/remitente';
  
  // --------------------------
  // Dimensions estimation endpoints
  // --------------------------
  static String get estimateDimensionsEndpoint => '$baseUrl/requests/dimensions/:estimate';
}