import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../domain/models/request_item.dart';
import '../pages/camera_capture_page.dart';

class AddItemDialog extends StatefulWidget {
  final RequestItem? item;
  final Function(RequestItem) onSave;

  const AddItemDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();
  
  bool _isFragile = false;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final item = widget.item!;
      _nameController.text = item.name;
      _widthController.text = item.width?.toString() ?? '';
      _heightController.text = item.height?.toString() ?? '';
      _lengthController.text = item.length?.toString() ?? '';
      _weightController.text = item.weight.toString();
      _quantityController.text = item.quantity.toString();
      _isFragile = item.isFragile;
      _imagePath = item.imagePath;
    } else {
      _quantityController.text = '1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraCapturePage(
          onImageCaptured: (imagePath) {
            setState(() {
              _imagePath = imagePath;
            });
          },
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final item = RequestItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      width: _widthController.text.isNotEmpty
          ? double.tryParse(_widthController.text)
          : null,
      height: _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null,
      length: _lengthController.text.isNotEmpty
          ? double.tryParse(_lengthController.text)
          : null,
      weight: double.parse(_weightController.text),
      quantity: int.tryParse(_quantityController.text) ?? 1,
      isFragile: _isFragile,
      imagePath: _imagePath,
    );

    widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Fondo difuminado
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: rcColor4.withOpacity(0.4),
            ),
          ),
          // Contenido del diálogo
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: rcColor1,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nombre del Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: rcColor6,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: rcColor6),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Nombre del producto
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
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
                  ),
                ),
                const SizedBox(height: 20),
                // Imagen
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: rcColor7,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        if (_imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: rcColor8,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tomar foto',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: rcColor8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Borde punteado
                        if (_imagePath == null)
                          CustomPaint(
                            size: Size.infinite,
                            painter: _DashedBorderPainter(
                              color: rcColor4.withOpacity(0.3),
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Dimensiones
                Row(
                  children: [
                    Expanded(
                      child: _buildDimensionField(_widthController, 'Ancho'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDimensionField(_heightController, 'Alto'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDimensionField(_lengthController, 'Largo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Peso
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Peso',
                          suffixText: 'kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: rcColor4.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: rcColor4.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: rcColor4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: rcColor4.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: rcColor4.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: rcColor4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Frágil
                CheckboxListTile(
                  title: const Text(
                    'Frágil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: rcColor6,
                    ),
                  ),
                  value: _isFragile,
                  onChanged: (value) {
                    setState(() {
                      _isFragile = value ?? false;
                    });
                  },
                  activeColor: rcColor4,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                // Botón Listo
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
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
                          'Listo',
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'cm',
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
      ),
    );
  }
}

// CustomPainter para borde punteado
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = 12.0;

    // Dibujar líneas punteadas en los bordes rectos
    // Top
    _drawDashedLine(
      canvas,
      paint,
      Offset(radius, 0),
      Offset(size.width - radius, 0),
    );

    // Right
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, radius),
      Offset(size.width, size.height - radius),
    );

    // Bottom
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width - radius, size.height),
      Offset(radius, size.height),
    );

    // Left
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, size.height - radius),
      Offset(0, radius),
    );

    // Esquinas redondeadas - dibujar arcos punteados
    _drawDashedArc(canvas, paint, Offset(radius, radius), radius, 3.14159, 1.5708);
    _drawDashedArc(canvas, paint, Offset(size.width - radius, radius), radius, -1.5708, 1.5708);
    _drawDashedArc(canvas, paint, Offset(size.width - radius, size.height - radius), radius, 0, 1.5708);
    _drawDashedArc(canvas, paint, Offset(radius, size.height - radius), radius, 1.5708, 1.5708);
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final distance = (end - start).distance;
    if (distance == 0) return;
    
    final direction = (end - start) / distance;
    double currentDistance = 0;
    final path = Path();

    while (currentDistance < distance) {
      final dashStart = start + direction * currentDistance;
      final dashEndDistance = (currentDistance + dashWidth < distance) 
          ? currentDistance + dashWidth 
          : distance;
      final dashEnd = start + direction * dashEndDistance;
      
      path.moveTo(dashStart.dx, dashStart.dy);
      path.lineTo(dashEnd.dx, dashEnd.dy);
      
      currentDistance += dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  void _drawDashedArc(Canvas canvas, Paint paint, Offset center, double radius, double startAngle, double sweepAngle) {
    final path = Path();
    final arcLength = radius * sweepAngle;
    final dashLength = dashWidth;
    final spaceLength = dashSpace;
    final segmentLength = dashLength + spaceLength;
    final numSegments = (arcLength / segmentLength).ceil();
    final anglePerSegment = sweepAngle / numSegments;
    final dashAngle = (dashLength / arcLength) * sweepAngle;
    
    for (int i = 0; i < numSegments; i++) {
      final segmentStart = startAngle + (i * anglePerSegment);
      final dashEnd = segmentStart + dashAngle;
      if (dashEnd > startAngle + sweepAngle) break;
      
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        segmentStart,
        (dashEnd - segmentStart).clamp(0.0, sweepAngle),
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

