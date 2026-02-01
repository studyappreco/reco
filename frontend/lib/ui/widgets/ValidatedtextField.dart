import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/PasswordField.dart';

class ValidatedTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final bool autofocus;
  final Validator? validator;
  final String? labelText;
  final TextEditingController controller;

  const ValidatedTextField({
    super.key,
    this.focusNode,
    this.autofocus = false,
    this.validator,
    this.labelText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      autofocus: autofocus,
      validator: validator,
      decoration: InputDecoration(labelText: labelText),
      controller: controller,
    );
  }
}
