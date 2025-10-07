import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';

class NumberInputField extends StatelessWidget {
  const NumberInputField({
    super.key,
    required this.label,
    required this.suffix,
  });

  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGray, fontSize: 12),
        suffix: Text(
          suffix,
          style: const TextStyle(
            color: AppColors.textBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Please enter $label" : null,
    );
  }
}
