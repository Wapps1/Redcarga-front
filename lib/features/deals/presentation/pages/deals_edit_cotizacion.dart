import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/presentation/widgets/deals_events_cards/articulo_card.dart';

class EditCotizacionPage extends StatefulWidget {
  final bool acceptedDeal;
  final bool editingMode;

  const EditCotizacionPage({
    super.key,
    this.acceptedDeal = false,
    this.editingMode = false,
  });

  @override
  State<EditCotizacionPage> createState() => _EditCotizacionPageState();
}

class _EditCotizacionPageState extends State<EditCotizacionPage> {
  late bool _acceptedDeal;
  late bool _editingMode;
  
  // Información de la solicitud
  late String _cliente;
  late String _dia;
  late String _origen;
  late String _destino;
  late bool _pagoContraentrega;
  
  // Información de la empresa
  late String _razonSocial;
  late String _ruc;
  late String _correo;
  
  // Comentario
  late String _comentario;
  late TextEditingController _comentarioController;
  
  // Artículos
  late List<ArticuloData> _articulos;
  late String _precioPropuesto;
  late TextEditingController _precioController;
  
  // Valores originales para detectar cambios
  late Map<String, dynamic> _valoresOriginales;

  @override
  void initState() {
    super.initState();
    _acceptedDeal = widget.acceptedDeal;
    _editingMode = widget.editingMode;
    
    // Inicializar datos de ejemplo
    _cliente = 'Juan Pérez';
    _dia = '10/10/2025';
    _origen = 'La Molina, Lima';
    _destino = 'La Victoria, Chiclayo';
    _pagoContraentrega = true;
    
    _razonSocial = 'Empresa 1';
    _ruc = '1234567890';
    _correo = 'empresa1@empresa.com';
    
    _comentario = 'No hay problema para transportar las cargas seleccionadas porque se cuenta con capacidad de hasta...';
    _comentarioController = TextEditingController(text: _comentario);
    
    _precioPropuesto = '1000';
    _precioController = TextEditingController(text: _precioPropuesto);
    
    _articulos = [
      ArticuloData(
        id: '1',
        titulo: 'Televisión',
        esFragil: true,
        fotos: [
          'https://via.placeholder.com/300',
          'https://via.placeholder.com/300',
          'https://via.placeholder.com/300',
          'https://via.placeholder.com/300',
        ],
        alto: 121.8,
        ancho: 68.5,
        largo: 20.0,
        peso: 30.8,
        cantidad: 8,
      ),
    ];
    
    _guardarValoresOriginales();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _guardarValoresOriginales() {
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
      'articulos': _articulos.map((a) => a.toMap()).toList(),
    };
  }

  void _verificarCambios() {
    final originalArticulos = _valoresOriginales['articulos'] as List;
    
    // Verificar cambios en campos básicos
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
    
    // Verificar cambios en artículos (cantidad, eliminación, adición)
    final hayCambiosArticulos = _articulos.length != originalArticulos.length ||
        _articulos.any((a) {
          final original = originalArticulos
              .firstWhere((o) => o['id'] == a.id, orElse: () => null);
          return original == null ||
              a.cantidad != original['cantidad'] ||
              a.peso != original['peso'];
        }) ||
        originalArticulos.any((original) {
          final actual = _articulos.firstWhere(
            (a) => a.id == original['id'],
            orElse: () => ArticuloData(
              id: '',
              titulo: '',
              fotos: [],
              alto: 0,
              ancho: 0,
              largo: 0,
              peso: 0,
              cantidad: 0,
            ),
          );
          return actual.id.isEmpty; // Artículo eliminado
        });

    final hayCambios = hayCambiosBasicos || hayCambiosArticulos;

    if (hayCambios && !_editingMode) {
      setState(() {
        _editingMode = true;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
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
                              onChanged: (value) {
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
                        TextField(
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
                            SizedBox(
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

                    // Mensaje informativo sobre deslizar para eliminar
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

                    const SizedBox(height: 16),

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
                        onEliminar: () {
                          setState(() {
                            _articulos.removeWhere((a) => a.id == articulo.id);
                            _verificarCambios();
                          });
                          _mostrarMensaje('Artículo eliminado');
                        },
                        onCantidadCambiada: (nuevaCantidad) {
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
                    // TODO: Actualizar cotización
                    _mostrarMensaje('Cotización actualizada');
                    setState(() {
                      _editingMode = false;
                      _guardarValoresOriginales();
                    });
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
      // Botones: Aceptar nueva cotización y Rechazar cotización
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Rechazar cotización
                _mostrarMensaje('Cotización rechazada');
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
                  onTap: () {
                    // TODO: Aceptar nueva cotización
                    _mostrarMensaje('Nueva cotización aceptada');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Aceptar nueva cotización',
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
                    // TODO: Proponer cotización
                    _mostrarMensaje('Cotización propuesta');
                    setState(() {
                      _editingMode = false;
                      _guardarValoresOriginales();
                    });
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

  void _mostrarFotosAmpliadas(List<String> fotos) {
    showDialog(
      context: context,
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

