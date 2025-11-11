import 'package:flutter/material.dart';
import 'package:red_carga/features/deals/presentation/pages/chats_page.dart';
import 'package:red_carga/features/deals/presentation/pages/cotizacion_page.dart';
import 'package:red_carga/features/home/presentation/pages/home_page.dart';
import '../widgets/customer_bottom_bar.dart';
import '../widgets/provider_bottom_bar.dart';

enum UserRole { customer, provider }

class MainPage extends StatefulWidget {
  final UserRole role;
  const MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  // Páginas para cada rol
  late final List<Widget> _customerPages = <Widget>[
    HomePage(role: widget.role),
    const CotizacionPage(),
    const ChatsPage(),
    const _Stub('Perfil'),
  ];

  late final List<Widget> _providerPages = <Widget>[
    HomePage(role: widget.role),
    const _Stub('Rutas'),
    const _Stub('Documentos'),
    const ChatsPage(),
    const _Stub('Perfil'),
  ];

  void _onTabChanged(int index) {
    setState(() => selectedIndex = index);
  }

  void _onCreatePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear nueva solicitud')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer =  widget.role == UserRole.customer;
    //final isCustomer =  false;
    final pages = isCustomer ? _customerPages : _providerPages;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),

      // Bottom bar específico por rol
      bottomNavigationBar: isCustomer
          ? CustomerBottomBar(
              currentIndex: selectedIndex,
              onChanged: _onTabChanged,
              onCreatePressed: _onCreatePressed,
            )
          : ProviderBottomBar(
              currentIndex: selectedIndex,
              onChanged: _onTabChanged,
            ),
    );
  }
}

// Placeholder para compilar si aún no tienes las páginas
class _Stub extends StatelessWidget {
  final String title;
  const _Stub(this.title);
  @override
  Widget build(BuildContext context) => Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      );
}
