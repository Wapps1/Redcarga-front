import '../../domain/repositories/provider_remote_repository.dart';
import '../../domain/models/provider/company_register_request.dart';
import '../../domain/models/provider/company_register_result.dart';
import '../services/provider_service.dart';
import '../mappers/provider_mappers.dart';

class ProviderRemoteRepositoryImpl implements ProviderRemoteRepository {
  final ProviderService _providerService;
  final Future<String> Function() _getFirebaseIdToken;

  ProviderRemoteRepositoryImpl({
    required ProviderService providerService,
    required Future<String> Function() getFirebaseIdToken,
  })  : _providerService = providerService,
        _getFirebaseIdToken = getFirebaseIdToken;

  @override
  Future<CompanyRegisterResult> registerCompany(
    CompanyRegisterRequest request,
  ) async {
    try {
      final firebaseIdToken = await _getFirebaseIdToken();
      final dto = await _providerService.registerCompany(
        request.toDto(),
        firebaseIdToken,
      );
      return dto.toDomain();
    } catch (e) {
      throw Exception('Failed to register company: $e');
    }
  }
}

