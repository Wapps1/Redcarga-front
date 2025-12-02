import 'dart:io';
import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_edit_cotizacion.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/counteroffer_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/counteroffer_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/cancel_deal_modal.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/cancel_deal_chat_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/payment_made_modal.dart';
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
import 'package:red_carga/core/session/session_store.dart';
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

  @override
  void initState() {
    super.initState();
    _dealsRepository = DealsRepositories.createDealsRepository();
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
        return _buildMessageBubble(message.text ?? '', message.isMe, colorScheme);
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
        // Contraoferta propuesta
        final price = _extractPriceFromInfo(message.info);
        return CounterofferChatCard(
          precio: price ?? 0.0,
          isMyCounteroffer: isMe,
          onAceptar: () {
            // TODO: Aceptar contraoferta
          },
          onRechazar: () {
            // TODO: Rechazar contraoferta
          },
        );
      case 'ACCEPTANCE_CONFIRMED':
      case 'ACCEPTANCE_REQUEST':
        // Trato aceptado
        return AcceptDealChatCard(
          isMyAcceptance: isMe,
          fleet: _extractFleetFromInfo(message.info),
          driver: _extractDriverFromInfo(message.info),
        );
      case 'CHANGE_APPLIED':
      case 'CHANGE_ACCEPTED':
        // Edición aplicada/aceptada
        return EditDealChatCard(
          acceptedDeal: _actualAcceptedDeal,
          isMyEdit: isMe,
        );
      case 'QUOTE_REJECTED':
        // Trato cancelado
        return CancelDealChatCard(
          isMyCancellation: isMe,
        );
      case 'PAYMENT_MADE':
      case 'PAYMENT_CONFIRMED':
        // Pago realizado
        return PaymentMadeChatCard(
          isMyPayment: isMe,
        );
      case 'SHIPMENT_RECEIVED':
        // Paquete recibido
        return PackageReceivedChatCard(
          isMyReceipt: isMe,
        );
      case 'SHIPMENT_SENT':
        // Carga enviada
        return ShipmentSentChatCard(
          isMyShipment: isMe,
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

  Widget _buildMessageBubble(String message, bool isMe, ColorScheme colorScheme) {
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
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isMe ? rcWhite : rcColor6,
              ),
        ),
      ),
    );
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
              if (message.text != null && message.text!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    message.text!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.isMe ? rcWhite : rcColor6,
                        ),
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
                    Text(
                      message.text!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: message.isMe ? rcWhite.withOpacity(0.8) : rcColor8,
                          ),
                      overflow: TextOverflow.ellipsis,
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
                  acceptedDeal: widget.acceptedDeal,
                  editingMode: false,
                  isCustomer: isCustomer,
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          'Editar carga actual',
          colorScheme.secondary,
          colorScheme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: widget.acceptedDeal,
                  editingMode: true,
                  isCustomer: isCustomer,
                  onEdicionCompletada: (motivo) {
                    setState(() {
                      _otherPersonAction = ChatAction.quoteEdit;
                      _isMyEdit = true;
                    });
                    // TODO: Enviar edición al servidor
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
            'Aceptar acuerdo',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalAceptarTrato();
            },
          ),
        if (_actualAcceptedDeal) ...[
          _buildActionButton(
            'Paquete recibido',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalPaqueteRecibido();
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
    } else {
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
                  isCustomer: isCustomer,
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          'Editar carga actual',
          colorScheme.secondary,
          colorScheme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: true,
                  isCustomer: isCustomer,
                  onEdicionCompletada: (motivo) {
                    setState(() {
                      _otherPersonAction = ChatAction.quoteEdit;
                      _isMyEdit = true;
                    });
                    // TODO: Enviar edición al servidor
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
            'Aceptar acuerdo',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalAceptarTrato();
            },
          ),
        if (_actualAcceptedDeal) ...[
          _buildActionButton(
            'Pago realizado',
            colorScheme.secondary,
            colorScheme,
            onTap: () {
              _mostrarModalPagoRealizado();
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
            if (isCustomer) ...[
              // Vista para customer
              _buildInfoSection(
                'Acciones',
                [
                  _buildActionButton(
                    'Ver Cotización actual',
                    colorScheme.primary,
                    colorScheme,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditCotizacionPage(
                            acceptedDeal: _actualAcceptedDeal,
                            editingMode: false,
                            isCustomer: isCustomer,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    'Editar carga actual',
                    colorScheme.secondary,
                    colorScheme,
                    onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: true,
                  isCustomer: isCustomer,
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
                  _buildActionButton(
                    'Paquete recibido',
                    colorScheme.secondary,
                    colorScheme,
                    onTap: () {
                      _mostrarModalPaqueteRecibido();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Documentos',
                [
                  _buildDocumentButton('Guía de remisión', colorScheme),
                  _buildDocumentButton('Guía de transportista', colorScheme),
                ],
              ),
            ] else ...[
              // Vista para provider
              _buildInfoSection(
                'Acciones de ruta',
                [
                  _buildDropdownField('Seleccionar Flota', 'Flota 1', colorScheme),
                  const SizedBox(height: 16),
                  _buildDropdownField('Seleccionar Conductor', 'Juan Pérez', colorScheme),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Acciones',
                [
                  _buildActionButton(
                    'Ver Cotización actual',
                    colorScheme.primary,
                    colorScheme,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditCotizacionPage(
                            acceptedDeal: _actualAcceptedDeal,
                            editingMode: false,
                            isCustomer: isCustomer,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    'Editar carga actual',
                    colorScheme.secondary,
                    colorScheme,
                    onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditCotizacionPage(
                  quoteId: widget.quoteId,
                  acceptedDeal: _actualAcceptedDeal,
                  editingMode: true,
                  isCustomer: isCustomer,
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
                  _buildActionButton('Pago realizado', colorScheme.secondary, colorScheme),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Documentos',
                [
                  _buildDocumentButton('Guía de remisión', colorScheme),
                  _buildDocumentButton('Guía de transportista', colorScheme),
                ],
              ),
            ],
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

  Widget _buildDropdownField(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: rcColor6,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: rcColor1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: rcColor8.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: rcColor6,
                    ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: rcColor8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentButton(String label, ColorScheme colorScheme) {
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
          onTap: () {
            // TODO: Descargar documento
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: PaymentMadeModal(
          onConfirmarPago: () {
            setState(() {
              _otherPersonAction = ChatAction.paymentMade;
              _isMyPayment = true;
            });
            // TODO: Enviar confirmación de pago al servidor
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
    final isProvider = widget.userRole == UserRole.provider;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: AcceptDealModal(
          onAceptarTrato: () {
            if (isProvider) {
              // Si es proveedor, mostrar modal de asignar flota y conductor
              // Esperar a que se cierre el modal actual antes de mostrar el siguiente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _mostrarModalAsignarFlotaConductor();
                }
              });
            } else {
              // Si es cliente, mostrar la card directamente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _actualAcceptedDeal = true; // Cambiar acceptedDeal a true
                    _otherPersonAction = ChatAction.dealAcceptance;
                    _isMyDealAcceptance = true;
                    // Actualizar el TabController para mostrar las tabs
                    _tabController.dispose();
                    _tabController = TabController(
                      length: 2,
                      vsync: this,
                    );
                    _tabController.addListener(() {
                      setState(() {});
                    });
                  });
                }
              });
              // TODO: Enviar aceptación de trato al servidor
            }
          },
        ),
      ),
    );
  }

  void _mostrarModalAsignarFlotaConductor() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: AssignFleetDriverModal(
          onAsignar: (fleet, driver) {
            if (mounted) {
              setState(() {
                _actualAcceptedDeal = true; // Cambiar acceptedDeal a true
                _otherPersonAction = ChatAction.dealAcceptance;
                _isMyDealAcceptance = true;
                _assignedFleet = fleet;
                _assignedDriver = driver;
                // Actualizar el TabController para mostrar las tabs
                _tabController.dispose();
                _tabController = TabController(
                  length: 2,
                  vsync: this,
                );
                _tabController.addListener(() {
                  setState(() {});
                });
              });
            }
            // TODO: Enviar aceptación de trato con flota y conductor al servidor
          },
        ),
      ),
    );
  }

  void _mostrarModalCargaEnviada() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ShipmentSentModal(
          onConfirmarEnvio: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _otherPersonAction = ChatAction.shipmentSent;
                  _isMyShipmentSent = true;
                });
              }
            });
            // TODO: Enviar confirmación de envío de carga al servidor
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
}

