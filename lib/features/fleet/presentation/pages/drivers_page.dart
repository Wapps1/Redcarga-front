import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/fleet/presentation/widgets/driver_card.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final List<Map<String, String>> _drivers = [
    {'name': 'Juan Pérez', 'dni': '12345678', 'phone': '+51 123123123'},
    {'name': 'Carlos Ruiz', 'dni': '87654321', 'phone': '+51 987654321'},
    {'name': 'Luis Gómez', 'dni': '11223344', 'phone': '+51 999888777'},
  ];

  Future<void> _openCreateDriverDialog() async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const Center(
          child: CreateDriverDialog(),
        );
      },
    );

    if (result != null) {
      setState(() {
        _drivers.insert(0, result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conductor creado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back, color: rcWhite),
                        ),
                        Text(
                          "Conductores",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: rcWhite,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: rcWhite),
                    ),
                  ],
                ),
              ),

              // Contenido blanco
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: rcColor1,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título y botón
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tus Conductores",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: rcColor6,
                                  ),
                            ),
                            ElevatedButton(
                              onPressed: _openCreateDriverDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: rcColor4,
                                foregroundColor: rcWhite,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("Agregar Conductor"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Lista de conductores
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _drivers.length,
                            itemBuilder: (context, index) {
                              final d = _drivers[index];
                              return DriverCard(
                                name: d['name'] ?? '',
                                dni: d['dni'] ?? '',
                                phone: d['phone'] ?? '',
                              );
                            },
                          ),
                        ),
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
}

class CreateDriverDialog extends StatefulWidget {
  const CreateDriverDialog({super.key});

  @override
  State<CreateDriverDialog> createState() => _CreateDriverDialogState();
}

class _CreateDriverDialogState extends State<CreateDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dniCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (_formKey.currentState?.validate() ?? false) {
      final driver = {
        'name': _nameCtrl.text.trim(),
        'dni': _dniCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      };
      Navigator.of(context).pop(driver);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width > 700 ? 600.0 : width * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: Material(
            borderRadius: BorderRadius.circular(18),
            color: rcColor1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      'Crear Conductor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),

                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _LabeledTextField(
                            controller: _nameCtrl,
                            label: 'Nombre',
                            hint: 'Nombre',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Ingresa el nombre';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _LabeledTextField(
                            controller: _dniCtrl,
                            label: 'DNI',
                            hint: 'DNI',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Ingresa el DNI';
                              if (v.trim().length < 6) return 'DNI inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _LabeledTextField(
                            controller: _phoneCtrl,
                            label: 'Teléfono',
                            hint: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Ingresa el teléfono';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Licencia
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Licencia de conducir',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: rcColor6)),
                          ),
                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Aquí se abriría la cámara/galería')),
                              );
                            },
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: rcWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: rcColor4.withOpacity(0.3), width: 2),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.camera_alt_outlined, size: 28, color: rcColor4),
                                    SizedBox(height: 8),
                                    Text('Tomar foto', style: TextStyle(color: rcColor4)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: rcColor4),
                                    foregroundColor: rcColor4,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: rcColor4,
                                    foregroundColor: rcWhite,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  ),
                                  onPressed: _onCreate,
                                  child: const Text('Crear'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _LabeledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: rcWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
