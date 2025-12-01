import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';

class CameraCapturePage extends StatefulWidget {
  final Function(List<String> imagePaths) onImagesCaptured;

  const CameraCapturePage({
    super.key,
    required this.onImagesCaptured,
  });

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _is2DMode = true; // true = frente (cuadrado), false = costado (cubo)
  String? _frontImagePath; // Foto de frente
  String? _sideImagePath; // Foto de costado
  bool _useImagePicker = false;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Determinar qué foto estamos capturando
  String? get _currentImagePath => _is2DMode ? _frontImagePath : _sideImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } else {
        // No hay cámaras disponibles, usar image_picker
        if (mounted) {
          setState(() {
            _useImagePicker = true;
            _isInitialized = true; // Marcar como inicializado para mostrar la UI
          });
        }
      }
    } catch (e) {
      // Si falla la inicialización, usar image_picker como fallback
      if (mounted) {
        setState(() {
          _useImagePicker = true;
          _isInitialized = true; // Marcar como inicializado para mostrar la UI
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_useImagePicker || _controller == null || !_controller!.value.isInitialized) {
      // Usar image_picker como fallback
      try {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (image != null && mounted) {
          setState(() {
            if (_is2DMode) {
              _frontImagePath = image.path;
            } else {
              _sideImagePath = image.path;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al capturar imagen: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        setState(() {
          if (_is2DMode) {
            _frontImagePath = image.path;
          } else {
            _sideImagePath = image.path;
          }
        });
      }
    } catch (e) {
      // Si falla, intentar con image_picker
      if (mounted) {
        try {
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );
          if (image != null) {
            setState(() {
              if (_is2DMode) {
                _frontImagePath = image.path;
              } else {
                _sideImagePath = image.path;
              }
            });
          }
        } catch (e2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al capturar imagen: $e2'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          if (_is2DMode) {
            _frontImagePath = image.path;
          } else {
            _sideImagePath = image.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _retake() {
    setState(() {
      if (_is2DMode) {
        _frontImagePath = null;
      } else {
        _sideImagePath = null;
      }
    });
  }

  void _done() {
    final List<String> images = [];
    if (_frontImagePath != null) {
      images.add(_frontImagePath!);
    }
    if (_sideImagePath != null) {
      images.add(_sideImagePath!);
    }
    
    if (images.isNotEmpty) {
      widget.onImagesCaptured(images);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor captura al menos una foto'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista previa de la cámara de fondo
          if (!_useImagePicker && _isInitialized && _controller != null && _currentImagePath == null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else if (_currentImagePath != null)
            Positioned.fill(
              child: Image.file(
                File(_currentImagePath!),
                fit: BoxFit.cover,
              ),
            )
          else if (_useImagePicker)
            Positioned.fill(
              child: Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Toca el botón para capturar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Se abrirá la cámara del dispositivo',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Inicializando cámara...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Overlay con fondo semi-transparente
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Título
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    children: [
                      Text(
                        _is2DMode ? 'Captura al objeto de frente' : 'Captura al objeto de costado',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Indicadores de progreso
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProgressIndicator('Frente', _frontImagePath != null),
                          const SizedBox(width: 12),
                          _buildProgressIndicator('Costado', _sideImagePath != null),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Área de vista de cámara/previsualización
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _currentImagePath != null
                          ? Image.file(
                              File(_currentImagePath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.transparent,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Controles de modo de captura
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Modo 2D (Frente)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _is2DMode = true;
                          });
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _is2DMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _frontImagePath != null
                                  ? Colors.green
                                  : Colors.white.withOpacity(0.6),
                              width: _frontImagePath != null ? 3 : 2,
                            ),
                          ),
                          child: Icon(
                            Icons.crop_square,
                            color: _frontImagePath != null ? Colors.green : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      // Botón de captura
                      GestureDetector(
                        onTap: _captureImage,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Modo 3D (Costado)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _is2DMode = false;
                          });
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: !_is2DMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _sideImagePath != null
                                  ? Colors.green
                                  : Colors.white.withOpacity(0.6),
                              width: _sideImagePath != null ? 3 : 2,
                            ),
                          ),
                          child: Icon(
                            Icons.view_in_ar,
                            color: _sideImagePath != null ? Colors.green : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botones de acción
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Repetir
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _retake,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                          child: const Text(
                            'Repetir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Galería
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Listo
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_frontImagePath != null || _sideImagePath != null) ? _done : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: (_frontImagePath != null || _sideImagePath != null)
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _frontImagePath != null && _sideImagePath != null
                                ? 'Listo'
                                : 'Continuar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.white.withOpacity(0.3),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: 8,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
