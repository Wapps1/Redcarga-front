import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/models/request_item.dart';
import '../../data/local/request_local_storage.dart';
import '../../data/requests_service.dart';
import '../../data/media_service.dart';
import '../../data/mappers/request_mappers.dart';

class RequestSummaryPage extends StatefulWidget {
  // Parámetros para cliente (crear solicitud)
  final String? name;
  final String? originDept; // código
  final String? originDeptName; // nombre
  final String? originProv; // código
  final String? originProvName; // nombre
  final String? originDist;
  final String? destDept; // código
  final String? destDeptName; // nombre
  final String? destProv; // código
  final String? destProvName; // nombre
  final String? destDist;
  final String? date;
  final bool? cashOnDelivery;
  final List<RequestItem>? items;
  
  // Parámetro para proveedor (ver solicitud recibida)
  final Map<String, dynamic>? solicitud;

  const RequestSummaryPage({
    super.key,
    // Constructor para cliente
    this.name,
    this.originDept,
    this.originDeptName,
    this.originProv,
    this.originProvName,
    this.originDist,
    this.destDept,
    this.destDeptName,
    this.destProv,
    this.destProvName,
    this.destDist,
    this.date,
    this.cashOnDelivery,
    this.items,
    // Constructor para proveedor
    this.solicitud,
  }) : assert(
          (name != null && items != null) || solicitud != null,
          'Debe proporcionar datos de cliente o solicitud de proveedor',
        );

  @override
  State<RequestSummaryPage> createState() => _RequestSummaryPageState();
}

class _RequestSummaryPageState extends State<RequestSummaryPage> {
  final RequestsService _requestsService = RequestsService();
  final MediaService _mediaService = MediaService();

  // Determinar si es vista de proveedor
  bool get _isProviderView => widget.solicitud != null;

  // Getters para cliente
  int get _totalArticles => widget.items?.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;
  double get _totalWeight => widget.items?.fold<double>(0.0, (sum, item) => sum + item.totalWeight) ?? 0.0;
  String get _origin => '${widget.originDist ?? ''}, ${widget.originProvName ?? widget.originProv ?? ''}';
  String get _destination => '${widget.destDist ?? ''}, ${widget.destProvName ?? widget.destProv ?? ''}';
  
  // Getters para proveedor
  List<Map<String, dynamic>> get _providerArticulos {
    if (!_isProviderView) return [];
    // Si viene en solicitud, usarlo; sino, datos de ejemplo
    return widget.solicitud!['articulos'] as List<Map<String, dynamic>>? ?? [
      {
        'nombre': 'Televisión',
        'cantidad': 8,
        'peso': 30.8,
        'pesoTotal': 246.4,
        'alto': 121.8,
        'ancho': 68.5,
        'largo': 20.0,
        'fragil': true,
      },
    ];
  }
  
  int get _providerTotalArticulos => _providerArticulos.fold<int>(
    0,
    (sum, articulo) => sum + (articulo['cantidad'] as int),
  );
  
  double get _providerPesoTotal => _providerArticulos.fold<double>(
    0.0,
    (sum, articulo) => sum + (articulo['pesoTotal'] as double),
  );

  Future<void> _sendRequest() async {
    // Solo ejecutar si es vista de cliente
    if (_isProviderView) return;
    
    // Validar que todos los campos requeridos estén llenos
    if (widget.name == null || widget.name!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para la solicitud'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.items == null || widget.items!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor agrega al menos un artículo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      // Mostrar indicador de carga
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Primero, subir todas las imágenes locales
      final imageUrlMap = <String, String>{};
      final items = widget.items ?? [];
      
      print('📸 [RequestSummaryPage] Verificando imágenes para subir...');
      for (var item in items) {
        // Subir todas las imágenes locales del item (imagePaths o imagePath)
        final imagePaths = item.imagePaths ?? (item.imagePath != null ? [item.imagePath!] : []);
        for (final imagePath in imagePaths) {
          if (imagePath != null && 
              !imagePath.startsWith('http') && 
              !imagePath.startsWith('https')) {
            // Es una ruta local, necesitamos subirla
            try {
              print('📤 [RequestSummaryPage] Subiendo imagen: $imagePath');
              final uploadResponse = await _mediaService.uploadImage(imagePath);
              imageUrlMap[imagePath] = uploadResponse.secureUrl;
              print('✅ [RequestSummaryPage] Imagen subida: ${uploadResponse.secureUrl}');
            } catch (e) {
              // Cerrar el diálogo de carga
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              
              // Mostrar error
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al subir imagen: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
              return; // Salir si hay error
            }
          }
        }
      }

      print('✅ [RequestSummaryPage] Todas las imágenes subidas. Creando solicitud...');

      // Convertir los datos al formato del endpoint con las URLs de las imágenes
      final requestDto = RequestMappers.toCreateRequestDto(
        name: widget.name ?? '',
        originDeptCode: widget.originDept ?? '',
        originDeptName: widget.originDeptName ?? '',
        originProvCode: widget.originProv ?? '',
        originProvName: widget.originProvName ?? '',
        originDist: widget.originDist ?? '',
        destDeptCode: widget.destDept ?? '',
        destDeptName: widget.destDeptName ?? '',
        destProvCode: widget.destProv ?? '',
        destProvName: widget.destProvName ?? '',
        destDist: widget.destDist ?? '',
        cashOnDelivery: widget.cashOnDelivery ?? false,
        items: items,
        imageUrlMap: imageUrlMap,
      );

      // Enviar la solicitud al backend
      final response = await _requestsService.createRequest(requestDto);

      // Cerrar el diálogo de carga
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar mensaje de éxito brevemente
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] as String? ?? 
              'Solicitud creada exitosamente'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Navegar de vuelta a la pantalla principal (main)
      if (mounted) {
        // Esperar un momento para que el usuario vea el mensaje de éxito
        await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
          // Regresar al main (primera pantalla en el stack)
        Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      // Cerrar el diálogo de carga si está abierto
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la solicitud: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si es vista de proveedor, usar diseño diferente
    if (_isProviderView) {
      return _buildProviderView(context);
    }
    
    // Vista de cliente (existente)
    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    // Artículos
                    _buildItemsSection(),
                  ],
                ),
              ),
            ),
            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProviderView(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              rcColor3,
              rcColor5,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildProviderHeader(context),
              // Contenido principal
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información del cliente
                        _buildClienteCard(),
                        const SizedBox(height: 20),
                        // Documentos
                        _buildDocumentosSection(),
                        const SizedBox(height: 20),
                        // Artículos
                        _buildProviderArticulosSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [rcColor3, rcColor4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: rcWhite, size: 24),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Text(
              'Realizar solicitud',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: rcWhite,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: rcWhite, size: 24),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: rcWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Información de la Solicitud',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: rcWhite,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: rcWhite),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: rcColor6,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Nombre:', widget.name ?? 'Sin nombre'),
          _buildSummaryRow('Día:', widget.date ?? 'No especificado'),
          _buildSummaryRow('Origen:', _origin),
          _buildSummaryRow('Destino:', _destination),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de Artículos:',
                    style: TextStyle(
                      fontSize: 14,
                      color: rcColor6.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalArticles',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Peso Total:',
                    style: TextStyle(
                      fontSize: 14,
                      color: rcColor6.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_totalWeight.toStringAsFixed(1)}kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: rcColor6.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: rcColor6,
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Artículos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        ...(widget.items ?? []).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(item),
          );
        }),
      ],
    );
  }

  Widget _buildItemCard(RequestItem item) {
    return Container(
        decoration: BoxDecoration(
          color: rcWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rcColor4.withOpacity(0.3),
            width: 1,
          ),
        ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Nombre y tags
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: rcColor6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (item.isFragile)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: rcColor5,
                      borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Frágil',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: rcWhite,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (item.quantity > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: rcColor2,
                      borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'X${item.quantity}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: rcColor6,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
          ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: rcColor6.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: rcColor6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rcWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: rcColor4.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Atrás',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _sendRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ).copyWith(
                elevation: MaterialStateProperty.all(0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [rcColor4, rcColor5],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(
                  child: Text(
                    'Enviar Solicitud',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: rcWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para vista de proveedor
  Widget _buildClienteCard() {
    final solicitud = widget.solicitud!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Cliente:', solicitud['nombre'] as String? ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Día:', solicitud['dia'] as String? ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Origen:', solicitud['origen'] as String? ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Destino:', solicitud['destino'] as String? ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDocumentosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: rcColor7,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                'DNI del Cliente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, color: rcColor4),
                onPressed: () {
                  // Ver documento
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderArticulosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Artículos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total de Artículos:',
                    style: TextStyle(
                      fontSize: 14,
                      color: rcColor8,
                    ),
                  ),
                  Text(
                    '$_providerTotalArticulos',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Peso Total:',
                    style: TextStyle(
                      fontSize: 14,
                      color: rcColor8,
                    ),
                  ),
                  Text(
                    '${_providerPesoTotal.toStringAsFixed(1)}kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Lista de artículos
        ..._providerArticulos.map((articulo) => _buildProviderArticuloCard(articulo)),
      ],
    );
  }

  Widget _buildProviderArticuloCard(Map<String, dynamic> articulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen principal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: rcColor7,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, color: rcColor8),
              ),
              const SizedBox(width: 12),
              // Miniaturas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < 3; i++)
                          Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: rcColor7,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, size: 20, color: rcColor8),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Ver fotos
                      },
                      icon: const Icon(Icons.photo_library, size: 16, color: rcColor4),
                      label: const Text(
                        'Ver fotos',
                        style: TextStyle(
                          fontSize: 12,
                          color: rcColor4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nombre y tags
          Row(
            children: [
              Text(
                articulo['nombre'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: rcColor6,
                ),
              ),
              if (articulo['fragil'] as bool? ?? false) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rcColor3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Frágil',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: rcWhite,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Dimensiones
          _buildInfoRow('Alto:', '${articulo['alto']} cm'),
          const SizedBox(height: 4),
          _buildInfoRow('Ancho:', '${articulo['ancho']} cm'),
          const SizedBox(height: 4),
          _buildInfoRow('largo:', '${articulo['largo']} cm'),
          const SizedBox(height: 8),
          _buildInfoRow('Peso:', '${articulo['peso']} kg'),
          const SizedBox(height: 4),
          _buildInfoRow('Peso Total:', '${articulo['pesoTotal']} kg'),
          const SizedBox(height: 8),
          // Cantidad
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: rcColor8.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'X${articulo['cantidad']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: rcColor6,
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

  Widget _buildInfoRow(String label, String value) {
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
}

