import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth/presentation/pages/auth_flow_example.dart';
import 'core/theme.dart';

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
    
    return MaterialApp(
      title: 'Red Carga',
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
      home: const AuthFlowExample(),
    );
  }
}
