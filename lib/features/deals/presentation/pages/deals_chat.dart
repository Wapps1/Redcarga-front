import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';

class ChatPage extends StatefulWidget {
  final String nombre;
  final UserRole userRole;
  final bool acceptedDeal;

  const ChatPage({
    super.key,
    required this.nombre,
    required this.userRole,
    this.acceptedDeal = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isActionsExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.acceptedDeal ? 2 : 1,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              if (widget.acceptedDeal)
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
                child: widget.acceptedDeal
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
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Mensajes de ejemplo
                _buildMessageBubble(
                  'Hola, estoy interesado en tu cotización',
                  false,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                _buildMessageBubble(
                  'Perfecto, podemos coordinar la entrega',
                  true,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                _buildMessageBubble(
                  '¿Cuándo podríamos iniciar?',
                  false,
                  colorScheme,
                ),
                const SizedBox(height: 12),
                _buildMessageBubble(
                  'Podríamos iniciar la próxima semana',
                  true,
                  colorScheme,
                ),
              ],
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
        _buildActionButton('Ver Cotización actual', colorScheme.primary, colorScheme),
        _buildActionButton('Editar carga actual', colorScheme.secondary, colorScheme),
        _buildActionButton('Hacer contraoferta', colorScheme.primary, colorScheme),
        _buildActionButton('Aceptar acuerdo', colorScheme.secondary, colorScheme),
        _buildActionButton('Paquete recibido', colorScheme.secondary, colorScheme),
        _buildActionButton('Cancelar trato', rcColor1, colorScheme, isOutlined: true),
      ];
    } else {
      return [
        _buildActionButton('Ver Cotización actual', colorScheme.primary, colorScheme),
        _buildActionButton('Editar carga actual', colorScheme.secondary, colorScheme),
        _buildActionButton('Hacer contraoferta', colorScheme.primary, colorScheme),
        _buildActionButton('Aceptar acuerdo', colorScheme.secondary, colorScheme),
        _buildActionButton('Pago realizado', colorScheme.secondary, colorScheme),
        _buildActionButton('Cancelar trato', rcColor1, colorScheme, isOutlined: true),
      ];
    }
  }

  Widget _buildActionButton(
    String label,
    Color backgroundColor,
    ColorScheme colorScheme, {
    bool isOutlined = false,
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
          onTap: () {
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
            onPressed: () {
              // TODO: Adjuntar documento
            },
            icon: Icon(
              Icons.attach_file,
              color: colorScheme.primary,
            ),
          ),
          // Botón tomar foto
          IconButton(
            onPressed: () {
              // TODO: Tomar foto
            },
            icon: Icon(
              Icons.camera_alt,
              color: colorScheme.primary,
            ),
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
                onTap: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    // TODO: Enviar mensaje
                    _messageController.clear();
                  }
                },
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
                  _buildActionButton('Ver Cotización actual', colorScheme.primary, colorScheme),
                  _buildActionButton('Editar carga actual', colorScheme.secondary, colorScheme),
                  _buildActionButton('Hacer contraoferta', colorScheme.primary, colorScheme),
                  _buildActionButton('Paquete recibido', colorScheme.secondary, colorScheme),
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
                  _buildActionButton('Ver Cotización actual', colorScheme.primary, colorScheme),
                  _buildActionButton('Editar carga actual', colorScheme.secondary, colorScheme),
                  _buildActionButton('Hacer contraoferta', colorScheme.primary, colorScheme),
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
}

