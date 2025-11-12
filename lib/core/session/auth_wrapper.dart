import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/auth_flow_example.dart';
import '../../features/main/presentation/pages/main_page.dart' show MainPage, UserRole;
import '../../features/auth/domain/models/value/role_code.dart';
import 'auth_bloc.dart';

/// Widget que decide qué mostrar según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          // Estado inicial, mostrar loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthSignedOut) {
          // Usuario no autenticado, mostrar flujo de autenticación
          return const AuthFlowExample();
        }

        if (state is AuthFirebaseOnly) {
          // Solo Firebase autenticado, mostrar flujo de autenticación
          // (esto no debería pasar normalmente, pero por si acaso)
          return const AuthFlowExample();
        }

        if (state is AuthSignedIn) {
          // Usuario autenticado, determinar rol y mostrar MainPage
          final session = state.session;
          final roles = session.roles;
          
          // Determinar el rol del usuario
          // Si tiene PROVIDER, es proveedor, sino es cliente
          final isProvider = roles.contains(RoleCode.provider);
          final userRole = isProvider 
              ? UserRole.provider 
              : UserRole.customer;
          
          print('🏠 [AuthWrapper] Usuario autenticado - Rol: ${userRole.name}, Roles: ${roles.map((r) => r.value).join(", ")}');
          
          return MainPage(role: userRole);
        }

        // Fallback (no debería llegar aquí)
        return const AuthFlowExample();
      },
    );
  }
}

