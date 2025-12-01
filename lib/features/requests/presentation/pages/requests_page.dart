import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../blocs/requests_bloc.dart';
import '../blocs/requests_event.dart';
import '../blocs/requests_state.dart';
import '../../domain/models/template.dart';
import 'create_request_page.dart';
import '../../../main/presentation/pages/main_page.dart';
import 'request_page.dart';

class RequestsPage extends StatelessWidget {
  final UserRole? role;
  
  const RequestsPage({
    super.key,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el rol: si no se pasa, intentar obtenerlo del contexto
    final userRole = role ?? _getRoleFromContext(context);
    final isProvider = userRole == UserRole.provider;

    // Si es proveedor, mostrar vista de solicitudes recibidas
    if (isProvider) {
      return const SolicitudesPage();
    }

    // Si es cliente, mostrar vista de plantillas (vista actual)
    return BlocProvider(
      create: (context) => RequestsBloc()..add(const RequestsLoadTemplates()),
      child: Scaffold(
        backgroundColor: rcColor1,
        body: SafeArea(
          child: Column(
            children: [
              // Header con gradiente
              _buildHeader(context),
              // Contenido principal
              Expanded(
                child: _buildContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UserRole _getRoleFromContext(BuildContext context) {
    // Intentar obtener el rol del MainPage a través del contexto
    // Por defecto, asumir cliente
    return UserRole.customer;
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

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<RequestsBloc, RequestsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Tus plantillas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rcColor6,
                ),
              ),
            ),
            // Lista de plantillas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.templates.length,
                itemBuilder: (context, index) {
                  final template = state.templates[index];
                  final isSelected = state.selectedTemplateId == template.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTemplateCard(
                      context,
                      template,
                      isSelected,
                    ),
                  );
                },
              ),
            ),
            // Botón de continuar
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildContinueButton(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    Template template,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<RequestsBloc>().add(
              RequestsSelectTemplate(template.id),
            );
      },
      child: Container(
        decoration: BoxDecoration(
          color: rcWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? rcColor5 : rcColor4.withOpacity(0.2),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: rcColor5.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la plantilla
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: rcColor6,
              ),
            ),
            const SizedBox(height: 12),
            // Información de origen y destino
            _buildInfoRow('Origen:', template.origin),
            const SizedBox(height: 8),
            _buildInfoRow('Destino:', template.destination),
            const SizedBox(height: 8),
            _buildInfoRow('Total de Artículos:', '${template.totalArticles}'),
            const SizedBox(height: 8),
            _buildInfoRow('Peso Total:', '${template.totalWeight}kg'),
            const SizedBox(height: 12),
            // Items con tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.items.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tag del nombre del item
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: rcColor7,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: rcColor6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Tag "Frágil" si aplica
                    if (item.isFragile)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: rcColor3,
                          borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 6),
                    // Tag de cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: rcColor2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'X${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: rcColor6,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: rcColor6.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _buildContinueButton(BuildContext context, RequestsState state) {
    final selectedTemplate = state.selectedTemplate;
    final buttonText = selectedTemplate != null
        ? 'Continuar con ${selectedTemplate.name}'
        : 'Continuar sin plantilla';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final selectedTemplate = state.selectedTemplate;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateRequestPage(),
            ),
          );
        },
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
          child: Center(
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: rcWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
