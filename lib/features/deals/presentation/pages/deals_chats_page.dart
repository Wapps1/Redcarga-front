import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/presentation/widgets/chat_card.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_chat.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';
import 'package:red_carga/features/deals/data/di/deals_repositories.dart';
import 'package:red_carga/features/deals/data/repositories/deals_repository.dart';
import 'package:red_carga/features/deals/data/models/chat_list_dto.dart';

class ChatsPage extends StatefulWidget {
  final UserRole userRole;
  
  const ChatsPage({
    super.key,
    this.userRole = UserRole.customer,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // Repositorio
  late DealsRepository _dealsRepository;
  
  // Estados de datos
  List<ChatItemDto> _chats = [];
  Map<int, String> _requestNames = {}; // Cache de nombres de solicitudes por quoteId
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dealsRepository = DealsRepositories.createDealsRepository();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final chatList = await _dealsRepository.getChatList();
      
      // Cargar nombres de solicitudes para cada chat
      final Map<int, String> requestNames = {};
      for (final chat in chatList.chats) {
        try {
          // Obtener el detalle de la cotización para obtener el requestId
          final quoteDetail = await _dealsRepository.getQuoteDetail(chat.quoteId);
          // Obtener el detalle de la solicitud para obtener el requestName
          final requestDetail = await _dealsRepository.getRequestDetail(quoteDetail.requestId);
          requestNames[chat.quoteId] = requestDetail.requestName;
        } catch (e) {
          print('⚠️ Error loading request name for quote ${chat.quoteId}: $e');
          requestNames[chat.quoteId] = 'Solicitud #${chat.quoteId}'; // Fallback
        }
      }
      
      setState(() {
        _chats = chatList.chats;
        _requestNames = requestNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los chats: $e';
        _isLoading = false;
      });
      print('❌ Error loading chats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
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
                  'Chat',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: rcWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              
              // Contenedor blanco con lista de chats
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
                  child: _buildChatsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null && _chats.isEmpty) {
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
                onPressed: _loadChats,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No hay chats disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: rcColor8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await _loadChats();
      },
      child: ListView(
        padding: const EdgeInsets.all(25),
        children: _chats.map((chat) {
        final isCustomer = widget.userRole == UserRole.customer;
        
        // Determinar el nombre según el rol
        String nombreEmpresaOCliente;
        if (isCustomer) {
          // Para customers: nombre de la empresa
          nombreEmpresaOCliente = (chat.otherCompanyTradeName?.isNotEmpty ?? false)
              ? chat.otherCompanyTradeName!
              : (chat.otherCompanyLegalName ?? 'Empresa ${chat.otherCompanyId}');
        } else {
          // Para proveedores: nombre del cliente
          nombreEmpresaOCliente = chat.otherPersonFullName ?? 'Cliente ${chat.otherUserId}';
        }
        
        // Obtener el nombre de la solicitud
        final requestName = _requestNames[chat.quoteId] ?? 'Solicitud';
        
        // Formatear el título: "nombre - solicitud"
        final titulo = '$nombreEmpresaOCliente - $requestName';
        
        final tieneMensajesNoLeidos = chat.unreadCount > 0;
        
        return ChatCard(
          nombre: titulo,
          ultimoMensaje: 'Cotización #${chat.quoteId}', // Placeholder ya que no viene en la respuesta
          hora: '—', // Placeholder ya que no viene en la respuesta
          tieneMensajesNoLeidos: tieneMensajesNoLeidos,
          cantidadNoLeidos: chat.unreadCount,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  quoteId: chat.quoteId,
                  nombre: titulo,
                  userRole: widget.userRole,
                  acceptedDeal: true,
                ),
              ),
            );
          },
        );
      }).toList(),
      ),
    );
  }
}
