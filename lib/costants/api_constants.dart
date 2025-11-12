class ApiConstants {
  static final String baseUrl = 'http://redcargabk-b4b7cng3ftb2bfea.canadacentral-01.azurewebsites.net';
  static final String loginEndpoint = '/api/users/login';

  // Fleet - Drivers
  static String driverById(int driverId) => '/fleet/drivers/$driverId';                 // GET, PUT, DELETE
  static String companyDrivers(int companyId) => '/fleet/companies/$companyId/drivers'; // GET (list), POST (create)

  // Fleet - Vehicles
  static String vehicleById(int vehicleId) => '/fleet/vehicles/$vehicleId';                 // GET, PUT, DELETE
  static String companyVehicles(int companyId) => '/fleet/companies/$companyId/vehicles';   // GET (list), POST (create)
}