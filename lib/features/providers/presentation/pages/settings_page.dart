import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // TODO: Obtener datos reales del usuario desde la sesión
  final TextEditingController _nombreController = TextEditingController(text: 'Juan Perez');
  final TextEditingController _emailController = TextEditingController(text: 'jperez@hotmail.com');
  final TextEditingController _celularController = TextEditingController(text: '935471554');
  final TextEditingController _documentoController = TextEditingController(text: '69458500');
  final TextEditingController _fechaNacimientoController = TextEditingController(text: '20/05/1995');
  final TextEditingController _rucController = TextEditingController(text: '10258745512');
  final TextEditingController _razonSocialController = TextEditingController(text: 'Acme Corp');
  String _idioma = 'Español';

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _documentoController.dispose();
    _fechaNacimientoController.dispose();
    _rucController.dispose();
    _razonSocialController.dispose();
    super.dispose();
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: rcWhite,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Configuración',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: rcWhite,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Menú de opciones
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: rcWhite,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: rcColor1,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Foto de perfil
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rcColor7,
                                border: Border.all(
                                  color: rcColor4,
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profile_placeholder.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: rcColor4,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: rcColor4,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: rcWhite,
                                    width: 3,
                                  ),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    // TODO: Cambiar foto de perfil
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: rcWhite,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Información de la cuenta
                        _buildSection(
                          context,
                          'Información de la cuenta',
                          [
                            _buildEditableField(
                              context,
                              'Nombre y Apellidos',
                              _nombreController,
                              Icons.person,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              context,
                              'Correo electrónico',
                              _emailController,
                              Icons.email,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              context,
                              'Número de celular',
                              _celularController,
                              Icons.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              context,
                              'Documento de Identidad',
                              _documentoController,
                              Icons.badge,
                              editable: false,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              context,
                              'Fecha de Nacimiento',
                              _fechaNacimientoController,
                              Icons.calendar_today,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Información de la empresa (solo para providers)
                        _buildSection(
                          context,
                          'Información de la empresa',
                          [
                            _buildEditableField(
                              context,
                              'RUC',
                              _rucController,
                              Icons.business,
                              editable: false,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              context,
                              'Razón Social',
                              _razonSocialController,
                              Icons.business_center,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              context,
                              'Idioma',
                              _idioma,
                              ['Español', 'English', 'Português'],
                              (value) {
                                setState(() {
                                  _idioma = value!;
                                });
                              },
                            ),
                          ],
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con línea decorativa
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [rcColor4, rcColor4.withOpacity(0.3)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: rcColor6,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [rcColor4.withOpacity(0.3), rcColor4],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool editable = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: rcColor8,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: editable,
          decoration: InputDecoration(
            filled: true,
            fillColor: rcColor7,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: editable
                ? Icon(
                    Icons.edit,
                    color: rcColor4,
                    size: 20,
                  )
                : null,
            prefixIcon: Icon(
              icon,
              color: rcColor4,
              size: 20,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: rcColor6,
              ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: rcColor8,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: rcColor7,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(
                Icons.language,
                color: rcColor4,
                size: 20,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: rcColor6,
                      ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcColor6,
                ),
          ),
        ),
      ],
    );
  }
}
