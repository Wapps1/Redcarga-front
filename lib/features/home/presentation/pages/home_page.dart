import 'package:flutter/material.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/presentation/pages/drivers_page.dart';
import 'package:red_carga/features/fleet/presentation/pages/vehicles_page.dart';
import 'package:red_carga/features/planning/presentation/pages/routes_page.dart';
import 'package:red_carga/features/deals/data/di/deals_repositories.dart';
import 'package:red_carga/features/deals/data/repositories/deals_repository.dart';
import 'package:red_carga/features/deals/data/models/request_dto.dart';
import 'package:red_carga/features/deals/data/models/chat_list_dto.dart';
import 'package:red_carga/features/deals/data/models/quote_dto.dart';
import 'package:red_carga/features/deals/data/models/company_dto.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_chat.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_cotizacion_page.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_chats_page.dart';

class HomePage extends StatefulWidget {
  final UserRole role;

  const HomePage({
    super.key,
    required this.role,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DealsRepository _dealsRepository;
  List<ChatItemDto> _chats = [];
  QuoteDto? _inProgressQuote;
  RequestDto? _inProgressRequest;
  CompanyDto? _inProgressCompany;
  bool _isLoadingChats = false;
  bool _isLoadingInProgress = false;
  int? _companyId;

  @override
  void initState() {
    super.initState();
    _dealsRepository = DealsRepositories.createDealsRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCompanyId();
    await Future.wait([
      _loadChats(),
      _loadInProgressOrders(),
    ]);
  }

  Future<void> _loadCompanyId() async {
    try {
      final sessionStore = SessionStore();
      final session = await sessionStore.getAppSession();
      if (session != null && session.companyId != null) {
        setState(() {
          _companyId = session.companyId;
        });
      }
    } catch (e) {
      print('❌ Error loading companyId: $e');
    }
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoadingChats = true;
    });

    try {
      final chatList = await _dealsRepository.getChatList();
      
      // Tomar los primeros 3 chats
      final recentChats = chatList.chats.take(3).toList();
      
      if (mounted) {
        setState(() {
          _chats = recentChats;
          _isLoadingChats = false;
        });
      }
    } catch (e) {
      print('❌ Error loading chats: $e');
      if (mounted) {
        setState(() {
          _isLoadingChats = false;
        });
      }
    }
  }

  Future<void> _loadInProgressOrders() async {
    if (_companyId == null) return;
    
    setState(() {
      _isLoadingInProgress = true;
    });

    try {
      // Obtener todas las requests del customer
      final requests = await _dealsRepository.getRequests();
      
      // Obtener quotes con estado ACEPTADA para todas las requests
      final allQuotes = <QuoteDto>[];
      for (var request in requests) {
        try {
          final quotes = await _dealsRepository.getQuotesByRequestId(
            request.requestId,
            state: 'ACEPTADA',
          );
          allQuotes.addAll(quotes);
        } catch (e) {
          print('⚠️ Error loading quotes for request ${request.requestId}: $e');
        }
      }
      
      // Filtrar quotes que tengan SHIPMENT_SENT con statusCode DONE
      final inProgressQuotes = <QuoteDto>[];
      for (var quote in allQuotes) {
        try {
          final checklistItems = await _dealsRepository.getChecklistItems(quote.quoteId);
          
          // Verificar si hay un item con code "SHIPMENT_SENT" y statusCode "DONE"
          final hasShipmentSentDone = checklistItems.any(
            (item) => item.code == 'SHIPMENT_SENT' && item.statusCode == 'DONE',
          );
          
          if (hasShipmentSentDone) {
            inProgressQuotes.add(quote);
          }
        } catch (e) {
          print('⚠️ Error loading checklist for quote ${quote.quoteId}: $e');
        }
      }
      
      // Ordenar por fecha de creación (más recientes primero) y tomar el primero
      if (inProgressQuotes.isNotEmpty) {
        inProgressQuotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final selectedQuote = inProgressQuotes.first;
        
        // Obtener el detalle de la quote, la request y la empresa
        final quoteDetail = await _dealsRepository.getQuoteDetail(selectedQuote.quoteId);
        final requestDetail = await _dealsRepository.getRequestDetail(selectedQuote.requestId);
        final company = await _dealsRepository.getCompany(quoteDetail.companyId);
        
        if (mounted) {
          setState(() {
            _inProgressQuote = selectedQuote;
            _inProgressCompany = company;
            _inProgressRequest = RequestDto(
              requestId: requestDetail.requestId,
              requestName: requestDetail.requestName,
              status: requestDetail.status,
              createdAt: requestDetail.createdAt,
              updatedAt: requestDetail.updatedAt,
              closedAt: requestDetail.closedAt,
              origin: requestDetail.origin,
              destination: requestDetail.destination,
              itemsCount: requestDetail.itemsCount,
              totalWeightKg: requestDetail.totalWeightKg,
              paymentOnDelivery: requestDetail.paymentOnDelivery,
            );
            _isLoadingInProgress = false;
          });
        }
        } else {
          if (mounted) {
            setState(() {
              _inProgressQuote = null;
              _inProgressRequest = null;
              _inProgressCompany = null;
              _isLoadingInProgress = false;
            });
          }
        }
    } catch (e) {
      print('❌ Error loading in progress orders: $e');
      if (mounted) {
        setState(() {
          _isLoadingInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.role == UserRole.customer;

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título del rol
              Text(
                isCustomer ? 'CLIENTES' : 'PROVEEDORES',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
              const SizedBox(height: 8),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: rcColor6),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Últimos chats (común para ambos)
              _buildLastChats(context),
              const SizedBox(height: 24),

              // Contenido específico por rol
              if (isCustomer) ...[
                _buildCustomerRoutes(context),
              ] else ...[
                _buildProviderActions(context),
                const SizedBox(height: 24),
                _buildProviderRoutes(context),
                const SizedBox(height: 24),
                _buildProviderDrivers(context),
                const SizedBox(height: 24),
                _buildProviderFleets(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastChats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor2.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rcColor4.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos chats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatsPage(userRole: widget.role),
                    ),
                  );
                },
                child: const Text(
                  'ver más >',
                  style: TextStyle(
                    fontSize: 14,
                    color: rcColor5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingChats)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_chats.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No hay chats activos',
                  style: TextStyle(
                    fontSize: 14,
                    color: rcColor8,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < _chats.length && i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i < 2 ? 12 : 0),
                    child: _buildChatCard(context, _chats[i]),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, ChatItemDto chat) {
    // Obtener el nombre a mostrar (empresa o persona)
    final displayName = chat.otherCompanyTradeName ?? 
                       chat.otherCompanyLegalName ?? 
                       chat.otherPersonFullName ?? 
                       'Usuario';
    
    return GestureDetector(
      onTap: () {
        // Navegar al chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              quoteId: chat.quoteId,
              nombre: displayName,
              userRole: widget.role,
              acceptedDeal: false, // Se actualizará automáticamente en el chat
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: rcWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rcColor4.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono de chat con badge de no leídos
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [rcColor4, rcColor5],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: rcWhite,
                    size: 24,
                  ),
                ),
                if (chat.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: rcColor5,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        chat.unreadCount > 9 ? '9+' : '${chat.unreadCount}',
                        style: const TextStyle(
                          color: rcWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Información del chat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: rcColor6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chat #${chat.quoteId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: rcColor8,
                    ),
                  ),
                ],
              ),
            ),
            // Icono de flecha
            const Icon(
              Icons.chevron_right,
              color: rcColor8,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRoutes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rcColor4.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pedidos en marcha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CotizacionPage(initialTabIndex: 2),
                    ),
                  );
                },
                child: const Text(
                  'Ver todos >',
                  style: TextStyle(
                    fontSize: 12,
                    color: rcColor5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingInProgress)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_inProgressRequest == null || _inProgressQuote == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: rcColor4.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  'No hay pedidos en marcha',
                  style: TextStyle(
                    fontSize: 14,
                    color: rcColor8,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                // Card interno con fondo blanco
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: rcColor4.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _inProgressRequest!.requestName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: rcColor6,
                        ),
                      ),
                      Text(
                        '#${_inProgressRequest!.requestId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: rcColor8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _RouteStops(
                              origin: _inProgressRequest!.origin,
                              destination: _inProgressRequest!.destination,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 120,
                              height: 90,
                              decoration: BoxDecoration(
                                color: rcColor7,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: rcColor8.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: const [
                                  CustomPaint(painter: _MapPainter()),
                                  Positioned(
                                    left: 90,
                                    top: 67.5,
                                    child: Icon(
                                      Icons.location_on,
                                      color: rcColor5,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navegar al chat del pedido en marcha
                    if (_inProgressQuote != null && _inProgressCompany != null) {
                      final companyName = _inProgressCompany!.tradeName ?? 
                                        _inProgressCompany!.legalName ?? 
                                        'Empresa';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            quoteId: _inProgressQuote!.quoteId,
                            nombre: companyName,
                            userRole: widget.role,
                            acceptedDeal: true,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [rcColor4, rcColor5],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Text(
                        'Ver pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: rcWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProviderActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Administrar\nRutas',
                Icons.route,
                rcColor2.withOpacity(0.4),
                rcColor4,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoutesPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Administrar\nconductores',
                Icons.person,
                rcColor3.withOpacity(0.4),
                rcColor4,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DriversPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Administrar\nFlotas',
                Icons.local_shipping,
                rcColor3.withOpacity(0.4),
                rcColor5,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VehiclesPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderRoutes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Rutas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rcColor4.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.location_on, color: rcColor5, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La Molina, Lima',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: rcColor6,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: rcColor4, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La Victoria, Chiclayo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: rcColor6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoutesPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'Ver ruta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderDrivers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Conductores',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        // Card demo (opcional)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rcColor4.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.person, color: rcColor5, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registra y gestiona a tus conductores',
                  style: TextStyle(fontSize: 14, color: rcColor6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón que navega a DriversPage
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriversPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'Ver conductores',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderFleets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus Flotas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rcColor4.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_shipping, color: rcColor5, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Administra tus vehículos y documentos',
                  style: TextStyle(fontSize: 14, color: rcColor6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehiclesPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [rcColor4, rcColor5],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Center(
              child: Text(
                'Ver flotas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteStops extends StatelessWidget {
  final LocationDto origin;
  final LocationDto destination;

  const _RouteStops({
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: rcColor5, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                origin.fullAddress,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: rcColor4, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                destination.fullAddress,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter para el mapa estilizado
class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = rcColor8.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = size.height * 0.2; y < size.height; y += size.height * 0.25) {
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        streetPaint,
      );
    }

    for (double x = size.width * 0.2; x < size.width; x += size.width * 0.3) {
      canvas.drawLine(
        Offset(x, size.height * 0.1),
        Offset(x, size.height * 0.9),
        streetPaint,
      );
    }

    final routePaint = Paint()
      ..color = rcColor5.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.75,
      );
    canvas.drawPath(routePath, routePaint);

    final pointPaint = Paint()
      ..color = rcColor5
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 3.5, pointPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.75), 3.5, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
