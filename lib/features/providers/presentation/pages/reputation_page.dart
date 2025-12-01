import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class ReputationPage extends StatelessWidget {
  const ReputationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = MaterialTheme.lightScheme();
    
    // TODO: Obtener reseñas reales desde el servidor
    final List<Map<String, dynamic>> reviews = [
      {
        'clientName': 'Cliente 1',
        'date': '18/09/25',
        'time': '18:47',
        'origin': 'El Porvenir, Trujillo',
        'destination': 'Ate, Lima',
        'rating': 5,
        'comment': 'La atención fue rápida y llegaron todos los paquetes en buen estado.',
        'finalPrice': 's/1000',
      },
      {
        'clientName': 'Cliente 2',
        'date': '26/07/25',
        'time': '18:47',
        'origin': 'Surco, Lima',
        'destination': 'Ica, Ica',
        'rating': 4,
        'comment': 'Todo conforme, fueron amables, pero se demoraron en responder.',
        'finalPrice': 's/750',
      },
    ];
    
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
                        'Reputación',
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
                  child: Column(
                    children: [
                      // Título
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: rcColor8.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Reseñas hechas por usuarios',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: rcColor6,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: rcColor8.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Lista de reseñas
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildReviewCard(context, review),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: rcColor4,
            width: 4,
          ),
        ),
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
          // Nombre del cliente
          Text(
            review['clientName'] as String,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: rcColor4,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          // Fecha y hora
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['date'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: rcColor8,
                    ),
              ),
              Text(
                review['time'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: rcColor8,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Origen y destino
          Text(
            'Origen: ${review['origin'] as String}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: rcColor8,
                ),
          ),
          Text(
            'Destino: ${review['destination'] as String}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: rcColor8,
                ),
          ),
          const SizedBox(height: 12),
          
          // Calificación
          Text(
            'Calificación por servicio',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: rcColor8,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (review['rating'] as int)
                    ? Icons.star
                    : Icons.star_border,
                color: rcColor4,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Comentario
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rcColor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              review['comment'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rcColor6,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Precio final
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio final:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: rcColor8,
                    ),
              ),
              Text(
                review['finalPrice'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: rcColor4,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
