import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../core/session/auth_bloc.dart';
import '../../data/deals_service.dart';

class ResumenCotizacionPage extends StatefulWidget {
  final Map<String, dynamic> solicitud;
  final List<Map<String, dynamic>> articulosSeleccionados;

  const ResumenCotizacionPage({
    super.key,
    required this.solicitud,
    required this.articulosSeleccionados,
  });

  @override
  State<ResumenCotizacionPage> createState() => _ResumenCotizacionPageState();
}

class _ResumenCotizacionPageState extends State<ResumenCotizacionPage> {
  final TextEditingController _precioController = TextEditingController(text: 's/1000');
  final TextEditingController _comentarioController = TextEditingController();
  final DealsService _dealsService = DealsService();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _precioController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  int get _totalArticulos {
    return widget.articulosSeleccionados.fold(
      0,
      (sum, articulo) => sum + (articulo['cantidadSeleccionada'] as int? ?? articulo['cantidad'] as int),
    );
  }

  double get _pesoTotal {
    double pesoTotal = 0.0;
    for (final articulo in widget.articulosSeleccionados) {
      final cantidadSeleccionada = articulo['cantidadSeleccionada'] as int? ?? articulo['cantidad'] as int;
      final pesoUnitario = articulo['peso'] as double;
      pesoTotal += pesoUnitario * cantidadSeleccionada;
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del cliente
                            _buildClienteCard(),
                            const SizedBox(height: 20),
                            // Artículos
                            _buildArticulosSection(),
                            const SizedBox(height: 20),
                            // Cotizar
                            _buildCotizarSection(),
                            const SizedBox(height: 20),
                            // Comentario
                            _buildComentarioSection(),
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

  Widget _buildArticulosSection() {
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
                    '$_totalArticulos',
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
                    '${_pesoTotal.toStringAsFixed(1)}kg',
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
      ],
    );
  }

  Widget _buildCotizarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cotizar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Precio propuesto:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: rcColor6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _precioController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: rcWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: rcColor4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: rcColor6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComentarioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentario',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rcColor6,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rcWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _comentarioController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Escribe un comentario...',
              hintStyle: TextStyle(color: rcColor8),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: rcColor6,
            ),
          ),
        ),
      ],
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
            _isSubmitting ? 'Enviando...' : 'Mandar Cotización',
            null,
            _isSubmitting ? null : () => _submitQuote(),
          ),
          const SizedBox(height: 12),
          _buildOutlinedButton(
            'Rechazar Solicitud',
            null,
            () => _rejectRequest(),
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

  Future<void> _submitQuote() async {
    final requestId = widget.solicitud['requestId'] as int?;
    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de solicitud no válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener companyId desde AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSignedIn || authState.session.companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró información de la empresa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final companyId = authState.session.companyId!;

    // Extraer precio del texto (remover "s/" y convertir a double)
    final precioText = _precioController.text.trim();
    final precioMatch = RegExp(r'[\d.]+').firstMatch(precioText);
    if (precioMatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un precio válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalAmount = double.tryParse(precioMatch.group(0) ?? '0') ?? 0.0;
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio debe ser mayor a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Preparar items para la cotización
    final items = <Map<String, dynamic>>[];
    
    for (final articulo in widget.articulosSeleccionados) {
      // El itemId debe estar presente
      final requestItemId = articulo['itemId'] as int?;
      if (requestItemId == null || requestItemId == 0) {
        print('⚠️ [ResumenCotizacion] Artículo sin itemId válido: $articulo');
        continue; // Saltar este artículo
      }
      
      final cantidadSeleccionada = articulo['cantidadSeleccionada'] as int? ?? articulo['cantidad'] as int;
      if (cantidadSeleccionada <= 0) {
        print('⚠️ [ResumenCotizacion] Artículo con cantidad inválida: $cantidadSeleccionada');
        continue; // Saltar este artículo
      }
      
      final qty = cantidadSeleccionada.toDouble();
      
      items.add({
        'requestItemId': requestItemId,
        'qty': qty,
      });
    }
    
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay artículos válidos para cotizar'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
    
    print('📦 [ResumenCotizacion] Items preparados: $items');

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _dealsService.createQuote(
        requestId: requestId,
        companyId: companyId,
        totalAmount: totalAmount,
        currency: 'PEN',
        items: items,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cotización enviada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar cotización: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest() async {
    final requestId = widget.solicitud['requestId'] as int?;
    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de solicitud no válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Solicitud'),
        content: const Text('¿Estás seguro de que deseas rechazar esta solicitud?'),
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

    if (confirmed != true) return;

    // Nota: El endpoint de rechazar requiere un quoteId, pero aquí solo tenemos requestId
    // Por ahora, solo mostramos un mensaje. Si necesitas rechazar directamente la solicitud,
    // necesitarías otro endpoint o crear una cotización con estado rechazado.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Para rechazar, primero debes crear una cotización. Usa el botón "Mandar Cotización" con un precio de 0.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
