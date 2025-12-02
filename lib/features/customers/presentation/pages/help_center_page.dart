import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': '¿Cómo se garantiza la seguridad de mi carga?',
      'answer':
          'Garantizamos la seguridad con transportistas validados y rastreo GPS obligatorio en tiempo real. Además, el pago se gestiona de forma segura a través de la app y solo se libera al transportista tras confirmar la entrega.',
    },
    {
      'question': '¿Cómo es el proceso para adquirir una subscripción?',
      'answer': 'Puedes adquirir una subscripción desde la sección de Suscripciones en tu perfil. Selecciona el plan que mejor se adapte a tus necesidades y completa el proceso de pago.',
    },
    {
      'question': '¿Cómo hacer seguimiento de mi pedido?',
      'answer': 'Puedes hacer seguimiento de tu pedido desde la sección de Chats, donde encontrarás información en tiempo real sobre la ubicación de tu carga.',
    },
    {
      'question': '¿Cómo funciona la toma de medidas mediante inteligencia artificial?',
      'answer': 'Nuestra IA analiza las fotos que subes de tus paquetes para calcular automáticamente las dimensiones y el peso, facilitando el proceso de cotización.',
    },
  ];

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
                        'Centro de ayuda',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FAQs
                        ...List.generate(_faqs.length, (index) {
                          final faq = _faqs[index];
                          final isExpanded = _expandedIndex == index;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
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
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                title: Text(
                                  faq['question']!,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: rcColor4,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                trailing: Icon(
                                  isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                  color: rcColor4,
                                ),
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _expandedIndex = expanded ? index : null;
                                  });
                                },
                                children: [
                                  Text(
                                    faq['answer']!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: rcColor6,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 24),
                        
                        // Ilustración (placeholder)
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: rcColor7,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.support_agent,
                              size: 100,
                              color: rcColor4,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Contacto
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Tu duda no se encuentra acá?',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: rcColor6,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '¡No hay problema!',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: rcColor6,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: rcColor6,
                                      ),
                                  children: [
                                    const TextSpan(
                                      text: 'Escríbenos un correo a ',
                                    ),
                                    TextSpan(
                                      text: 'redcarga@gmail.com',
                                      style: TextStyle(
                                        color: rcColor4,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' y te atenderemos en la brevedad posible.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
