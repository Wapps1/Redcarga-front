import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

/// Campo de fecha personalizado de Red Carga
class RcDatePickerField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final IconData? leadingIcon;

  const RcDatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.leadingIcon,
  });

  @override
  State<RcDatePickerField> createState() => _RcDatePickerFieldState();
}

class _RcDatePickerFieldState extends State<RcDatePickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(RcDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (widget.value.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(widget.value);
      } catch (e) {
        // Si hay error al parsear, usar la fecha actual
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      widget.onChanged(DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.leadingIcon != null
            ? Icon(widget.leadingIcon, color: rcColor6)
            : null,
        suffixIcon: const Icon(Icons.calendar_today, color: rcColor6),
        filled: true,
        fillColor: rcWhite.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: rcColor2.withOpacity(0.3),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: rcColor2.withOpacity(0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: rcColor2.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
    );
  }
}

