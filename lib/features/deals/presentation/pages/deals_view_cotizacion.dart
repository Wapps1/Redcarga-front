import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/data/di/deals_repositories.dart';
import 'package:red_carga/features/deals/data/models/quote_detail_dto.dart';
import 'package:red_carga/features/deals/data/models/request_detail_dto.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_cotizacion_page.dart';
import 'package:intl/intl.dart';

class ViewCotizacionPage extends StatefulWidget {
  final int quoteId;
  final String tabOrigen; // 'todas', 'en trato', 'en marcha'

  const ViewCotizacionPage({
    super.key,
    required this.quoteId,
    required this.tabOrigen,
  });

  @override
  State<ViewCotizacionPage> createState() => _ViewCotizacionPageState();
}

class _ViewCotizacionPageState extends State<ViewCotizacionPage> {
  // Repositorio
  final _dealsRepository = DealsRepositories.createDealsRepository();
  
  // Estados de carga
  bool _isLoading = true;
  String? _errorMessage;
  
  // Datos del API
  QuoteDetailDto? _quoteDetail;
  RequestDetailDto? _requestDetail;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Cargar detalle de la cotización
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId);
      
      // Cargar detalle de la solicitud
      final requestDetail = await _dealsRepository.getRequestDetail(quoteDetail.requestId);
      
      setState(() {
        _quoteDetail = quoteDetail;
        _requestDetail = requestDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
      print('❌ Error loading data: $e');
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
  
  String _getComments() {
    if (_requestDetail == null) return 'Sin comentario';
    
    // Concatenar todos los notes de los items que no sean null
    final comments = _requestDetail!.items
        .where((item) => item.notes != null && item.notes!.isNotEmpty)
        .map((item) => item.notes!)
        .join('\n\n');
    
    return comments.isEmpty ? 'Sin comentario' : comments;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    final isTodas = widget.tabOrigen == 'todas';
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: rcColor1,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: rcColor1,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_quoteDetail == null || _requestDetail == null) {
      return Scaffold(
        backgroundColor: rcColor1,
        body: const Center(
          child: Text('No hay datos disponibles'),
        ),
      );
    }
    
    final precio = _formatPrice(_quoteDetail!.totalAmount, _quoteDetail!.currencyCode);
    final comments = _getComments();

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de regresar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Menú de opciones
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Título
                    Text(
                      'Información de la empresa',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Información de la empresa
                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(context, 'Razón social:', 'Empresa ${_quoteDetail!.companyId}'),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'RUC:', '-'), // TODO: Obtener RUC desde endpoint de empresa
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Correo:', '-'), // TODO: Obtener correo desde endpoint de empresa
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Detalles de la solicitud
                    Text(
                      'Detalles de la solicitud',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(context, 'Cliente:', _requestDetail!.requesterNameSnapshot),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Día:', _formatDate(_requestDetail!.createdAt)),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Origen:', _requestDetail!.origin.fullAddress),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Destino:', _requestDetail!.destination.fullAddress),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Cotización
                    Text(
                      'Cotización',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(context, 'Total de Artículos:', _requestDetail!.itemsCount.toString()),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Peso Total:', '${_requestDetail!.totalWeightKg.toStringAsFixed(1)}kg'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Precio propuesto:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: rcColor8,
                                  ),
                            ),
                            Text(
                              precio,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Botón de descargar cotización
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // TODO: Descargar cotización
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.download,
                                      color: rcWhite,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cotización',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: rcWhite,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Comentario
                    Text(
                      'Comentario',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: rcColor6,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      children: [
                        Text(
                          comments,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: comments == 'Sin comentario' ? rcColor8 : rcColor6,
                                fontStyle: comments == 'Sin comentario' ? FontStyle.italic : FontStyle.normal,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Botones de acción
                    if (isTodas) ...[
                      // Botón Iniciar Trato
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              try {
                                // Obtener la versión de la cotización
                                final versionDto = await _dealsRepository.getQuoteVersion(widget.quoteId);
                                
                                // Iniciar la negociación
                                await _dealsRepository.startNegotiation(
                                  widget.quoteId,
                                  ifMatch: versionDto.version.toString(),
                                );
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Negociación iniciada exitosamente'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // Navegar a la página de cotizaciones en el tab "EN TRATO" (índice 1)
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const CotizacionPage(initialTabIndex: 1),
                                    ),
                                    (route) => route.isFirst,
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al iniciar negociación: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Iniciar Trato',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: rcWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Botón Rechazar Trato
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: rcWhite,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              try {
                                // Rechazar la cotización
                                await _dealsRepository.rejectQuote(widget.quoteId);
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cotización rechazada exitosamente'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // Navegar a la página de cotizaciones en el tab "TODAS" (índice 0)
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const CotizacionPage(initialTabIndex: 0),
                                    ),
                                    (route) => route.isFirst,
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al rechazar cotización: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Rechazar Trato',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Botón Ir al chat (para "en trato" o "en marcha")
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: Ir al chat
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Ir al chat',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: rcWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rcColor8.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: rcColor8,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: rcColor6,
                ),
          ),
        ),
      ],
    );
  }
}

