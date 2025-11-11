import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/value/email.dart';
import '../../../domain/models/value/password.dart';
import '../../../domain/models/value/platform.dart' as domain;
import '../../../domain/models/session/app_login_request.dart';
import '../../../domain/repositories/auth_remote_repository.dart';
import '../../../domain/repositories/firebase_auth_repository.dart';
import 'package:red_carga/core/session/auth_bloc.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRemoteRepository _authRemoteRepository;
  final FirebaseAuthRepository _firebaseAuthRepository;
  final AuthBloc _authBloc;

  SignInBloc({
    required AuthRemoteRepository authRemoteRepository,
    required FirebaseAuthRepository firebaseAuthRepository,
    required AuthBloc authBloc,
  })  : _authRemoteRepository = authRemoteRepository,
        _firebaseAuthRepository = firebaseAuthRepository,
        _authBloc = authBloc,
        super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    emit(state.copyWith(email: event.email, clearError: true));
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    emit(state.copyWith(password: event.password, clearError: true));
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    print('🚀🚀🚀 [SignInBloc] MÉTODO _onSubmitted EJECUTADO - VERSIÓN NUEVA 🚀🚀🚀');
    print('🔐 [SignInBloc] Iniciando proceso de login...');
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      // Paso 1: Firebase login
      print('🔥 [SignInBloc] Paso 1: Autenticando con Firebase...');
      final firebaseSession = await _firebaseAuthRepository.signInWithPassword(
        Email(state.email),
        Password(state.password),
      );
      print('✅ [SignInBloc] Firebase login exitoso - UID: ${firebaseSession.uid}');

      // Paso 2: Backend login
      print('🌐 [SignInBloc] Paso 2: Autenticando con backend...');
      
      // FORZAR valores WEB y 192.168.1.1
      final platform = domain.Platform.web;
      final ip = '192.168.1.1';
      final ttlSeconds = 3600; // 1 hora (igual que en Swagger)
      
      // Logs de verificación
      print('🔍 [SignInBloc] VERIFICACIÓN - Platform enum: $platform');
      print('🔍 [SignInBloc] VERIFICACIÓN - Platform.value: ${platform.value}');
      print('🔍 [SignInBloc] VERIFICACIÓN - IP: $ip');
      
      final loginRequest = AppLoginRequest(
        platform: platform, 
        ip: ip, 
        ttlSeconds: ttlSeconds,
      );
      
      print('🔍 [SignInBloc] VERIFICACIÓN - Request platform: ${loginRequest.platform.value}');
      print('🔍 [SignInBloc] VERIFICACIÓN - Request IP: ${loginRequest.ip}');
      
      final appSession = await _authRemoteRepository.login(loginRequest);
      print('✅ [SignInBloc] Backend login exitoso - AccountId: ${appSession.accountId}, Roles: ${appSession.roles.map((r) => r.value).join(", ")}');

      // Guardar sesión en el AuthBloc global
      _authBloc.add(AuthAppSessionSaved(appSession));
      
      print('🎉 [SignInBloc] Login completo exitoso');
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      ));
    } catch (e, stackTrace) {
      print('❌ [SignInBloc] Error en login: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      ));
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('firebase')) {
      if (errorString.contains('user-not-found') || errorString.contains('wrong-password')) {
        return 'Email o contraseña incorrectos';
      }
      if (errorString.contains('network')) {
        return 'Error de conexión. Verifica tu internet';
      }
      return 'Error de autenticación: ${error.toString()}';
    }
    
    if (errorString.contains('failed to login')) {
      return 'Error al iniciar sesión. Verifica tus credenciales';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Error de conexión. Verifica tu internet';
    }
    
    return 'Error: ${error.toString()}';
  }
}

