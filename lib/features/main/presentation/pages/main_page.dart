import 'package:flutter/material.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_chats_page.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_cotizacion_page.dart';
import 'package:red_carga/features/home/presentation/pages/home_page.dart';
import 'package:red_carga/features/providers/presentation/pages/provider_profile_page.dart';
import 'package:red_carga/features/customers/presentation/pages/customer_profile_page.dart';
import 'package:red_carga/features/driver/presentation/pages/driver_home_page.dart';
import 'package:red_carga/features/driver/presentation/pages/driver_map_page.dart';
import 'package:red_carga/features/driver/presentation/pages/driver_profile_page.dart';
import 'package:red_carga/features/profile/presentation/pages/profile_page.dart';
import 'package:red_carga/features/requests/presentation/pages/requests_page.dart';
import 'package:red_carga/features/planning/presentation/pages/routes_page.dart';
import '../widgets/customer_bottom_bar.dart';
import '../widgets/provider_bottom_bar.dart';
import '../widgets/driver_bottom_bar.dart';

enum UserRole { customer, provider, driver }

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
    ChatsPage(userRole: widget.role),
    const CustomerProfilePage(),
  ];

  late final List<Widget> _providerPages = <Widget>[
    HomePage(role: widget.role),
    const RoutesPage(),
    RequestsPage(role: widget.role),
    ChatsPage(userRole: widget.role),
    const ProviderProfilePage(),
  ];

  late final List<Widget> _driverPages = <Widget>[
    DriverHomePage(onNavigateToMap: () => _onTabChanged(1)),
    DriverMapPage(quoteId: 0),
    const DriverProfilePage(),
  ];

  void _onTabChanged(int index) {
    setState(() => selectedIndex = index);
  }

  void _onCreatePressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestsPage(role: widget.role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.role == UserRole.customer;
    final isDriver = widget.role == UserRole.driver;
    //final isCustomer = false;
    //final isDriver = true;
    final pages = isCustomer
        ? _customerPages
        : isDriver
            ? _driverPages
            : _providerPages;

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
          : isDriver
              ? DriverBottomBar(
                  currentIndex: selectedIndex,
                  onChanged: _onTabChanged,
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
