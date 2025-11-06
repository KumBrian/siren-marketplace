import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    super.key,
    required this.label,
    this.role = Role.fisher,
    this.value,
    required this.suffix,
    required this.controller,
    this.onChanged,
    this.validator,
    this.isReadOnly = false,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final Role role;
  final String? value;
  final String suffix;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool isReadOnly;
  final String? Function(dynamic value)? validator;
  final TextInputType keyboardType;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  @override
  void initState() {
    super.initState();

    // --- NEW LOGIC: Initialize the read-only 'Weight' field ---
    if (widget.label == "Name" && widget.value != null) {
      // Defer setting text to ensure controller is safely attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final newText = widget.value!;
        if (widget.controller.text.isEmpty ||
            widget.controller.text != newText) {
          widget.controller.text = newText;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.isReadOnly;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      onChanged: isReadOnly ? null : widget.onChanged,
      readOnly: isReadOnly,
      style: TextStyle(
        color: isReadOnly
            ? AppColors.textBlue.withValues(alpha: .7)
            : AppColors.textBlue,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffix: Text(
          widget.suffix,
          style: TextStyle(
            color: AppColors.textBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Only validate if it's an input field and requires a positive number
      validator: widget.validator,
    );
  }
}
