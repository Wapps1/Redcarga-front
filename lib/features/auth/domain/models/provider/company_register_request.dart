import '../value/email.dart';

class CompanyRegisterRequest {
  final int accountId;
  final String legalName;
  final String tradeName;
  final String ruc;
  final Email email;
  final String phone;
  final String address;

  CompanyRegisterRequest({
    required this.accountId,
    required this.legalName,
    required this.tradeName,
    required this.ruc,
    required this.email,
    required this.phone,
    required this.address,
  });
}

