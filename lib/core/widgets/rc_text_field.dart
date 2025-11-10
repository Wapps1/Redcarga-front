import 'package:flutter/material.dart';
import '../theme.dart';

/// Campo de texto personalizado de Red Carga
class RcTextField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final IconData? leadingIcon;
  final bool isPassword;
  final bool isError;
  final String? errorMessage;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;

  const RcTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.leadingIcon,
    this.isPassword = false,
    this.isError = false,
    this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<RcTextField> createState() => _RcTextFieldState();
}

class _RcTextFieldState extends State<RcTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          enabled: widget.enabled,
          controller: TextEditingController(text: widget.value)
            ..selection = TextSelection.collapsed(offset: widget.value.length),
          onChanged: widget.onChanged,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: widget.leadingIcon != null
                ? Icon(widget.leadingIcon, color: rcColor6)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: rcColor6,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: rcWhite.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isError
                    ? Colors.red
                    : rcColor2.withOpacity(0.3),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isError
                    ? Colors.red
                    : rcColor2.withOpacity(0.3),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isError
                    ? Colors.red
                    : rcColor2.withOpacity(0.3),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: rcColor2.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
        ),
        if (widget.isError && widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}


