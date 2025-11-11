import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'package:red_carga/core/session/auth_bloc.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/core/session/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTA: No necesitamos inicializar Firebase.initializeApp() porque
  // usamos la API REST de Firebase directamente (igual que en Android)
  // No se requiere google-services.json
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(redcargaTextTheme());
    
    return BlocProvider(
      create: (context) {
        final authBloc = AuthBloc(sessionStore: SessionStore());
        // Hacer bootstrap al iniciar
        authBloc.add(const AuthBootstrap());
        return authBloc;
      },
      child: MaterialApp(
        title: 'Red Carga',
        debugShowCheckedModeBanner: false,
        theme: materialTheme.light(),
        darkTheme: materialTheme.dark(),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),
        home: const AuthWrapper(),
      ),
    );
  }
}
