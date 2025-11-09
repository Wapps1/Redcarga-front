import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/presentation/widgets/chat_card.dart';
import 'package:red_carga/features/deals/presentation/pages/deals_chat.dart';
import 'package:red_carga/features/main/presentation/pages/main_page.dart';

class ChatsPage extends StatelessWidget {
  final UserRole userRole;
  
  const ChatsPage({
    super.key,
    this.userRole = UserRole.customer,
  });

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
            begin: Alignment.centerLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  'Chat',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: rcWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              
              // Contenedor blanco con lista de chats
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: rcColor1,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(25),
                    children: [
                      // Chats hardcodeados
                      ChatCard(
                        nombre: 'Empresa Transportes ABC',
                        ultimoMensaje: 'Hola, estoy interesado en tu cotización',
                        hora: '10:30',
                        tieneMensajesNoLeidos: true,
                        cantidadNoLeidos: 2,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Empresa Transportes ABC',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
                      ),
                      ChatCard(
                        nombre: 'Logística Rápida S.A.',
                        ultimoMensaje: 'Perfecto, podemos coordinar la entrega',
                        hora: '09:15',
                        tieneMensajesNoLeidos: true,
                        cantidadNoLeidos: 1,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Logística Rápida S.A.',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
                      ),
                      ChatCard(
                        nombre: 'Transportes del Norte',
                        ultimoMensaje: 'Gracias por tu respuesta',
                        hora: 'Ayer',
                        tieneMensajesNoLeidos: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Transportes del Norte',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
                      ),
                      ChatCard(
                        nombre: 'Carga Express',
                        ultimoMensaje: '¿Podrías enviarme más detalles?',
                        hora: 'Ayer',
                        tieneMensajesNoLeidos: true,
                        cantidadNoLeidos: 3,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Carga Express',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
                      ),
                      ChatCard(
                        nombre: 'Mudanzas y Fletes',
                        ultimoMensaje: 'El precio me parece razonable',
                        hora: '15/10',
                        tieneMensajesNoLeidos: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Mudanzas y Fletes',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
                      ),
                      ChatCard(
                        nombre: 'Transporte Seguro',
                        ultimoMensaje: '¿Cuándo podríamos iniciar?',
                        hora: '14/10',
                        tieneMensajesNoLeidos: true,
                        cantidadNoLeidos: 1,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Transporte Seguro',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
                      ),
                      ChatCard(
                        nombre: 'Fletes y Envíos',
                        ultimoMensaje: 'Perfecto, nos vemos entonces',
                        hora: '13/10',
                        tieneMensajesNoLeidos: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                nombre: 'Fletes y Envíos',
                                userRole: userRole,
                                acceptedDeal: true,
                              ),
                            ),
                          );
                        },
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
}
