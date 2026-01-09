import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



typedef Validator = String? Function(String? value);

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final Validator? validator;
  final String label;
  final String hint;

  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
    required this.label,
    required this.hint
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
