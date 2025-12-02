import 'dart:async';
import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/articulo_card.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/edit_deal_modal.dart';
import 'package:red_carga/features/deals/data/di/deals_repositories.dart';
import 'package:red_carga/features/deals/data/models/quote_detail_dto.dart';
import 'package:red_carga/features/deals/data/models/quote_change_request_dto.dart';
import 'package:red_carga/features/deals/data/models/company_dto.dart';
import 'package:intl/intl.dart';

class EditCotizacionPage extends StatefulWidget {
  final int? quoteId;
  final bool acceptedDeal;
  final bool editingMode;
  final bool isCustomer;
  final Function(String motivo)? onEdicionCompletada;

  const EditCotizacionPage({
    super.key,
    this.quoteId,
    this.acceptedDeal = false,
    this.editingMode = false,
    this.isCustomer = false,
    this.onEdicionCompletada,
  });

  @override
  State<EditCotizacionPage> createState() => _EditCotizacionPageState();
}

class _EditCotizacionPageState extends State<EditCotizacionPage> {
  late bool _acceptedDeal;
  late bool _editingMode;
  late bool _isCustomer;
  
  // Repositorio
  final _dealsRepository = DealsRepositories.createDealsRepository();
  
  // Estados de carga
  bool _isLoading = true;
  String? _errorMessage;
  
  // Datos del API
  QuoteDetailDto? _quoteDetail;
  
  // Información de la solicitud
  String _cliente = '';
  String _dia = '';
  String _origen = '';
  String _destino = '';
  bool _pagoContraentrega = false;
  
  // Información de la empresa
  String _razonSocial = 'Empresa';
  String _ruc = '';
  String _correo = '';
  
  // Comentario
  String _comentario = '';
  late TextEditingController _comentarioController;
  
  // Artículos
  List<ArticuloData> _articulos = [];
  String _precioPropuesto = '0';
  late TextEditingController _precioController;
  
  // Valores originales para detectar cambios
  Map<String, dynamic> _valoresOriginales = {};
  
  // Mapeo de quoteItemId por requestItemId (para poder hacer ITEM_REMOVE)
  Map<int, int> _quoteItemIdMap = {}; // requestItemId -> quoteItemId
  
  // Timer para debounce de verificación de cambios
  
  Timer? _verificarCambiosTimer;

  @override
  void initState() {
    super.initState();
    _acceptedDeal = widget.acceptedDeal;
    _editingMode = widget.editingMode;
    _isCustomer = widget.isCustomer;
    
    _comentarioController = TextEditingController();
    _precioController = TextEditingController();
    
    _loadData();
  }
  
  Future<void> _loadData() async {
    if (widget.quoteId == null) {
      setState(() {
        _errorMessage = 'No se proporcionó un quoteId';
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Cargar detalle de la cotización
      final quoteDetail = await _dealsRepository.getQuoteDetail(widget.quoteId!);
      
      // Cargar detalle de la solicitud
      final requestDetail = await _dealsRepository.getRequestDetail(quoteDetail.requestId);
      
      // Cargar datos de la empresa
      CompanyDto? company;
      try {
        company = await _dealsRepository.getCompany(quoteDetail.companyId);
      } catch (e) {
        print('⚠️ Error loading company ${quoteDetail.companyId}: $e');
      }
      
      setState(() {
        _quoteDetail = quoteDetail;
        
        // Actualizar acceptedDeal basándose en el stateCode
        _acceptedDeal = quoteDetail.stateCode == 'ACEPTADA';
        
        // Mapear datos de la solicitud
        _cliente = requestDetail.requesterNameSnapshot;
        _dia = _formatDate(requestDetail.createdAt);
        _origen = requestDetail.origin.fullAddress;
        _destino = requestDetail.destination.fullAddress;
        _pagoContraentrega = requestDetail.paymentOnDelivery;
        
        // Mapear datos de la empresa
        if (company != null) {
          _razonSocial = company.legalName;
          _ruc = company.ruc;
          _correo = company.email;
        }
        
        // Mapear precio
        _precioPropuesto = quoteDetail.totalAmount.toStringAsFixed(2);
        _precioController.text = _precioPropuesto;
        
        // Mapear artículos y guardar mapeo de quoteItemId
        // Optimización: crear Map para lookup O(1) en lugar de firstWhere O(n)
        _quoteItemIdMap.clear();
        final quoteItemsMap = <int, QuoteItemDto>{};
        for (final quoteItem in quoteDetail.items) {
          quoteItemsMap[quoteItem.requestItemId] = quoteItem;
        }
        
        _articulos = requestDetail.items.map((item) {
          // Buscar la cantidad correspondiente en la cotización usando Map O(1)
          final quoteItem = quoteItemsMap[item.itemId];
          
          // Guardar el mapeo para poder hacer ITEM_REMOVE
          if (quoteItem != null) {
            _quoteItemIdMap[item.itemId] = quoteItem.quoteItemId;
          }
          
          return ArticuloData(
            id: item.itemId.toString(),
            titulo: item.itemName,
            esFragil: item.fragile,
            fotos: item.images.map((img) => img.imageUrl).toList(),
            alto: item.heightCm,
            ancho: item.widthCm,
            largo: item.lengthCm,
            peso: item.weightKg,
            // Usar la cantidad de la cotización si existe, sino la de la solicitud
            cantidad: quoteItem?.qty ?? item.quantity,
          );
        }).toList();
        
        _comentario = ''; // No hay comentario en el API por ahora
        _comentarioController.text = _comentario;
        
        _isLoading = false;
        _guardarValoresOriginales();
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

  @override
  void dispose() {
    _verificarCambiosTimer?.cancel();
    _comentarioController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _guardarValoresOriginales() {
    // Optimización: crear lista de maps de forma eficiente
    final articulosList = List<Map<String, dynamic>>.generate(
      _articulos.length,
      (index) => _articulos[index].toMap(),
      growable: false,
    );
    
    _valoresOriginales = {
      'cliente': _cliente,
      'dia': _dia,
      'origen': _origen,
      'destino': _destino,
      'pagoContraentrega': _pagoContraentrega,
      'razonSocial': _razonSocial,
      'ruc': _ruc,
      'correo': _correo,
      'comentario': _comentario,
      'precioPropuesto': _precioPropuesto,
      'articulos': articulosList,
    };
  }

  void _verificarCambios() {
    // No verificar cambios si está en modo solo lectura
    if (_isReadOnly) {
      return;
    }

    // Cancelar timer anterior si existe (debounce)
    _verificarCambiosTimer?.cancel();
    
    // Ejecutar verificación después de un delay para evitar sobrecargar el hilo principal
    _verificarCambiosTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || _isReadOnly) return;
      
      final originalArticulos = _valoresOriginales['articulos'] as List;
      
      // Verificar cambios en campos básicos (rápido)
      final hayCambiosBasicos = _cliente != _valoresOriginales['cliente'] ||
          _dia != _valoresOriginales['dia'] ||
          _origen != _valoresOriginales['origen'] ||
          _destino != _valoresOriginales['destino'] ||
          _pagoContraentrega != _valoresOriginales['pagoContraentrega'] ||
          _razonSocial != _valoresOriginales['razonSocial'] ||
          _ruc != _valoresOriginales['ruc'] ||
          _correo != _valoresOriginales['correo'] ||
          _comentario != _valoresOriginales['comentario'] ||
          _precioPropuesto != _valoresOriginales['precioPropuesto'];
      
      // Verificación rápida de artículos (solo longitud primero)
      bool hayCambiosArticulos = false;
      if (_articulos.length != originalArticulos.length) {
        hayCambiosArticulos = true;
      } else {
        // Solo verificar detalles si la longitud coincide (optimización)
        // Crear Map de artículos originales para lookup rápido
        final originalArticulosMap = <String, Map<String, dynamic>>{};
        for (final original in originalArticulos) {
          originalArticulosMap[original['id'] as String] = original;
        }
        
        // Verificar cambios usando Maps O(1) lookup con early exit
        for (final actual in _articulos) {
          final original = originalArticulosMap[actual.id];
          if (original == null || 
              actual.cantidad != original['cantidad'] ||
              actual.peso != original['peso']) {
            hayCambiosArticulos = true;
            break;
          }
        }
        
        // Verificar si hay artículos eliminados solo si no se encontraron cambios
        if (!hayCambiosArticulos) {
          final actualArticulosIds = _articulos.map((a) => a.id).toSet();
          for (final original in originalArticulos) {
            if (!actualArticulosIds.contains(original['id'] as String)) {
              hayCambiosArticulos = true;
              break;
            }
          }
        }
      }

      final hayCambios = hayCambiosBasicos || hayCambiosArticulos;

      if (hayCambios && !_editingMode && mounted) {
        setState(() {
          _editingMode = true;
        });
      }
    });
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
        backgroundColor: rcColor6,
      ),
    );
  }

  int _calcularTotalArticulos() {
    return _articulos.fold(0, (sum, articulo) => sum + articulo.cantidad);
  }

  double _calcularPesoTotal() {
    return _articulos.fold(
      0.0,
      (sum, articulo) => sum + (articulo.peso * articulo.cantidad),
    );
  }

  bool get _isReadOnly {
    // Cuando es cliente y no está en modo edición y no hay deal aceptado, es solo lectura
    return _isCustomer && !_editingMode && !_acceptedDeal;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
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
    
    final totalArticulos = _calcularTotalArticulos();
    final pesoTotal = _calcularPesoTotal();

    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de retroceso
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

                    // Información de la solicitud
                    _buildSectionTitle('Información de la Solicitud'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      children: [
                        _buildInfoRow('Cliente:', _cliente),
                        const SizedBox(height: 12),
                        _buildInfoRow('Día:', _dia),
                        const SizedBox(height: 12),
                        _buildInfoRow('Origen:', _origen),
                        const SizedBox(height: 12),
                        _buildInfoRow('Destino:', _destino),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _pagoContraentrega,
                              onChanged: _isReadOnly
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _pagoContraentrega = value ?? false;
                                        _verificarCambios();
                                      });
                                    },
                              activeColor: colorScheme.primary,
                            ),
                            Text(
                              'Hacer pago contraentrega',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: rcColor6,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Información de la empresa
                    _buildSectionTitle('Información de la Empresa'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      children: [
                        _buildInfoRow('Razón social:', _razonSocial),
                        const SizedBox(height: 12),
                        _buildInfoRow('RUC:', _ruc),
                        const SizedBox(height: 12),
                        _buildInfoRow('Correo:', _correo),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Comentario
                    _buildSectionTitle('Comentario'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      children: [
                        _isReadOnly
                            ? Text(
                                _comentario.isEmpty
                                    ? 'Sin comentario'
                                    : _comentario,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: _comentario.isEmpty ? rcColor8 : rcColor6,
                                    ),
                              )
                            : TextField(
                                controller: _comentarioController,
                                onChanged: (value) {
                                  _comentario = value;
                                  _verificarCambios();
                                },
                                maxLines: 4,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Escribe un comentario...',
                                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: rcColor8,
                                      ),
                                ),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: rcColor6,
                                    ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Artículos
                    _buildSectionTitle('Artículos'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      children: [
                        _buildInfoRow('Total de Artículos:', '$totalArticulos'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Peso Total:', '${pesoTotal.toStringAsFixed(1)}kg'),
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
                            _isReadOnly
                                ? Text(
                                    's/${_precioPropuesto}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: rcColor6,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  )
                                : SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _precioController,
                                      onChanged: (value) {
                                        _precioPropuesto = value;
                                        _verificarCambios();
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: 's/',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: rcColor8.withOpacity(0.3),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: rcColor8.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: rcColor6,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Mensaje informativo sobre deslizar para eliminar (solo si no es solo lectura)
                    if (!_isReadOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: rcColor7,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: rcColor8.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Desliza hacia la izquierda para eliminar artículos',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: rcColor6,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!_isReadOnly) const SizedBox(height: 16),

                    // Lista de artículos
                    ..._articulos.map((articulo) {
                      return ArticuloCard(
                        titulo: articulo.titulo,
                        esFragil: articulo.esFragil,
                        fotos: articulo.fotos,
                        alto: articulo.alto,
                        ancho: articulo.ancho,
                        largo: articulo.largo,
                        peso: articulo.peso,
                        cantidad: articulo.cantidad,
                        onVerFotos: () {
                          _mostrarFotosAmpliadas(articulo.fotos);
                        },
                        onEliminar: _isReadOnly
                            ? null
                            : () {
                                setState(() {
                                  _articulos.removeWhere((a) => a.id == articulo.id);
                                  _verificarCambios();
                                });
                                _mostrarMensaje('Artículo eliminado');
                              },
                        onCantidadCambiada: _isReadOnly
                            ? null
                            : (nuevaCantidad) {
                                setState(() {
                                  articulo.cantidad = nuevaCantidad;
                                  _verificarCambios();
                                });
                                _mostrarMensaje('Cantidad actualizada');
                              },
                      );
                    }),

                    const SizedBox(height: 100), // Espacio para los botones
                  ],
                ),
              ),
            ),

            // Botones según estados
            if (_editingMode || _acceptedDeal)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: rcColor1,
                  boxShadow: [
                    BoxShadow(
                      color: rcColor8.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _buildActionButtons(colorScheme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: rcColor6,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
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

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildActionButtons(ColorScheme colorScheme) {
    if (!_editingMode && !_acceptedDeal) {
      return const SizedBox.shrink();
    }

    if (_editingMode && !_acceptedDeal) {
      // Botones: Cancelar y Actualizar cotización
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _editingMode = false;
                  // Restaurar valores originales
                  _cliente = _valoresOriginales['cliente'];
                  _dia = _valoresOriginales['dia'];
                  _origen = _valoresOriginales['origen'];
                  _destino = _valoresOriginales['destino'];
                  _pagoContraentrega = _valoresOriginales['pagoContraentrega'];
                  _razonSocial = _valoresOriginales['razonSocial'];
                  _ruc = _valoresOriginales['ruc'];
                  _correo = _valoresOriginales['correo'];
                  _comentario = _valoresOriginales['comentario'];
                  _comentarioController.text = _comentario;
                  _precioPropuesto = _valoresOriginales['precioPropuesto'];
                  _precioController.text = _precioPropuesto;
                  // Restaurar artículos
                  _articulos = (_valoresOriginales['articulos'] as List)
                      .map((map) => ArticuloData(
                            id: map['id'],
                            titulo: map['titulo'],
                            esFragil: map['esFragil'] ?? false,
                            fotos: List<String>.from(map['fotos'] ?? []),
                            alto: map['alto']?.toDouble() ?? 0.0,
                            ancho: map['ancho']?.toDouble() ?? 0.0,
                            largo: map['largo']?.toDouble() ?? 0.0,
                            peso: map['peso']?.toDouble() ?? 0.0,
                            cantidad: map['cantidad'] ?? 1,
                          ))
                      .toList();
                });
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                backgroundColor: rcWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _mostrarModalEditarTrato();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Actualizar cotización',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: rcWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!_editingMode && _acceptedDeal) {
      // Botones: Iniciar negociación y Rechazar cotización
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _quoteDetail == null ? null : () async {
                try {
                  await _rejectQuote();
                } catch (e) {
                  if (mounted) {
                    _mostrarMensaje('Error al rechazar cotización: $e');
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: rcError),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Rechazar cotización',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: rcError,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _quoteDetail == null ? null : () async {
                    try {
                      await _startNegotiation();
                    } catch (e) {
                      if (mounted) {
                        _mostrarMensaje('Error al iniciar negociación: $e');
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Iniciar negociación',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: rcWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_editingMode && _acceptedDeal) {
      // Botones: Proponer cotización y Cancelar
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _editingMode = false;
                });
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                backgroundColor: rcWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _mostrarModalEditarTrato();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Proponer cotización',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: rcWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _mostrarModalEditarTrato() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: EditDealModal(
          acceptedDeal: _acceptedDeal,
          onActualizarCotizacion: (motivo) async {
            // Cerrar el modal primero
            Navigator.of(dialogContext).pop();
            
            // Cerrar el teclado si está abierto
            FocusScope.of(context).unfocus();
            
            // Esperar un frame para que el teclado se cierre
            await Future.delayed(const Duration(milliseconds: 100));
            
            if (!mounted) return;
            
            // Mostrar indicador de carga
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (loadingContext) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
            
            try {
              // Si acceptedDeal es false, aplicar cambios al API
              if (!_acceptedDeal && widget.quoteId != null) {
                await _aplicarCambios();
              }
              
              if (!mounted) return;
              
              // Cerrar el indicador de carga
              Navigator.of(context).pop(); // Cerrar loading
              
              // Guardar el callback para ejecutarlo después
              final callback = widget.onEdicionCompletada;
              
              if (mounted) {
                // Guardar valores antes de cerrar
                setState(() {
                  _editingMode = false;
                  _guardarValoresOriginales();
                });
                // Mostrar mensaje antes de cerrar
                _mostrarMensaje('Cotización actualizada');
                // Cerrar la página de edición
                Navigator.of(context).pop();
                // Ejecutar el callback después de cerrar la página
                if (callback != null) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted) {
                      callback(motivo);
                    }
                  });
                }
              }
            } catch (e) {
              if (!mounted) return;
              // Cerrar el indicador de carga
              Navigator.of(context).pop(); // Cerrar loading
              _mostrarMensaje('Error al actualizar cotización: $e');
              // No cerrar la página si hay error
            }
          },
          onEnviarSolicitud: (motivo) {
            // Cerrar el modal primero
            Navigator.of(dialogContext).pop();
            // Guardar el callback para ejecutarlo después
            final callback = widget.onEdicionCompletada;
            // Luego ejecutar callbacks y cerrar la página
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Guardar valores antes de cerrar
                setState(() {
                  _editingMode = false;
                  _guardarValoresOriginales();
                });
                // Mostrar mensaje antes de cerrar
                _mostrarMensaje('Solicitud de cotización enviada');
                // Cerrar la página de edición
                Navigator.of(context).pop();
                // Ejecutar el callback después de cerrar la página
                if (callback != null) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    callback(motivo);
                  });
                }
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _startNegotiation() async {
    if (widget.quoteId == null) return;
    
    try {
      // Obtener la versión de la cotización
      final versionDto = await _dealsRepository.getQuoteVersion(widget.quoteId!);
      
      await _dealsRepository.startNegotiation(
        widget.quoteId!,
        ifMatch: versionDto.version.toString(),
      );
      
      if (mounted) {
        _mostrarMensaje('Negociación iniciada exitosamente');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error al iniciar negociación: $e');
      }
      rethrow;
    }
  }
  
  Future<void> _rejectQuote() async {
    if (widget.quoteId == null) return;
    
    try {
      await _dealsRepository.rejectQuote(widget.quoteId!);
      
      if (mounted) {
        _mostrarMensaje('Cotización rechazada exitosamente');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('Error al rechazar cotización: $e');
      }
      rethrow;
    }
  }

  Future<void> _aplicarCambios() async {
    if (widget.quoteId == null || _quoteDetail == null) return;
    
    try {
      // Obtener la versión de la cotización
      final versionDto = await _dealsRepository.getQuoteVersion(widget.quoteId!);
      
      // Detectar cambios
      final changes = _detectarCambios();
      
      if (changes.items.isEmpty) {
        print('⚠️ No hay cambios para aplicar');
        return;
      }
      
      // Aplicar cambios
      await _dealsRepository.applyQuoteChanges(
        widget.quoteId!,
        changes,
        ifMatch: versionDto.version.toString(),
      );
      
      print('✅ Cambios aplicados exitosamente');
    } catch (e) {
      print('❌ Error applying changes: $e');
      rethrow;
    }
  }

  QuoteChangeRequestDto _detectarCambios() {
    final changes = <QuoteChangeItemDto>[];
    
    // 1. Verificar cambio en precio
    final precioOriginal = double.tryParse(_valoresOriginales['precioPropuesto'] ?? '0') ?? 0.0;
    final precioNuevo = double.tryParse(_precioPropuesto) ?? 0.0;
    
    if (precioOriginal != precioNuevo) {
      changes.add(QuoteChangeItemDto(
        fieldCode: 'PRICE_TOTAL',
        oldValue: precioOriginal.toStringAsFixed(2),
        newValue: precioNuevo.toStringAsFixed(2),
      ));
    }
    
    // 2. Verificar cambios en artículos
    final originalArticulos = (_valoresOriginales['articulos'] as List)
        .map((map) => Map<String, dynamic>.from(map))
        .toList();
    
    // Artículos originales por ID
    final originalArticulosMap = <String, Map<String, dynamic>>{};
    for (final original in originalArticulos) {
      originalArticulosMap[original['id'] as String] = original;
    }
    
    // Artículos actuales por ID
    final actualArticulosMap = <String, ArticuloData>{};
    for (final actual in _articulos) {
      actualArticulosMap[actual.id] = actual;
    }
    
    // Detectar artículos eliminados (ITEM_REMOVE)
    for (final original in originalArticulos) {
      final id = original['id'] as String;
      if (!actualArticulosMap.containsKey(id)) {
        // Artículo fue eliminado
        final requestItemId = int.tryParse(id);
        if (requestItemId != null && _quoteItemIdMap.containsKey(requestItemId)) {
          changes.add(QuoteChangeItemDto(
            fieldCode: 'ITEM_REMOVE',
            targetQuoteItemId: _quoteItemIdMap[requestItemId],
          ));
        }
      }
    }
    
    // Detectar artículos añadidos (ITEM_ADD)
    for (final actual in _articulos) {
      final id = actual.id;
      if (!originalArticulosMap.containsKey(id)) {
        // Artículo fue añadido
        final requestItemId = int.tryParse(id);
        if (requestItemId != null) {
          changes.add(QuoteChangeItemDto(
            fieldCode: 'ITEM_ADD',
            targetRequestItemId: requestItemId,
            newValue: actual.cantidad.toString(),
          ));
        }
      }
    }
    
    // Detectar cambios en cantidad de artículos existentes
    for (final actual in _articulos) {
      final id = actual.id;
      if (originalArticulosMap.containsKey(id)) {
        // Artículo existe, verificar si cambió la cantidad
        final original = originalArticulosMap[id]!;
        final cantidadOriginal = original['cantidad'] as int;
        final cantidadNueva = actual.cantidad;
        
        if (cantidadOriginal != cantidadNueva) {
          // La cantidad cambió, necesitamos actualizar usando QTY
          final requestItemId = int.tryParse(id);
          if (requestItemId != null && _quoteItemIdMap.containsKey(requestItemId)) {
            final quoteItemId = _quoteItemIdMap[requestItemId]!;
            changes.add(QuoteChangeItemDto(
              fieldCode: 'QTY',
              targetQuoteItemId: quoteItemId,
              newValue: cantidadNueva.toString(),
            ));
          }
        }
      }
    }
    
    return QuoteChangeRequestDto(items: changes);
  }

  void _mostrarFotosAmpliadas(List<String> fotos) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Image.network(
                    fotos[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image,
                        color: rcWhite,
                        size: 100,
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: rcWhite,
                  size: 30,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: rcColor6.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase auxiliar para los datos del artículo
class ArticuloData {
  final String id;
  final String titulo;
  final bool esFragil;
  final List<String> fotos;
  final double alto;
  final double ancho;
  final double largo;
  final double peso;
  int cantidad;

  ArticuloData({
    required this.id,
    required this.titulo,
    this.esFragil = false,
    required this.fotos,
    required this.alto,
    required this.ancho,
    required this.largo,
    required this.peso,
    required this.cantidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'esFragil': esFragil,
      'fotos': fotos,
      'alto': alto,
      'ancho': ancho,
      'largo': largo,
      'peso': peso,
      'cantidad': cantidad,
    };
  }
}

