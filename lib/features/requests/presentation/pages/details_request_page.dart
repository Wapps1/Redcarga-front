import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../data/requests_service.dart';
import '../../domain/models/request_detail.dart';
import 'quotation_page.dart';

class DetallesSolicitudPage extends StatefulWidget {
  final Map<String, dynamic> solicitud;
  final bool fromAcceptedTab;

  const DetallesSolicitudPage({
    super.key,
    required this.solicitud,
    this.fromAcceptedTab = false,
  });

  @override
  State<DetallesSolicitudPage> createState() => _DetallesSolicitudPageState();
}

class _DetallesSolicitudPageState extends State<DetallesSolicitudPage> {
  final RequestsService _requestsService = RequestsService();
  RequestDetail? _requestDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
  }

  Future<void> _loadRequestDetail() async {
    final requestId = widget.solicitud['requestId'] as int?;
    if (requestId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID de solicitud no válido';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final detail = await _requestsService.getRequestDetail(requestId);
      
      setState(() {
        _requestDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar detalles: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal sin encabezado
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
                    // Título y botón de retroceso
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: rcColor6),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              'Información de la Solicitud',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: rcColor6,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: rcColor6),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    // Contenido
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, size: 64, color: rcColor8),
                                      const SizedBox(height: 16),
                                      Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: rcColor8),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadRequestDetail,
                                        child: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: _buildInformacionSolicitud(),
                                ),
                    ),
                    // Botones de acción (solo si NO viene del tab de aceptadas)
                    if (!widget.fromAcceptedTab) _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionSolicitud() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del cliente
        _buildClienteCard(),
        const SizedBox(height: 20),
        // Documentos
        _buildDocumentosSection(),
        const SizedBox(height: 20),
        // Artículos
        _buildArticulosSection(),
      ],
    );
  }

  Widget _buildClienteCard() {
    final detail = _requestDetail;
    if (detail == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Cliente:', detail.requesterNameSnapshot),
          const SizedBox(height: 8),
          _buildInfoRow('Día:', detail.formattedDate),
          const SizedBox(height: 8),
          _buildInfoRow('Origen:', detail.originDisplay),
          const SizedBox(height: 8),
          _buildInfoRow('Destino:', detail.destDisplay),
          if (detail.paymentOnDelivery) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Pago:', 'Contra entrega'),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentosSection() {
    final detail = _requestDetail;
    if (detail == null) {
      return const SizedBox.shrink();
    }

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
              Text(
                'DNI: ${detail.requesterDocNumber}',
                style: const TextStyle(
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

  Widget _buildArticulosSection() {
    final detail = _requestDetail;
    if (detail == null) {
      return const SizedBox.shrink();
    }

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
                    '${detail.itemsCount}',
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
                    '${detail.totalWeightKg.toStringAsFixed(1)}kg',
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
        ...detail.items.map((item) => _buildArticuloCard(item)),
      ],
    );
  }

  Widget _buildArticuloCard(RequestDetailItem item) {
    final firstImage = item.images.isNotEmpty ? item.images.first.imageUrl : null;
    final otherImages = item.images.length > 1 ? item.images.sublist(1, item.images.length > 4 ? 4 : item.images.length) : [];

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
                child: firstImage != null
                    ? GestureDetector(
                        onTap: () {
                          if (item.images.isNotEmpty) {
                            _showFullScreenImage(item.images, 0);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            firstImage,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: rcColor8),
                          ),
                        ),
                      )
                    : const Icon(Icons.image, color: rcColor8),
              ),
              const SizedBox(width: 12),
              // Miniaturas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (otherImages.isNotEmpty)
                      Row(
                        children: [
                          for (int i = 0; i < (otherImages.length > 3 ? 3 : otherImages.length); i++)
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: rcColor7,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (item.images.isNotEmpty) {
                                    final imageIndex = i + 1; // +1 porque la primera ya está en firstImage
                                    _showFullScreenImage(item.images, imageIndex);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    otherImages[i].imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(strokeWidth: 1),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 20, color: rcColor8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (item.images.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Ver todas las fotos
                          _showImageGallery(item.images);
                        },
                        icon: const Icon(Icons.photo_library, size: 16, color: rcColor4),
                        label: Text(
                          'Ver ${item.images.length} foto${item.images.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: rcColor4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nombre y tags
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: rcColor6,
                  ),
                ),
              ),
              if (item.fragile) ...[
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
          _buildInfoRow('Alto:', '${item.heightCm.toStringAsFixed(1)} cm'),
          const SizedBox(height: 4),
          _buildInfoRow('Ancho:', '${item.widthCm.toStringAsFixed(1)} cm'),
          const SizedBox(height: 4),
          _buildInfoRow('Largo:', '${item.lengthCm.toStringAsFixed(1)} cm'),
          const SizedBox(height: 8),
          _buildInfoRow('Peso:', '${item.weightKg.toStringAsFixed(1)} kg'),
          const SizedBox(height: 4),
          _buildInfoRow('Peso Total:', '${item.totalWeightKg.toStringAsFixed(1)} kg'),
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
                    'X${item.quantity}',
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

  void _showImageGallery(List<RequestItemImage> images, {int initialIndex = 0}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: rcWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Imágenes del artículo (${images.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: rcColor6,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Grid de miniaturas
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: rcWhite,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showFullScreenImage(images, index);
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: index == initialIndex ? rcColor4 : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            images[index].imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: rcColor7,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: rcColor7,
                              child: const Icon(Icons.image, color: rcColor8),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(List<RequestItemImage> images, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Image.network(
                      images[index].imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Botón cerrar
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Indicador de página
            if (images.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${initialIndex + 1} / ${images.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rcColor1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGradientButton(
            'Realizar Cotización',
            null,
            () {
              if (_requestDetail == null) return;
              
              // Convertir RequestDetail a formato para CotizacionPage
              final articulosMap = _requestDetail!.items.map((item) {
                return {
                  'itemId': item.itemId,
                  'nombre': item.itemName,
                  'cantidad': item.quantity,
                  'peso': item.weightKg,
                  'pesoTotal': item.totalWeightKg,
                  'alto': item.heightCm,
                  'ancho': item.widthCm,
                  'largo': item.lengthCm,
                  'fragil': item.fragile,
                  'imagenes': item.images.map((img) => img.imageUrl).toList(),
                };
              }).toList();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CotizacionPage(
                    solicitud: {
                      'requestId': _requestDetail!.requestId,
                      'nombre': _requestDetail!.requesterNameSnapshot,
                      'dia': _requestDetail!.formattedDate,
                      'origen': _requestDetail!.originDisplay,
                      'destino': _requestDetail!.destDisplay,
                    },
                    articulos: articulosMap,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOutlinedButton(
            'Rechazar Solicitud',
            null,
            () {
              // Rechazar solicitud
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, IconData? icon, VoidCallback onPressed) {
    return Container(
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: rcWhite, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: rcWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String label, IconData? icon, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: rcColor4, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: rcWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: rcColor4, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: rcColor4,
            ),
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
