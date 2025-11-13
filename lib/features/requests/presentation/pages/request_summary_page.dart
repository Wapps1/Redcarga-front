import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/models/request_item.dart';
import '../../data/local/request_local_storage.dart';

class RequestSummaryPage extends StatefulWidget {
  final String name;
  final String originDept;
  final String originProv;
  final String originDist;
  final String destDept;
  final String destProv;
  final String destDist;
  final String date;
  final bool cashOnDelivery;
  final List<RequestItem> items;

  const RequestSummaryPage({
    super.key,
    required this.name,
    required this.originDept,
    required this.originProv,
    required this.originDist,
    required this.destDept,
    required this.destProv,
    required this.destDist,
    required this.date,
    required this.cashOnDelivery,
    required this.items,
  });

  @override
  State<RequestSummaryPage> createState() => _RequestSummaryPageState();
}

class _RequestSummaryPageState extends State<RequestSummaryPage> {
  final Map<int, bool> _expandedItems = {};

  int get _totalArticles => widget.items.fold(0, (sum, item) => sum + item.quantity);
  double get _totalWeight => widget.items.fold(0.0, (sum, item) => sum + item.totalWeight);

  String get _origin => '${widget.originDist}, ${widget.originProv}';
  String get _destination => '${widget.destDist}, ${widget.destProv}';

  void _toggleItem(int index) {
    setState(() {
      _expandedItems[index] = !(_expandedItems[index] ?? false);
    });
  }

  Future<void> _sendRequest() async {
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

      // Guardar la solicitud en almacenamiento local
      final requestId = await RequestLocalStorage.saveRequest(
        name: widget.name,
        originDept: widget.originDept,
        originProv: widget.originProv,
        originDist: widget.originDist,
        destDept: widget.destDept,
        destProv: widget.destProv,
        destDist: widget.destDist,
        date: widget.date,
        cashOnDelivery: widget.cashOnDelivery,
        items: widget.items,
      );

      // Cerrar el diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud guardada correctamente (ID: $requestId)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Navegar de vuelta a la pantalla principal
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
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
            content: Text('Error al guardar la solicitud: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _buildSummaryRow('Nombre:', widget.name),
          const SizedBox(height: 12),
          _buildSummaryRow('Día:', widget.date),
          const SizedBox(height: 12),
          _buildSummaryRow('Origen:', _origin),
          const SizedBox(height: 12),
          _buildSummaryRow('Destino:', _destination),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryRow('Total de Artículos:', '$_totalArticles'),
              _buildSummaryRow('Peso Total:', '${_totalWeight.toStringAsFixed(1)}kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isExpanded = _expandedItems[index] ?? false;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(item, index, isExpanded),
          );
        }),
      ],
    );
  }

  Widget _buildItemCard(RequestItem item, int index, bool isExpanded) {
    return GestureDetector(
      onTap: () => _toggleItem(index),
      child: Container(
        decoration: BoxDecoration(
          color: rcWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rcColor4.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header del item (siempre visible)
            Padding(
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
                              borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
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
                  // Icono de expandir/colapsar
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: rcColor6,
                  ),
                ],
              ),
            ),
            // Detalles expandibles
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 12),
                    // Imagen si existe
                    if (item.imagePath != null) ...[
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: rcColor4.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(item.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Dimensiones
                    if (item.width != null || item.height != null || item.length != null) ...[
                      const Text(
                        'Dimensiones:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: rcColor6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.height != null)
                        _buildDetailRow('Alto:', '${item.height!.toStringAsFixed(1)} cm'),
                      if (item.width != null)
                        _buildDetailRow('Ancho:', '${item.width!.toStringAsFixed(1)} cm'),
                      if (item.length != null)
                        _buildDetailRow('Largo:', '${item.length!.toStringAsFixed(1)} cm'),
                      const SizedBox(height: 12),
                    ],
                    // Peso
                    _buildDetailRow('Peso unitario:', '${item.weight.toStringAsFixed(1)} kg'),
                    _buildDetailRow('Peso total:', '${item.totalWeight.toStringAsFixed(1)} kg'),
                  ],
                ),
              ),
          ],
        ),
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
}

