class Driver {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String licenseNumber;
  final bool active;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.active,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json['id'] ?? json['driverId'] ?? 0,
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        licenseNumber: json['licenseNumber'] ?? '',
        active: json['active'] ?? true,
      );
}
