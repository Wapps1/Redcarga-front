import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'summary_quotation.dart';

class CotizacionPage extends StatefulWidget {
  final Map<String, dynamic> solicitud;
  final List<Map<String, dynamic>> articulos;

  const CotizacionPage({
    super.key,
    required this.solicitud,
    required this.articulos,
  });

  @override
  State<CotizacionPage> createState() => _CotizacionPageState();
}

class _CotizacionPageState extends State<CotizacionPage> {
  // Mapa para almacenar la cantidad seleccionada de cada artículo
  final Map<int, int> _cantidadesSeleccionadas = {};
  final Map<int, bool> _articulosSeleccionados = {};

  @override
  void initState() {
    super.initState();
    // Inicializar todos los artículos como seleccionados con su cantidad completa
    for (int i = 0; i < widget.articulos.length; i++) {
      _articulosSeleccionados[i] = true;
      _cantidadesSeleccionadas[i] = widget.articulos[i]['cantidad'] as int;
    }
  }

  int get _totalArticulosSeleccionados {
    return _cantidadesSeleccionadas.values.fold(0, (sum, cantidad) => sum + cantidad);
  }

  double get _pesoTotalSeleccionado {
    double pesoTotal = 0.0;
    for (int i = 0; i < widget.articulos.length; i++) {
      if (_articulosSeleccionados[i] == true) {
        final articulo = widget.articulos[i];
        final cantidadSeleccionada = _cantidadesSeleccionadas[i] ?? 0;
        final pesoUnitario = articulo['peso'] as double;
        pesoTotal += pesoUnitario * cantidadSeleccionada;
      }
    }
    return pesoTotal;
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
                              'Cotización',
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del cliente
                            _buildClienteCard(),
                            const SizedBox(height: 20),
                            // Seleccionar artículos
                            _buildSeleccionarArticulosSection(),
                          ],
                        ),
                      ),
                    ),
                    // Botones de acción
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Cliente:', widget.solicitud['nombre'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Día:', widget.solicitud['dia'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Origen:', widget.solicitud['origen'] as String),
          const SizedBox(height: 8),
          _buildInfoRow('Destino:', widget.solicitud['destino'] as String),
        ],
      ),
    );
  }

  Widget _buildSeleccionarArticulosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar artículos',
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
                    '$_totalArticulosSeleccionados',
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
                    '${_pesoTotalSeleccionado.toStringAsFixed(1)}kg',
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
        // Lista de artículos con selección
        ...widget.articulos.asMap().entries.map((entry) {
          final index = entry.key;
          final articulo = entry.value;
          return _buildArticuloCardSeleccionable(articulo, index);
        }),
      ],
    );
  }

  Widget _buildArticuloCardSeleccionable(Map<String, dynamic> articulo, int index) {
    final isSelected = _articulosSeleccionados[index] ?? false;
    final cantidadOriginal = articulo['cantidad'] as int;
    final cantidadSeleccionada = _cantidadesSeleccionadas[index] ?? cantidadOriginal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? rcColor4 : rcColor8.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _articulosSeleccionados[index] = value ?? false;
                    if (value == false) {
                      _cantidadesSeleccionadas[index] = 0;
                    } else {
                      _cantidadesSeleccionadas[index] = cantidadOriginal;
                    }
                  });
                },
                activeColor: rcColor4,
              ),
              const SizedBox(width: 8),
              // Imagen principal
              Expanded(
                child: _buildImageSection(articulo),
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
              if (articulo['fragil'] as bool) ...[
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
          const SizedBox(height: 8),
          // Selector de cantidad
          if (isSelected) ...[
            Row(
              children: [
                const Text(
                  'Cantidad:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: rcColor6,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: rcColor4.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: cantidadSeleccionada > 0
                            ? () {
                                setState(() {
                                  _cantidadesSeleccionadas[index] = cantidadSeleccionada - 1;
                                });
                              }
                            : null,
                        color: rcColor4,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$cantidadSeleccionada',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: rcColor6,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: cantidadSeleccionada < cantidadOriginal
                            ? () {
                                setState(() {
                                  _cantidadesSeleccionadas[index] = cantidadSeleccionada + 1;
                                });
                              }
                            : null,
                        color: rcColor4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'de $cantidadOriginal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: rcColor8,
                  ),
                ),
              ],
            ),
          ] else ...[
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
                      'X${cantidadOriginal}',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final tieneArticulosSeleccionados = _articulosSeleccionados.values.any((selected) => selected == true);

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
            'Siguiente',
            null,
            tieneArticulosSeleccionados
                ? () {
                    // Preparar artículos seleccionados
                    final articulosSeleccionados = <Map<String, dynamic>>[];
                    for (int i = 0; i < widget.articulos.length; i++) {
                      if (_articulosSeleccionados[i] == true) {
                        final articulo = Map<String, dynamic>.from(widget.articulos[i]);
                        articulo['cantidadSeleccionada'] = _cantidadesSeleccionadas[i];
                        articulosSeleccionados.add(articulo);
                      }
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResumenCotizacionPage(
                          solicitud: widget.solicitud,
                          articulosSeleccionados: articulosSeleccionados,
                        ),
                      ),
                    );
                  }
                : null,
          ),
          const SizedBox(height: 12),
          _buildOutlinedButton(
            'Rechazar Solicitud',
            null,
            () async {
              // Mostrar diálogo de confirmación
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Rechazar Solicitud'),
                  content: const Text('¿Estás seguro de que deseas rechazar esta solicitud? Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Rechazar'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                // Por ahora, solo navegar de vuelta
                // Nota: El endpoint de rechazar requiere un quoteId, 
                // por lo que necesitarías crear una cotización primero o tener otro endpoint
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solicitud rechazada'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, IconData? icon, VoidCallback? onPressed) {
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null ? rcWhite : rcWhite.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String label, IconData? icon, VoidCallback? onPressed) {
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

  Widget _buildImageSection(Map<String, dynamic> articulo) {
    final imagenes = articulo['imagenes'] as List<dynamic>? ?? [];
    final firstImage = imagenes.isNotEmpty ? imagenes[0] as String : null;
    final otherImages = imagenes.length > 1 ? imagenes.sublist(1, imagenes.length > 4 ? 4 : imagenes.length).cast<String>() : <String>[];

    return Row(
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
                  onTap: () => _showImageGallery(imagenes.cast<String>(), 0),
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
                      GestureDetector(
                        onTap: () => _showImageGallery(imagenes.cast<String>(), i + 1),
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: rcColor7,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              otherImages[i],
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
              if (imagenes.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showImageGallery(imagenes.cast<String>(), 0),
                  icon: const Icon(Icons.photo_library, size: 16, color: rcColor4),
                  label: Text(
                    'Ver ${imagenes.length} foto${imagenes.length > 1 ? 's' : ''}',
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
    );
  }

  void _showImageGallery(List<String> images, int initialIndex) {
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
                      images[index],
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
