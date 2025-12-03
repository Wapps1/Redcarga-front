import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/driver/domain/driver_identity_repository.dart';

import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final DriverIdentityRepository identityRepository;
  final SessionStore sessionStore;

  DriverProfileBloc({
    required this.identityRepository,
    required this.sessionStore,
  }) : super(const DriverProfileInitial()) {
    on<DriverProfileStarted>(_onStarted);
  }

  Future<void> _onStarted(
    DriverProfileStarted event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(const DriverProfileLoading());

    try {
      final appSession = await sessionStore.getAppSession();
      final firebaseSession = await sessionStore.getFirebaseSession();

      if (appSession == null) {
        emit(const DriverProfileError('No hay sesión activa.'));
        return;
      }

      final identity = await identityRepository.getIdentity(
        accountId: appSession.accountId,
        accessToken: appSession.accessToken,
      );

      final fallbackUsername = identity.fullName.trim().split(RegExp(r'\s+'));
      final username = appSession.username?.trim().isNotEmpty == true
          ? appSession.username!
          : (fallbackUsername.isNotEmpty ? fallbackUsername.first : '');

      final email =
          appSession.email ?? firebaseSession?.email ?? '';

      emit(DriverProfileLoaded(
        fullName: identity.fullName,
        username: username,
        email: email,
        docNumber: identity.docNumber,
        phone: identity.phone,
      ));
    } catch (e, stackTrace) {
      print('❌ [DriverProfileBloc] Error en _onStarted: $e');
      print(stackTrace);
      emit(const DriverProfileError(
        'Ocurrió un error al cargar la información del conductor.',
      ));
    }
  }
}