import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../features/auth/domain/models/session/app_session.dart';
import '../../features/auth/domain/models/firebase/firebase_session.dart';
import 'session_store.dart';

/// Estados de sesión de la aplicación
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthFirebaseOnly extends AuthState {
  final FirebaseSession session;
  const AuthFirebaseOnly(this.session);

  @override
  List<Object?> get props => [session];
}

class AuthSignedIn extends AuthState {
  final AppSession session;
  const AuthSignedIn(this.session);

  @override
  List<Object?> get props => [session];
}

/// Eventos del BLoC de autenticación
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthBootstrap extends AuthEvent {
  const AuthBootstrap();
}

class AuthAppSessionSaved extends AuthEvent {
  final AppSession session;
  const AuthAppSessionSaved(this.session);

  @override
  List<Object?> get props => [session];
}

class AuthFirebaseSessionSaved extends AuthEvent {
  final FirebaseSession session;
  const AuthFirebaseSessionSaved(this.session);

  @override
  List<Object?> get props => [session];
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}

/// BLoC de autenticación global
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SessionStore _sessionStore;

  AuthBloc({required SessionStore sessionStore})
      : _sessionStore = sessionStore,
        super(const AuthInitial()) {
    on<AuthBootstrap>(_onBootstrap);
    on<AuthAppSessionSaved>(_onAppSessionSaved);
    on<AuthFirebaseSessionSaved>(_onFirebaseSessionSaved);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onBootstrap(
    AuthBootstrap event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 [AuthBloc] Bootstrap: Verificando sesiones guardadas...');
    
    // Primero verificar AppSession
    final appSession = await _sessionStore.getAppSession();
    if (appSession != null) {
      print('✅ [AuthBloc] AppSession encontrada - SessionId: ${appSession.sessionId}');
      emit(AuthSignedIn(appSession));
      return;
    }

    // Si no hay AppSession, verificar FirebaseSession
    final firebaseSession = await _sessionStore.getFirebaseSession();
    if (firebaseSession != null) {
      print('✅ [AuthBloc] FirebaseSession encontrada - UID: ${firebaseSession.uid}');
      emit(AuthFirebaseOnly(firebaseSession));
      return;
    }

    // Si no hay ninguna sesión, usuario no autenticado
    print('ℹ️ [AuthBloc] No hay sesiones guardadas');
    emit(const AuthSignedOut());
  }

  Future<void> _onAppSessionSaved(
    AuthAppSessionSaved event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionStore.saveAppSession(event.session);
    emit(AuthSignedIn(event.session));
    print('✅ [AuthBloc] AppSession guardada y estado actualizado');
  }

  Future<void> _onFirebaseSessionSaved(
    AuthFirebaseSessionSaved event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionStore.saveFirebaseSession(event.session);
    emit(AuthFirebaseOnly(event.session));
    print('✅ [AuthBloc] FirebaseSession guardada y estado actualizado');
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionStore.clearAll();
    emit(const AuthSignedOut());
    print('✅ [AuthBloc] Logout completado');
  }
}


