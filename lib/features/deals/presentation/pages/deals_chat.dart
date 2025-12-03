import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_edit_cotizacion.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/counteroffer_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/counteroffer_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/cancel_deal_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/cancel_deal_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/payment_made_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/payment_confirm_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/payment_made_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/package_received_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/package_received_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/rating_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/accept_deal_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/assign_fleet_driver_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/accept_deal_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/shipment_sent_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/shipment_sent_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/edit_deal_chat_card.dart';
import 'package:red_carga/features/deals/data/di/deals_repositories.dart';
import 'package:red_carga/features/deals/data/repositories/deals_repository.dart';
import 'package:red_carga/features/deals/data/models/quote_change_request_dto.dart';
import 'package:red_carga/features/deals/data/models/assignment_dto.dart';
import 'package:red_carga/features/deals/data/models/checklist_item_dto.dart';
import 'package:red_carga/features/deals/data/models/company_dto.dart';
import 'package:red_carga/features/deals/data/models/driver_dto.dart';
import 'package:red_carga/features/deals/data/models/vehicle_dto.dart';
import 'package:red_carga/core/session/session_store.dart';
import 'package:red_carga/features/auth/domain/models/value/role_code.dart';
import 'package:red_carga/features/auth/data/repositories/identity_remote_repository_impl.dart';
import 'package:red_carga/features/auth/data/services/identity_service.dart';
import 'package:red_carga/features/auth/data/models/user_identity_dto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatPage extends StatefulWidget {
  final int quoteId;
  final String nombre;
  final UserRole userRole;
  final bool acceptedDeal;

  const ChatPage({
    super.key,
    required this.quoteId,
    required this.nombre,
    required this.userRole,
    this.acceptedDeal = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// Modelo unificado de mensaje del chat
class ChatMessage {
  final String id;
  final String? text;
  final bool isMe;
  final DateTime timestamp;
  final String? imagePath;
  final String? filePath;
  final String? fileName;
  final MessageType type;
  final bool isSystemEvent;
  final String? systemSubtypeCode; // Para eventos del sistema
  final String? info; // Para eventos del sistema
  final bool isUnread; // Para marcar mensajes no leídos

  ChatMessage({
    required this.id,
    this.text,
    required this.isMe,
    required this.timestamp,
    this.imagePath,
    this.filePath,
    this.fileName,
    required this.type,
    this.isSystemEvent = false,
    this.systemSubtypeCode,
    this.info,
    this.isUnread = false,
  });
}

enum MessageType {
  text,
  image,
  file,
  systemEvent,
}

// Estados para acciones del chat
enum ChatAction {
  none,
  counteroffer, // contraoferta
  quoteEdit, // edición de cotización
  dealCancellation, // cancelar trato
  paymentMade, // pago realizado
  packageReceived, // paquete recibido
  dealAcceptance, // aceptación de trato
  shipmentSent, // carga enviada
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isActionsExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Repositorio y datos del usuario
  late DealsRepository _dealsRepository;
  late IdentityRemoteRepositoryImpl _identityRepository;
  int? _currentAccountId;
  bool _isLoadingMessages = false;
  
  // Cambiar este valor para forzar acceptedDeal a false (comentar/descomentar)
  // final bool _actualAcceptedDeal = false;
  late bool _actualAcceptedDeal;
  
  // Lista de mensajes del chat
  final List<ChatMessage> _messages = [];
  int _lastReadMessageId = 0;
  
  // Estados de acciones del chat
  ChatAction _otherPersonAction = ChatAction.none; // Acción de la otra persona
  double _counterofferPrice = 0.0; // Precio de la contraoferta
  double _currentQuotePrice = 0.0; // Precio actual de la cotización
  bool _isMyCounteroffer = false; // Si el usuario actual hizo la contraoferta
  bool _isMyCancellation = false; // Si el usuario actual canceló el trato
  bool _isMyPayment = false; // Si el usuario actual confirmó el pago
  bool _isMyPackageReceived = false; // Si el usuario actual confirmó la recepción del paquete
  bool _isMyDealAcceptance = false; // Si el usuario actual aceptó el trato
  String? _assignedFleet; // Flota asignada (solo para proveedor)
  String? _assignedDriver; // Conductor asignado (solo para proveedor)
  bool _isMyShipmentSent = false; // Si el usuario actual envió la carga
  bool _isMyEdit = false; // Si el usuario actual editó el documento
  AssignmentDto? _currentAssignment; // Asignación actual de flota y conductor
  List<ChecklistItemDto> _checklistItems = []; // Items del checklist
  bool _isLoadingChecklist = false; // Estado de carga del checklist
  bool _isChecklistExpanded = false; // Estado de expansión del checklist

  @override
  void initState() {
    super.initState();
    _dealsRepository = DealsRepositories.createDealsRepository();
    
    // Inicializar repositorio de identidad
    final identityService = IdentityService();
    final sessionStore = SessionStore();
    _identityRepository = IdentityRemoteRepositoryImpl(
      identityService: identityService,
      getFirebaseIdToken: () async {
        final session = await sessionStore.getAppSession();
        if (session == null) {
          throw Exception('No hay sesión activa');
        }
        return session.accessToken;
      },
    );
    
    // Inicializar con false, se actualizará al cargar el detalle de la cotización
    _actualAcceptedDeal = false;
    
    _tabController = TabController(
      length: 1, // Inicialmente solo el tab de Chat
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Listener para detectar Enter y enviar mensaje
    _messageController.addListener(() {
      final text = _messageController.text;
      // Si el texto termina con un salto de línea, enviar el mensaje
      if (text.endsWith('\n') && text.trim().isNotEmpty) {
        // Remover el salto de línea
        _messageController.text = text.substring(0, text.length - 1);
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
        // Enviar el mensaje
        _enviarMensaje();
      }
    });
    
    // Cargar el estado de la cotización y los mensajes del chat
    _loadQuoteState();
    _loadChatMessages();
    _loadAssignment();
    _loadChecklist();
  }
  
  Future<void> _loadChecklist() async {
    try {
      setState(() {
        _isLoadingChecklist = true;
      });
      
      final items = await _dealsRepository.getChecklistItems(widget.quoteId);
      
      if (mounted) {
        setState(() {
          _checklistItems = items;
          _isLoadingChecklist = false;
        });
      }
    } catch (e) {
      print('❌ Error loading checklist: $e');
      if (mounted) {
        setState(() {
          _isLoadingChecklist = false;
        });
      }
    }
  }
  
  Future<void> _loadAssignment() async {
    try {
      final assignment = await _dealsRepository.getAssignment(widget.quoteId);
      if (mounted) {
        setState(() {
          _currentAssignment = assignment;
        });
      }
    } catch (e) {
      print('❌ Error loading assignment: $e');
      // No mostrar error al usuario, simplemente no hay asignación
    }
  }

  Future<void> _loadQuoteState() async {
    try {
      // Cargar detalle de la cotización para obtener el stateCode
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId);
      
      // Determinar si el trato está aceptado basándose en el stateCode
      final isAccepted = quoteDetail.stateCode == 'ACEPTADA';
      
      if (mounted) {
        setState(() {
          _actualAcceptedDeal = isAccepted;
          _currentQuotePrice = quoteDetail.totalAmount;
          
          // Actualizar el TabController si es necesario
          if (isAccepted && _tabController.length == 1) {
            _tabController.dispose();
            _tabController = TabController(length: 2, vsync: this);
            _tabController.addListener(() {
              setState(() {});
            });
          } else if (!isAccepted && _tabController.length == 2) {
            _tabController.dispose();
            _tabController = TabController(length: 1, vsync: this);
            _tabController.addListener(() {
              setState(() {});
            });
          }
        });
      }
    } catch (e) {
      print('❌ Error loading quote state: $e');
      // En caso de error, mantener el valor por defecto
    }
  }

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

  Future<void> _loadChatMessages() async {
    setState(() {
      _isLoadingMessages = true;
    });
    
    try {
      // Obtener accountId del usuario actual
      final sessionStore = SessionStore();
      final session = await sessionStore.getAppSession();
      if (session != null) {
        _currentAccountId = session.accountId;
      }
      
      // Cargar mensajes del chat
      final chatDto = await _dealsRepository.getChat(widget.quoteId);
      _lastReadMessageId = chatDto.lastReadMessageId;
      
      // Mapear mensajes del API a mensajes locales (procesar en batches para no bloquear)
      final List<ChatMessage> messages = [];
      final messagesCount = chatDto.messages.length;
      
      // Procesar en batches de 50 para no bloquear el hilo principal
      const batchSize = 50;
      for (int i = 0; i < messagesCount; i += batchSize) {
        final end = (i + batchSize < messagesCount) ? i + batchSize : messagesCount;
        
        // Procesar batch sin crear sublista innecesaria
        for (int j = i; j < end; j++) {
          final msgDto = chatDto.messages[j];
          final isMe = _currentAccountId != null && msgDto.createdBy == _currentAccountId;
          final isUnread = msgDto.messageId > _lastReadMessageId;
          
          // Parsear fecha de forma segura (cachear si es posible)
          DateTime timestamp;
          try {
            timestamp = DateTime.parse(msgDto.createdAt);
          } catch (e) {
            timestamp = DateTime.now(); // Fallback si hay error de parsing
          }
          
          if (msgDto.typeCode == 'SYSTEM') {
            // Es un evento del sistema
            messages.add(ChatMessage(
              id: msgDto.messageId.toString(),
              text: msgDto.body,
              isMe: isMe,
              timestamp: timestamp,
              type: MessageType.systemEvent,
              isSystemEvent: true,
              systemSubtypeCode: msgDto.systemSubtypeCode,
              info: msgDto.info,
              isUnread: isUnread,
            ));
          } else {
            // Es un mensaje de usuario
            MessageType messageType = MessageType.text;
            String? fileName;
            String? imagePath;
            String? filePath;
            
            if (msgDto.contentCode == 'IMAGE') {
              messageType = MessageType.image;
              imagePath = msgDto.mediaUrl;
            } else if (msgDto.mediaUrl != null) {
              messageType = MessageType.file;
              filePath = msgDto.mediaUrl;
              // Optimizar: solo hacer split si realmente necesitamos el fileName
              final lastSlash = msgDto.mediaUrl!.lastIndexOf('/');
              fileName = lastSlash >= 0 && lastSlash < msgDto.mediaUrl!.length - 1
                  ? msgDto.mediaUrl!.substring(lastSlash + 1)
                  : null;
            }
            
            messages.add(ChatMessage(
              id: msgDto.messageId.toString(),
              text: msgDto.body,
              isMe: isMe,
              timestamp: timestamp,
              type: messageType,
              imagePath: imagePath,
              filePath: filePath,
              fileName: fileName,
              isUnread: isUnread,
            ));
          }
        }
        
        // Permitir que el hilo principal procese otros eventos entre batches
        if (i + batchSize < messagesCount) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
      
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
          _isLoadingMessages = false;
        });
      }
      
      _scrollToBottom();
    } catch (e) {
      print('❌ Error loading chat messages: $e');
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  @override
  void dispose() {
    // Marcar mensajes como leídos antes de salir
    _markMessagesAsRead();
    
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    if (_messages.isEmpty) return;
    
    try {
      // Obtener el ID del último mensaje
      final lastMessageId = _messages
          .map((msg) => int.tryParse(msg.id) ?? 0)
          .reduce((a, b) => a > b ? a : b);
      
      if (lastMessageId > 0) {
        await _dealsRepository.markMessagesAsRead(widget.quoteId, lastMessageId);
        print('✅ Mensajes marcados como leídos: lastSeenMessageId=$lastMessageId');
      }
    } catch (e) {
      print('❌ Error marking messages as read: $e');
      // No mostrar error al usuario ya que está saliendo del chat
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    final isCustomer = widget.userRole == UserRole.customer;
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: rcWhite,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.nombre,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: rcWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Menú de opciones
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: rcWhite,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Tabs (solo si acceptedDeal es true)
              if (_actualAcceptedDeal)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildTab('Chat', 0, colorScheme),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTab('Información', 1, colorScheme),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Contenido de los tabs
              Expanded(
                child: _actualAcceptedDeal
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          _buildChatTab(isCustomer, colorScheme),
                          _buildInfoTab(isCustomer, colorScheme),
                        ],
                      )
                    : _buildChatTab(isCustomer, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, ColorScheme colorScheme) {
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

  Widget _buildChatTab(bool isCustomer, ColorScheme colorScheme) {
    return Container(
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
          // Área de chat
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_otherPersonAction != ChatAction.none ? 1 : 0),
              itemBuilder: (context, index) {
                      // Mostrar cards de acciones especiales si existen (solo si no hay mensaje del sistema correspondiente)
                if (index == _messages.length && _otherPersonAction != ChatAction.none) {
                        // Verificar si ya existe un mensaje del sistema para esta acción
                        bool hasSystemMessage = false;
                        if (_otherPersonAction == ChatAction.counteroffer) {
                          hasSystemMessage = _messages.any((msg) => 
                            msg.isSystemEvent && 
                            msg.systemSubtypeCode == 'CHANGE_PROPOSED' &&
                            msg.isMe == _isMyCounteroffer
                          );
                        }
                        
                        // Solo mostrar el card temporal si no hay mensaje del sistema
                        if (!hasSystemMessage) {
                  return _buildActionCard(colorScheme);
                        } else {
                          // Si ya hay mensaje del sistema, limpiar la acción temporal
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _otherPersonAction = ChatAction.none;
                              });
                            }
                          });
                          return const SizedBox.shrink();
                        }
                }
                
                final message = _messages[index];
                      
                      // Mostrar separador de mensajes no leídos
                      final shouldShowUnreadSeparator = index > 0 && 
                          message.isUnread && 
                          !_messages[index - 1].isUnread;
                      
                      return Column(
                        children: [
                          if (shouldShowUnreadSeparator)
                            _buildUnreadSeparator(colorScheme),
                          Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMessageWidget(message, colorScheme),
                          ),
                        ],
                );
              },
            ),
          ),

          // Zona de acciones (colapsable)
          _buildActionsSection(isCustomer, colorScheme),

          // Input de mensaje
          _buildMessageInput(colorScheme),
        ],
      ),
    );
  }

  Widget _buildActionCard(ColorScheme colorScheme) {
    switch (_otherPersonAction) {
      case ChatAction.counteroffer:
        return CounterofferChatCard(
          precio: _counterofferPrice,
          isMyCounteroffer: _isMyCounteroffer,
          onAceptar: () {
            setState(() {
              _otherPersonAction = ChatAction.none;
            });
            // TODO: Aceptar contraoferta
          },
          onRechazar: () {
            setState(() {
              _otherPersonAction = ChatAction.none;
            });
            // TODO: Rechazar contraoferta
          },
        );
      case ChatAction.dealCancellation:
        return CancelDealChatCard(
          isMyCancellation: _isMyCancellation,
        );
      case ChatAction.paymentMade:
        return PaymentMadeChatCard(
          isMyPayment: _isMyPayment,
        );
      case ChatAction.packageReceived:
        return PackageReceivedChatCard(
          isMyReceipt: _isMyPackageReceived,
        );
      case ChatAction.dealAcceptance:
        return AcceptDealChatCard(
          isMyAcceptance: _isMyDealAcceptance,
          fleet: _assignedFleet,
          driver: _assignedDriver,
        );
      case ChatAction.shipmentSent:
        return ShipmentSentChatCard(
          isMyShipment: _isMyShipmentSent,
        );
      case ChatAction.quoteEdit:
        return EditDealChatCard(
          acceptedDeal: _actualAcceptedDeal,
          isMyEdit: _isMyEdit,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageWidget(ChatMessage message, ColorScheme colorScheme) {
    // Si es un evento del sistema, mostrar la card correspondiente
    if (message.isSystemEvent && message.systemSubtypeCode != null) {
      return _buildSystemEventCard(message, colorScheme);
    }
    
    // Si es un mensaje de usuario normal
    switch (message.type) {
      case MessageType.text:
        return _buildMessageBubble(message.text ?? '', message.isMe, colorScheme, timestamp: message.timestamp);
      case MessageType.image:
        return _buildImageMessage(message, colorScheme);
      case MessageType.file:
        return _buildFileMessage(message, colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUnreadSeparator(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Mensajes no leídos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemEventCard(ChatMessage message, ColorScheme colorScheme) {
    final isMe = message.isMe;
    final subtypeCode = message.systemSubtypeCode!;
    
    switch (subtypeCode) {
      case 'CHANGE_PROPOSED':
        // Si acceptedDeal es true, mostrar card de editar documento
        // Si acceptedDeal es false, mostrar card de contraoferta
        final changeData = _extractChangeFromInfo(message.info);
        final isCreatedByMe = changeData?['createdBy'] != null && 
                              _currentAccountId != null && 
                              changeData!['createdBy'] == _currentAccountId;
        
        if (_actualAcceptedDeal) {
          // Si el cambio está pendiente y no lo creó el usuario actual, mostrar botón para ver cotización
          return EditDealChatCard(
            acceptedDeal: _actualAcceptedDeal,
            isMyEdit: isCreatedByMe,
            statusCode: changeData?['statusCode'] as String?,
            timestamp: message.timestamp,
            onVerCotizacion: changeData?['statusCode'] == 'PENDIENTE' &&
                    changeData?['changeId'] != null &&
                    !isCreatedByMe
                ? () => _verCotizacionConCambios(
                      widget.quoteId,
                      changeData!['changeId'] as int,
                    )
                : null,
          );
        } else {
          // Contraoferta propuesta
          final price = _extractPriceFromInfo(message.info);
          return CounterofferChatCard(
            precio: price ?? 0.0,
            isMyCounteroffer: isMe,
            statusCode: changeData?['statusCode'] as String?,
            timestamp: message.timestamp,
            onVerCotizacion: changeData?['statusCode'] == 'PENDIENTE' &&
                    changeData?['changeId'] != null &&
                    !isCreatedByMe
                ? () => _verCotizacionConCambios(
                      widget.quoteId,
                      changeData!['changeId'] as int,
                    )
                : null,
            onAceptar: () {
              // TODO: Aceptar contraoferta
            },
            onRechazar: () {
              // TODO: Rechazar contraoferta
            },
          );
        }
      case 'CHANGE_ACCEPTED':
        // Cambio aceptado - mostrar card según si es acceptedDeal o no
        final changeDataAccepted = _extractChangeFromInfo(message.info);
        final isCreatedByMeAccepted = changeDataAccepted?['createdBy'] != null && 
                                      _currentAccountId != null && 
                                      changeDataAccepted!['createdBy'] == _currentAccountId;
        
        if (_actualAcceptedDeal) {
          return EditDealChatCard(
            acceptedDeal: _actualAcceptedDeal,
            isMyEdit: isCreatedByMeAccepted,
            statusCode: changeDataAccepted?['statusCode'] as String?,
            timestamp: message.timestamp,
          );
        } else {
          // Cambio aceptado (contraoferta)
          final changeData = _extractChangeFromInfo(message.info);
          final price = _extractPriceFromInfo(message.info);
          return CounterofferChatCard(
            precio: price ?? 0.0,
            isMyCounteroffer: isMe,
            statusCode: changeData?['statusCode'] as String?,
            timestamp: message.timestamp,
          );
        }
      case 'ACCEPTANCE_CONFIRMED':
      case 'ACCEPTANCE_REQUEST':
        // Trato aceptado
        final acceptanceData = _extractAcceptanceFromInfo(message.info);
        return AcceptDealChatCard(
          isMyAcceptance: isMe,
          fleet: _extractFleetFromInfo(message.info),
          driver: _extractDriverFromInfo(message.info),
          status: acceptanceData?['status'] as String?,
          acceptanceId: acceptanceData?['acceptanceId'] as int?,
          initiatorUserId: acceptanceData?['initiatorUserId'] as int?,
          currentUserId: _currentAccountId,
          timestamp: message.timestamp,
          onAceptar: acceptanceData?['status'] == 'PENDIENTE' &&
                  acceptanceData?['acceptanceId'] != null &&
                  acceptanceData?['initiatorUserId'] != null &&
                  _currentAccountId != null &&
                  acceptanceData?['initiatorUserId'] != _currentAccountId
              ? () => _confirmarAceptacion(acceptanceData!['acceptanceId'] as int)
              : null,
          onRechazar: acceptanceData?['status'] == 'PENDIENTE' &&
                  acceptanceData?['acceptanceId'] != null &&
                  acceptanceData?['initiatorUserId'] != null &&
                  _currentAccountId != null &&
                  acceptanceData?['initiatorUserId'] != _currentAccountId
              ? () => _rechazarAceptacion(acceptanceData!['acceptanceId'] as int)
              : null,
        );
      case 'CHANGE_APPLIED':
        // Edición aplicada
        return EditDealChatCard(
          acceptedDeal: _actualAcceptedDeal,
          isMyEdit: isMe,
          timestamp: message.timestamp,
        );
      case 'QUOTE_REJECTED':
        // Trato cancelado
        return CancelDealChatCard(
          isMyCancellation: isMe,
          timestamp: message.timestamp,
        );
      case 'PAYMENT_MADE':
        // Pago realizado - mostrar botón para confirmar recepción si no es mi pago
        return PaymentMadeChatCard(
          isMyPayment: isMe,
          systemSubtypeCode: subtypeCode,
          timestamp: message.timestamp,
          onConfirmarRecepcion: !isMe
              ? () => _mostrarModalConfirmarRecepcionPago()
              : null,
        );
      case 'PAYMENT_CONFIRMED':
        // Pago confirmado por ambas partes
        return PaymentMadeChatCard(
          isMyPayment: isMe,
          systemSubtypeCode: subtypeCode,
          timestamp: message.timestamp,
        );
      case 'SHIPMENT_RECEIVED':
        // Paquete recibido - mostrar card de envío recibido
        return ShipmentSentChatCard(
          isMyShipment: isMe,
          systemSubtypeCode: subtypeCode,
          timestamp: message.timestamp,
        );
      case 'SHIPMENT_SENT':
        // Carga enviada - mostrar botón para confirmar recepción si no es mi envío
        return ShipmentSentChatCard(
          isMyShipment: isMe,
          systemSubtypeCode: subtypeCode,
          timestamp: message.timestamp,
          onConfirmarRecepcion: !isMe
              ? () => _mostrarModalConfirmarRecepcionEnvio()
              : null,
        );
      case 'DOC_GRE_REMITENTE':
      case 'DOC_GRE_TRANSPORTISTA':
      case 'INFO':
      case 'STATE_TRANSITION':
      case 'CHANGE_REJECTED':
      case 'ACCEPTANCE_REJECTED':
      default:
        // Mostrar como mensaje de texto genérico
        return _buildMessageBubble(
          message.info ?? message.text ?? 'Evento del sistema',
          false,
          colorScheme,
          timestamp: message.timestamp,
        );
    }
  }

  double? _extractPriceFromInfo(String? info) {
    if (info == null) return null;
    try {
      // Intentar extraer el precio del info (puede estar en formato JSON o texto)
      final regex = RegExp(r'(\d+\.?\d*)');
      final match = regex.firstMatch(info);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
    } catch (e) {
      print('Error extracting price from info: $e');
    }
    return null;
  }

  String? _extractFleetFromInfo(String? info) {
    if (info == null) return null;
    // Intentar extraer la flota del info
    final regex = RegExp(r'[Ff]lota[:\s]+([^,\n]+)');
    final match = regex.firstMatch(info);
    return match?.group(1)?.trim();
  }

  String? _extractDriverFromInfo(String? info) {
    if (info == null) return null;
    // Intentar extraer el conductor del info
    final regex = RegExp(r'[Cc]onductor[:\s]+([^,\n]+)');
    final match = regex.firstMatch(info);
    return match?.group(1)?.trim();
  }

  /// Extrae los datos del cambio del campo info
  Map<String, dynamic>? _extractChangeFromInfo(String? info) {
    if (info == null) return null;
    try {
      Map<String, dynamic> infoMap;
      
      // El info siempre viene como String (JSON string) desde el DTO
      try {
        infoMap = jsonDecode(info) as Map<String, dynamic>;
      } catch (e) {
        // Si no es JSON válido, retornar null
        return null;
      }
      
      // Extraer datos del cambio
      final change = infoMap['change'] as Map<String, dynamic>?;
      if (change == null) return null;
      
      return {
        'changeId': change['changeId'] as int?,
        'statusCode': change['statusCode'] as String?,
        'createdBy': change['createdBy'] as int?,
        'kindCode': change['kindCode'] as String?,
      };
    } catch (e) {
      print('Error extracting change from info: $e');
      return null;
    }
  }

  /// Extrae los datos de aceptación del campo info
  Map<String, dynamic>? _extractAcceptanceFromInfo(String? info) {
    if (info == null) return null;
    try {
      Map<String, dynamic> infoMap;
      
      // El info siempre viene como String (JSON string) desde el DTO
      try {
        infoMap = jsonDecode(info) as Map<String, dynamic>;
      } catch (e) {
        // Si no es JSON válido, retornar null
        return null;
      }
      
      // Extraer datos de aceptación
      final acceptance = infoMap['acceptance'] as Map<String, dynamic>?;
      if (acceptance == null) return null;
      
      return {
        'acceptanceId': acceptance['acceptanceId'] as int?,
        'status': acceptance['status'] as String?,
        'initiatorUserId': acceptance['initiatorUserId'] as int?,
        'resolverUserId': acceptance['resolverUserId'] as int?,
      };
    } catch (e) {
      print('Error extracting acceptance from info: $e');
      return null;
    }
  }

  Widget _buildMessageBubble(String message, bool isMe, ColorScheme colorScheme, {DateTime? timestamp}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : rcColor7,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isMe ? rcWhite : rcColor6,
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatMessageTime(timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isMe ? rcWhite.withOpacity(0.7) : rcColor8,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      // Si es hoy, mostrar solo la hora
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Si es ayer
      return 'Ayer ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      // Si es otro día, mostrar fecha y hora
      return DateFormat('dd/MM HH:mm').format(timestamp);
    }
  }

  Widget _buildImageMessage(ChatMessage message, ColorScheme colorScheme) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? colorScheme.primary : rcColor7,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imagePath != null)
                Image.file(
                  File(message.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: rcColor8.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: rcWhite, size: 50),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.text != null && message.text!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                          message.text!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.isMe ? rcWhite : rcColor6,
                        ),
                        ),
                      ),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: message.isMe ? rcWhite.withOpacity(0.7) : rcColor8,
                            fontSize: 11,
                          ),
                    ),
                  ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileMessage(ChatMessage message, ColorScheme colorScheme) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe ? colorScheme.primary : rcColor7,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: message.isMe ? rcWhite : colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.fileName ?? 'Archivo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.isMe ? rcWhite : rcColor6,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.text != null && message.text!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        message.text!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: message.isMe ? rcWhite.withOpacity(0.8) : rcColor8,
                          ),
                      overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: message.isMe ? rcWhite.withOpacity(0.7) : rcColor8,
                          fontSize: 11,
                        ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(bool isCustomer, ColorScheme colorScheme) {
    return Column(
      children: [
        // División
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: rcColor8.withOpacity(0.3),
        ),
        
        // Botón para expandir/colapsar
        GestureDetector(
          onTap: () {
            setState(() {
              _isActionsExpanded = !_isActionsExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: rcColor1,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isActionsExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: colorScheme.primary,
                  size: 20,
                ),
                if (!_isActionsExpanded) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Acciones',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Contenido de acciones
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          child: ClipRect(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isActionsExpanded ? 1.0 : 0.0,
              child: _isActionsExpanded
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: rcColor1,
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _buildActionButtons(isCustomer, colorScheme),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(bool isCustomer, ColorScheme colorScheme) {
    if (isCustomer) {
      // Acciones para CUSTOMER
      return [
        _buildActionButton(
          'Ver Cotización actual',
          colorScheme.primary,
          colorScheme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: false,
                  isCustomer: true,
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          'Editar cotización',
          colorScheme.secondary,
          colorScheme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: true,
                  isCustomer: true,
                  onEdicionCompletada: (motivo) {
                    setState(() {
                      _otherPersonAction = ChatAction.quoteEdit;
                      _isMyEdit = true;
                    });
                  },
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          'Hacer contraoferta',
          colorScheme.primary,
          colorScheme,
          onTap: () {
            _mostrarModalContraoferta(_currentQuotePrice > 0 ? _currentQuotePrice : 1000.0);
          },
        ),
        if (!_actualAcceptedDeal)
          _buildActionButton(
            'Aceptar trato',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalAceptarTrato();
            },
          ),
        if (_actualAcceptedDeal)
          _buildActionButton(
            'Pago enviado',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalPagoRealizado();
            },
          ),
        _buildActionButton(
          'Cancelar trato',
          rcColor1,
          colorScheme,
          isOutlined: true,
          onTap: () {
            _mostrarModalCancelarTrato();
          },
        ),
      ];
    } else {
      // Acciones para PROVIDER
      return [
        _buildActionButton(
          'Ver Cotización actual',
          colorScheme.primary,
          colorScheme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: false,
                  isCustomer: false,
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          'Editar cotización',
          colorScheme.secondary,
          colorScheme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: true,
                  isCustomer: false,
                  onEdicionCompletada: (motivo) {
                    setState(() {
                      _otherPersonAction = ChatAction.quoteEdit;
                      _isMyEdit = true;
                    });
                  },
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          'Hacer contraoferta',
          colorScheme.primary,
          colorScheme,
          onTap: () {
            _mostrarModalContraoferta(_currentQuotePrice > 0 ? _currentQuotePrice : 1000.0);
          },
        ),
        if (!_actualAcceptedDeal)
          _buildActionButton(
            'Aceptar trato',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalAceptarTrato();
            },
          ),
        if (_actualAcceptedDeal) ...[
          _buildActionButton(
            'Asignación de flota',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalAsignarFlotaConductor();
            },
          ),
          _buildActionButton(
            'Carga enviada',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalCargaEnviada();
            },
          ),
        ],
        _buildActionButton(
          'Cancelar trato',
          rcColor1,
          colorScheme,
          isOutlined: true,
          onTap: () {
            _mostrarModalCancelarTrato();
          },
        ),
      ];
    }
  }

  Widget _buildActionButton(
    String label,
    Color backgroundColor,
    ColorScheme colorScheme, {
    bool isOutlined = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isOutlined ? rcColor1 : backgroundColor,
        border: isOutlined
            ? Border.all(
                color: colorScheme.primary,
                width: 1.5,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            // TODO: Acción del botón
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isOutlined ? colorScheme.primary : rcWhite,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón adjuntar documento
          IconButton(
            onPressed: _seleccionarArchivo,
            icon: Icon(
              Icons.attach_file,
              color: colorScheme.primary,
            ),
          ),
          // Botón tomar/seleccionar foto
          PopupMenuButton<String>(
            icon: Icon(
              Icons.camera_alt,
              color: colorScheme.primary,
            ),
            onSelected: (value) {
              if (value == 'camera') {
                _tomarFoto();
              } else if (value == 'gallery') {
                _seleccionarFoto();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Tomar foto'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'gallery',
                child: Row(
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text('Seleccionar de galería'),
                  ],
                ),
              ),
            ],
          ),
          // Campo de texto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviarMensaje(),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rcWhite,
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: rcWhite,
                    ),
                textCapitalization: TextCapitalization.sentences,
                enableSuggestions: true,
                autocorrect: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón enviar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _enviarMensaje,
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.send,
                    color: rcWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(bool isCustomer, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checklist
            if (_checklistItems.isNotEmpty || _isLoadingChecklist) ...[
              Text(
                'Checklist',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: rcColor6,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (_isLoadingChecklist)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: rcColor8.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: rcColor8.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header clicable
                      GestureDetector(
                    onTap: () {
                          setState(() {
                            _isChecklistExpanded = !_isChecklistExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                'Tareas pendientes',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: rcColor6,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              // Contador de completados
                              Text(
                                '${_checklistItems.where((item) => item.isCompleted).length}/${_checklistItems.length}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: rcColor8,
                                      fontSize: 12,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _isChecklistExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: rcColor8,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Contenido expandible
                      if (_isChecklistExpanded) ...[
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: rcColor8.withOpacity(0.2),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: _checklistItems
                                .map((item) => _buildChecklistItem(item, colorScheme))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
              ),
              const SizedBox(height: 24),
            ],
            // Asignación de flota (solo para provider)
            if (!isCustomer && _actualAcceptedDeal) ...[
              _buildInfoSection(
                'Asignación de flota',
                [
                  if (_currentAssignment != null) ...[
                    // Mostrar información de la asignación actual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: rcColor7,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asignación actual:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: rcColor6,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<Map<String, String?>>(
                            future: _getAssignmentDetails(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              final details = snapshot.data ?? {};
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (details['vehicle'] != null)
                                    Text(
                                      'Flota: ${details['vehicle']}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: rcColor6,
                                          ),
                                    ),
                                  if (details['driver'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Conductor: ${details['driver']}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: rcColor6,
                                          ),
                                    ),
                                  ],
                                ],
                      );
                    },
                  ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildActionButton(
                    _currentAssignment != null
                        ? 'Modificar asignación'
                        : 'Asignar flota y conductor',
          colorScheme.primary,
          colorScheme,
          onTap: () {
                      _mostrarModalAsignarFlotaConductor();
          },
        ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Documentos
              _buildInfoSection(
                'Documentos',
                [
                  _buildDocumentButton('Guía de remisión', colorScheme),
                  _buildDocumentButton('Guía de transportista', colorScheme),
                ],
              ),
            // Acciones comentadas por ahora
            // if (isCustomer) ...[
            //   // Vista para customer
            //   _buildInfoSection(
            //     'Acciones',
            //     [
            //       _buildActionButton(
            //         'Ver Cotización actual',
            //         colorScheme.primary,
            //         colorScheme,
            //         onTap: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder: (context) => EditCotizacionPage(
            //                 acceptedDeal: _actualAcceptedDeal,
            //                 editingMode: false,
            //                 isCustomer: isCustomer,
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //       _buildActionButton(
            //         'Editar carga actual',
            //         colorScheme.secondary,
            //         colorScheme,
            //         onTap: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder: (context) => EditCotizacionPage(
            //                 quoteId: widget.quoteId,
            //                 acceptedDeal: _actualAcceptedDeal,
            //                 editingMode: true,
            //                 isCustomer: isCustomer,
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //       _buildActionButton(
            //         'Hacer contraoferta',
            //         colorScheme.primary,
            //         colorScheme,
            //         onTap: () {
            //           _mostrarModalContraoferta(_currentQuotePrice > 0 ? _currentQuotePrice : 1000.0);
            //         },
            //       ),
            //       _buildActionButton(
            //         'Paquete recibido',
            //         colorScheme.secondary,
            //         colorScheme,
            //         onTap: () {
            //           _mostrarModalPaqueteRecibido();
            //         },
            //       ),
            //     ],
            //   ),
            //   const SizedBox(height: 24),
            // ] else ...[
            //   // Vista para provider
            //   if (_actualAcceptedDeal) ...[
            //     _buildInfoSection(
            //       'Asignación de flota',
            //       [
            //         if (_currentAssignment != null) ...[
            //           // Mostrar información de la asignación actual
            //           Container(
            //             width: double.infinity,
            //             padding: const EdgeInsets.all(16),
            //             decoration: BoxDecoration(
            //               color: rcColor7,
            //               borderRadius: BorderRadius.circular(12),
            //               border: Border.all(
            //                 color: colorScheme.primary.withOpacity(0.3),
            //                 width: 1,
            //               ),
            //             ),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   'Asignación actual:',
            //                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //                         color: rcColor6,
            //                         fontWeight: FontWeight.w600,
            //                       ),
            //                 ),
            //                 const SizedBox(height: 8),
            //                 FutureBuilder<Map<String, String?>>(
            //                   future: _getAssignmentDetails(),
            //                   builder: (context, snapshot) {
            //                     if (snapshot.connectionState == ConnectionState.waiting) {
            //                       return const CircularProgressIndicator();
            //                     }
            //                     final details = snapshot.data ?? {};
            //                     return Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         if (details['vehicle'] != null)
            //                           Text(
            //                             'Flota: ${details['vehicle']}',
            //                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //                                   color: rcColor6,
            //                                 ),
            //                           ),
            //                         if (details['driver'] != null) ...[
            //                           const SizedBox(height: 4),
            //                           Text(
            //                             'Conductor: ${details['driver']}',
            //                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //                                   color: rcColor6,
            //                                 ),
            //                           ),
            //                         ],
            //                       ],
            //                     );
            //                   },
            //                 ),
            //               ],
            //             ),
            //           ),
            //           const SizedBox(height: 12),
            //         ],
            //         _buildActionButton(
            //           _currentAssignment != null
            //               ? 'Modificar asignación'
            //               : 'Asignar flota y conductor',
            //           colorScheme.primary,
            //           colorScheme,
            //           onTap: () {
            //             _mostrarModalAsignarFlotaConductor();
            //           },
            //         ),
            //       ],
            //     ),
            //     const SizedBox(height: 24),
            //   ],
            //   _buildInfoSection(
            //     'Acciones',
            //     [
            //       _buildActionButton(
            //         'Ver Cotización actual',
            //         colorScheme.primary,
            //         colorScheme,
            //         onTap: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder: (context) => EditCotizacionPage(
            //                 acceptedDeal: _actualAcceptedDeal,
            //                 editingMode: false,
            //                 isCustomer: isCustomer,
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //       _buildActionButton(
            //         'Editar carga actual',
            //         colorScheme.secondary,
            //         colorScheme,
            //         onTap: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder: (context) => EditCotizacionPage(
            //                 quoteId: widget.quoteId,
            //                 acceptedDeal: _actualAcceptedDeal,
            //                 editingMode: true,
            //                 isCustomer: isCustomer,
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //       _buildActionButton(
            //         'Hacer contraoferta',
            //         colorScheme.primary,
            //         colorScheme,
            //         onTap: () {
            //           _mostrarModalContraoferta(_currentQuotePrice > 0 ? _currentQuotePrice : 1000.0);
            //         },
            //       ),
            //       _buildActionButton('Pago realizado', colorScheme.secondary, colorScheme),
            //     ],
            //   ),
            //   const SizedBox(height: 24),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: rcColor6,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children,
        ),
      ],
    );
  }

  Widget _buildChecklistItem(ChecklistItemDto item, ColorScheme colorScheme) {
    // Mapear códigos a nombres legibles
    String itemName = _getChecklistItemName(item.code);
    
    return Container(
          width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
            border: Border.all(
          color: item.isCompleted
              ? rcColor8.withOpacity(0.2)
              : rcColor8.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
          // Checkbox más pequeño y discreto
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: item.isCompleted ? colorScheme.primary.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: item.isCompleted
                    ? colorScheme.primary.withOpacity(0.5)
                    : rcColor8.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: item.isCompleted
                ? Icon(
                    Icons.check,
                    size: 12,
                    color: colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          // Descripción más discreta
          Expanded(
            child: Text(
              itemName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: item.isCompleted ? rcColor8 : rcColor6,
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    fontSize: 13,
                  ),
          ),
        ),
      ],
      ),
    );
  }

  String _getChecklistItemName(String code) {
    switch (code) {
      case 'DOC_GRE_REMITENTE':
        return 'Guía de Remisión';
      case 'DOC_GRE_TRANSPORTISTA':
        return 'Guía de Transportista';
      case 'PAYMENT_MADE':
        return 'Pago Realizado';
      case 'PAYMENT_CONFIRMED':
        return 'Pago Confirmado';
      case 'ASSIGNMENT_SET':
        return 'Asignación de Flota';
      case 'SHIPMENT_SENT':
        return 'Carga Enviada';
      case 'SHIPMENT_RECEIVED':
        return 'Carga Recibida';
      default:
        return code;
    }
  }

  String _formatChecklistDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDocumentButton(String label, ColorScheme colorScheme) {
    final isRemitente = label == 'Guía de remisión';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (isRemitente) {
              await _generarGuiaRemitente();
            } else {
              await _generarGuiaTransportista();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.download,
                  color: rcWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rcWhite,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarModalContraoferta(double precioActual) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: CounterofferModal(
          precioActual: _currentQuotePrice > 0 ? _currentQuotePrice : precioActual,
          onRealizarContraoferta: (nuevoPrecio) async {
            Navigator.of(context).pop(); // Cerrar el modal
            
            // Mostrar el card de contraoferta inmediatamente (optimista)
            if (mounted) {
            setState(() {
              _otherPersonAction = ChatAction.counteroffer;
              _counterofferPrice = nuevoPrecio;
              _isMyCounteroffer = true;
                _currentQuotePrice = nuevoPrecio; // Actualizar precio actual
              });
            }
            
            // Aplicar la contraoferta usando el mismo endpoint que editar cotización
            try {
              await _aplicarContraoferta(nuevoPrecio);
              
              // Recargar mensajes para obtener el evento del sistema
              // El card se mantendrá visible hasta que llegue el mensaje del sistema
              if (mounted) {
                await _loadChatMessages();
                
                // Después de recargar, verificar si ya llegó el mensaje del sistema
                // Si llegó, el card se mostrará desde los mensajes, si no, se mantiene el temporal
                final hasSystemMessage = _messages.any((msg) => 
                  msg.isSystemEvent && 
                  msg.systemSubtypeCode == 'CHANGE_PROPOSED' &&
                  msg.isMe
                );
                
                if (hasSystemMessage && mounted) {
                  // Si ya llegó el mensaje del sistema, limpiar la acción temporal
                  setState(() {
                    _otherPersonAction = ChatAction.none;
                  });
                }
              }
            } catch (e) {
              // En caso de error, mantener el card visible pero mostrar error
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al enviar contraoferta: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
  
  Future<void> _aplicarContraoferta(double nuevoPrecio) async {
    try {
      // Obtener la versión de la cotización
      final versionDto = await _dealsRepository.getQuoteVersion(widget.quoteId);
      
      // Crear el cambio de precio
      final changes = QuoteChangeRequestDto(
        items: [
          QuoteChangeItemDto(
            fieldCode: 'PRICE_TOTAL',
            oldValue: _currentQuotePrice.toStringAsFixed(2),
            newValue: nuevoPrecio.toStringAsFixed(2),
          ),
        ],
      );
      
      // Aplicar cambios
      await _dealsRepository.applyQuoteChanges(
        widget.quoteId,
        changes,
        ifMatch: versionDto.version.toString(),
      );
      
      print('✅ Contraoferta aplicada exitosamente');
    } catch (e) {
      print('❌ Error applying counteroffer: $e');
      rethrow;
    }
  }

  void _mostrarModalCancelarTrato() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: CancelDealModal(
          onCancelarTrato: () {
            setState(() {
              _otherPersonAction = ChatAction.dealCancellation;
              _isMyCancellation = true;
            });
            // TODO: Enviar cancelación al servidor
          },
        ),
      ),
    );
  }

  void _mostrarModalPagoRealizado() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: PaymentMadeModal(
          onConfirmarPago: () async {
            Navigator.of(dialogContext).pop(); // Cerrar el modal
            
            try {
              await _dealsRepository.paymentMade(widget.quoteId);
              
              if (mounted) {
            setState(() {
              _otherPersonAction = ChatAction.paymentMade;
              _isMyPayment = true;
            });
                
                // Recargar mensajes para obtener el evento del sistema
                await _loadChatMessages();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al confirmar pago: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _mostrarModalConfirmarRecepcionPago() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: PaymentConfirmModal(
          onConfirmarRecepcion: () async {
            Navigator.of(dialogContext).pop(); // Cerrar el modal
            
            try {
              await _dealsRepository.paymentConfirm(widget.quoteId);
              
              if (mounted) {
                // Recargar mensajes para obtener el evento del sistema
                await _loadChatMessages();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al confirmar recepción del pago: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _mostrarModalPaqueteRecibido() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: PackageReceivedModal(
          onConfirmarRecepcion: () {
            setState(() {
              _otherPersonAction = ChatAction.packageReceived;
              _isMyPackageReceived = true;
            });
            // TODO: Enviar confirmación de recepción al servidor
            
            // Cerrar el modal de confirmación y mostrar el modal de calificación
            Navigator.of(context).pop();
            // Esperar a que el modal se cierre completamente antes de mostrar el siguiente
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _mostrarModalCalificacion();
              }
            });
          },
        ),
      ),
    );
  }

  void _mostrarModalCalificacion() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: RatingModal(
          onCalificar: (rating, comment) {
            // TODO: Enviar calificación al servidor
            // La card de paquete recibido ya se mostró en el paso anterior
          },
        ),
      ),
    );
  }

  void _mostrarModalAceptarTrato() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: AcceptDealModal(
          onAceptarTrato: () async {
            Navigator.of(dialogContext).pop(); // Cerrar el modal
            
            // Crear la aceptación en el servidor
            try {
              await _dealsRepository.createAcceptance(widget.quoteId);
              
              // Mostrar la card directamente
                if (mounted) {
                  setState(() {
                    _otherPersonAction = ChatAction.dealAcceptance;
                    _isMyDealAcceptance = true;
                });
                
                // Recargar mensajes para obtener el evento del sistema
                await _loadChatMessages();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al aceptar trato: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _mostrarModalAsignarFlotaConductor() async {
    // Obtener el companyId del quoteDetail
    int? companyId;
    try {
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId);
      companyId = quoteDetail.companyId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar información: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    if (mounted) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: AssignFleetDriverModal(
            companyId: companyId!,
            quoteId: widget.quoteId,
            dealsRepository: _dealsRepository,
            onAsignar: (driverId, vehicleId) async {
            Navigator.of(dialogContext).pop(); // Cerrar el modal
            
            try {
              // Asignar flota y conductor
              await _dealsRepository.assignFleetDriver(
                widget.quoteId,
                driverId,
                vehicleId,
              );
              
              // La aceptación ya se creó en el paso anterior, solo actualizar UI
            if (mounted) {
              setState(() {
                _otherPersonAction = ChatAction.dealAcceptance;
                _isMyDealAcceptance = true;
                });
                
                // Recargar mensajes y asignación
                await _loadChatMessages();
                await _loadAssignment();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al asignar flota y conductor: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
    }
  }
  
  Future<Map<String, String?>> _getAssignmentDetails() async {
    if (_currentAssignment == null) {
      return {};
    }
    
    try {
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId);
      final companyId = quoteDetail.companyId;
      
      final drivers = await _dealsRepository.getDrivers(companyId);
      final vehicles = await _dealsRepository.getVehicles(companyId);
      
      final driver = drivers.firstWhere(
        (d) => d.driverId == _currentAssignment!.driverId,
        orElse: () => drivers.first,
      );
      
      final vehicle = vehicles.firstWhere(
        (v) => v.vehicleId == _currentAssignment!.vehicleId,
        orElse: () => vehicles.first,
      );
      
      return {
        'driver': driver.fullName,
        'vehicle': '${vehicle.name} - ${vehicle.plate}',
      };
    } catch (e) {
      print('❌ Error getting assignment details: $e');
      return {};
    }
  }

  /// Confirma una aceptación de trato pendiente
  Future<void> _confirmarAceptacion(int acceptanceId) async {
    try {
      await _dealsRepository.confirmAcceptance(widget.quoteId, acceptanceId);
      
      if (mounted) {
        // Recargar mensajes para obtener el estado actualizado
        await _loadChatMessages();
        
        // Actualizar el estado si es necesario
        await _loadQuoteState();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar aceptación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Rechaza una aceptación de trato pendiente
  Future<void> _rechazarAceptacion(int acceptanceId) async {
    try {
      await _dealsRepository.rejectAcceptance(widget.quoteId, acceptanceId);
      
      if (mounted) {
        // Recargar mensajes para obtener el estado actualizado
        await _loadChatMessages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar aceptación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navega a la pantalla de ver cotización con los cambios aplicados
  Future<void> _verCotizacionConCambios(int quoteId, int changeId) async {
    try {
      // Obtener los detalles del cambio
      final change = await _dealsRepository.getChange(quoteId, changeId);
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditCotizacionPage(
              quoteId: quoteId,
              acceptedDeal: _actualAcceptedDeal,
              editingMode: false,
              isCustomer: widget.userRole == UserRole.customer,
              changePreview: change, // Pasar el cambio para preview
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cambios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarModalCargaEnviada() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ShipmentSentModal(
          onConfirmarEnvio: () async {
            Navigator.of(dialogContext).pop(); // Cerrar el modal
            
            try {
              await _dealsRepository.shipmentSent(widget.quoteId);
              
              if (mounted) {
                setState(() {
                  _otherPersonAction = ChatAction.shipmentSent;
                  _isMyShipmentSent = true;
                });
                
                // Recargar mensajes para obtener el evento del sistema
                await _loadChatMessages();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al confirmar envío: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _mostrarModalConfirmarRecepcionEnvio() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: PackageReceivedModal(
          onConfirmarRecepcion: () async {
            Navigator.of(dialogContext).pop(); // Cerrar el modal
            
            try {
              await _dealsRepository.shipmentReceived(widget.quoteId);
              
              if (mounted) {
                // Recargar mensajes para obtener el evento del sistema
                await _loadChatMessages();
                
                // Mostrar modal de calificación después de confirmar recepción
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _mostrarModalCalificacion();
                  }
                });
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al confirmar recepción del envío: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  // Métodos para manejar mensajes, archivos y fotos
  Future<void> _enviarMensaje() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Crear mensaje optimista
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final newMessage = ChatMessage(
      id: tempId,
      text: text,
        isMe: true,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      
      setState(() {
        _messages.add(newMessage);
      _messageController.clear();
      });
      
      _scrollToBottom();
      
    // Enviar mensaje al servidor
    try {
      await _dealsRepository.sendTextMessage(widget.quoteId, text);
      // Recargar mensajes para obtener el mensaje real del servidor
      await _loadChatMessages();
    } catch (e) {
      // Remover mensaje optimista en caso de error
      setState(() {
        _messages.removeWhere((msg) => msg.id == tempId);
        _messageController.text = text; // Restaurar el texto
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        // En algunas plataformas (web), path puede ser null, usar name como respaldo
        final filePath = file.path;
        final fileName = file.name;
        
        if (filePath != null || fileName.isNotEmpty) {
          final newMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Archivo adjunto: $fileName',
            isMe: true,
            timestamp: DateTime.now(),
            filePath: filePath,
            fileName: fileName,
            type: MessageType.file,
          );
          
          setState(() {
            _messages.add(newMessage);
          });
          
          _scrollToBottom();
          
          // TODO: Subir archivo al servidor
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        await _enviarImagen(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _enviarImagen(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enviarImagen(String imagePath) async {
    final caption = _messageController.text.trim();
    
    // Crear mensaje optimista
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = ChatMessage(
      id: tempId,
      text: caption.isNotEmpty ? caption : null,
      isMe: true,
      timestamp: DateTime.now(),
      imagePath: imagePath,
      type: MessageType.image,
    );
    
    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    
    _scrollToBottom();
    
    // Subir imagen y enviar mensaje al servidor
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subiendo imagen...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Subir imagen a Cloudinary
      final uploadResponse = await _dealsRepository.uploadImage(imagePath);

      // Enviar mensaje de imagen
      await _dealsRepository.sendImageMessage(
        widget.quoteId,
        uploadResponse.secureUrl,
        caption: caption.isNotEmpty ? caption : null,
      );

      // Recargar mensajes para obtener el mensaje real del servidor
      await _loadChatMessages();
    } catch (e) {
      // Remover mensaje optimista en caso de error
      setState(() {
        _messages.removeWhere((msg) => msg.id == tempId);
        if (caption.isNotEmpty) {
          _messageController.text = caption; // Restaurar el texto
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Genera la Guía de Remisión del Remitente en PDF
  Future<void> _generarGuiaRemitente() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generando guía de remisión del remitente...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Obtener todos los datos necesarios
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId);
      final requestDetail = await _dealsRepository.getRequestDetail(quoteDetail.requestId);
      
      // Determinar quién es el remitente y destinatario
      final isCustomer = widget.userRole == UserRole.customer;
      
      // Obtener datos del remitente (quien creó la solicitud)
      UserIdentityDto? remitenteData;
      CompanyDto? remitenteCompany;
      try {
        remitenteData = await _identityRepository.getUserIdentity(requestDetail.requesterAccountId);
      } catch (e) {
        print('⚠️ No se pudo obtener datos del remitente: $e');
      }
      
      // Obtener datos del destinatario (la otra parte)
      UserIdentityDto? destinatarioData;
      CompanyDto? destinatarioCompany;
      if (isCustomer) {
        // Si soy customer, el destinatario es el provider
        try {
          destinatarioCompany = await _dealsRepository.getCompany(quoteDetail.companyId);
        } catch (e) {
          print('⚠️ No se pudo obtener datos del destinatario: $e');
        }
      } else {
        // Si soy provider, el destinatario es el customer
        try {
          destinatarioData = await _identityRepository.getUserIdentity(quoteDetail.createdByAccountId);
        } catch (e) {
          print('⚠️ No se pudo obtener datos del destinatario: $e');
        }
      }
      
      // Obtener datos de transporte si existe asignación
      AssignmentDto? assignment;
      DriverDto? driver;
      VehicleDto? vehicle;
      try {
        assignment = await _dealsRepository.getAssignment(widget.quoteId);
        if (assignment != null) {
          final drivers = await _dealsRepository.getDrivers(quoteDetail.companyId);
          final vehicles = await _dealsRepository.getVehicles(quoteDetail.companyId);
          driver = drivers.firstWhere((d) => d.driverId == assignment!.driverId, orElse: () => drivers.first);
          vehicle = vehicles.firstWhere((v) => v.vehicleId == assignment!.vehicleId, orElse: () => vehicles.first);
        }
      } catch (e) {
        print('⚠️ No se pudo obtener datos de transporte: $e');
      }

      // Generar PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Título
              pw.Header(
                level: 0,
                child: pw.Text(
                  'GUÍA DE REMISIÓN ELECTRÓNICA',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Remitente
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REMITENTE (Dueño de la carga)',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('RUC:', remitenteData?.ruc ?? remitenteCompany?.ruc ?? requestDetail.requesterDocNumber),
                    _buildPdfRow('Razón Social / Nombres:', remitenteData?.fullName ?? remitenteCompany?.legalName ?? requestDetail.requesterNameSnapshot),
                    if (remitenteCompany != null) _buildPdfRow('Nombre Comercial:', remitenteCompany.tradeName),
                    if (remitenteCompany != null) _buildPdfRow('Dirección:', remitenteCompany.address),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Destinatario
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DESTINATARIO',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('RUC / Documento:', destinatarioData?.docNumber ?? destinatarioCompany?.ruc ?? 'N/A'),
                    _buildPdfRow('Razón Social / Nombres:', destinatarioData?.fullName ?? destinatarioCompany?.legalName ?? 'N/A'),
                    if (destinatarioCompany != null) _buildPdfRow('Dirección:', destinatarioCompany.address),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Traslado / Ruta
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TRASLADO / RUTA',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Punto de Partida:', requestDetail.origin.fullAddress),
                    _buildPdfRow('Punto de Llegada:', requestDetail.destination.fullAddress),
                    _buildPdfRow('Fecha de Inicio:', DateFormat('dd/MM/yyyy').format(DateTime.parse(requestDetail.createdAt))),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Bienes Transportados
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BIENES TRANSPORTADOS',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Peso (kg)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      ],
                    ),
                    ...requestDetail.items.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.itemName, style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.quantity.toString(), style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.totalWeightKg.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 9))),
                      ],
                    )),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(requestDetail.itemsCount.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(requestDetail.totalWeightKg.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      ],
                    ),
                  ],
                  ),
                ],
                ),
              ),
              
              // Transporte (si existe)
              if (assignment != null && driver != null && vehicle != null)
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TRANSPORTE',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      _buildPdfRow('Placa del Vehículo:', vehicle.plate),
                      _buildPdfRow('Nombre del Conductor:', driver.fullName),
                      _buildPdfRow('N° de Licencia:', driver.licenseNumber),
                    ],
                  ),
                ),
            ];
          },
        ),
      );

      // Guardar PDF y compartir
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/guia_remision_remitente_${widget.quoteId}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        // Compartir directamente el PDF
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Guía de Remisión del Remitente',
          subject: 'Guía de Remisión del Remitente',
        );
      }
    } catch (e) {
      print('❌ Error generando guía de remitente: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar guía: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Genera la Guía de Remisión del Transportista en PDF
  Future<void> _generarGuiaTransportista() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generando guía de remisión del transportista...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Obtener todos los datos necesarios
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId);
      final requestDetail = await _dealsRepository.getRequestDetail(quoteDetail.requestId);
      final transportistaCompany = await _dealsRepository.getCompany(quoteDetail.companyId);
      
      // Obtener datos del remitente y destinatario
      UserIdentityDto? remitenteData;
      CompanyDto? remitenteCompany;
      try {
        remitenteData = await _identityRepository.getUserIdentity(requestDetail.requesterAccountId);
      } catch (e) {
        print('⚠️ No se pudo obtener datos del remitente: $e');
      }
      
      UserIdentityDto? destinatarioData;
      CompanyDto? destinatarioCompany;
      try {
        destinatarioData = await _identityRepository.getUserIdentity(quoteDetail.createdByAccountId);
      } catch (e) {
        print('⚠️ No se pudo obtener datos del destinatario: $e');
      }
      
      // Obtener datos de transporte
      AssignmentDto? assignment;
      DriverDto? driver;
      VehicleDto? vehicle;
      try {
        assignment = await _dealsRepository.getAssignment(widget.quoteId);
        if (assignment != null) {
          final drivers = await _dealsRepository.getDrivers(quoteDetail.companyId);
          final vehicles = await _dealsRepository.getVehicles(quoteDetail.companyId);
          driver = drivers.firstWhere((d) => d.driverId == assignment!.driverId, orElse: () => drivers.first);
          vehicle = vehicles.firstWhere((v) => v.vehicleId == assignment!.vehicleId, orElse: () => vehicles.first);
        }
      } catch (e) {
        print('⚠️ No se pudo obtener datos de transporte: $e');
      }

      // Generar PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Título
              pw.Header(
                level: 0,
                child: pw.Text(
                  'GUÍA DE REMISIÓN DEL TRANSPORTISTA',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Transportista
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TRANSPORTISTA (Empresa que traslada)',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('RUC:', transportistaCompany.ruc),
                    _buildPdfRow('Razón Social:', transportistaCompany.legalName),
                    _buildPdfRow('Nombre Comercial:', transportistaCompany.tradeName),
                    _buildPdfRow('Dirección:', transportistaCompany.address),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Unidad de transporte y conductor
              if (assignment != null && driver != null && vehicle != null)
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'UNIDAD DE TRANSPORTE Y CONDUCTOR',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      _buildPdfRow('Marca y Placa:', '${vehicle.name} - ${vehicle.plate}'),
                      _buildPdfRow('Nombre del Conductor:', driver.fullName),
                      _buildPdfRow('N° de Licencia:', driver.licenseNumber),
                    ],
                  ),
                ),
              pw.SizedBox(height: 15),
              
              // Remitente y Destinatario
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REMITENTE Y DESTINATARIO (Referenciales)',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Remitente:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 4),
                    _buildPdfRow('  RUC:', remitenteData?.ruc ?? remitenteCompany?.ruc ?? requestDetail.requesterDocNumber),
                    _buildPdfRow('  Razón Social / Nombres:', remitenteData?.fullName ?? remitenteCompany?.legalName ?? requestDetail.requesterNameSnapshot),
                    pw.SizedBox(height: 8),
                    pw.Text('Destinatario:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 4),
                    _buildPdfRow('  RUC / Documento:', destinatarioData?.docNumber ?? destinatarioCompany?.ruc ?? 'N/A'),
                    _buildPdfRow('  Razón Social / Nombres:', destinatarioData?.fullName ?? destinatarioCompany?.legalName ?? 'N/A'),
                    ],
                  ),
                ],
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Traslado / Ruta
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TRASLADO / RUTA',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Distrito y Departamento de Partida:', '${requestDetail.origin.districtText}, ${requestDetail.origin.departmentName}'),
                    _buildPdfRow('Distrito y Departamento de Llegada:', '${requestDetail.destination.districtText}, ${requestDetail.destination.departmentName}'),
                    _buildPdfRow('Fecha de Inicio:', DateFormat('dd/MM/yyyy').format(DateTime.parse(requestDetail.createdAt))),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Bienes Transportados (Resumen)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BIENES TRANSPORTADOS (Resumen)',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Descripción de la carga:', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    ...requestDetail.items.map((item) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                      child: pw.Text('• ${item.itemName} (${item.quantity} unidades)', style: const pw.TextStyle(fontSize: 9)),
                    )),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Cantidad Total:', requestDetail.itemsCount.toString()),
                    _buildPdfRow('Peso Total Aproximado:', '${requestDetail.totalWeightKg.toStringAsFixed(2)} kg'),
                    ],
                  ),
                ],
                ),
              ),
              
              // Quién paga el flete
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'QUIÉN PAGA EL FLETE',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    if (requestDetail.paymentOnDelivery)
                      _buildPdfRow('Paga:', 'Destinatario - ${destinatarioData?.docNumber ?? destinatarioCompany?.ruc ?? "N/A"}')
                    else
                      _buildPdfRow('Paga:', 'Remitente - ${remitenteData?.ruc ?? remitenteCompany?.ruc ?? requestDetail.requesterDocNumber}'),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Guardar PDF y compartir
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/guia_remision_transportista_${widget.quoteId}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        // Compartir directamente el PDF
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Guía de Remisión del Transportista',
          subject: 'Guía de Remisión del Transportista',
        );
      }
    } catch (e) {
      print('❌ Error generando guía de transportista: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar guía: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper para construir filas en el PDF
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isNotEmpty ? value : 'N/A',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

