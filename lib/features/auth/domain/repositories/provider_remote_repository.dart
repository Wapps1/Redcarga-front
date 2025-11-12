import '../models/provider/company_register_request.dart';
import '../models/provider/company_register_result.dart';

abstract class ProviderRemoteRepository {
  Future<CompanyRegisterResult> registerCompany(CompanyRegisterRequest request);
}

