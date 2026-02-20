import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class TaskTitleField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final bool autoFocus;

  const TaskTitleField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.validator,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autoFocus,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: 'What needs to be done?',

        hintStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textInputAction: TextInputAction.next,
    );
  }
}
