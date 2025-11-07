import 'package:flutter/material.dart';
import '../theme.dart';

/// Dropdown personalizado de Red Carga
class RcDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final List<String> options;
  final IconData? leadingIcon;

  const RcDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.options,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: leadingIcon != null
            ? Icon(leadingIcon, color: RcColors.rcColor6)
            : null,
        filled: true,
        fillColor: RcColors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RcColors.rcColor2.withOpacity(0.3),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RcColors.rcColor2.withOpacity(0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RcColors.rcColor2.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

