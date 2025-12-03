import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/auth_flow_example.dart';
import '../../features/main/presentation/pages/main_page.dart' show MainPage, UserRole;
import '../../features/auth/domain/models/value/role_code.dart';
import 'auth_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is AuthSignedOut || state is AuthFirebaseOnly) {
          return const AuthFlowExample();
        }

        if (state is AuthSignedIn) {
          final session = state.session;
          final globalRoles = session.roles;
          final companyRoles = session.companyRoles;

          final isDriver = globalRoles.contains(RoleCode.driver) ||
              companyRoles.contains(RoleCode.driver);
          final isProvider = globalRoles.contains(RoleCode.provider);

          final userRole = isDriver
              ? UserRole.driver
              : isProvider
                  ? UserRole.provider
                  : UserRole.customer;

          print(
            '🏠 [AuthWrapper] Usuario autenticado - Rol: ${userRole.name}, Roles: ${globalRoles.map((r) => r.value).join(", ")}, CompanyRoles: ${companyRoles.map((r) => r.value).join(", ")}',
          );

          return MainPage(role: userRole);
        }

        return const AuthFlowExample();
      },
    );
  }
}