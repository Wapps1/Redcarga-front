import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

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
                        'Facturación',
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
                        // Plan actual
                        _buildSection(
                          context,
                          'Plan actual',
                          [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: rcColor2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Profesional Plus',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: rcColor6,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Próximo pago:\n15 Octubre',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: rcColor6,
                                            ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '\$20.00 /mensual',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: rcColor6,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // TODO: Cancelar suscripción
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        side: const BorderSide(color: rcColor4, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancelar subscripción',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: rcColor4,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Método de pago
                        _buildSection(
                          context,
                          'Método de pago',
                          [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: rcColor7,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'VISA',
                                      style: TextStyle(
                                        color: rcWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Visa ****04752',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                color: rcColor6,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          'Expira 02/2029',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: rcColor8,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Información de pago
                        _buildSection(
                          context,
                          'Información de pago',
                          [
                            _buildInfoRow(context, 'Nombre', 'Juan Perez'),
                            const SizedBox(height: 12),
                            _buildInfoRow(context, 'Correo electrónico', 'jperez@hotmail.com'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Historial de pagos (comentado según instrucciones)
                        // _buildSection(
                        //   context,
                        //   'Historial de pagos',
                        //   [
                        //     _buildPaymentHistoryItem(context, '15 Ago 2025', 'Profesional Plus', '\$20.00', 'Pagado'),
                        //     const SizedBox(height: 12),
                        //     _buildPaymentHistoryItem(context, '15 Sep 2025', 'Profesional Plus', '\$20.00', 'Pagado'),
                        //   ],
                        // ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: rcColor6,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: rcColor8,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: rcColor6,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(BuildContext context, String date, String plan, String amount, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor7,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rcColor6,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  plan,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: rcColor8,
                      ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: rcColor6,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
