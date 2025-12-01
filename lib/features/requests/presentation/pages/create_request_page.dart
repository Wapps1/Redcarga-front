import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../domain/models/request_item.dart';
import '../widgets/add_item_dialog.dart';
import 'request_summary_page.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _nameController = TextEditingController();
  final _originDeptController = TextEditingController();
  final _originProvController = TextEditingController();
  final _originDistController = TextEditingController();
  final _destDeptController = TextEditingController();
  final _destProvController = TextEditingController();
  final _destDistController = TextEditingController();
  final _dateController = TextEditingController();
  
  bool _cashOnDelivery = false;
  final List<RequestItem> _items = [];

  @override
  void dispose() {
    _nameController.dispose();
    _originDeptController.dispose();
    _originProvController.dispose();
    _originDistController.dispose();
    _destDeptController.dispose();
    _destProvController.dispose();
    _destDistController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  int get _totalArticles => _items.fold(0, (sum, item) => sum + item.quantity);
  double get _totalWeight => _items.fold(0.0, (sum, item) => sum + item.totalWeight);

  void _addItem(RequestItem item) {
    setState(() {
      _items.add(item);
    });
  }

  void _editItem(int index, RequestItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rcColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    _buildNameField(),
                    const SizedBox(height: 20),
                    // Origen
                    _buildSectionTitle('Origen'),
                    const SizedBox(height: 12),
                    _buildLocationFields(
                      _originDeptController,
                      _originProvController,
                      _originDistController,
                    ),
                    const SizedBox(height: 20),
                    // Destino
                    _buildSectionTitle('Destino'),
                    const SizedBox(height: 12),
                    _buildLocationFields(
                      _destDeptController,
                      _destProvController,
                      _destDistController,
                    ),
                    const SizedBox(height: 8),
                    _buildNote(),
                    const SizedBox(height: 20),
                    // Fecha
                    _buildSectionTitle('Fecha'),
                    const SizedBox(height: 12),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    // Pago contraentrega
                    _buildCashOnDelivery(),
                    const SizedBox(height: 20),
                    // Artículos
                    _buildItemsSection(),
                  ],
                ),
              ),
            ),
            // Botones de navegación
            _buildNavigationButtons(context),
          ],
        ),
      ),
    );
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

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Sin Nombre',
        hintText: 'Sin Nombre',
        suffixIcon: const Icon(Icons.edit, color: rcColor5, size: 20),
        filled: true,
        fillColor: rcWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rcColor4, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: rcColor6,
      ),
    );
  }

  Widget _buildLocationFields(
    TextEditingController dept,
    TextEditingController prov,
    TextEditingController dist,
  ) {
    return Column(
      children: [
        _buildTextField(dept, 'Departamento'),
        const SizedBox(height: 12),
        _buildTextField(prov, 'Provincia'),
        const SizedBox(height: 12),
        _buildTextField(dist, 'Distrito'),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: rcWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rcColor4, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildNote() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'El distrito de origen o destino puede ser la misma a la solicitada o una con mayor proximidad.',
        style: TextStyle(
          fontSize: 12,
          color: rcColor6.withOpacity(0.6),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'dd/mm/aaaa',
        hintText: 'dd/mm/aaaa',
        filled: true,
        fillColor: rcWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rcColor4.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rcColor4, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          _dateController.text =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
      },
    );
  }

  Widget _buildCashOnDelivery() {
    return Row(
      children: [
        Checkbox(
          value: _cashOnDelivery,
          onChanged: (value) {
            setState(() {
              _cashOnDelivery = value ?? false;
            });
          },
          activeColor: rcColor4,
        ),
        const Expanded(
          child: Text(
            'Hacer pago contraentrega',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: rcColor6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Artículos'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total de Artículos: $_totalArticles',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: rcColor6,
              ),
            ),
            Text(
              'Peso Total: ${_totalWeight.toStringAsFixed(1)}kg',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: rcColor6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Lista de artículos
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildItemCard(item, index),
          );
        }),
        // Botón agregar artículo
        _buildAddItemButton(),
      ],
    );
  }

  Widget _buildItemCard(RequestItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: rcWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rcColor4.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre y tag frágil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: rcColor6,
                  ),
                ),
              ),
              if (item.isFragile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rcColor5,
                    borderRadius: BorderRadius.circular(12),
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
            ],
          ),
          const SizedBox(height: 12),
          // Imagen y detalles
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen placeholder
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: rcColor7,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: rcColor8.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: item.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(item.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.tv,
                            size: 40,
                            color: rcColor8,
                          ),
                  ),
                  if (item.quantity > 1)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: rcColor2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'X${item.quantity}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: rcColor6,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Detalles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.height != null)
                      Text(
                        'Alto: ${item.height?.toStringAsFixed(1) ?? '-'} cm',
                        style: TextStyle(
                          fontSize: 12,
                          color: rcColor6.withOpacity(0.7),
                        ),
                      ),
                    if (item.width != null)
                      Text(
                        'Ancho: ${item.width?.toStringAsFixed(1) ?? '-'} cm',
                        style: TextStyle(
                          fontSize: 12,
                          color: rcColor6.withOpacity(0.7),
                        ),
                      ),
                    if (item.length != null)
                      Text(
                        'Largo: ${item.length?.toStringAsFixed(1) ?? '-'} cm',
                        style: TextStyle(
                          fontSize: 12,
                          color: rcColor6.withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Peso: ${item.weight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: rcColor6.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Peso Total: ${item.totalWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: rcColor6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Botón editar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showEditItemDialog(item, index),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: rcColor4.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: rcColor6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddItemDialog(),
        icon: const Icon(Icons.add, color: rcColor5),
        label: const Text(
          'Agregar artículo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: rcColor6,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: rcColor4.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rcWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: rcColor4.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rcColor6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RequestSummaryPage(
                      name: _nameController.text.isEmpty 
                          ? 'Sin Nombre' 
                          : _nameController.text,
                      originDept: _originDeptController.text,
                      originProv: _originProvController.text,
                      originDist: _originDistController.text,
                      destDept: _destDeptController.text,
                      destProv: _destProvController.text,
                      destDist: _destDistController.text,
                      date: _dateController.text,
                      cashOnDelivery: _cashOnDelivery,
                      items: _items,
                    ),
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
                child: const Center(
                  child: Text(
                    'Siguiente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: rcWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onSave: (item) {
          _addItem(item);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditItemDialog(RequestItem item, int index) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        item: item,
        onSave: (editedItem) {
          _editItem(index, editedItem);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

