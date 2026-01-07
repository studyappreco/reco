import 'package:frontend/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/SpecifyDegreePage.dart';



class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({super.key});

  @override
  CreateAccountFormState createState() {
    return CreateAccountFormState();
  }
}

class CreateAccountFormState extends State<CreateAccountForm> {

  final _formKey = GlobalKey<FormState>();
  late FocusNode formFocusNode;

  final nameController = TextEditingController();
  final  emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordControllerRepeat = TextEditingController();

  @override
  void initState() {
    super.initState();
    formFocusNode = FocusNode();
  }

  @override
  void dispose() {
    formFocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordControllerRepeat.dispose();
    super.dispose();
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    if (value.length < 5) {
      return "Name must exceed 5 characters";
    }

    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email address";
    }
    if (!value.endsWith("gmail.com")) {
      return "Email address is not valid";
    }
    return null;
  }

  String? passwordValidator(String? value) {
    print("validating");
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }
    if (value.length < 5) {
      return "Password must at least have 8 characters";
    }
    return null;
  }

  String? passwordValidatorRepeat(String? value) {
    if (value == null || value.isEmpty) {
      return "Repeat Password cannot be empty";
    }
    if (passwordController.text != value) {
      return "Passwords do not match";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.standardWhitebackground,
      appBar: AppBar(title: const Text("Create your account")),
      body:

      Form(
        key: _formKey,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 350,
                child: ValidatedTextField(focusNode: null,
                    validator: nameValidator,
                    labelText: "User Name", controller: nameController),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 350,
                child: ValidatedTextField(focusNode: null,
                    validator: emailValidator,
                    labelText: "example@gmail.com", controller: emailController),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 350,
                child: PasswordField(controller: passwordController, label: "Password", hint: "Enter your password")),
              const SizedBox(height: 16),
              SizedBox(
                width: 350,
                child: PasswordField(controller: passwordControllerRepeat, label: "Repeat password", hint: "Repeat your password", validator: passwordValidatorRepeat)),
            ],
          ),
        )
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.buttonText,
            disabledBackgroundColor: AppColors.primaryBlueLight,
            disabledForegroundColor: AppColors.buttonText,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecifyDegreePage(),
                ),
              );
            }
          },
          child: const Text("Continue"),
        ),
      ),
    );
  }
}

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


class DropdownMenuDegree extends StatefulWidget {
  const DropdownMenuDegree({
    super.key,
    required this.selectives,
    required this.menuLabel,
    required this.initialSelection,
  });

  final String initialSelection;
  final String menuLabel;
  final List<DropdownMenuEntry<String>> selectives;

  @override
  State<DropdownMenuDegree> createState() => _DropdownMenuDegreeState();
}

class _DropdownMenuDegreeState extends State<DropdownMenuDegree> {
    String? selected;

    @override
  Widget build(BuildContext context) {
      final initialSelection = widget.initialSelection;
      final entries = widget.selectives;
      final label = widget.menuLabel;

    return DropdownMenu<String>(
      width: 350,
      initialSelection: initialSelection,
      requestFocusOnTap: true,
      label: Text(label),
      onSelected: (String? degreeType) {
        setState(() {
          selected = degreeType;
        });
      },
      dropdownMenuEntries: entries ,
    );
  }
}

typedef Validator = String? Function(String? value);

class ValidatedTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final bool autofocus;
  final Validator? validator;
  final String? labelText;
  final TextEditingController controller;

  const ValidatedTextField({
    Key? key,
    this.focusNode,
    this.autofocus = false,
    this.validator,
    this.labelText,
    required this.controller,
  }) : super(key: key);

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



