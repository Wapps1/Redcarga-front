import 'package:flutter/material.dart';
import 'package:red_carga/core/theme.dart';
import 'package:red_carga/features/deals/presentation/widgets/cotizacion_card.dart';

class CotizacionPage extends StatefulWidget {
  const CotizacionPage({super.key});

  @override
  State<CotizacionPage> createState() => _CotizacionPageState();
}

class _CotizacionPageState extends State<CotizacionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final colorScheme = MaterialTheme.lightScheme();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Cotizaciones',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: rcWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildTab('Todas', 0),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTab('En trato', 1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTab('En marcha', 2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent('Todas', 'Todas las cotizaciones disponibles'),
                    _buildTabContent('En trato', 'Cotizaciones en proceso de negociación'),
                    _buildTabContent('En marcha', 'Cotizaciones en camino'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabController.index == index;
    
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.2),
                border: Border.all(
                  color: colorScheme.primaryContainer,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: rcWhite,
                    width: 1,
                  ),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? rcWhite : rcWhite,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String titulo, String descripcion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.only(top: 5),

      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del tab
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: rcColor6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Descripción del tab
                Text(
                  descripcion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: rcColor8,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Sección de Solicitud
                _buildSolicitudSection(),
                
                const SizedBox(height: 20),
                
                // Barra de búsqueda
                _buildSearchBar(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Lista de cotizaciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              children: [
                CotizacionCard(
                  empresaNombre: 'Empresa 1',
                  solicitudNombre: 'Solicitud 1',
                  calificacion: 3,
                  precio: 's/1000',
                  onDetalles: () {
                    // TODO: Navegar a detalles
                  },
                  onChat: () {
                    // TODO: Navegar a chat
                  },
                ),
                CotizacionCard(
                  empresaNombre: 'Empresa 2',
                  solicitudNombre: 'Solicitud 1',
                  calificacion: 4,
                  precio: 's/1200',
                  onDetalles: () {
                    // TODO: Navegar a detalles
                  },
                  onChat: () {
                    // TODO: Navegar a chat
                  },
                ),
                CotizacionCard(
                  empresaNombre: 'Empresa 3',
                  solicitudNombre: 'Solicitud 1',
                  calificacion: 5,
                  precio: 's/900',
                  onDetalles: () {
                    // TODO: Navegar a detalles
                  },
                  onChat: () {
                    // TODO: Navegar a chat
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solicitud 1',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: rcColor6,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: rcColor8,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSolicitudRow('Día:', '10/10/2025'),
          const SizedBox(height: 8),
          _buildSolicitudRow('Origen:', 'La Molina, Lima'),
          const SizedBox(height: 8),
          _buildSolicitudRow('Destino:', 'La Victoria, Chiclayo'),
        ],
      ),
    );
  }

  Widget _buildSolicitudRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: rcColor8,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: rcColor6,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: rcColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar un Cotizaciones',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: rcColor8,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: rcColor8,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
