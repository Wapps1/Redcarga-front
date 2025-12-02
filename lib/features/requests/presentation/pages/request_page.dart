import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme.dart';
import '../../../../core/session/auth_bloc.dart';
import '../../../../core/session/session_store.dart';
import '../../data/request_inbox_service.dart';
import '../../domain/models/request_inbox_item.dart';
import '../blocs/request_inbox_bloc.dart';
import '../blocs/request_inbox_event.dart';
import '../blocs/request_inbox_state.dart';
import 'details_request_page.dart';
import 'summary_requests_page.dart';

class SolicitudesPage extends StatelessWidget {
  const SolicitudesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener companyId desde AuthBloc
    final sessionCompanyId = context.select<AuthBloc, int?>((bloc) {
      final s = bloc.state;
      return s is AuthSignedIn ? s.session.companyId : null;
    });

    if (sessionCompanyId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business, size: 64, color: rcColor8),
              const SizedBox(height: 16),
              const Text(
                'Registra tu empresa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: rcColor6),
              ),
              const SizedBox(height: 8),
              const Text(
                'Para ver solicitudes, primero debes registrar tu empresa',
                textAlign: TextAlign.center,
                style: TextStyle(color: rcColor8),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => RequestInboxBloc(
        service: RequestInboxService(SessionStore()),
      )..add(RequestInboxLoad(sessionCompanyId)),
      child: _SolicitudesView(companyId: sessionCompanyId),
    );
  }
}

class _SolicitudesView extends StatefulWidget {
  final int companyId;
  const _SolicitudesView({required this.companyId});

  @override
  State<_SolicitudesView> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<_SolicitudesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _selectedTab) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _refresh() async {
    if (mounted) {
      context.read<RequestInboxBloc>().add(RequestInboxRefresh(widget.companyId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              rcColor5,
                            rcColor3,

            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      'Solicitudes',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: rcWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: rcWhite),
                      onPressed: () {
                        // Acción del menú
                      },
                    ),
                  ],
                ),
              ),
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton('Todas', 0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTabButton('Aceptadas', 1),
                    ),
                  ],
                ),
              ),
              // Contenedor blanco con lista de solicitudes
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: rcColor1,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Barra de búsqueda
                      _buildSearchBar(),
                      // Lista de solicitudes
                      Expanded(
                        child: BlocBuilder<RequestInboxBloc, RequestInboxState>(
                          builder: (context, state) {
                            if (state.status == RequestInboxStatus.loading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state.status == RequestInboxStatus.failure) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, size: 64, color: rcColor8),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.message ?? 'Error al cargar solicitudes',
                                      style: const TextStyle(color: rcColor8),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refresh,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return RefreshIndicator(
                              onRefresh: _refresh,
                              child: _buildSolicitudesList(state.requests),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? rcWhite : Colors.transparent,
          border: Border.all(
            color: rcColor7.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? rcColor4 : rcWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar una Solicitud',
                hintStyle: TextStyle(
                  color: rcColor8,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: rcColor6,
                fontSize: 14,
              ),
            ),
          ),
          const Icon(
            Icons.search,
            color: rcColor6,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudesList(List<RequestInboxItem> allRequests) {
    // Filtrar por tab (Todas o Aceptadas)
    List<RequestInboxItem> filteredRequests = _selectedTab == 0
        ? allRequests
        : allRequests.where((r) => r.isAccepted).toList();

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filteredRequests = filteredRequests.where((request) {
        return request.requesterName.toLowerCase().contains(_searchQuery) ||
            request.originDisplay.toLowerCase().contains(_searchQuery) ||
            request.destDisplay.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (filteredRequests.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty
              ? 'No se encontraron solicitudes'
              : 'No hay solicitudes',
          style: const TextStyle(
            color: rcColor8,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSolicitudCard(filteredRequests[index]),
        );
      },
    );
  }

  Widget _buildSolicitudCard(RequestInboxItem solicitud) {
    final isAceptada = solicitud.isAccepted;
    final isAceptadasTab = _selectedTab == 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del usuario
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: rcColor6,
              ),
              children: [
                TextSpan(
                  text: solicitud.requesterName,
                  style: const TextStyle(
                    color: rcColor4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: ' ha realizado una solicitud',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Detalles
          _buildDetailRow('Día:', solicitud.formattedDate),
          const SizedBox(height: 4),
          _buildDetailRow('Origen:', solicitud.originDisplay),
          const SizedBox(height: 4),
          _buildDetailRow('Destino:', solicitud.destDisplay),
          const SizedBox(height: 8),
          // Icono de paquete y cantidad
          Row(
            children: [
              // Icono de caja con colores originales
              SvgPicture.asset(
                'assets/icons/box_icon.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              // Badge circular con cantidad
              Container(
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rcColor7,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'X${solicitud.totalQuantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: rcColor4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Botones
          _buildDetallesButton(solicitud),
          if (isAceptadasTab && isAceptada) ...[
            const SizedBox(height: 8),
            _buildIrAlChatButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: rcColor6,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: rcColor6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetallesButton(RequestInboxItem solicitud) {
    final isAceptada = solicitud.isAccepted;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Convertir RequestInboxItem a Map para compatibilidad con las páginas existentes
          final solicitudMap = {
            'requestId': solicitud.requestId, // Importante: pasar el requestId para cargar el detalle
            'nombre': solicitud.requesterName,
            'dia': solicitud.formattedDate,
            'origen': solicitud.originDisplay,
            'destino': solicitud.destDisplay,
            'cantidad': solicitud.totalQuantity,
            'aceptada': isAceptada,
            'status': solicitud.status,
            'matchedRouteId': solicitud.matchedRouteId,
            'routeTypeId': solicitud.routeTypeId,
          };
          
          if (isAceptada && _selectedTab == 1) {
            // Si está en la pestaña "Aceptadas", mostrar resumen (solo lectura)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResumenSolicitudPage(solicitud: solicitudMap),
              ),
            );
          } else {
            // Si está en "Todas", mostrar detalles completos (cargará datos del endpoint)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallesSolicitudPage(solicitud: solicitudMap),
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: rcColor4.withOpacity(0.5), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: rcWhite,
        ),
        child: const Text(
          'Detalles',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: rcColor4,
          ),
        ),
      ),
    );
  }

  Widget _buildIrAlChatButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [rcColor4, rcColor5],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navegar al chat
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: Text(
                  'Ir al chat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: rcWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
