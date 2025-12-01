import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class TransportDocumentationPage extends StatelessWidget {
  const TransportDocumentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentación de Transportista'),
        backgroundColor: colorScheme.primary,
        foregroundColor: rcWhite,
      ),
      body: Container(
        color: rcColor1,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Documentos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: rcColor6,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // TODO: Implementar lista de documentos
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: rcWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Contenido de documentación próximamente',
                    style: TextStyle(color: rcColor8),
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

