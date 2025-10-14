import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class NumberInputField extends StatefulWidget {
  const NumberInputField({
    super.key,
    required this.label,
    this.value,
    required this.suffix,
    required this.controller,
    this.onChanged,
    this.validator,
  });

  final String label;
  final double? value;
  final String suffix;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? Function(dynamic value)? validator;

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  @override
  void didUpdateWidget(covariant NumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // This logic ensures the controller is updated only when the external
    // calculated value (widget.value) changes.
    if (widget.label == "Price/Kg") {
      final newValue = widget.value;

      // Check if the calculated value is different from the old value.
      if (newValue != oldWidget.value) {
        // *** CRITICAL FIX: Defer the controller update to the next frame ***
        // This avoids triggering Form rebuild notifications during the current update cycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return; // Safety check if the widget was disposed

          if (newValue != null && newValue > 0.0) {
            final newText = newValue.toStringAsFixed(2);
            // Only update if the text is genuinely different
            if (widget.controller.text != newText) {
              widget.controller.text = newText;
            }
          } else {
            // Clear text if the calculated value is zero or null
            widget.controller.text = '';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the field should be read-only (i.e., the calculated Price/Kg field)
    final isReadOnly = widget.label == "Price/Kg";

    return TextFormField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),

      // Only attach onChanged for the input fields ("Weight" and "Total")
      onChanged: isReadOnly ? null : widget.onChanged,
      readOnly: isReadOnly,

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.textGray, fontSize: 12),
        suffix: Text(
          widget.suffix,
          style: const TextStyle(
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
