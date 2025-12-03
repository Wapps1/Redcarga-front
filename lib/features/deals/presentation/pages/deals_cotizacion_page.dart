import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/presentation/widgets/cotizacion_card.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_view_cotizacion.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_chat.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';
import 'package:red_carga/features/deals/data/di/deals_repositories.dart';
import 'package:red_carga/features/deals/data/repositories/deals_repository.dart';
import 'package:red_carga/features/deals/data/models/request_dto.dart';
import 'package:red_carga/features/deals/data/models/quote_dto.dart';
import 'package:red_carga/features/deals/data/models/quote_detail_dto.dart';
import 'package:red_carga/features/deals/data/models/company_dto.dart';
import 'package:red_carga/features/deals/data/models/checklist_item_dto.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/auth/domain/models/value/role_code.dart';
import 'package:intl/intl.dart';

class CotizacionPage extends StatefulWidget {
  final int? initialTabIndex; // 0: Todas, 1: En trato, 2: En marcha
  
  const CotizacionPage({super.key, this.initialTabIndex});

  @override
  State<CotizacionPage> createState() => _CotizacionPageState();
}

class _CotizacionPageState extends State<CotizacionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final colorScheme = MaterialTheme.lightScheme();
  
  // Repositorio y servicios
  late DealsRepository _dealsRepository;
  
  // Estados de datos
  List<RequestDto> _requests = [];
  RequestDto? _selectedRequest;
  List<QuoteDto> _quotes = [];
  Map<int, QuoteDetailDto> _quoteDetails = {};
  Map<int, CompanyDto> _companies = {}; // Cache de empresas
  bool _isLoadingRequests = false;
  bool _isLoadingQuotes = false;
  String? _errorMessage;
  
  // Estado del selector desplegable
  bool _isRequestDropdownOpen = false;
  
  // Helper para obtener el rol del usuario
  Future<UserRole> _getUserRole() async {
    try {
      final sessionStore = SessionStore();
      final session = await sessionStore.getAppSession();
      if (session != null && session.roles.isNotEmpty) {
        // Prioridad: driver > provider > customer
        if (session.roles.contains(RoleCode.driver)) {
          return UserRole.driver;
        } else if (session.roles.contains(RoleCode.provider)) {
          return UserRole.provider;
        } else {
          return UserRole.customer;
        }
      }
    } catch (e) {
      print('❌ Error getting user role: $e');
    }
    // Fallback a customer si no se puede obtener
    return UserRole.customer;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _tabController.addListener(() {
      setState(() {});
      // Recargar cotizaciones cuando cambia el tab
      if (_selectedRequest != null) {
        _loadQuotes(_selectedRequest!.requestId);
      }
    });
    
    // Inicializar repositorio usando el helper centralizado
    _dealsRepository = DealsRepositories.createDealsRepository();
    
    // Cargar solicitudes
    _loadRequests();
  }
  
  Future<void> _loadRequests() async {
    setState(() {
      _isLoadingRequests = true;
      _errorMessage = null;
    });
    
    try {
      final requests = await _dealsRepository.getRequests();
      setState(() {
        _requests = requests;
        if (requests.isNotEmpty && _selectedRequest == null) {
          _selectedRequest = requests.first;
          _loadQuotes(requests.first.requestId);
        }
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar solicitudes: $e';
        _isLoadingRequests = false;
      });
      print('❌ Error loading requests: $e');
    }
  }
  
  Future<void> _loadQuotes(int requestId) async {
    setState(() {
      _isLoadingQuotes = true;
      _errorMessage = null;
    });
    
    try {
      List<QuoteDto> quotes = [];
      
      switch (_tabController.index) {
        case 0: // Todas - sin filtrar por state (como antes)
          quotes = await _dealsRepository.getQuotesByRequestId(
            requestId,
            state: 'PENDIENTE',
          );
          break;
        case 1: // En trato - llamar 2 veces con "ACEPTADA" y "TRATO"
          final quotesAceptadas = await _dealsRepository.getQuotesByRequestId(
            requestId,
            state: 'ACEPTADA',
          );
          final quotesTrato = await _dealsRepository.getQuotesByRequestId(
            requestId,
            state: 'TRATO',
          );
          // Combinar ambas listas, evitando duplicados por quoteId
          final quoteIds = <int>{};
          quotes = [];
          for (var quote in [...quotesAceptadas, ...quotesTrato]) {
            if (!quoteIds.contains(quote.quoteId)) {
              quoteIds.add(quote.quoteId);
              quotes.add(quote);
            }
          }
          break;
        case 2: // En marcha - solo "ACEPTADA" y filtrar por checklist
          final quotesAceptadas = await _dealsRepository.getQuotesByRequestId(
            requestId,
            state: 'ACEPTADA',
          );
          
          print('📦 [CotizacionPage] Quotes aceptadas encontradas: ${quotesAceptadas.length}');
          
          // Filtrar quotes que tengan SHIPMENT_SENT en el checklist (debe existir el registro)
          final filteredQuotes = <QuoteDto>[];
          for (var quote in quotesAceptadas) {
            try {
              final checklistItems = await _dealsRepository.getChecklistItems(quote.quoteId);
              print('📋 [CotizacionPage] Quote ${quote.quoteId} - Checklist items: ${checklistItems.length}');
              print('📋 [CotizacionPage] Items: ${checklistItems.map((i) => '${i.code}:${i.statusCode}').join(', ')}');
              
              // Verificar si hay un item con code "SHIPMENT_SENT" y statusCode "DONE"
              final shipmentSentItem = checklistItems.firstWhere(
                (item) => item.code == 'SHIPMENT_SENT',
                orElse: () => ChecklistItemDto(
                  instanceItemId: 0,
                  instanceId: 0,
                  code: '',
                  statusCode: '',
                ),
              );
              
              final hasShipmentSentDone = shipmentSentItem.code == 'SHIPMENT_SENT' && 
                                         shipmentSentItem.statusCode == 'DONE';
              print('📦 [CotizacionPage] Quote ${quote.quoteId} - SHIPMENT_SENT status: ${shipmentSentItem.statusCode}, Tiene DONE: $hasShipmentSentDone');
              
              if (hasShipmentSentDone) {
                filteredQuotes.add(quote);
                print('✅ [CotizacionPage] Quote ${quote.quoteId} agregada a filtradas');
              }
            } catch (e) {
              print('⚠️ Error loading checklist for quote ${quote.quoteId}: $e');
              // Si hay error al cargar el checklist, no incluir la quote
            }
          }
          
          print('📦 [CotizacionPage] Quotes filtradas finales: ${filteredQuotes.length}');
          quotes = filteredQuotes;
          break;
      }
      
      // Cargar detalles de cada cotización y datos de empresas
      final Map<int, QuoteDetailDto> details = {};
      final Map<int, CompanyDto> companies = {};
      
      for (final quote in quotes) {
        try {
          final detail = await _dealsRepository.getQuoteDetail(quote.quoteId);
          details[quote.quoteId] = detail;
          
          // Cargar datos de la empresa si no están en cache
          if (!_companies.containsKey(quote.companyId)) {
            try {
              final company = await _dealsRepository.getCompany(quote.companyId);
              companies[quote.companyId] = company;
            } catch (e) {
              print('⚠️ Error loading company ${quote.companyId}: $e');
            }
          }
        } catch (e) {
          print('⚠️ Error loading quote detail ${quote.quoteId}: $e');
        }
      }
      
      setState(() {
        _quotes = quotes;
        _quoteDetails = details;
        _companies.addAll(companies); // Agregar nuevas empresas al cache
        _isLoadingQuotes = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar cotizaciones: $e';
        _isLoadingQuotes = false;
      });
      print('❌ Error loading quotes: $e');
    }
  }
  
  void _onRequestSelected(RequestDto? request) {
    if (request != null && request.requestId != _selectedRequest?.requestId) {
      setState(() {
        _selectedRequest = request;
        _isRequestDropdownOpen = false;
        _quotes = [];
        _quoteDetails = {};
      });
      _loadQuotes(request.requestId);
    }
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  String _formatPrice(double amount, String currencyCode) {
    final currencySymbol = currencyCode == 'PEN' ? 's/' : '\$';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  'Cotizaciones',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: rcWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildTab('Todas', 0),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTab('En trato', 1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTab('En marcha', 2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent('Todas', 'Todas las cotizaciones disponibles'),
                    _buildTabContent('En trato', 'Cotizaciones en proceso de negociación'),
                    _buildTabContent('En marcha', 'Cotizaciones en camino'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabController.index == index;
    
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.2),
                border: Border.all(
                  color: colorScheme.primaryContainer,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: rcWhite,
                    width: 1,
                  ),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? rcWhite : rcWhite,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetalles(BuildContext context, int quoteId, String empresaNombre, String solicitudNombre, String precio) {
    final tabName = _tabController.index == 0 
        ? 'todas' 
        : _tabController.index == 1 
            ? 'en trato' 
            : 'en marcha';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ViewCotizacionPage(
          quoteId: quoteId,
          tabOrigen: tabName,
        ),
      ),
    );
  }

  Widget _buildTabContent(String titulo, String descripcion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.only(top: 5),

      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del tab
                /*Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: rcColor6,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
                const SizedBox(height: 8),
                // Descripción del tab
                Text(
                  descripcion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rcColor8,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Sección de Solicitud
                _buildSolicitudSection(),
                
                const SizedBox(height: 20),
                
                // Barra de búsqueda
                _buildSearchBar(),
                
              ],
            ),
          ),
          
          // Lista de cotizaciones
          Expanded(
            child: _buildQuotesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isRequestDropdownOpen = !_isRequestDropdownOpen;
              });
            },
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Expanded(
                  child: Text(
                    _selectedRequest?.requestName ?? 'Selecciona una solicitud',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: rcColor6,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                  _isRequestDropdownOpen 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down,
                color: rcColor8,
              ),
            ],
          ),
          ),
          if (_isRequestDropdownOpen && _requests.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: rcWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rcColor8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final isSelected = _selectedRequest?.requestId == request.requestId;
                  return InkWell(
                    onTap: () => _onRequestSelected(request),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? rcColor1 : rcWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.requestName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? rcColor6 : rcColor8,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (_selectedRequest != null) ...[
          const SizedBox(height: 12),
            _buildSolicitudRow('Día:', _formatDate(_selectedRequest!.createdAt)),
          const SizedBox(height: 8),
            _buildSolicitudRow('Origen:', _selectedRequest!.origin.fullAddress),
          const SizedBox(height: 8),
            _buildSolicitudRow('Destino:', _selectedRequest!.destination.fullAddress),
          ] else if (_isLoadingRequests) ...[
            const SizedBox(height: 12),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSolicitudRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: rcColor8,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: rcColor6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuotesList() {
    if (_selectedRequest == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Selecciona una solicitud para ver las cotizaciones',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: rcColor8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    if (_isLoadingQuotes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null && _quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_selectedRequest != null) {
                    _loadQuotes(_selectedRequest!.requestId);
                  }
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No hay cotizaciones disponibles para esta solicitud',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: rcColor8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    final isTodasTab = _tabController.index == 0;
    final isOtherTabs = _tabController.index == 1 || _tabController.index == 2; // "EN TRATO" o "EN MARCHA"
    
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      children: _quotes.map((quote) {
        final company = _companies[quote.companyId];
        final empresaNombre = company?.tradeName ?? company?.legalName ?? 'Empresa ${quote.companyId}';
        
        return CotizacionCard(
          empresaNombre: empresaNombre,
          solicitudNombre: _selectedRequest?.requestName ?? '',
          calificacion: 3, // TODO: Obtener calificación real de la empresa
          precio: _formatPrice(quote.totalAmount, quote.currencyCode),
          isTodasTab: isTodasTab,
          backgroundColor: (isTodasTab || isOtherTabs) ? rcColor1 : null, // Color de fondo para todos los tabs
          onVerCotizacion: isTodasTab ? () {
            _navigateToDetalles(
              context,
              quote.quoteId,
              empresaNombre,
              _selectedRequest?.requestName ?? '',
              _formatPrice(quote.totalAmount, quote.currencyCode),
            );
          } : null,
          onDetalles: isOtherTabs ? () {
            _navigateToDetalles(
              context,
              quote.quoteId,
              empresaNombre,
              _selectedRequest?.requestName ?? '',
              _formatPrice(quote.totalAmount, quote.currencyCode),
            );
          } : null,
          onChat: isOtherTabs ? () async {
            final detail = _quoteDetails[quote.quoteId];
            final company = _companies[quote.companyId];
            final empresaNombre = company?.tradeName ?? company?.legalName ?? 'Empresa ${quote.companyId}';
            final requestName = _selectedRequest?.requestName ?? 'Solicitud';
            final titulo = '$empresaNombre - $requestName';
            
            // Obtener el rol del usuario desde la sesión
            final userRole = await _getUserRole();
            
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    quoteId: quote.quoteId,
                    nombre: titulo,
                    userRole: userRole,
                    acceptedDeal: detail?.stateCode == 'ACEPTADA',
                  ),
                ),
              );
            }
          } : null,
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: rcWhite,
        border: Border.all(color: rcColor8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar un Cotizaciones',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: rcColor8,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: rcColor8,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
